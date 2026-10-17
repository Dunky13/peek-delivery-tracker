\set ON_ERROR_STOP on
begin;
insert into auth.users (id, email) values ('19000000-0000-0000-0000-000000000026', 'relay-postcode-test@example.test');
select set_config('request.jwt.claim.sub', '19000000-0000-0000-0000-000000000026', true);
set local role authenticated;
do $$
declare
  parcel public.packages;
begin
  -- Relay takes a delivery postcode when one is given.
  parcel := test_support.add_parcel('RELR00000001', 'Relay fixture', 'relaytech', null, ' ab1  2cd ');
  if parcel.carrier <> 'relaytech' or parcel.dpd_postcode <> 'AB1 2CD' then
    raise exception 'Relay lost its postcode on creation';
  end if;
  -- It tracks without one too, through other sources.
  parcel := test_support.add_parcel('RELR00000002', 'Without a postcode', 'relaytech');
  if parcel.dpd_postcode is not null then raise exception 'Relay invented a postcode'; end if;
  perform public.change_owned_package_carrier(parcel.id, 'relaytech', null, 'ab12 3cd');
  if (select dpd_postcode from public.packages where id = parcel.id) <> 'AB12 3CD' then
    raise exception 'Relay postcode was not saved on a carrier change';
  end if;
  begin
    perform test_support.add_parcel('RELR00000003', 'Malformed postcode', 'relaytech', null, 'AB1/2CD');
    raise exception 'A malformed Relay postcode was accepted';
  exception when sqlstate '22023' then null;
  end;
  perform public.change_owned_package_carrier(parcel.id, 'dsv');
  if (select dpd_postcode from public.packages where id = parcel.id) is not null then
    raise exception 'The Relay postcode followed the parcel to DSV';
  end if;
end;
$$;
rollback;
