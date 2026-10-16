\set ON_ERROR_STOP on
begin;

do $$
declare
  parcel public.packages;
  correction jsonb;
  scans jsonb := jsonb_build_array(jsonb_build_object('provider_event_id', 'unknown:journey-result',
    'stage', 'in_transit', 'description', 'In transit', 'occurred_at', now()));
begin
  insert into public.packages(user_id, tracking_number, carrier)
  values ('10000000-0000-0000-0000-000000000001', 'MLXX000000001R', 'unknown') returning * into parcel;
  correction := jsonb_build_object('carrier', 'mailamericas', 'tracking_url', null, 'dpd_postcode', null,
    'current_stage', 'in_transit', 'sync_status', 'ok', 'carrier_data', jsonb_build_object(
      'tracking_provider', 'ParcelsApp', 'discovered_carrier', 'mailamericas',
      'reported_carriers', jsonb_build_array('MailAmericas', 'Cainiao'),
      'routing', jsonb_build_object('version', 1, 'configured_carrier', 'mailamericas', 'discovered_carrier', 'mailamericas',
        'preferred_number', parcel.tracking_number, 'preferred_provider', 'ParcelsApp', 'last_event_at', now())));
  begin
    perform public.apply_tracking_sync(parcel.id, parcel.tracking_generation,
      jsonb_set(correction, '{carrier_data,reported_carriers}', '["A","B","C","D","E"]'), scans);
    raise exception 'A provider journey of more than four carriers was accepted';
  exception when sqlstate '22023' then null;
  end;
  correction := jsonb_set(correction, '{carrier_data,carrier_answered}', 'true');
  begin
    perform public.apply_tracking_sync(parcel.id, parcel.tracking_generation,
      jsonb_set(correction, '{carrier_data,reported_carriers}', '["A","B","C","D","E"]'), scans);
    raise exception 'An answered carrier was filed from an unbounded provider report';
  exception when sqlstate '22023' then null;
  end;
  begin
    perform public.apply_tracking_sync(parcel.id, parcel.tracking_generation,
      jsonb_set(correction, '{carrier_data,reported_carriers}', '["MailAmericas",null]'), scans);
    raise exception 'An answered carrier was filed from a malformed provider report';
  exception when sqlstate '22023' then null;
  end;
  begin
    -- The sync writer names the carrier that answered as the one routing settled on.
    perform public.apply_tracking_sync(parcel.id, parcel.tracking_generation,
      correction #- '{carrier_data,discovered_carrier}' #- '{carrier_data,routing,discovered_carrier}', scans);
    raise exception 'An answered carrier was filed without being the one routing settled on';
  exception when sqlstate '22023' then null;
  end;
  begin
    perform public.apply_tracking_sync(parcel.id, parcel.tracking_generation, correction);
    raise exception 'An answered carrier was filed without dated movement';
  exception when sqlstate '22023' then null;
  end;
  if not public.apply_tracking_sync(parcel.id, parcel.tracking_generation, correction, scans) then
    raise exception 'The answered carrier of a provider journey was not saved';
  end if;
  if not exists (select 1 from public.packages where id = parcel.id and carrier = 'mailamericas'
      and carrier_data#>>'{routing,confirmed_carrier}' is null
      and not (carrier_data ? 'auto_changed_from')) then
    raise exception 'The answered carrier claimed direct confirmation';
  end if;
end;
$$;
rollback;
