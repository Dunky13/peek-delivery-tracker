\set ON_ERROR_STOP on
begin;

do $$
declare
  parcel public.packages;
  job uuid;
  scans jsonb := jsonb_build_array(jsonb_build_object('provider_event_id', 'unknown:taken',
    'stage', 'in_transit', 'description', 'Received at the depot', 'occurred_at', '2026-01-04T12:00:42Z'));
begin
  insert into public.packages(user_id, tracking_number, carrier)
  values ('10000000-0000-0000-0000-000000000001', 'EXAMPLE0000000001', 'gofo') returning * into parcel;
  insert into public.tracking_events(package_id, provider_event_id, stage, description, occurred_at)
  select parcel.id, copy.id, 'in_transit', copy.id, '2026-01-04T12:00:42Z'
  from unnest(array['unknown:taken', 'unknown:copy', 'unknown:other', 'gofo:kept']) as copy(id);
  -- A copy the sync names goes; a row the batch writes stays, whatever the list says.
  if not public.apply_tracking_sync(parcel.id, parcel.tracking_generation, '{"sync_status":"ok"}', scans,
      '{}', array['unknown:copy', 'unknown:taken']) then
    raise exception 'The sync with absorbed copies was not saved';
  end if;
  if (select array_agg(provider_event_id order by provider_event_id) from public.tracking_events
      where package_id = parcel.id and provider_event_id not like 'app:%')
      is distinct from array['gofo:kept', 'unknown:other', 'unknown:taken'] then
    raise exception 'The sync deleted other rows than the absorbed copy';
  end if;
  -- A caller that names no copies, and the leased sync, still resolve.
  if not public.apply_tracking_sync(parcel.id, parcel.tracking_generation, '{"sync_status":"ok"}', scans, '{}') then
    raise exception 'The sync without absorbed copies was not saved';
  end if;
  insert into public.sync_jobs(user_id, package_id, kind, dedupe_key, state, locked_by, lease_until)
  values (parcel.user_id, parcel.id, 'package', 'package:' || parcel.id, 'running', 'worker',
    clock_timestamp() + interval '1 minute') returning id into job;
  if not public.apply_leased_tracking_sync(job, 'worker', parcel.id, parcel.tracking_generation,
      '{"sync_status":"ok"}', '[]', '{}', array['unknown:other']) then
    raise exception 'The leased sync with absorbed copies was not saved';
  end if;
  if exists (select 1 from public.tracking_events where package_id = parcel.id and provider_event_id = 'unknown:other') then
    raise exception 'The leased sync kept the absorbed copy';
  end if;
end;
$$;
rollback;
