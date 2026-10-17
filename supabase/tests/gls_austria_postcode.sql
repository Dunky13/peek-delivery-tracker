\set ON_ERROR_STOP on
begin;
insert into auth.users (id, email) values ('19000000-0000-0000-0000-000000000045', 'gls-austria-postcode-test@example.test');
select set_config('request.jwt.claim.sub', '19000000-0000-0000-0000-000000000045', true);
set local role authenticated;
do $$
declare
  parcel public.packages;
begin
  -- GLS Austria takes a delivery postcode when one is given, in GLS Germany's shape.
  parcel := test_support.add_parcel('GLA00000001', 'GLS Austria fixture', 'gls-at', null, ' 1234 ');
  if parcel.carrier <> 'gls-at' or parcel.dpd_postcode <> '1234' then
    raise exception 'GLS Austria lost its postcode on creation';
  end if;
  -- Unlike GLS Germany, it tracks without one too.
  parcel := test_support.add_parcel('GLA00000002', 'Without a postcode', 'gls-at');
  if parcel.dpd_postcode is not null then raise exception 'GLS Austria invented a postcode'; end if;
  perform public.change_owned_package_carrier(parcel.id, 'gls-at', null, 'at 1234');
  if (select dpd_postcode from public.packages where id = parcel.id) <> 'AT 1234' then
    raise exception 'GLS Austria postcode was not saved on a carrier change';
  end if;
  begin
    perform test_support.add_parcel('GLA00000003', 'Malformed postcode', 'gls-at', null, '12/34');
    raise exception 'A malformed GLS Austria postcode was accepted';
  exception when sqlstate '22023' then null;
  end;
  perform public.change_owned_package_carrier(parcel.id, 'dsv');
  if (select dpd_postcode from public.packages where id = parcel.id) is not null then
    raise exception 'The GLS Austria postcode followed the parcel to DSV';
  end if;
end;
$$;
rollback;
