-- A stage change the sync saw without a scan time is stored at the time it saw it. When a source
-- later dated that scan (DPD UK's scans on London's clock), the dated row was stored beside it.
-- The sync now lets the dated scan take the sighting over, or deletes the sighting
-- (`datedObservations`, eventIdentity.ts); this removes the sightings already stored, by the same
-- rule against every dated row stored: an observed row of a parcel and the one dated row with the
-- same stage, the same wording apart from case and spacing and not empty, the same provider code
-- when both carry one, the same place unless one names none, dated no later than the sighting
-- and, when the sighting kept the scan's wall clock (`local_time`), showing it whole quarter hours
-- away up to 14 h, or within that day for a day alone. The dated row stays and takes the
-- sighting's receipts. Each removed row is kept, with its receipts as they were, in
-- private.dated_stage_sightings.
create table if not exists private.dated_stage_sightings (
  like public.tracking_events,
  kept_event_id uuid not null,
  receipts jsonb not null,
  removed_at timestamptz not null default now()
);
alter table private.dated_stage_sightings enable row level security;
revoke all on private.dated_stage_sightings from public, anon, authenticated;
comment on table private.dated_stage_sightings is
  'Stage changes stored at the time the sync saw them, removed once a dated row of the same scan was stored, with the dated row kept and the removed row''s receipts.';

do $$
declare
  receipt record;
begin
  lock table public.tracking_events in share row exclusive mode;

  create temporary table dated_sightings as
  with rows as materialized (
    select id, package_id, coalesce(stage, '') as stage, occurred_at,
      coalesce(raw_data->'observed_without_provider_timestamp' = 'true'::jsonb, false) as observed,
      coalesce(raw_data->>'local_time', '') as local_time,
      coalesce(raw_data->>'provider_code', '') as code,
      btrim(lower(regexp_replace(coalesce(description, ''), '[[:space:]]+', ' ', 'g'))) as wording,
      btrim(lower(regexp_replace(coalesce(location, ''), '[[:space:]]+', ' ', 'g'))) as place
    from public.tracking_events
    where provider_event_id ~ '^[^:]+:' and provider_event_id not like 'app:%'
      and package_id in (
        select package_id from public.tracking_events
        where raw_data->'observed_without_provider_timestamp' = 'true'::jsonb
      )
  ), sightings as materialized (
    select *,
      case when local_time ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}[T ][0-9]{2}:[0-9]{2}(:[0-9]{2})?'
        then substring(local_time from '^[0-9]{4}-[0-9]{2}-[0-9]{2}[T ][0-9]{2}:[0-9]{2}(?::[0-9]{2})?')::timestamp end as wall,
      case when local_time ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' then local_time::date end as day
    from rows where observed and wording <> ''
  ), pairs as materialized (
    select sighting.id as sighting_id, scan.id as scan_id
    from sightings sighting
    join rows scan on scan.package_id = sighting.package_id and not scan.observed
      and scan.stage = sighting.stage and scan.wording = sighting.wording
      and (scan.code = '' or sighting.code = '' or scan.code = sighting.code)
      and (scan.place = sighting.place or scan.place = '' or sighting.place = '')
      and scan.occurred_at <= sighting.occurred_at
    cross join lateral (
      select extract(epoch from date_trunc(unit, sighting.wall) - date_trunc(unit, scan.occurred_at at time zone 'UTC')) as shift
      from (select case when date_trunc('minute', sighting.wall) = sighting.wall
        or date_trunc('minute', scan.occurred_at) = scan.occurred_at then 'minute' else 'second' end as unit) units
    ) clock
    where (sighting.day is null or (scan.occurred_at >= sighting.day::timestamp at time zone 'UTC' - interval '14 hours'
        and scan.occurred_at < sighting.day::timestamp at time zone 'UTC' + interval '38 hours'))
      and (sighting.wall is null or (mod(clock.shift, 900) = 0 and abs(clock.shift) <= 14 * 3600))
  )
  select sighting_id as copy_id, min(scan_id::text)::uuid as kept_id
  from pairs group by sighting_id having count(distinct scan_id) = 1;

  insert into private.dated_stage_sightings
  select event.*, scan.kept_id, jsonb_build_object(
    'push_deliveries', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from public.push_deliveries r where r.event_id = event.id),
    'native_push_deliveries', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from public.native_push_deliveries r where r.event_id = event.id),
    'parcel_link_alert_deliveries', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from public.parcel_link_alert_deliveries r where r.event_id = event.id),
    'live_activity_event_deliveries', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from public.live_activity_event_deliveries r where r.event_id = event.id),
    'delivery_emails', (select coalesce(jsonb_agg(r.id), '[]') from public.delivery_emails r where r.event_id = event.id),
    'tracking_status_observations', (select coalesce(jsonb_agg(r.observation_key), '[]') from public.tracking_status_observations r where r.sample_event_id = event.id)
  ), now()
  from public.tracking_events event join dated_sightings scan on scan.copy_id = event.id;

  for receipt in select * from (values
    ('push_deliveries', 'subscription_id'), ('native_push_deliveries', 'device_id'),
    ('parcel_link_alert_deliveries', 'alert_id')
  ) as receipts(table_name, owner_column) loop
    execute format(
      'insert into public.%I as kept (%I, event_id, sent_at)
       select r.%I, scan.kept_id, min(r.sent_at)
       from public.%I r join dated_sightings scan on scan.copy_id = r.event_id
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
  join dated_sightings scan on scan.copy_id = r.event_id
  join public.tracking_events event on event.id = scan.kept_id
  order by r.device_id, scan.kept_id, r.sent_at
  on conflict (device_id, event_id) do update set sent_at = least(kept.sent_at, excluded.sent_at);

  update public.tracking_status_observations observation set sample_event_id = scan.kept_id
  from dated_sightings scan where observation.sample_event_id = scan.copy_id;
  update public.delivery_emails email set event_id = scan.kept_id
  from dated_sightings scan where email.event_id = scan.copy_id
    and not exists (select 1 from public.delivery_emails told where told.event_id = scan.kept_id);

  delete from public.tracking_events event using dated_sightings scan where event.id = scan.copy_id;

  drop table dated_sightings;
end;
$$;

insert into public.applied_migrations (name) values ('20261020190000_dated_stage_sightings') on conflict do nothing;
