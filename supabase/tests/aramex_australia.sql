\set ON_ERROR_STOP on
begin;
insert into auth.users (id, email) values ('19000000-0000-0000-0000-000000000019', 'aramex-australia-test@example.test');
select set_config('request.jwt.claim.sub', '19000000-0000-0000-0000-000000000019', true);
set local role authenticated;
do $$
declare
  parcel public.packages;
begin
  parcel := test_support.add_parcel('MP0000000001', 'Aramex Australia fixture', 'aramex-au');
  if parcel.carrier <> 'aramex-au' then raise exception 'Aramex Australia was lost on creation'; end if;
  perform public.change_owned_package_carrier(parcel.id, 'unknown');
  perform public.change_owned_package_carrier(parcel.id, 'aramex-au');
  if (select carrier from public.packages where id = parcel.id) <> 'aramex-au' then
    raise exception 'Carrier change to Aramex Australia failed';
  end if;
  -- Aramex Australia asks for no postcode.
  begin
    perform test_support.add_parcel('MP0000000002', 'With a postcode', 'aramex-au', null, '2000');
    raise exception 'An Aramex Australia postcode was accepted';
  exception when sqlstate '22023' then null;
  end;
end;
$$;
rollback;
