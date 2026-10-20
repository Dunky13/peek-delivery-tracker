\set ON_ERROR_STOP on
begin;

insert into auth.users (id, email)
values ('95000000-0000-0000-0000-000000000001', 'dhl-express-wall-clock-copies@example.invalid');
insert into public.packages (id, user_id, tracking_number, carrier, current_stage)
values ('95000000-0000-0000-0000-000000000002', '95000000-0000-0000-0000-000000000001', '1234567891', 'dhl-express', 'customs');

insert into public.tracking_events (id, package_id, provider_event_id, stage, description, location, occurred_at, created_at, raw_data)
select ('95000000-0000-0000-0000-' || lpad(id::text, 12, '0'))::uuid, '95000000-0000-0000-0000-000000000002',
  provider_event_id, stage, description, location, (raw::jsonb->>'time')::timestamptz, created::timestamptz, raw::jsonb
from (values
  -- One record from both feeds: the mobile API's on the facility's clock without a code, the
  -- global portal's under another offset with one. The row stored first stays, whichever feed wrote it.
  (10, 'dhl-express:mobile', 'customs', 'Customs clearance status updated', 'EXAMPLE CITY - ITALY', '2026-10-06T09:00Z', '{"time":"2026-10-05T11:00:00+02:00"}'),
  (11, 'dhl-express:portal', 'customs', 'Customs clearance status updated', 'EXAMPLE CITY - ITALY', '2026-10-06T10:00Z', '{"time":"2026-10-05T11:00:00+01:00","provider_code":"RR"}'),
  (12, 'dhl-express:late-mobile', 'in_transit', 'Processed at EXAMPLE CITY', 'EXAMPLE CITY - ITALY', '2026-10-06T10:00Z', '{"time":"2026-10-05T12:30:00+02:00"}'),
  (13, 'dhl-express:early-utc', 'in_transit', 'PROCESSED  at example city ', 'EXAMPLE CITY - ITALY', '2026-10-06T09:00Z', '{"time":"2026-10-05T12:30:00Z","provider_code":"PL"}'),
  -- Left alone: another minute, another second, another place, other wording, a naive clock,
  -- an observation, a universal copy, another carrier's row, and the same offset spelled otherwise.
  (20, 'dhl-express:hub', 'in_transit', 'Arrived at facility', 'EXAMPLE HUB - ITALY', '2026-10-06T08:00Z', '{"time":"2026-10-04T09:00:00+02:00"}'),
  (21, 'dhl-express:minute', 'in_transit', 'Arrived at facility', 'EXAMPLE HUB - ITALY', '2026-10-06T09:00Z', '{"time":"2026-10-04T09:01:00+01:00"}'),
  (22, 'dhl-express:second', 'in_transit', 'Arrived at facility', 'EXAMPLE HUB - ITALY', '2026-10-06T09:00Z', '{"time":"2026-10-04T09:00:30+01:00"}'),
  (23, 'dhl-express:place', 'in_transit', 'Arrived at facility', 'OTHER HUB - ITALY', '2026-10-06T09:00Z', '{"time":"2026-10-04T09:00:00+01:00"}'),
  (24, 'dhl-express:wording', 'in_transit', 'Departed facility', 'EXAMPLE HUB - ITALY', '2026-10-06T09:00Z', '{"time":"2026-10-04T09:00:00+01:00"}'),
  (25, 'dhl-express:naive', 'in_transit', 'Arrived at facility', 'EXAMPLE HUB - ITALY', '2026-10-06T09:00Z', '{"time":"2026-10-04T09:00:00"}'),
  (26, 'dhl-express:observed', 'in_transit', 'Arrived at facility', 'EXAMPLE HUB - ITALY', '2026-10-06T09:00Z', '{"time":"2026-10-04T09:00:00+01:00","observed_without_provider_timestamp":true}'),
  (27, 'unknown:hub', 'in_transit', 'Arrived at facility', 'EXAMPLE HUB - ITALY', '2026-10-06T09:00Z', '{"time":"2026-10-04T09:00:00-05:00","universal_provider":"17TRACK"}'),
  (28, 'dhl:hub', 'in_transit', 'Arrived at facility', 'EXAMPLE HUB - ITALY', '2026-10-06T09:00Z', '{"time":"2026-10-04T09:00:00+03:00"}'),
  (29, 'dhl-express:utc', 'in_transit', 'Departed facility', 'EXAMPLE HUB - ITALY', '2026-10-06T08:00Z', '{"time":"2026-10-04T15:00:00+00:00"}'),
  (30, 'dhl-express:utc-z', 'in_transit', 'Departed facility', 'EXAMPLE HUB - ITALY', '2026-10-06T09:00Z', '{"time":"2026-10-04T15:00:00Z"}'),
  -- Codes that differ, and empty wording.
  (40, 'dhl-express:coded', 'customs', 'Clearance event', 'EXAMPLE CITY - ITALY', '2026-10-06T08:00Z', '{"time":"2026-10-04T10:00:00+02:00","provider_code":"OH"}'),
  (41, 'dhl-express:recoded', 'customs', 'Clearance event', 'EXAMPLE CITY - ITALY', '2026-10-06T09:00Z', '{"time":"2026-10-04T10:00:00+01:00","provider_code":"CR"}'),
  (42, 'dhl-express:blank', 'in_transit', '', 'EXAMPLE CITY - ITALY', '2026-10-06T08:00Z', '{"time":"2026-10-04T11:00:00+02:00"}'),
  (43, 'dhl-express:blank-copy', 'in_transit', ' ', 'EXAMPLE CITY - ITALY', '2026-10-06T09:00Z', '{"time":"2026-10-04T11:00:00+01:00"}'),
  -- Three rows of one wall clock under three offsets: none matches only one other.
  (50, 'dhl-express:hold', 'in_transit', 'Shipment on hold', 'EXAMPLE CITY - ITALY', '2026-10-06T08:00Z', '{"time":"2026-10-04T14:00:00+02:00"}'),
  (51, 'dhl-express:hold-portal', 'in_transit', 'Shipment on hold', 'EXAMPLE CITY - ITALY', '2026-10-06T09:00Z', '{"time":"2026-10-04T14:00:00+01:00"}'),
  (52, 'dhl-express:hold-utc', 'in_transit', 'Shipment on hold', 'EXAMPLE CITY - ITALY', '2026-10-06T10:00Z', '{"time":"2026-10-04T14:00:00Z"}')
) as rows(id, provider_event_id, stage, description, location, created, raw);

