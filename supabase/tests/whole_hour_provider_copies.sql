\set ON_ERROR_STOP on
begin;

insert into auth.users (id, email)
values ('97000000-0000-0000-0000-000000000001', 'whole-hour-provider-copies@example.invalid');
insert into public.packages (id, user_id, tracking_number, carrier, current_stage)
values ('97000000-0000-0000-0000-000000000002', '97000000-0000-0000-0000-000000000001', '1Z0000000000000000', 'ups', 'customs');

insert into public.tracking_events (id, package_id, provider_event_id, stage, description, location, occurred_at, created_at, raw_data)
select ('97000000-0000-0000-0000-' || lpad(id::text, 12, '0'))::uuid, '97000000-0000-0000-0000-000000000002',
  provider_event_id, stage, description, location, occurred::timestamptz, occurred::timestamptz, raw::jsonb
from (values
  -- The carrier's scan to the second, a provider's copy to the minute 11 h late: the copy goes.
  (10, 'ups:customs', 'customs', 'Clearing agency', 'EXAMPLE CITY, US', '2026-01-04T12:09:15Z', '{"provider_code":"XC"}'),
  (11, 'unknown:customs', 'customs', 'clearing  agency', 'EXAMPLE CITY, US', '2026-01-04T23:09:00Z', '{"universal_provider":"ParcelsApp"}'),
  -- To the second, three hours early, left pending.
  (12, 'ups:sorted', 'in_transit', 'Sorted', 'EXAMPLE HUB, US', '2026-01-05T10:00:05Z', '{}'),
  (13, 'unknown:sorted', 'pending', 'Sorted', 'EXAMPLE HUB, US', '2026-01-05T07:00:05Z', '{"universal_provider":"17TRACK"}'),
  -- Left alone: another place, seconds of its own, half an hour off, 15 h away, the carrier's
  -- own scan at the copy's minute, two copies of one row, another code, a copy that names no
  -- provider, an earlier release's row at the copy's minute, and one as the only row hours away.
  (20, 'ups:arrived', 'in_transit', 'Arrived', 'EXAMPLE HUB, US', '2026-01-06T10:00:15Z', '{}'),
  (21, 'unknown:arrived-place', 'in_transit', 'Arrived', 'OTHER HUB, US', '2026-01-06T12:00:00Z', '{"universal_provider":"ParcelsApp"}'),
  (22, 'unknown:arrived-second', 'in_transit', 'Arrived', 'EXAMPLE HUB, US', '2026-01-06T13:00:30Z', '{"universal_provider":"ParcelsApp"}'),
  (23, 'unknown:arrived-half', 'in_transit', 'Arrived', 'EXAMPLE HUB, US', '2026-01-06T13:30:00Z', '{"universal_provider":"ParcelsApp"}'),
  (24, 'unknown:arrived-far', 'in_transit', 'Arrived', 'EXAMPLE HUB, US', '2026-01-07T01:00:00Z', '{"universal_provider":"ParcelsApp"}'),
  (30, 'ups:departed', 'in_transit', 'Departed', 'EXAMPLE HUB, US', '2026-01-06T08:00:15Z', '{}'),
  (31, 'ups:departed-again', 'in_transit', 'Departed', 'EXAMPLE HUB, US', '2026-01-06T11:00:40Z', '{}'),
  (32, 'unknown:departed', 'in_transit', 'Departed', 'EXAMPLE HUB, US', '2026-01-06T11:00:00Z', '{"universal_provider":"ParcelsApp"}'),
  (40, 'ups:loaded', 'in_transit', 'Loaded', 'EXAMPLE HUB, US', '2026-01-06T06:00:15Z', '{}'),
  (41, 'unknown:loaded', 'in_transit', 'Loaded', 'EXAMPLE HUB, US', '2026-01-06T08:00:00Z', '{"universal_provider":"ParcelsApp"}'),
  (42, 'unknown:loaded-again', 'in_transit', 'Loaded', 'EXAMPLE HUB, US', '2026-01-06T09:00:00Z', '{"universal_provider":"ParcelsApp"}'),
  (50, 'ups:coded', 'customs', 'Held', 'EXAMPLE CITY, US', '2026-01-06T04:00:15Z', '{"provider_code":"A"}'),
  (51, 'unknown:coded', 'customs', 'Held', 'EXAMPLE CITY, US', '2026-01-06T06:00:00Z', '{"provider_code":"B","universal_provider":"ParcelsApp"}'),
  (60, 'ups:scanned', 'in_transit', 'Scanned', 'EXAMPLE HUB, US', '2026-01-07T04:00:15Z', '{}'),
  (61, 'unknown:scanned', 'in_transit', 'Scanned', 'EXAMPLE HUB, US', '2026-01-07T06:00:00Z', '{}'),
  (70, 'ups:weighed', 'in_transit', 'Weighed', 'EXAMPLE HUB, US', '2026-01-07T08:00:15Z', '{}'),
  (71, 'unknown:weighed-legacy', 'in_transit', 'Weighed', 'EXAMPLE HUB, US', '2026-01-07T10:00:20Z', '{}'),
  (72, 'unknown:weighed', 'in_transit', 'Weighed', 'EXAMPLE HUB, US', '2026-01-07T10:00:00Z', '{"universal_provider":"ParcelsApp"}'),
  (80, 'unknown:measured-legacy', 'in_transit', 'Measured', 'EXAMPLE HUB, US', '2026-01-07T12:00:15Z', '{}'),
  (81, 'unknown:measured', 'in_transit', 'Measured', 'EXAMPLE HUB, US', '2026-01-07T14:00:00Z', '{"universal_provider":"ParcelsApp"}')
) as rows(id, provider_event_id, stage, description, location, occurred, raw);

insert into public.push_subscriptions (id, user_id, endpoint, p256dh, auth, subscribed_at)
values ('97000000-0000-0000-0000-000000000003', '97000000-0000-0000-0000-000000000001',
  'https://fcm.googleapis.com/fcm/send/synthetic-whole-hour-copies-fixture', 'test', 'test', '2000-01-01');
insert into public.push_deliveries (subscription_id, event_id, sent_at) values
  ('97000000-0000-0000-0000-000000000003', '97000000-0000-0000-0000-000000000011', '2026-01-05T00:00Z');

\ir ../migrations/20261020190100_whole_hour_provider_copies.sql
-- A second run changes nothing.
\ir ../migrations/20261020190100_whole_hour_provider_copies.sql

do $$
begin
  if (select array_agg(provider_event_id || '>' || kept_event_id order by provider_event_id) from private.whole_hour_provider_copies
      where package_id = '97000000-0000-0000-0000-000000000002')
      is distinct from array['unknown:customs>97000000-0000-0000-0000-000000000010',
        'unknown:sorted>97000000-0000-0000-0000-000000000012']
    or (select count(*) from public.tracking_events where package_id = '97000000-0000-0000-0000-000000000002'
      and provider_event_id not like 'app:%') <> 22 then
    raise exception 'Whole-hour copy cleanup removed other rows: %', (
      select array_agg(provider_event_id order by provider_event_id) from private.whole_hour_provider_copies
      where package_id = '97000000-0000-0000-0000-000000000002');
  end if;
  if not exists (select 1 from public.push_deliveries where event_id = '97000000-0000-0000-0000-000000000010') then
    raise exception 'Whole-hour copy cleanup lost a receipt';
  end if;
end;
$$;
rollback;
