-- A universal provider's copies of a carrier's scans stored on a clock an earlier release misread
-- stayed beside the carrier's rows once the carrier answered itself (a Shiprocket parcel showed
-- each scan three times: 17TRACK read India's wall clock as US Eastern, and ParcelsApp dated each
-- scan at midnight). The sync now deletes a copy a zone away (`sharedScans`, eventIdentity.ts), and
-- the scraper keeps the days of a network a provider dates only by the day. This removes the copies
-- already stored, from universal rows that name their provider, with no observation:
-- - by the sync's rule, a copy with the one carrier row a zone away. That is the carrier row of the
--   same scan (the same wording apart from case and spacing and not empty, the same place, the
--   same provider code when both carry one, stages that agree) a whole number of hours away up to
--   14 h, compared to the carrier's minute when the copy is in whole minutes and to its second
--   otherwise. Or, when two or more of the provider's copies of the parcel show one shift in whole
--   quarter hours up to 14 h from such rows and no other shift as many, the carrier row at the
--   same place, with provider codes that agree, at that shift, compared to the minute when either
--   is in whole minutes;
-- - a row of a provider whose rows of the parcel, three or more over two days or more, are all at
--   midnight UTC, with the one carrier row of the same scan whose own date is that day.
-- A row at the copy's minute and place that names no provider, or a second copy of the carrier row
-- from the provider, keeps the copy. The carrier row stays and takes the copy's receipts. Each
-- removed row is kept, with its receipts as they were, in private.misread_clock_provider_copies.
create table if not exists private.misread_clock_provider_copies (
  like public.tracking_events,
  kept_event_id uuid not null,
  receipts jsonb not null,
  removed_at timestamptz not null default now()
);
alter table private.misread_clock_provider_copies enable row level security;
revoke all on private.misread_clock_provider_copies from public, anon, authenticated;
comment on table private.misread_clock_provider_copies is
  'Universal copies of a carrier''s scans stored on a provider clock an earlier release misread, with the carrier row kept and the removed row''s receipts.';

do $$
declare
  receipt record;
