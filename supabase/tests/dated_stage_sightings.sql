\set ON_ERROR_STOP on
begin;

insert into auth.users (id, email)
values ('96000000-0000-0000-0000-000000000001', 'dated-stage-sightings@example.invalid');
insert into public.packages (id, user_id, tracking_number, carrier, current_stage)
values ('96000000-0000-0000-0000-000000000002', '96000000-0000-0000-0000-000000000001', '00000000000001', 'dpd-uk', 'in_transit');

insert into public.tracking_events (id, package_id, provider_event_id, stage, description, location, occurred_at, created_at, raw_data)
select ('96000000-0000-0000-0000-' || lpad(id::text, 12, '0'))::uuid, '96000000-0000-0000-0000-000000000002',
  provider_event_id, stage, description, location, occurred::timestamptz, occurred::timestamptz, raw::jsonb
from (values
  -- Seen at a check, then dated by the carrier on its own clock an hour from UTC: the dated row stays.
  (10, 'dpd-uk:observed', 'registered', 'Order details received', null, '2026-10-20T16:11:32Z',
    '{"observed_without_provider_timestamp":true,"local_time":"2026-09-22T19:09:00"}'),
  (11, 'unknown:registered', 'registered', 'Order  details received ', 'EXAMPLE SENDER', '2026-09-22T18:09:00Z',
    '{"time":"2026-09-22T18:09:00.000Z","universal_provider":"Ship24"}'),
  -- Seen without a clock, dated by a provider earlier that day.
  (12, 'swiss-post:observed', 'ready_for_pickup', 'Ready for pick-up', null, '2026-10-12T11:48:00Z',
    '{"observed_without_provider_timestamp":true,"provider_code":"P1"}'),
  (13, 'swiss-post:ready', 'ready_for_pickup', 'Ready for pick-up', 'EXAMPLE POINT', '2026-10-12T11:28:07Z',
    '{"time":"2026-10-12T13:28:07+02:00","provider_code":"P1"}'),
  -- Left alone: two dated rows, another stage, another code, another place, a later scan, another clock.
  (20, 'india-post:observed', 'in_transit', 'Item dispatched', null, '2026-09-14T19:50:03Z', '{"observed_without_provider_timestamp":true}'),
  (21, 'india-post:one', 'in_transit', 'Item dispatched', 'EXAMPLE OFFICE', '2026-09-12T14:47:10Z', '{"time":"2026-09-12T14:47:10Z"}'),
  (22, 'india-post:two', 'in_transit', 'Item dispatched', 'EXAMPLE HUB', '2026-09-13T01:24:35Z', '{"time":"2026-09-13T01:24:35Z"}'),
  (30, 'mrw:observed', 'exception', 'Incomplete address', 'EXAMPLE TOWN', '2026-10-20T17:42:49Z',
    '{"observed_without_provider_timestamp":true,"local_time":"2026-10-19T14:58:00"}'),
  (31, 'unknown:pending', 'pending', 'Incomplete address', 'EXAMPLE TOWN', '2026-10-19T12:58:00Z', '{"time":"2026-10-19T12:58:00.000Z"}'),
  (40, 'gls-de:observed', 'out_for_delivery', 'Out for delivery', null, '2026-10-13T07:02:00Z',
    '{"observed_without_provider_timestamp":true,"provider_code":"A"}'),
  (41, 'gls-de:out', 'out_for_delivery', 'Out for delivery', 'EXAMPLE DEPOT', '2026-10-13T05:44:30Z', '{"time":"2026-10-13T07:44:30+02:00","provider_code":"B"}'),
  (50, 'landmark-global:observed', 'delivered', 'Delivered', 'EXAMPLE STREET', '2026-10-15T22:50:23Z', '{"observed_without_provider_timestamp":true}'),
  (51, 'landmark-global:delivered', 'delivered', 'Delivered', 'OTHER STREET', '2026-10-15T13:03:27Z', '{"time":"2026-10-15T13:03:27Z"}'),
  (60, 'sf-express:observed', 'accepted', 'Collected', null, '2026-10-16T06:00:00Z', '{"observed_without_provider_timestamp":true}'),
  (61, 'unknown:collected', 'accepted', 'Collected', null, '2026-10-16T06:53:03Z', '{"time":"2026-10-16T14:53:03+08:00"}'),
  (70, 'sf-express:observed-clock', 'in_transit', 'Arrived', null, '2026-10-16T13:00:00Z',
    '{"observed_without_provider_timestamp":true,"local_time":"2026-10-16T20:32:27"}'),
  (71, 'unknown:arrived', 'in_transit', 'Arrived', null, '2026-10-16T12:31:27Z', '{"time":"2026-10-16T20:31:27+08:00"}')
) as rows(id, provider_event_id, stage, description, location, occurred, raw);

insert into public.push_subscriptions (id, user_id, endpoint, p256dh, auth, subscribed_at)
values ('96000000-0000-0000-0000-000000000003', '96000000-0000-0000-0000-000000000001',
  'https://fcm.googleapis.com/fcm/send/synthetic-dated-sightings-fixture', 'test', 'test', '2000-01-01');
-- The sighting was announced; the dated row was not.
insert into public.push_deliveries (subscription_id, event_id, sent_at) values
  ('96000000-0000-0000-0000-000000000003', '96000000-0000-0000-0000-000000000010', '2026-10-20T16:12Z');

\ir ../migrations/20261020190000_dated_stage_sightings.sql
-- A second run changes nothing.
\ir ../migrations/20261020190000_dated_stage_sightings.sql

do $$
begin
  if (select array_agg(provider_event_id order by provider_event_id) from public.tracking_events
      where package_id = '96000000-0000-0000-0000-000000000002' and provider_event_id like '%:observed%')
      is distinct from array['gls-de:observed', 'india-post:observed', 'landmark-global:observed', 'mrw:observed',
        'sf-express:observed', 'sf-express:observed-clock'] then
    raise exception 'Dated sighting cleanup kept other sightings: %', (
      select array_agg(provider_event_id order by provider_event_id) from public.tracking_events
      where package_id = '96000000-0000-0000-0000-000000000002' and provider_event_id like '%:observed%');
  end if;
  if (select array_agg(provider_event_id || '>' || kept_event_id order by provider_event_id) from private.dated_stage_sightings
      where package_id = '96000000-0000-0000-0000-000000000002')
      is distinct from array['dpd-uk:observed>96000000-0000-0000-0000-000000000011',
        'swiss-post:observed>96000000-0000-0000-0000-000000000013']
    or (select jsonb_array_length(receipts->'push_deliveries') from private.dated_stage_sightings
      where id = '96000000-0000-0000-0000-000000000010') <> 1 then
    raise exception 'Dated sighting cleanup kept another backup';
  end if;
  if not exists (select 1 from public.push_deliveries where event_id = '96000000-0000-0000-0000-000000000011') then
    raise exception 'Dated sighting cleanup lost a receipt';
  end if;
end;
$$;
rollback;
