\set ON_ERROR_STOP on
begin;
insert into auth.users (id, email) values ('19000000-0000-0000-0000-000000000027', 'dx-arrow-xl-postcode-test@example.test');
select set_config('request.jwt.claim.sub', '19000000-0000-0000-0000-000000000027', true);
set local role authenticated;
do $$
declare
  parcel public.packages;
begin
  -- DX Freight and ArrowXL take a delivery postcode when one is given.
  parcel := test_support.add_parcel('D0000001', 'DX fixture', 'dx', null, ' ab1  2cd ');
  if parcel.carrier <> 'dx' or parcel.dpd_postcode <> 'AB1 2CD' then
    raise exception 'DX lost its postcode on creation';
  end if;
  parcel := test_support.add_parcel('AXL0000000001', 'ArrowXL fixture', 'arrow-xl', null, 'ab12 3cd');
  if parcel.carrier <> 'arrow-xl' or parcel.dpd_postcode <> 'AB12 3CD' then
    raise exception 'ArrowXL lost its postcode on creation';
  end if;
  -- They track without one too, through other sources.
  parcel := test_support.add_parcel('D0000002', 'Without a postcode', 'dx');
  if parcel.dpd_postcode is not null then raise exception 'DX invented a postcode'; end if;
  perform public.change_owned_package_carrier(parcel.id, 'arrow-xl', null, 'ab1 2cd');
  if (select dpd_postcode from public.packages where id = parcel.id) <> 'AB1 2CD' then
    raise exception 'ArrowXL postcode was not saved on a carrier change';
  end if;
  begin
    perform test_support.add_parcel('D0000003', 'Malformed postcode', 'dx', null, 'AB1/2CD');
    raise exception 'A malformed DX postcode was accepted';
  exception when sqlstate '22023' then null;
  end;
  perform public.change_owned_package_carrier(parcel.id, 'dsv');
  if (select dpd_postcode from public.packages where id = parcel.id) is not null then
    raise exception 'The ArrowXL postcode followed the parcel to DSV';
  end if;
end;
$$;
rollback;
