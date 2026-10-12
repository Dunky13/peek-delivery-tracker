\set ON_ERROR_STOP on
begin;
insert into auth.users (id, email) values ('19000000-0000-0000-0000-000000000013', 'cacesa-gls-spain-test@example.test');
select set_config('request.jwt.claim.sub', '19000000-0000-0000-0000-000000000013', true);
set local role authenticated;
do $$
declare
  parcel public.packages;
begin
  parcel := test_support.add_parcel('CA000000000001', 'CACESA fixture', 'cacesa');
  if parcel.carrier <> 'cacesa' then raise exception 'CACESA was lost on creation'; end if;
  perform public.change_owned_package_carrier(parcel.id, 'unknown');
  perform public.change_owned_package_carrier(parcel.id, 'cacesa');
  if (select carrier from public.packages where id = parcel.id) <> 'cacesa' then
    raise exception 'Carrier change to CACESA failed';
  end if;
  -- CACESA asks for no postcode.
  begin
    perform test_support.add_parcel('CA000000000002', 'With a postcode', 'cacesa', null, '28000');
    raise exception 'A CACESA postcode was accepted';
  exception when sqlstate '22023' then null;
  end;

  -- GLS Spain shows a shipment only with its delivery postcode, Spanish or Portuguese.
  parcel := test_support.add_parcel('GS000000000001', 'GLS Spain fixture', 'gls-es', null, ' 08000 ');
  if parcel.carrier <> 'gls-es' or parcel.dpd_postcode <> '08000' then
    raise exception 'GLS Spain lost its postcode on creation';
  end if;
  perform public.change_owned_package_carrier(parcel.id, 'gls-es', null, '1000-001');
  if (select dpd_postcode from public.packages where id = parcel.id) <> '1000-001' then
    raise exception 'Portuguese postcode was not saved for GLS Spain';
  end if;
  begin
    perform test_support.add_parcel('GS000000000002', 'Without a postcode', 'gls-es');
    raise exception 'GLS Spain was accepted without a postcode';
  exception when sqlstate '22023' then null;
  end;
  begin
    perform test_support.add_parcel('GS000000000003', 'Malformed postcode', 'gls-es', null, '08/00');
    raise exception 'A malformed GLS Spain postcode was accepted';
  exception when sqlstate '22023' then null;
  end;
  begin
    perform public.change_owned_package_carrier(parcel.id, 'gls-es', null, null);
    raise exception 'GLS Spain lost its postcode on a carrier change';
  exception when sqlstate '22023' then null;
  end;
  perform public.change_owned_package_carrier(parcel.id, 'cacesa');
  if (select dpd_postcode from public.packages where id = parcel.id) is not null then
    raise exception 'The GLS Spain postcode followed the parcel to CACESA';
  end if;
end;
$$;
reset role;
-- A GLS Spain parcel stored before the postcode was asked for keeps none.
insert into public.packages (user_id, tracking_number, label, carrier)
values ('19000000-0000-0000-0000-000000000013', 'GS000000000004', 'Stored earlier', 'gls-es');
set local role service_role;
do $$
declare answer jsonb;
begin
  answer := public.create_one_off_parcel('CA000000000005', 'cacesa', null, null, repeat('e', 64));
  if answer#>>'{package,carrier}' is distinct from 'cacesa' then
    raise exception 'One-off CACESA carrier was lost';
  end if;
  answer := public.create_one_off_parcel('GS000000000006', 'gls-es', null, '08000', repeat('d', 64));
  if answer#>>'{package,carrier}' is distinct from 'gls-es' then
    raise exception 'One-off GLS Spain carrier was lost';
  end if;
end;
$$;
rollback;