insert into public.push_subscriptions (id, user_id, endpoint, p256dh, auth, subscribed_at)
values
  ('95000000-0000-0000-0000-000000000003', '95000000-0000-0000-0000-000000000001',
    'https://fcm.googleapis.com/fcm/send/synthetic-wall-clock-copies-fixture', 'test', 'test', '2000-01-01'),
  ('95000000-0000-0000-0000-000000000004', '95000000-0000-0000-0000-000000000001',
    'https://fcm.googleapis.com/fcm/send/synthetic-wall-clock-copies-later', 'test', 'test', '2000-01-01');
-- Both rows were announced, the copy to a second subscription too.
insert into public.push_deliveries (subscription_id, event_id, sent_at) values
  ('95000000-0000-0000-0000-000000000003', '95000000-0000-0000-0000-000000000010', '2026-10-06T09:00Z'),
  ('95000000-0000-0000-0000-000000000003', '95000000-0000-0000-0000-000000000011', '2026-10-06T10:00Z'),
  ('95000000-0000-0000-0000-000000000004', '95000000-0000-0000-0000-000000000011', '2026-10-06T10:00Z');
insert into public.tracking_status_observations (observation_key, carrier, description_normalized, stage_source, chosen_stage, sample_event_id)
values (repeat('f', 64), 'dhl-express', 'customs clearance status updated', 'none', 'customs', '95000000-0000-0000-0000-000000000011');
insert into public.delivery_emails (user_id, package_id, event_id, status, sent_at)
values ('95000000-0000-0000-0000-000000000001', '95000000-0000-0000-0000-000000000002',
  '95000000-0000-0000-0000-000000000012', 'sent', '2026-10-06T10:00Z');

\ir ../migrations/20261020164500_dhl_express_wall_clock_copies.sql
-- A second run changes nothing.
\ir ../migrations/20261020164500_dhl_express_wall_clock_copies.sql

do $$
declare
  copies constant text[] := array['dhl-express:late-mobile', 'dhl-express:portal'];
begin
  if exists (select 1 from public.tracking_events
      where package_id = '95000000-0000-0000-0000-000000000002' and provider_event_id = any(copies))
    or (select count(*) from public.tracking_events where package_id = '95000000-0000-0000-0000-000000000002'
      and provider_event_id not like 'app:%') <> 20 then
    raise exception 'Wall-clock copy cleanup removed other rows than the copies: %', (
      select array_agg(provider_event_id order by provider_event_id) from public.tracking_events
      where package_id = '95000000-0000-0000-0000-000000000002' and provider_event_id not like 'app:%');
  end if;
  if (select array_agg(provider_event_id || '>' || kept_event_id order by provider_event_id) from private.dhl_express_wall_clock_copies
      where package_id = '95000000-0000-0000-0000-000000000002')
      is distinct from array['dhl-express:late-mobile>95000000-0000-0000-0000-000000000013',
        'dhl-express:portal>95000000-0000-0000-0000-000000000010']
    or (select jsonb_array_length(receipts->'push_deliveries') from private.dhl_express_wall_clock_copies
      where id = '95000000-0000-0000-0000-000000000011') <> 2
    or (select receipts->'tracking_status_observations' from private.dhl_express_wall_clock_copies
      where id = '95000000-0000-0000-0000-000000000011') <> jsonb_build_array(repeat('f', 64))
    or (select jsonb_array_length(receipts->'delivery_emails') from private.dhl_express_wall_clock_copies
      where id = '95000000-0000-0000-0000-000000000012') <> 1
    or (select raw_data->>'provider_code' from private.dhl_express_wall_clock_copies
      where id = '95000000-0000-0000-0000-000000000011') <> 'RR' then
    raise exception 'Wall-clock copy cleanup kept another backup: %', (
      select jsonb_agg(to_jsonb(copy) - 'raw_data') from private.dhl_express_wall_clock_copies copy
      where package_id = '95000000-0000-0000-0000-000000000002');
  end if;
  if (select array_agg(subscription_id::text || '@' || sent_at::text order by subscription_id) from public.push_deliveries
      where event_id = '95000000-0000-0000-0000-000000000010')
      is distinct from array['95000000-0000-0000-0000-000000000003@' || '2026-10-06T09:00Z'::timestamptz::text,
        '95000000-0000-0000-0000-000000000004@' || '2026-10-06T10:00Z'::timestamptz::text]
    or (select sample_event_id from public.tracking_status_observations where observation_key = repeat('f', 64))
      <> '95000000-0000-0000-0000-000000000010'::uuid
    or not exists (select 1 from public.delivery_emails where event_id = '95000000-0000-0000-0000-000000000013') then
    raise exception 'Wall-clock copy cleanup lost a receipt';
  end if;
end;
$$;
rollback;
