-- Accounts cost nothing to make, so an allowance per account does not bound what many
-- of them add or have carriers asked about together. Every account now also shares an
-- allowance per UTC hour for each kind of work.
--
-- The three-argument claim_account_tracking stays for the server deployed before this
-- one; the server that counts the hours calls the four-argument one.

create table private.account_tracking_hours (
  hour timestamptz not null,
  kind text not null check (kind in ('lookup', 'detection')),
  count integer not null default 0 check (count >= 0),
  primary key (hour, kind)
);
alter table private.account_tracking_hours enable row level security;
revoke all on private.account_tracking_hours from public, anon, authenticated;
comment on table private.account_tracking_hours is
  'Parcel additions and carrier detections by every account together per UTC hour. Kept for seven days.';

-- Counts one use against this hour's allowance for every account and the account's own
-- for today (UTC), unless one of them is used up: then nothing is counted and `scope`
-- names it, `overall` before `account`. `overall` is how many every account together
-- has used this hour. Every claim of a kind locks the hour's row first, so all instances
-- share the limits. The first claim of an hour forgets the counts of over a week ago.
create function public.claim_account_tracking(
  p_user_id uuid,
  p_kind text,
  p_limit integer,
  p_overall_limit integer
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  this_hour constant timestamptz := date_trunc('hour', now(), 'UTC');
  today constant date := (now() at time zone 'UTC')::date;
  used_overall integer;
  claimed integer;
begin
  if p_user_id is null or p_kind is null or p_kind not in ('lookup', 'detection')
      or p_limit is null or p_limit < 0 or p_overall_limit is null or p_overall_limit < 0 then
    raise exception 'Invalid tracking allowance' using errcode = '22023';
  end if;

  insert into private.account_tracking_hours (hour, kind) values (this_hour, p_kind)
  on conflict do nothing;
  if found then
    delete from private.account_tracking_hours where hour < this_hour - interval '7 days';
    delete from private.account_tracking_usage where day < today - 7;
  end if;
  select count into used_overall from private.account_tracking_hours
  where hour = this_hour and kind = p_kind for update;
  if used_overall >= p_overall_limit then
    return jsonb_build_object('allowed', false, 'scope', 'overall', 'overall', used_overall);
  end if;

  if p_limit > 0 then
    insert into private.account_tracking_usage as usage (user_id, day, kind, count)
    values (p_user_id, today, p_kind, 1)
    on conflict (user_id, day, kind) do update set count = usage.count + 1
    where usage.count < p_limit
    returning count into claimed;
  end if;
  if claimed is null then
    return jsonb_build_object('allowed', false, 'scope', 'account', 'overall', used_overall);
  end if;

  update private.account_tracking_hours set count = count + 1 where hour = this_hour and kind = p_kind;
  return jsonb_build_object('allowed', true, 'scope', null, 'overall', used_overall + 1);
end;
$$;
revoke all on function public.claim_account_tracking(uuid, text, integer, integer) from public, anon, authenticated;
grant execute on function public.claim_account_tracking(uuid, text, integer, integer) to service_role;

notify pgrst, 'reload schema';

insert into public.applied_migrations (name) values ('20261012200000_hourly_account_tracking') on conflict do nothing;