begin
  lock table public.tracking_events in share row exclusive mode;

  create temporary table misread_copies as
  with rows as materialized (
    select id, package_id, coalesce(stage, '') as stage, occurred_at,
      date_trunc('minute', occurred_at) = occurred_at as whole_minute,
      provider_event_id like 'unknown:%' as universal,
      case when provider_event_id like 'unknown:%' and jsonb_typeof(raw_data->'universal_provider') = 'string'
        then raw_data->>'universal_provider' else '' end as provider,
      coalesce(raw_data->>'provider_code', '') as code,
      coalesce(raw_data->>'time', '') as time,
      btrim(lower(regexp_replace(coalesce(description, ''), '[[:space:]]+', ' ', 'g'))) as wording,
      btrim(lower(regexp_replace(coalesce(location, ''), '[[:space:]]+', ' ', 'g'))) as place
    from public.tracking_events
    where provider_event_id ~ '^[^:]+:' and provider_event_id not like 'app:%'
      and raw_data->'observed_without_provider_timestamp' is distinct from 'true'::jsonb
  ), pairs as materialized (
    -- Each copy with each carrier row of its parcel at its place.
    select copy.id as copy_id, copy.package_id, copy.provider, copy.occurred_at as copy_at,
      carrier.id as carrier_id, carrier.occurred_at as carrier_at, carrier.time as carrier_time,
      copy.wording <> '' and carrier.wording = copy.wording
        and (carrier.stage = copy.stage or carrier.stage in ('', 'pending') or copy.stage in ('', 'pending')) as same_scan,
      extract(epoch from date_trunc(clock.unit, copy.occurred_at) - date_trunc(clock.unit, carrier.occurred_at)) as shift,
      extract(epoch from copy.occurred_at - date_trunc(case when copy.whole_minute then 'minute' else 'second' end,
        carrier.occurred_at)) as hours
    from rows copy
    join rows carrier on carrier.package_id = copy.package_id and not carrier.universal and carrier.place = copy.place
      and (carrier.code = '' or copy.code = '' or carrier.code = copy.code)
    cross join lateral (
      select case when copy.whole_minute or carrier.whole_minute then 'minute' else 'second' end as unit
    ) clock
    where copy.provider <> ''
  ), shown as (
    select package_id, provider, shift, count(distinct copy_id) as copies from pairs
    where same_scan and shift <> 0 and mod(shift, 900) = 0 and abs(shift) <= 14 * 3600
    group by 1, 2, 3
  ), ranked as (
    select *, rank() over (partition by package_id, provider order by copies desc) as ranking,
      count(*) over (partition by package_id, provider, copies) as tied
    from shown
  ), clocks as (
    select package_id, provider, shift from ranked where ranking = 1 and copies >= 2 and tied = 1
  ), zoned as (
    select pairs.copy_id, pairs.provider, pairs.carrier_id from pairs
    left join clocks on clocks.package_id = pairs.package_id and clocks.provider = pairs.provider
    where case when clocks.shift is null
      then pairs.same_scan and pairs.hours <> 0 and mod(pairs.hours, 3600) = 0 and abs(pairs.hours) <= 14 * 3600
      else pairs.shift = clocks.shift end
  ), midnight as (
    select package_id, provider from rows where provider <> ''
    group by 1, 2
    having bool_and(occurred_at = date_trunc('day', occurred_at, 'UTC')) and count(*) >= 3
      and count(distinct date_trunc('day', occurred_at, 'UTC')) >= 2
  ), dated as (
    select pairs.copy_id, pairs.provider, pairs.carrier_id from pairs
    join midnight on midnight.package_id = pairs.package_id and midnight.provider = pairs.provider
    where pairs.same_scan and pairs.carrier_at <> pairs.copy_at and pairs.carrier_time ~ '^\d{4}-\d{2}-\d{2}T'
      and left(pairs.carrier_time, 10) = to_char(pairs.copy_at at time zone 'UTC', 'YYYY-MM-DD')
  ), single as (
    select copy_id, min(provider) as provider, min(carrier_id::text)::uuid as carrier_id
    from (select * from zoned union select * from dated) found
    group by copy_id having count(distinct carrier_id) = 1
  ), stale as (
    select single.* from single join rows copy on copy.id = single.copy_id
    where not exists (select 1 from rows held where held.package_id = copy.package_id and held.provider = ''
      and held.place = copy.place and date_trunc('minute', held.occurred_at) = date_trunc('minute', copy.occurred_at))
  )
  select copy_id, carrier_id as kept_id from stale
  where (select count(*) from stale other where other.carrier_id = stale.carrier_id and other.provider = stale.provider) = 1;

  insert into private.misread_clock_provider_copies
  select event.*, scan.kept_id, jsonb_build_object(
    'push_deliveries', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from public.push_deliveries r where r.event_id = event.id),
    'native_push_deliveries', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from public.native_push_deliveries r where r.event_id = event.id),
    'parcel_link_alert_deliveries', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from public.parcel_link_alert_deliveries r where r.event_id = event.id),
    'live_activity_event_deliveries', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from public.live_activity_event_deliveries r where r.event_id = event.id),
    'delivery_emails', (select coalesce(jsonb_agg(r.id), '[]') from public.delivery_emails r where r.event_id = event.id),
    'tracking_status_observations', (select coalesce(jsonb_agg(r.observation_key), '[]') from public.tracking_status_observations r where r.sample_event_id = event.id)
  ), now()
  from public.tracking_events event join misread_copies scan on scan.copy_id = event.id;

  for receipt in select * from (values
    ('push_deliveries', 'subscription_id'), ('native_push_deliveries', 'device_id'),
    ('parcel_link_alert_deliveries', 'alert_id')
  ) as receipts(table_name, owner_column) loop
    execute format(
      'insert into public.%I as kept (%I, event_id, sent_at)
       select r.%I, scan.kept_id, min(r.sent_at)
       from public.%I r join misread_copies scan on scan.copy_id = r.event_id
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
  join misread_copies scan on scan.copy_id = r.event_id
  join public.tracking_events event on event.id = scan.kept_id
  order by r.device_id, scan.kept_id, r.sent_at
  on conflict (device_id, event_id) do update set sent_at = least(kept.sent_at, excluded.sent_at);

  update public.tracking_status_observations observation set sample_event_id = scan.kept_id
  from misread_copies scan where observation.sample_event_id = scan.copy_id;
  -- Two providers' copies can share the kept row, which holds one email at most.
  update public.delivery_emails email set event_id = moved.kept_id
  from (
    select distinct on (scan.kept_id) scan.kept_id, told.id
    from misread_copies scan join public.delivery_emails told on told.event_id = scan.copy_id
    order by scan.kept_id, told.claimed_at
  ) moved
  where email.id = moved.id
    and not exists (select 1 from public.delivery_emails told where told.event_id = moved.kept_id);

  delete from public.tracking_events event using misread_copies scan where event.id = scan.copy_id;

  drop table misread_copies;
end;
$$;

insert into public.applied_migrations (name) values ('20261020213000_misread_clock_provider_copies') on conflict do nothing;
