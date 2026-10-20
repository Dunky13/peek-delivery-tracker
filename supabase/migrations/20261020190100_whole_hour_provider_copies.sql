-- A universal provider's copy of a carrier's scan read on the wrong clock by an earlier release
-- stayed beside the carrier's own row a whole number of hours away (a copy of UPS's customs scan,
-- kept to the minute, 11 h late). The sync now deletes such a copy and leaves out the provider's
-- later copies (`sharedScans`, eventIdentity.ts); this removes the copies already stored, by the
-- same rule: a universal row of a parcel that names its provider, no observation, and the one
-- carrier row a whole number of hours away up to 14 h, compared to the carrier's minute when the
-- copy is in whole minutes and to its second otherwise, with the same wording apart from case and
-- spacing and not empty, the same place, the same provider code when both carry one and stages
-- that agree (the same, or one pending or unclassified). A row of the same scan at the copy's own
-- minute, from the carrier or from an earlier release that named no provider, or a second copy of
-- the carrier row, keeps the copy. The carrier row stays and takes the copy's receipts.
-- Each removed row is kept, with its receipts as they were, in private.whole_hour_provider_copies.
create table if not exists private.whole_hour_provider_copies (
  like public.tracking_events,
  kept_event_id uuid not null,
  receipts jsonb not null,
  removed_at timestamptz not null default now()
);
alter table private.whole_hour_provider_copies enable row level security;
revoke all on private.whole_hour_provider_copies from public, anon, authenticated;
comment on table private.whole_hour_provider_copies is
  'Universal copies of a carrier''s scan stored a whole number of hours from the carrier''s row, with the carrier row kept and the removed row''s receipts.';

do $$
declare
  receipt record;
begin
  lock table public.tracking_events in share row exclusive mode;

  create temporary table whole_hour_copies as
  with rows as materialized (
    select id, package_id, coalesce(stage, '') as stage, occurred_at,
      provider_event_id like 'unknown:%' as universal,
      provider_event_id like 'unknown:%' and coalesce(jsonb_typeof(raw_data->'universal_provider') = 'string', false) as named,
      coalesce(raw_data->>'provider_code', '') as code,
      btrim(lower(regexp_replace(coalesce(description, ''), '[[:space:]]+', ' ', 'g'))) as wording,
      btrim(lower(regexp_replace(coalesce(location, ''), '[[:space:]]+', ' ', 'g'))) as place
    from public.tracking_events
    where provider_event_id ~ '^[^:]+:' and provider_event_id not like 'app:%'
      and raw_data->'observed_without_provider_timestamp' is distinct from 'true'::jsonb
      and btrim(coalesce(description, '')) <> ''
  ), scans as materialized (
    select copy.id as copy_id, copy.occurred_at as copy_at, carrier.id as carrier_id, carrier.occurred_at as carrier_at,
      carrier.universal as unnamed
    from rows copy
    join rows carrier on carrier.package_id = copy.package_id and not carrier.named
      and carrier.wording = copy.wording and carrier.place = copy.place
      and (carrier.code = '' or copy.code = '' or carrier.code = copy.code)
      and (carrier.stage = copy.stage or carrier.stage in ('', 'pending') or copy.stage in ('', 'pending'))
    where copy.named
  ), apart as materialized (
    select scans.* from scans
    cross join lateral (
      select extract(epoch from copy_at - date_trunc(case when date_trunc('minute', copy_at) = copy_at then 'minute' else 'second' end,
        carrier_at)) as shift
    ) clock
    where not scans.unnamed and clock.shift <> 0 and mod(clock.shift, 3600) = 0 and abs(clock.shift) <= 14 * 3600
  ), single as (
    select copy_id, min(carrier_id::text)::uuid as carrier_id from apart
    group by copy_id having count(distinct carrier_id) = 1
  ), stale as (
    select * from single
    where not exists (select 1 from scans same where same.copy_id = single.copy_id
      and date_trunc('minute', same.carrier_at) = date_trunc('minute', same.copy_at))
  )
  select copy_id, carrier_id as kept_id from stale
  where (select count(*) from stale other where other.carrier_id = stale.carrier_id) = 1;

  insert into private.whole_hour_provider_copies
  select event.*, scan.kept_id, jsonb_build_object(
    'push_deliveries', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from public.push_deliveries r where r.event_id = event.id),
    'native_push_deliveries', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from public.native_push_deliveries r where r.event_id = event.id),
    'parcel_link_alert_deliveries', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from public.parcel_link_alert_deliveries r where r.event_id = event.id),
    'live_activity_event_deliveries', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from public.live_activity_event_deliveries r where r.event_id = event.id),
    'delivery_emails', (select coalesce(jsonb_agg(r.id), '[]') from public.delivery_emails r where r.event_id = event.id),
    'tracking_status_observations', (select coalesce(jsonb_agg(r.observation_key), '[]') from public.tracking_status_observations r where r.sample_event_id = event.id)
  ), now()
  from public.tracking_events event join whole_hour_copies scan on scan.copy_id = event.id;

  for receipt in select * from (values
    ('push_deliveries', 'subscription_id'), ('native_push_deliveries', 'device_id'),
    ('parcel_link_alert_deliveries', 'alert_id')
  ) as receipts(table_name, owner_column) loop
    execute format(
      'insert into public.%I as kept (%I, event_id, sent_at)
       select r.%I, scan.kept_id, min(r.sent_at)
       from public.%I r join whole_hour_copies scan on scan.copy_id = r.event_id
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
  join whole_hour_copies scan on scan.copy_id = r.event_id
  join public.tracking_events event on event.id = scan.kept_id
  order by r.device_id, scan.kept_id, r.sent_at
  on conflict (device_id, event_id) do update set sent_at = least(kept.sent_at, excluded.sent_at);

  update public.tracking_status_observations observation set sample_event_id = scan.kept_id
  from whole_hour_copies scan where observation.sample_event_id = scan.copy_id;
  update public.delivery_emails email set event_id = scan.kept_id
  from whole_hour_copies scan where email.event_id = scan.copy_id
    and not exists (select 1 from public.delivery_emails told where told.event_id = scan.kept_id);

  delete from public.tracking_events event using whole_hour_copies scan where event.id = scan.copy_id;

  drop table whole_hour_copies;
end;
$$;

insert into public.applied_migrations (name) values ('20261020190100_whole_hour_provider_copies') on conflict do nothing;
