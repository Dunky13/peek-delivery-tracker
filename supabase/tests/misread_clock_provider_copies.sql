\set ON_ERROR_STOP on
begin;

insert into auth.users (id, email)
values ('98000000-0000-0000-0000-000000000001', 'misread-clock-provider-copies@example.invalid');
insert into public.packages (id, user_id, tracking_number, carrier, current_stage) values
  ('98000000-0000-0000-0000-000000000002', '98000000-0000-0000-0000-000000000001', 'EX0000000000001', 'shiprocket', 'in_transit'),
  ('98000000-0000-0000-0000-000000000003', '98000000-0000-0000-0000-000000000001', '1Z0000000000000001', 'ups', 'in_transit');

insert into public.tracking_events (id, package_id, provider_event_id, stage, description, location, occurred_at, created_at, raw_data)
select ('98000000-0000-0000-0000-' || lpad(id::text, 12, '0'))::uuid, ('98000000-0000-0000-0000-00000000000' || parcel)::uuid,
  provider_event_id, stage, description, location, occurred::timestamptz, occurred::timestamptz, raw::jsonb
from (values
  -- The carrier's scans, to the minute on India's clock.
  (10, 2, 'shiprocket:booked', 'registered', 'Shipment booked', 'EXAMPLE HUB, MH', '2026-10-13T04:04:00Z', '{"time":"2026-10-13T09:34:00+05:30"}'),
  (11, 2, 'shiprocket:picked', 'accepted', 'Picked up', 'EXAMPLE HUB, MH', '2026-10-13T08:56:00Z', '{"time":"2026-10-13T14:26:00+05:30"}'),
  (12, 2, 'shiprocket:hub', 'in_transit', 'Reached hub', 'EXAMPLE HUB, MH', '2026-10-13T12:33:00Z', '{"time":"2026-10-13T18:03:00+05:30"}'),
  (13, 2, 'shiprocket:sorted', 'in_transit', 'Sorted', 'EXAMPLE HUB, MH', '2026-10-13T13:05:00Z', '{"time":"2026-10-13T18:35:00+05:30"}'),
  (14, 2, 'shiprocket:next', 'in_transit', 'Sorted', 'OTHER HUB, MH', '2026-10-14T02:05:00Z', '{"time":"2026-10-14T07:35:00+05:30"}'),
  -- A provider read them as US Eastern, with seconds of its own: two copies of the same scan
  -- show the shift, so those in another stage or wording go too. One with no carrier scan
  -- at the shift stays.
  (20, 2, 'unknown:t-booked', 'registered', 'Shipment booked', 'EXAMPLE HUB, MH', '2026-10-13T13:34:01Z', '{"universal_provider":"17TRACK"}'),
  (21, 2, 'unknown:t-picked', 'in_transit', 'Picked up', 'EXAMPLE HUB, MH', '2026-10-13T18:26:21Z', '{"universal_provider":"17TRACK"}'),
  (22, 2, 'unknown:t-hub', 'in_transit', 'Arrived at hub', 'EXAMPLE HUB, MH', '2026-10-13T22:03:41Z', '{"universal_provider":"17TRACK"}'),
  (23, 2, 'unknown:t-sorted', 'in_transit', 'Sorted', 'EXAMPLE HUB, MH', '2026-10-13T22:35:21Z', '{"universal_provider":"17TRACK"}'),
  (24, 2, 'unknown:t-extra', 'in_transit', 'Out of hub', 'EXAMPLE HUB, MH', '2026-10-13T23:30:06Z', '{"universal_provider":"17TRACK"}'),
  -- Another dated every scan at midnight: each copy of a carrier scan of its day goes, one of another day stays.
  (30, 2, 'unknown:p-booked', 'registered', 'Shipment booked', 'EXAMPLE HUB, MH', '2026-10-13T00:00:00Z', '{"universal_provider":"ParcelsApp"}'),
  (31, 2, 'unknown:p-picked', 'accepted', 'Picked up', 'EXAMPLE HUB, MH', '2026-10-13T00:00:00Z', '{"universal_provider":"ParcelsApp"}'),
  (32, 2, 'unknown:p-next', 'in_transit', 'Sorted', 'OTHER HUB, MH', '2026-10-14T00:00:00Z', '{"universal_provider":"ParcelsApp"}'),
  (33, 2, 'unknown:p-sorted', 'in_transit', 'Sorted', 'EXAMPLE HUB, MH', '2026-10-13T00:00:00Z', '{"universal_provider":"ParcelsApp"}'),
  (34, 2, 'unknown:p-hub', 'in_transit', 'Reached hub', 'EXAMPLE HUB, MH', '2026-10-15T00:00:00Z', '{"universal_provider":"ParcelsApp"}'),
  -- Left alone: one copy half an hour off a whole hour, and a midnight copy from a provider
  -- with timed rows. A copy a whole number of hours away goes alone.
  (40, 3, 'ups:arrived', 'in_transit', 'Arrived', 'EXAMPLE CITY, US', '2026-01-06T10:20:15Z', '{"time":"2026-01-06T10:20:15Z"}'),
  (41, 3, 'unknown:arrived', 'in_transit', 'Arrived', 'EXAMPLE CITY, US', '2026-01-06T15:50:00Z', '{"universal_provider":"17TRACK"}'),
  (42, 3, 'unknown:arrived-day', 'in_transit', 'Arrived', 'EXAMPLE CITY, US', '2026-01-06T00:00:00Z', '{"universal_provider":"ParcelsApp"}'),
  (43, 3, 'unknown:loaded', 'in_transit', 'Loaded', 'EXAMPLE CITY, US', '2026-01-05T08:12:00Z', '{"universal_provider":"ParcelsApp"}'),
  (44, 3, 'unknown:departed', 'in_transit', 'Departed', 'EXAMPLE CITY, US', '2026-01-06T18:00:00Z', '{"universal_provider":"Ship24"}'),
  (45, 3, 'ups:departed', 'in_transit', 'Departed', 'EXAMPLE CITY, US', '2026-01-06T07:00:20Z', '{}')
) as rows(id, parcel, provider_event_id, stage, description, location, occurred, raw);

