\set ON_ERROR_STOP on
begin;
insert into auth.users (id, email) values ('19000000-0000-0000-0000-000000000025', 'gls-poland-postcode-test@example.test');
select set_config('request.jwt.claim.sub', '19000000-0000-0000-0000-000000000025', true);
set local role authenticated;
do $$
declare
  parcel public.packages;
begin
  -- GLS Poland takes a delivery postcode when one is given, in GLS Germany's shape.
  parcel := test_support.add_parcel('GLP00000001', 'GLS Poland fixture', 'gls-pl', null, ' 12  345 ');
  if parcel.carrier <> 'gls-pl' or parcel.dpd_postcode <> '12 345' then
    raise exception 'GLS Poland lost its postcode on creation';
  end if;
  -- Unlike GLS Germany, it tracks without one too.
  parcel := test_support.add_parcel('GLP00000002', 'Without a postcode', 'gls-pl');
  if parcel.dpd_postcode is not null then raise exception 'GLS Poland invented a postcode'; end if;
  perform public.change_owned_package_carrier(parcel.id, 'gls-pl', null, 'pl 12-345');
  if (select dpd_postcode from public.packages where id = parcel.id) <> 'PL 12-345' then
    raise exception 'GLS Poland postcode was not saved on a carrier change';
  end if;
  begin
    perform test_support.add_parcel('GLP00000003', 'Malformed postcode', 'gls-pl', null, '12/345');
    raise exception 'A malformed GLS Poland postcode was accepted';
  exception when sqlstate '22023' then null;
  end;
  perform public.change_owned_package_carrier(parcel.id, 'dsv');
  if (select dpd_postcode from public.packages where id = parcel.id) is not null then
    raise exception 'The GLS Poland postcode followed the parcel to DSV';
  end if;
end;
$$;
rollback;
