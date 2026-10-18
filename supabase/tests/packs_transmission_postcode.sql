\set ON_ERROR_STOP on
begin;
insert into auth.users (id, email) values ('19000000-0000-0000-0000-000000000047', 'packs-transmission-postcode-test@example.test');
select set_config('request.jwt.claim.sub', '19000000-0000-0000-0000-000000000047', true);
set local role authenticated;
do $$
declare
  parcel public.packages;
begin
  -- Packs and TransMission show a shipment only with its delivery postcode.
  parcel := test_support.add_parcel('PACKS00000001', 'Packs fixture', 'packs', null, ' 1234 ab ');
  if parcel.carrier <> 'packs' or parcel.dpd_postcode <> '1234 AB' then
    raise exception 'Packs lost its postcode on creation';
  end if;
  perform public.change_owned_package_carrier(parcel.id, 'transmission', null, '1234ab');
  if (select dpd_postcode from public.packages where id = parcel.id) <> '1234AB' then
    raise exception 'TransMission postcode was not saved on a carrier change';
  end if;
  begin
    perform test_support.add_parcel('PACKS00000002', 'Without a postcode', 'packs');
    raise exception 'Packs was accepted without a postcode';
  exception when sqlstate '22023' then null;
  end;
  begin
    perform test_support.add_parcel('TM00000003', 'Without a postcode', 'transmission');
    raise exception 'TransMission was accepted without a postcode';
  exception when sqlstate '22023' then null;
  end;
  begin
    perform test_support.add_parcel('PACKS00000004', 'Malformed postcode', 'packs', null, '12/34');
    raise exception 'A malformed Packs postcode was accepted';
  exception when sqlstate '22023' then null;
  end;
  begin
    perform public.change_owned_package_carrier(parcel.id, 'packs', null, null);
    raise exception 'Packs lost its postcode on a carrier change';
  exception when sqlstate '22023' then null;
  end;
  perform public.change_owned_package_carrier(parcel.id, 'dsv');
  if (select dpd_postcode from public.packages where id = parcel.id) is not null then
    raise exception 'The TransMission postcode followed the parcel to DSV';
  end if;
end;
$$;
reset role;
-- A Packs or TransMission parcel stored before the postcode was asked for keeps none.
insert into public.packages (user_id, tracking_number, label, carrier)
values ('19000000-0000-0000-0000-000000000047', 'PACKS00000005', 'Stored earlier', 'packs'),
  ('19000000-0000-0000-0000-000000000047', 'TM00000006', 'Stored earlier', 'transmission');
rollback;
