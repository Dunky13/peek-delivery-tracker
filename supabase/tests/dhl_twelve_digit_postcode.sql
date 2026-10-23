\set ON_ERROR_STOP on
begin;
insert into auth.users (id, email) values ('19000000-0000-0000-0000-000000000049', 'dhl-postcode-test@example.test');
select set_config('request.jwt.claim.sub', '19000000-0000-0000-0000-000000000049', true);
set local role authenticated;
do $$
declare
  parcel public.packages;
  letter public.packages;
begin
  -- DHL shows a twelve-digit parcel it holds among others under the number for its postal code.
  parcel := test_support.add_parcel('340000000001', 'DHL fixture', 'dhl', null, ' a-1010  ');
  if parcel.carrier <> 'dhl' or parcel.dpd_postcode <> 'A-1010' then
    raise exception 'DHL lost its postal code on creation';
  end if;
  if (test_support.add_parcel('340000000002', 'Without a postal code', 'dhl')).dpd_postcode is not null then
    raise exception 'DHL invented a postal code';
  end if;
  begin
    perform test_support.add_parcel('340000000003', 'Malformed postal code', 'dhl', null, '10/10');
    raise exception 'A malformed DHL postal code was accepted';
  exception when sqlstate '22023' then null;
  end;
  begin
    perform test_support.add_parcel('LF000000005DE', 'Not a twelve-digit number', 'dhl', null, '10115');
    raise exception 'DHL took a postal code for a number of another shape';
  exception when sqlstate '22023' then null;
  end;
  letter := test_support.add_parcel('LF000000006DE', 'Letter', 'dhl');
  begin
    perform public.change_owned_package_carrier(letter.id, 'dhl', null, '10115');
    raise exception 'DHL took a postal code for a number of another shape on a carrier change';
  exception when sqlstate '22023' then null;
  end;
  perform public.change_owned_package_carrier(parcel.id, 'dhl', null, null);
  if (select dpd_postcode from public.packages where id = parcel.id) is not null then
    raise exception 'The optional DHL postal code could not be cleared';
  end if;
  perform public.change_owned_package_carrier(parcel.id, 'dhl', null, '10115');
  if (select dpd_postcode from public.packages where id = parcel.id) <> '10115' then
    raise exception 'The DHL postal code was not saved on a carrier change';
  end if;
end;
$$;
reset role;
do $$
begin
  insert into public.packages (user_id, tracking_number, label, carrier, dpd_postcode)
  values ('19000000-0000-0000-0000-000000000049', 'JJD000000000000000001', 'Plate', 'dhl', '10115');
  raise exception 'The table took a DHL postal code for a number of another shape';
exception when check_violation then null;
end;
$$;
rollback;
