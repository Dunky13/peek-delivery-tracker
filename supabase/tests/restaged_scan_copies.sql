\set ON_ERROR_STOP on
begin;

insert into auth.users (id, email)
values ('94000000-0000-0000-0000-000000000001', 'restaged-scan-copies@example.invalid');
insert into public.packages (id, user_id, tracking_number, carrier, current_stage)
values ('94000000-0000-0000-0000-000000000002', '94000000-0000-0000-0000-000000000001', 'EXAMPLE0000000021', 'ups', 'out_for_delivery');

insert into public.tracking_events (package_id, provider_event_id, stage, description, location, occurred_at, raw_data)
select '94000000-0000-0000-0000-000000000002', provider_event_id, stage, description, location, occurred::timestamptz, raw::jsonb
from (values
  -- UPS's scans, and a provider's copies of them in another stage: the copies go.
  ('ups:out', 'out_for_delivery', 'Out For Delivery Today', 'EXAMPLE CITY EX', '2026-10-19T14:05:52Z', '{}'),
  ('unknown:exception', 'exception', 'Delivery change requested', 'Example City, EX, US', '2026-10-19T14:05:52Z', '{"universal_provider":"17TRACK"}'),
  ('ups:attempt', 'failed_attempt', 'Delivery attempt made', 'Example City', '2026-10-19T08:28:10Z', '{}'),
  ('unknown:no-place', 'exception', 'Delivery attempt failed', null, '2026-10-19T08:28:10Z', '{"universal_provider":"17TRACK"}'),
  -- Left alone: a copy in the carrier's stage, another instant, another place, a place that shares
  -- only its country, a row a carrier took over (it names no provider), and copies beside an
  -- observed stage change or the app's own row.
  ('unknown:same-stage', 'out_for_delivery', 'Out for delivery', 'Example City', '2026-10-19T14:05:52Z', '{"universal_provider":"17TRACK"}'),
  ('unknown:later', 'exception', 'Delivery change requested', 'Example City', '2026-10-19T14:06:22Z', '{"universal_provider":"17TRACK"}'),
  ('unknown:elsewhere', 'exception', 'Held at facility', 'Othertown', '2026-10-19T14:05:52Z', '{"universal_provider":"17TRACK"}'),
  ('ups:departed', 'in_transit', 'Departed from facility', 'Hub Town, Germany', '2026-10-17T10:15:00Z', '{}'),
  ('unknown:country', 'accepted', 'Shipment received', 'Othertown, Germany', '2026-10-17T10:15:00Z', '{"universal_provider":"Ship24"}'),
  ('unknown:taken', 'in_transit', 'Arrived at facility', 'Example City', '2026-10-19T14:05:52Z', '{}'),
  ('ups:observed', 'delivered', 'Delivered', null, '2026-10-18T09:00:00Z', '{"observed_without_provider_timestamp":true}'),
  ('unknown:beside-observed', 'exception', 'Delivery exception', null, '2026-10-18T09:00:00Z', '{"universal_provider":"17TRACK"}'),
  ('app:added', 'pending', 'Tracking added', null, '2026-10-16T09:00:00Z', '{}'),
  ('unknown:beside-app', 'registered', 'Label created', null, '2026-10-16T09:00:00Z', '{"universal_provider":"17TRACK"}')
) as rows(provider_event_id, stage, description, location, occurred, raw);

\ir ../migrations/20261019230000_restaged_scan_copies.sql
-- A second run changes nothing.
\ir ../migrations/20261019230000_restaged_scan_copies.sql

do $$
begin
  if (select array_agg(provider_event_id order by provider_event_id) from public.tracking_events
      where package_id = '94000000-0000-0000-0000-000000000002' and provider_event_id not like 'app:%')
      is distinct from array['unknown:beside-app', 'unknown:beside-observed', 'unknown:country', 'unknown:elsewhere',
        'unknown:later', 'unknown:same-stage', 'unknown:taken', 'ups:attempt', 'ups:departed', 'ups:observed', 'ups:out'] then
    raise exception 'Restaged copy cleanup removed other rows than the copies in another stage: %', (
      select array_agg(provider_event_id order by provider_event_id) from public.tracking_events
      where package_id = '94000000-0000-0000-0000-000000000002' and provider_event_id not like 'app:%');
  end if;
end;
$$;
rollback;
