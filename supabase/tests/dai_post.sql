\set ON_ERROR_STOP on
begin;
insert into auth.users (id, email) values ('19000000-0000-0000-0000-000000000018', 'dai-post-test@example.test');
select set_config('request.jwt.claim.sub', '19000000-0000-0000-0000-000000000018', true);
set local role authenticated;
do $$
declare
  parcel public.packages;
begin
  parcel := test_support.add_parcel('NZC000000001', 'DAI Post fixture', 'dai-post');
  if parcel.carrier <> 'dai-post' then raise exception 'DAI Post was lost on creation'; end if;
  perform public.change_owned_package_carrier(parcel.id, 'unknown');
  perform public.change_owned_package_carrier(parcel.id, 'dai-post');
  if (select carrier from public.packages where id = parcel.id) <> 'dai-post' then
    raise exception 'Carrier change to DAI Post failed';
  end if;
  -- DAI Post asks for no postcode.
  begin
    perform test_support.add_parcel('NZC000000002', 'With a postcode', 'dai-post', null, '1010');
    raise exception 'A DAI Post postcode was accepted';
  exception when sqlstate '22023' then null;
  end;
end;
$$;
rollback;
