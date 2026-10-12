\set ON_ERROR_STOP on
begin;
insert into auth.users (id, email) values
 ('e8000000-0000-4000-8000-000000000001', 'budget-one@example.test'),
 ('e8000000-0000-4000-8000-000000000002', 'budget-two@example.test');
do $$
declare role_name text;
begin
  foreach role_name in array array['anon', 'authenticated'] loop
    if has_function_privilege(role_name, 'public.claim_account_tracking(uuid,text,integer)', 'EXECUTE')
        or has_function_privilege(role_name, 'public.claim_account_tracking(uuid,text,integer,integer)', 'EXECUTE')
        or has_table_privilege(role_name, 'private.account_tracking_usage', 'SELECT,INSERT,UPDATE,DELETE')
        or has_table_privilege(role_name, 'private.account_tracking_hours', 'SELECT,INSERT,UPDATE,DELETE') then
      raise exception 'Tracking budgets must be server-only';
    end if;
  end loop;
  if not has_function_privilege('service_role', 'public.claim_account_tracking(uuid,text,integer,integer)', 'EXECUTE') then
    raise exception 'The server must be able to claim tracking';
  end if;
end;
$$;
set local role service_role;
do $$
declare account_id constant uuid := 'e8000000-0000-4000-8000-000000000001';
begin
  if not public.claim_account_tracking(account_id, 'lookup', 2)
      or not public.claim_account_tracking(account_id, 'lookup', 2)
      or public.claim_account_tracking(account_id, 'lookup', 2)
      or public.claim_account_tracking(account_id, 'lookup', 2) then
    raise exception 'Lookup budget was not enforced';
  end if;
  if not public.claim_account_tracking(account_id, 'detection', 1)
      or public.claim_account_tracking(account_id, 'detection', 1)
      or not public.claim_account_tracking('e8000000-0000-4000-8000-000000000002', 'lookup', 2)
      or public.claim_account_tracking(account_id, 'lookup', 0) then
    raise exception 'Budgets must be independent and support disabling work';
  end if;
end;
$$;
reset role;
update private.account_tracking_usage set day = day - 1;
set local role service_role;
select public.claim_account_tracking('e8000000-0000-4000-8000-000000000001', 'lookup', 1) as reset_allowed \gset
\if :reset_allowed
\else
  \quit 1
\endif

-- Every account shares an hourly allowance, checked before the account's own.
reset role;
delete from private.account_tracking_usage;
insert into private.account_tracking_hours (hour, kind, count)
values (date_trunc('hour', now(), 'UTC') - interval '8 days', 'lookup', 5);
insert into private.account_tracking_usage (user_id, day, kind, count)
values ('e8000000-0000-4000-8000-000000000001', (now() at time zone 'UTC')::date - 8, 'lookup', 3);
set local role service_role;
do $$
declare
  one constant uuid := 'e8000000-0000-4000-8000-000000000001';
  two constant uuid := 'e8000000-0000-4000-8000-000000000002';
begin
  if public.claim_account_tracking(one, 'lookup', 2, 3) <> '{"allowed": true, "scope": null, "overall": 1}'
      or public.claim_account_tracking(one, 'lookup', 2, 3) <> '{"allowed": true, "scope": null, "overall": 2}'
      or public.claim_account_tracking(one, 'lookup', 2, 3) <> '{"allowed": false, "scope": "account", "overall": 2}' then
    raise exception 'The account allowance was not enforced under the hourly one';
  end if;
  if public.claim_account_tracking(two, 'lookup', 2, 3) <> '{"allowed": true, "scope": null, "overall": 3}'
      or public.claim_account_tracking(two, 'lookup', 2, 3) <> '{"allowed": false, "scope": "overall", "overall": 3}'
      or public.claim_account_tracking(one, 'lookup', 2, 3) -> 'scope' <> '"overall"' then
    raise exception 'The hourly allowance was not enforced first';
  end if;
  if public.claim_account_tracking(two, 'detection', 2, 1) -> 'allowed' <> 'true'
      or public.claim_account_tracking(two, 'detection', 0, 5) -> 'scope' <> '"account"'
      or public.claim_account_tracking(two, 'detection', 5, 0) -> 'scope' <> '"overall"' then
    raise exception 'Kinds must be counted apart and support disabling work';
  end if;
  begin
    perform public.claim_account_tracking(one, 'lookup', 2, -1);
    raise exception 'A negative hourly allowance was accepted' using errcode = 'P0002';
  exception when invalid_parameter_value then null;
  end;
end;
$$;
reset role;
do $$
declare
  this_hour constant timestamptz := date_trunc('hour', now(), 'UTC');
  today constant date := (now() at time zone 'UTC')::date;
begin
  if (select count from private.account_tracking_hours where hour = this_hour and kind = 'lookup') <> 3
      or (select count from private.account_tracking_hours where hour = this_hour and kind = 'detection') <> 1
      or (select count from private.account_tracking_usage
        where user_id = 'e8000000-0000-4000-8000-000000000001' and day = today and kind = 'lookup') <> 2
      or (select count from private.account_tracking_usage
        where user_id = 'e8000000-0000-4000-8000-000000000002' and day = today and kind = 'lookup') <> 1
      or (select count from private.account_tracking_usage
        where user_id = 'e8000000-0000-4000-8000-000000000002' and day = today and kind = 'detection') <> 1 then
    raise exception 'A refused claim was counted';
  end if;
  if exists (select from private.account_tracking_hours where hour < this_hour - interval '7 days')
      or exists (select from private.account_tracking_usage where day < today - 7) then
    raise exception 'Counts of over a week ago were kept';
  end if;
end;
$$;
update private.account_tracking_hours set hour = hour - interval '1 hour';
set local role service_role;
do $$ begin
  if public.claim_account_tracking('e8000000-0000-4000-8000-000000000002', 'lookup', 2, 3)
      <> '{"allowed": true, "scope": null, "overall": 1}' then
    raise exception 'A new hour must start a new hourly count';
  end if;
end; $$;

reset role;
delete from auth.users where id in ('e8000000-0000-4000-8000-000000000001', 'e8000000-0000-4000-8000-000000000002');
do $$ begin
  if exists (select from private.account_tracking_usage where user_id = 'e8000000-0000-4000-8000-000000000001') then
    raise exception 'Account deletion must remove usage';
  end if;
end; $$;
rollback;