insert into public.push_subscriptions (id, user_id, endpoint, p256dh, auth, subscribed_at)
values ('98000000-0000-0000-0000-000000000004', '98000000-0000-0000-0000-000000000001',
  'https://fcm.googleapis.com/fcm/send/synthetic-misread-clock-copies-fixture', 'test', 'test', '2000-01-01');
insert into public.push_deliveries (subscription_id, event_id, sent_at) values
  ('98000000-0000-0000-0000-000000000004', '98000000-0000-0000-0000-000000000020', '2026-10-14T00:00Z');

\ir ../migrations/20261020213000_misread_clock_provider_copies.sql
-- A second run changes nothing.
\ir ../migrations/20261020213000_misread_clock_provider_copies.sql

do $$
begin
  if (select array_agg(provider_event_id || '>' || right(kept_event_id::text, 2) order by provider_event_id)
      from private.misread_clock_provider_copies where package_id::text like '98000000-%')
      is distinct from array['unknown:departed>45', 'unknown:p-booked>10', 'unknown:p-next>14', 'unknown:p-picked>11',
        'unknown:p-sorted>13', 'unknown:t-booked>10', 'unknown:t-hub>12', 'unknown:t-picked>11', 'unknown:t-sorted>13']
    or (select count(*) from public.tracking_events where package_id::text like '98000000-%'
      and provider_event_id not like 'app:%') <> 12 then
    raise exception 'Misread clock cleanup removed other rows: %', (
      select array_agg(provider_event_id order by provider_event_id) from private.misread_clock_provider_copies
      where package_id::text like '98000000-%');
  end if;
  if not exists (select 1 from public.push_deliveries where event_id = '98000000-0000-0000-0000-000000000010') then
    raise exception 'Misread clock cleanup lost a receipt';
  end if;
end;
$$;
rollback;
