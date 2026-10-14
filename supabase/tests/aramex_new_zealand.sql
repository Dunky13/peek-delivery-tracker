\set ON_ERROR_STOP on
begin;
insert into auth.users (id, email) values ('19000000-0000-0000-0000-000000000020', 'aramex-new-zealand-test@example.test');
select set_config('request.jwt.claim.sub', '19000000-0000-0000-0000-000000000020', true);
set local role authenticated;
do $$
declare
  parcel public.packages;
begin
  parcel := test_support.add_parcel('XX0000000001', 'Aramex New Zealand fixture', 'aramex-nz');
  if parcel.carrier <> 'aramex-nz' then raise exception 'Aramex New Zealand was lost on creation'; end if;
  perform public.change_owned_package_carrier(parcel.id, 'unknown');
  perform public.change_owned_package_carrier(parcel.id, 'aramex-nz');
  if (select carrier from public.packages where id = parcel.id) <> 'aramex-nz' then
    raise exception 'Carrier change to Aramex New Zealand failed';
  end if;
  -- Aramex New Zealand asks for no postcode.
  begin
    perform test_support.add_parcel('XX0000000002', 'With a postcode', 'aramex-nz', null, '6011');
    raise exception 'An Aramex New Zealand postcode was accepted';
  exception when sqlstate '22023' then null;
  end;
end;
$$;
rollback;
