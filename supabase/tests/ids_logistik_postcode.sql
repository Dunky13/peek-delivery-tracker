\set ON_ERROR_STOP on
begin;
insert into auth.users (id, email) values ('19000000-0000-0000-0000-000000000046', 'ids-logistik-postcode-test@example.test');
select set_config('request.jwt.claim.sub', '19000000-0000-0000-0000-000000000046', true);
set local role authenticated;
do $$
declare
  parcel public.packages;
begin
  -- IDS Logistik shows a shipment only with its delivery postcode, in any country's shape.
  parcel := test_support.add_parcel('IDS00000001', 'IDS Logistik fixture', 'ids-logistik', null, ' 12345 ');
  if parcel.carrier <> 'ids-logistik' or parcel.dpd_postcode <> '12345' then
    raise exception 'IDS Logistik lost its postcode on creation';
  end if;
  perform public.change_owned_package_carrier(parcel.id, 'ids-logistik', null, 'l-1234');
  if (select dpd_postcode from public.packages where id = parcel.id) <> 'L-1234' then
    raise exception 'IDS Logistik postcode was not saved on a carrier change';
  end if;
  begin
    perform test_support.add_parcel('IDS00000002', 'Without a postcode', 'ids-logistik');
    raise exception 'IDS Logistik was accepted without a postcode';
  exception when sqlstate '22023' then null;
  end;
  begin
    perform test_support.add_parcel('IDS00000003', 'Malformed postcode', 'ids-logistik', null, '12/345');
    raise exception 'A malformed IDS Logistik postcode was accepted';
  exception when sqlstate '22023' then null;
  end;
  begin
    perform public.change_owned_package_carrier(parcel.id, 'ids-logistik', null, null);
    raise exception 'IDS Logistik lost its postcode on a carrier change';
  exception when sqlstate '22023' then null;
  end;
  perform public.change_owned_package_carrier(parcel.id, 'dsv');
  if (select dpd_postcode from public.packages where id = parcel.id) is not null then
    raise exception 'The IDS Logistik postcode followed the parcel to DSV';
  end if;
  begin
    perform public.change_owned_package_carrier(parcel.id, 'ids-logistik');
    raise exception 'A parcel moved to IDS Logistik without a postcode';
  exception when sqlstate '22023' then null;
  end;
end;
$$;
reset role;
-- An IDS Logistik parcel stored before the postcode was asked for keeps none.
insert into public.packages (user_id, tracking_number, label, carrier)
values ('19000000-0000-0000-0000-000000000046', 'IDS00000004', 'Stored earlier', 'ids-logistik');
rollback;
