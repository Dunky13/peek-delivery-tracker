\set ON_ERROR_STOP on
begin;

-- Only the database's owner settles a repair.
do $$
begin
  if has_function_privilege('anon', 'private.settle_repaired_parcels(uuid[])', 'EXECUTE')
      or has_function_privilege('authenticated', 'private.settle_repaired_parcels(uuid[])', 'EXECUTE') then
    raise exception 'Public roles can settle a parcel';
  end if;
end;
$$;

-- kept: a provider's misread copy set the watermark, and the repair deleted it; its summary is
-- a scan left. delivered: the repair deleted another parcel's delivery its summary showed.
-- emptied: every scan was deleted. observed: a stage change observed after its newest scan.
-- unrouted: no routing saved. untouched: not settled.
insert into public.packages (id, user_id, one_off, tracking_number, carrier, current_stage, last_status_text, created_at, carrier_data)
values
  ('5e000000-0000-4000-8000-000000000001', null, true, 'SETTLE0001', 'la-poste', 'in_transit', 'Colis en transit',
    '2026-10-01T08:00:00Z', '{"tracking_provider": "ParcelsApp", "routing": {"version": 1, "last_event_at": "2026-10-05T18:00:00.000Z"}}'),
  ('5e000000-0000-4000-8000-000000000002', null, true, 'SETTLE0002', 'aliexpress', 'delivered', 'Delivered',
    '2026-10-01T08:00:00Z', '{"routing": {"version": 1, "last_event_at": "2026-10-07T09:00:00.000Z"}}'),
  ('5e000000-0000-4000-8000-000000000003', null, true, 'SETTLE0003', 'aliexpress', 'in_transit', 'Departed',
    '2026-10-01T08:00:00Z', '{"routing": {"version": 1, "last_event_at": "2026-10-03T09:00:00.000Z"}}'),
  ('5e000000-0000-4000-8000-000000000004', null, true, 'SETTLE0004', 'la-poste', 'out_for_delivery', 'En cours de livraison',
    '2026-10-01T08:00:00Z', '{"routing": {"version": 1, "last_event_at": "2026-10-06T12:00:00.000Z"}}'),
  ('5e000000-0000-4000-8000-000000000005', null, true, 'SETTLE0005', 'la-poste', 'delivered', 'Livré',
    '2026-10-01T08:00:00Z', '{"sender_name": "Shop"}'),
  ('5e000000-0000-4000-8000-000000000006', null, true, 'SETTLE0006', 'la-poste', 'delivered', 'Livré',
    '2026-10-01T08:00:00Z', '{"routing": {"version": 1, "last_event_at": "2026-10-09T09:00:00.000Z"}}');

insert into public.tracking_events (package_id, stage, description, occurred_at, provider_event_id, raw_data)
values
  ('5e000000-0000-4000-8000-000000000001', 'in_transit', 'Colis en transit', '2026-10-05T10:00:00Z', 'la-poste:transit', '{}'),
  ('5e000000-0000-4000-8000-000000000001', 'in_transit', 'Pris en charge', '2026-10-04T10:00:00Z', 'la-poste:taken', '{}'),
  ('5e000000-0000-4000-8000-000000000002', 'in_transit', 'Departed from sorting center', '2026-10-04T10:00:00Z', 'aliexpress:departed', '{}'),
  ('5e000000-0000-4000-8000-000000000002', 'in_transit', 'Arrived at sorting center', '2026-10-03T10:00:00Z', 'aliexpress:arrived', '{}'),
  ('5e000000-0000-4000-8000-000000000004', 'in_transit', 'Colis en transit', '2026-10-06T08:00:00Z', 'la-poste:transit', '{}'),
  ('5e000000-0000-4000-8000-000000000004', 'out_for_delivery', 'En cours de livraison', '2026-10-06T12:00:00Z',
    'la-poste:observed:in_transit->out_for_delivery', '{"observed_without_provider_timestamp": true}'),
  ('5e000000-0000-4000-8000-000000000005', 'in_transit', 'Colis en transit', '2026-10-06T08:00:00Z', 'la-poste:transit', '{}'),
  ('5e000000-0000-4000-8000-000000000006', 'in_transit', 'Colis en transit', '2026-10-06T08:00:00Z', 'la-poste:transit', '{}');

create temp table settled on commit drop as
select * from private.settle_repaired_parcels(array[
  '5e000000-0000-4000-8000-000000000001', '5e000000-0000-4000-8000-000000000002', '5e000000-0000-4000-8000-000000000003',
  '5e000000-0000-4000-8000-000000000004', '5e000000-0000-4000-8000-000000000005']::uuid[]);

do $$
begin
  -- Each settled parcel reports its stage and watermark before and after.
  if (select array_agg(row(stage_before, stage_after, watermark_before, watermark_after)::text order by package_id) from settled)
      is distinct from array[
        row('in_transit', 'in_transit', '2026-10-05T18:00:00.000Z', '2026-10-05T10:00:00.000Z')::text,
        row('delivered', 'in_transit', '2026-10-07T09:00:00.000Z', '2026-10-04T10:00:00.000Z')::text,
        row('in_transit', 'pending', '2026-10-03T09:00:00.000Z', null)::text,
        row('out_for_delivery', 'out_for_delivery', '2026-10-06T12:00:00.000Z', '2026-10-06T08:00:00.000Z')::text,
        row('delivered', 'in_transit', null, null)::text] then
    raise exception 'The repaired parcels were not settled: %', (select array_agg(row(settled.*)::text order by package_id) from settled);
  end if;
  -- A summary a scan left shows stays; another takes the newest row's words, or none.
  if (select array_agg(row(tracking_number, current_stage, last_status_text)::text order by tracking_number)
      from public.packages where tracking_number like 'SETTLE%')
      is distinct from array[
        row('SETTLE0001', 'in_transit', 'Colis en transit')::text,
        row('SETTLE0002', 'in_transit', 'Departed from sorting center')::text,
        row('SETTLE0003', 'pending', null)::text,
        row('SETTLE0004', 'out_for_delivery', 'En cours de livraison')::text,
        row('SETTLE0005', 'in_transit', 'Colis en transit')::text,
        row('SETTLE0006', 'delivered', 'Livré')::text] then
    raise exception 'The summaries were misread: %', (select array_agg(row(tracking_number, current_stage, last_status_text)::text
      order by tracking_number) from public.packages where tracking_number like 'SETTLE%');
  end if;
  -- The rest of the parcel's data stays: its provider, routing and sender, and the parcel not settled.
  if (select carrier_data from public.packages where tracking_number = 'SETTLE0001')
        is distinct from '{"tracking_provider": "ParcelsApp", "routing": {"version": 1, "last_event_at": "2026-10-05T10:00:00.000Z"}}'
      or (select carrier_data from public.packages where tracking_number = 'SETTLE0003') is distinct from '{"routing": {"version": 1}}'
      or (select carrier_data from public.packages where tracking_number = 'SETTLE0005') is distinct from '{"sender_name": "Shop"}'
      or (select carrier_data->'routing'->>'last_event_at' from public.packages where tracking_number = 'SETTLE0006')
        is distinct from '2026-10-09T09:00:00.000Z' then
    raise exception 'Settling changed more than the summary and watermark';
  end if;
end;
$$;

\echo 'settle repaired parcels assertions passed'

rollback;
