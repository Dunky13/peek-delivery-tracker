-- DHL Express's mobile API reads a record's wall clock on the facility's zone, and its global
-- portal labels it with the offset of the system that wrote the record, so a record one feed
-- stored came back from the other as a second row an hour or more away. The sync now lets such a
-- record take over the row the other feed stored (`matchWallClock`, eventIdentity.ts); this
-- removes the second rows already stored, by the same rule: two DHL Express rows of a parcel, no
-- observation, showing the same date and time, to the second, under different offsets, with the
-- same trimmed location, the same wording apart from case and spacing and not empty, and the same
-- provider code when both carry one, each matching no other row. The row stored first stays and
-- takes the other's receipts. Each removed row is kept, with its receipts as they were, in
-- private.dhl_express_wall_clock_copies.
create table if not exists private.dhl_express_wall_clock_copies (
  like public.tracking_events,
  kept_event_id uuid not null,
  receipts jsonb not null,
  removed_at timestamptz not null default now()
);
alter table private.dhl_express_wall_clock_copies enable row level security;
revoke all on private.dhl_express_wall_clock_copies from public, anon, authenticated;
comment on table private.dhl_express_wall_clock_copies is
  'DHL Express rows removed as another feed''s copy of a stored record, with the stored row kept and the removed row''s receipts.';

do $$
declare
  receipt record;
begin
  lock table public.tracking_events in share row exclusive mode;

  create temporary table wall_clock_copies as
  with scans as materialized (
    select id, package_id, created_at,
      left(raw_data->>'time', 19) as wall_clock,
      case when raw_data->>'time' like '%Z' then 0
        else (case when substring(raw_data->>'time' from '([+-])[0-9]{2}:?[0-9]{2}$') = '-' then -1 else 1 end)
          * (substring(raw_data->>'time' from '[+-]([0-9]{2}):?[0-9]{2}$')::integer * 60
            + substring(raw_data->>'time' from '[+-][0-9]{2}:?([0-9]{2})$')::integer)
      end as offset_minutes,
      coalesce(raw_data->>'provider_code', '') as code,
      btrim(lower(regexp_replace(description, '[[:space:]]+', ' ', 'g'))) as wording,
      btrim(coalesce(location, '')) as place
    from public.tracking_events
    where provider_event_id like 'dhl-express:%'
      and raw_data->'observed_without_provider_timestamp' is distinct from 'true'::jsonb
      and raw_data->>'time' ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?(Z|[+-][0-9]{2}:?[0-9]{2})$'
  ), pairs as materialized (
    select one.id as one_id, one.created_at as one_at, other.id as other_id, other.created_at as other_at
    from scans one
    join scans other on other.package_id = one.package_id and other.id <> one.id
      and other.wall_clock = one.wall_clock and other.offset_minutes <> one.offset_minutes
      and (one.code = '' or other.code = '' or other.code = one.code)
      and one.wording <> '' and other.wording = one.wording and other.place = one.place
  ), single as (
    select one_id from pairs group by one_id having count(*) = 1
  )
  select pairs.one_id as kept_id, pairs.other_id as copy_id
  from pairs
  join single kept on kept.one_id = pairs.one_id
  join single copy on copy.one_id = pairs.other_id
  where (pairs.one_at, pairs.one_id) < (pairs.other_at, pairs.other_id);

  insert into private.dhl_express_wall_clock_copies
  select event.*, scan.kept_id, jsonb_build_object(
    'push_deliveries', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from public.push_deliveries r where r.event_id = event.id),
    'native_push_deliveries', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from public.native_push_deliveries r where r.event_id = event.id),
    'parcel_link_alert_deliveries', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from public.parcel_link_alert_deliveries r where r.event_id = event.id),
    'live_activity_event_deliveries', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from public.live_activity_event_deliveries r where r.event_id = event.id),
    'delivery_emails', (select coalesce(jsonb_agg(r.id), '[]') from public.delivery_emails r where r.event_id = event.id),
    'tracking_status_observations', (select coalesce(jsonb_agg(r.observation_key), '[]') from public.tracking_status_observations r where r.sample_event_id = event.id)
  ), now()
  from public.tracking_events event join wall_clock_copies scan on scan.copy_id = event.id;

  for receipt in select * from (values
    ('push_deliveries', 'subscription_id'), ('native_push_deliveries', 'device_id'),
    ('parcel_link_alert_deliveries', 'alert_id')
  ) as receipts(table_name, owner_column) loop
    execute format(
      'insert into public.%I as kept (%I, event_id, sent_at)
       select r.%I, scan.kept_id, min(r.sent_at)
       from public.%I r join wall_clock_copies scan on scan.copy_id = r.event_id
       group by r.%I, scan.kept_id
       on conflict (%I, event_id) do update set sent_at = least(kept.sent_at, excluded.sent_at)',
      receipt.table_name, receipt.owner_column, receipt.owner_column,
      receipt.table_name, receipt.owner_column, receipt.owner_column
    );
  end loop;

  insert into public.live_activity_event_deliveries as kept (
    device_id, event_id, package_id, delivery_kind, event_created_at, sent_at
  )
  select distinct on (r.device_id, scan.kept_id)
    r.device_id, scan.kept_id, r.package_id, r.delivery_kind, event.created_at, r.sent_at
  from public.live_activity_event_deliveries r
  join wall_clock_copies scan on scan.copy_id = r.event_id
  join public.tracking_events event on event.id = scan.kept_id
  order by r.device_id, scan.kept_id, r.sent_at
  on conflict (device_id, event_id) do update set sent_at = least(kept.sent_at, excluded.sent_at);

  update public.tracking_status_observations observation set sample_event_id = scan.kept_id
  from wall_clock_copies scan where observation.sample_event_id = scan.copy_id;
  update public.delivery_emails email set event_id = scan.kept_id
  from wall_clock_copies scan where email.event_id = scan.copy_id
    and not exists (select 1 from public.delivery_emails told where told.event_id = scan.kept_id);

  delete from public.tracking_events event using wall_clock_copies scan where event.id = scan.copy_id;

  drop table wall_clock_copies;
end;
$$;

insert into public.applied_migrations (name) values ('20261020164500_dhl_express_wall_clock_copies') on conflict do nothing;
