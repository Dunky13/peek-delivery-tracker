\set ON_ERROR_STOP on
begin;

insert into auth.users (id, email)
values ('92000000-0000-0000-0000-000000000001', 'universal-provider-notices@example.invalid');
insert into public.packages (id, user_id, tracking_number, carrier, current_stage) values
  ('92000000-0000-0000-0000-000000000002', '92000000-0000-0000-0000-000000000001', 'EX0000000000001', 'unknown', 'in_transit');

insert into public.tracking_events (id, package_id, provider_event_id, stage, description, occurred_at, raw_data)
select ('92000000-0000-0000-0000-' || lpad(id::text, 12, '0'))::uuid, '92000000-0000-0000-0000-000000000002',
  provider_event_id, 'pending', description, occurred::timestamptz, raw::jsonb
from (values
  -- The providers' notices go.
  (10, 'unknown:characters', 'Tracking number must contain only capital letters and digits. Please check that tracking number is correct.', '2026-10-17T10:00:00Z', '{"universal_provider":"ParcelsApp"}'),
  (11, 'unknown:partner', 'Track Sendcloud shipment by tapping the button', '2026-10-17T10:00:01Z', '{"universal_provider":"ParcelsApp"}'),
  (12, 'unknown:drop-off', 'A preferred drop-off location was booked for the shipment', '2026-10-16T08:00:00Z', '{"universal_provider":"ParcelsApp"}'),
  (13, 'unknown:parameters', 'Shipment parameters updated', '2026-10-16T09:00:00Z', '{"universal_provider":"Postal Ninja"}'),
  (14, 'unknown:unnamed', 'Please check that your tracking number is correct', '2026-10-16T09:30:00Z', '{}'),
  -- Scans stay: a carrier's own row in those words, and wordings the rule leaves to scans.
  (20, 'dpd:retry', 'Delivery attempt failed, we will try again later', '2026-10-16T11:00:00Z', '{}'),
  (21, 'unknown:weight', 'Shipment parameters updated: weight 2 kg', '2026-10-16T12:00:00Z', '{"universal_provider":"Postal Ninja"}'),
  (22, 'unknown:sorted', 'Arrived at sorting center', '2026-10-15T12:00:00Z', '{"universal_provider":"ParcelsApp"}')
) as rows(id, provider_event_id, description, occurred, raw);

insert into public.push_subscriptions (id, user_id, endpoint, p256dh, auth, subscribed_at)
values ('92000000-0000-0000-0000-000000000003', '92000000-0000-0000-0000-000000000001',
  'https://fcm.googleapis.com/fcm/send/synthetic-universal-provider-notices-fixture', 'test', 'test', '2000-01-01');
insert into public.push_deliveries (subscription_id, event_id, sent_at) values
  ('92000000-0000-0000-0000-000000000003', '92000000-0000-0000-0000-000000000010', '2026-10-17T10:01Z');

\ir ../migrations/20261020233000_universal_provider_notices.sql
-- A second run changes nothing.
\ir ../migrations/20261020233000_universal_provider_notices.sql

do $$
begin
  if (select array_agg(provider_event_id order by provider_event_id)
      from private.universal_provider_notices where package_id::text like '92000000-%')
      is distinct from array['unknown:characters', 'unknown:drop-off', 'unknown:parameters', 'unknown:partner', 'unknown:unnamed']
    or (select array_agg(provider_event_id order by provider_event_id) from public.tracking_events
      where package_id::text like '92000000-%' and provider_event_id not like 'app:%')
      is distinct from array['dpd:retry', 'unknown:sorted', 'unknown:weight'] then
    raise exception 'Notice cleanup removed other rows: %', (
      select array_agg(provider_event_id order by provider_event_id) from private.universal_provider_notices
      where package_id::text like '92000000-%');
  end if;
  if (select jsonb_array_length(receipts->'push_deliveries') from private.universal_provider_notices
      where id = '92000000-0000-0000-0000-000000000010') <> 1 then
    raise exception 'Notice cleanup lost a removed row''s receipt';
  end if;
end;
$$;
rollback;
