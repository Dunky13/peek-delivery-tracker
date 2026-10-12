\set ON_ERROR_STOP on
begin;
insert into auth.users (id, email) values ('19000000-0000-0000-0000-000000000017', 'gebrueder-weiss-postcode-test@example.test');
select set_config('request.jwt.claim.sub', '19000000-0000-0000-0000-000000000017', true);
set local role authenticated;
do $$
declare
  parcel public.packages;
begin
  -- Gebrüder Weiss takes a postcode when one is given, in GLS Germany's shape.
  parcel := test_support.add_parcel('GW000000000001', 'Gebrüder Weiss fixture', 'gebrueder-weiss', null, ' 68 20 ');
  if parcel.carrier <> 'gebrueder-weiss' or parcel.dpd_postcode <> '68 20' then
    raise exception 'Gebrüder Weiss lost its postcode on creation';
  end if;
  -- It tracks without one too.
  parcel := test_support.add_parcel('GW000000000002', 'Without a postcode', 'gebrueder-weiss');
  if parcel.dpd_postcode is not null then raise exception 'Gebrüder Weiss invented a postcode'; end if;
  perform public.change_owned_package_carrier(parcel.id, 'gebrueder-weiss', null, 'a-6923');
  if (select dpd_postcode from public.packages where id = parcel.id) <> 'A-6923' then
    raise exception 'Gebrüder Weiss postcode was not saved on a carrier change';
  end if;
  begin
    perform test_support.add_parcel('GW000000000003', 'Malformed postcode', 'gebrueder-weiss', null, '69/23');
    raise exception 'A malformed Gebrüder Weiss postcode was accepted';
  exception when sqlstate '22023' then null;
  end;
  perform public.change_owned_package_carrier(parcel.id, 'dsv');
  if (select dpd_postcode from public.packages where id = parcel.id) is not null then
    raise exception 'The Gebrüder Weiss postcode followed the parcel to DSV';
  end if;
end;
$$;
rollback;
