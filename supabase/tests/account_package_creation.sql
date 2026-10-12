\set ON_ERROR_STOP on
begin;
insert into auth.users (id, email) values ('19000000-0000-0000-0000-000000000015', 'account-package-test@example.test');
insert into auth.users (id, email, is_anonymous) values ('19000000-0000-0000-0000-000000000016', null, true);
set local role service_role;
do $$
declare
  parcel public.packages;
begin
  -- The server adds a parcel for the account it names, with the checks a user's own call has.
  parcel := public.create_account_package('19000000-0000-0000-0000-000000000015', 'XD000000000011', 'Account fixture', 'xdp', null, ' ab1  2cd ');
  if parcel.user_id <> '19000000-0000-0000-0000-000000000015' or parcel.dpd_postcode <> 'AB1 2CD' then
    raise exception 'The parcel was not added to the named account';
  end if;
  if auth.uid() is not null then raise exception 'The named account outlived the call'; end if;
  begin
    perform public.create_account_package('19000000-0000-0000-0000-000000000016', 'XD000000000012', 'Guest', 'xdp');
    raise exception 'A guest account was given a parcel';
  exception when sqlstate '42501' then null;
  end;
end;
$$;
reset role;
do $$
begin
  if has_function_privilege('authenticated', 'public.create_account_package(uuid,text,text,text,text,text)', 'EXECUTE')
      or has_function_privilege('anon', 'public.create_account_package(uuid,text,text,text,text,text)', 'EXECUTE') then
    raise exception 'A user can add parcels without the server';
  end if;
end;
$$;
rollback;
