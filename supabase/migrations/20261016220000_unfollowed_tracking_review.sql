-- Support cases and routing signals outlive their parcels, for the review to learn from.
-- They go 10 days after no parcel, an account's or a lookup's, follows their number any
-- more, and 10 days after their last check: the parcel or the account was deleted, or the
-- number was checked without being saved. A parcel following the number again stops the
-- clock. The scheduled maintenance deletes them; deleting an account no longer does.
drop trigger forget_account_tracking_review on auth.users;
drop function public.forget_account_tracking_review();

alter table public.tracking_support_cases add column unfollowed_at timestamptz;
alter table public.tracking_routing_signals add column unfollowed_at timestamptz;
create index tracking_support_cases_unfollowed_idx on public.tracking_support_cases (unfollowed_at)
  where unfollowed_at is not null;
create index tracking_routing_signals_unfollowed_idx on public.tracking_routing_signals (unfollowed_at)
  where unfollowed_at is not null;
create index tracking_routing_signals_number_idx on public.tracking_routing_signals (tracking_number);
create index packages_tracking_number_idx on public.packages (tracking_number);

-- An entry written for a number no parcel follows starts its clock.
create function public.mark_unfollowed_tracking_review()
returns trigger language plpgsql security definer set search_path = pg_catalog as $$
begin
  if NEW.unfollowed_at is null
      and not exists(select 1 from public.packages where tracking_number = NEW.tracking_number) then
    NEW.unfollowed_at := now();
  end if;
  return NEW;
end;
$$;
create trigger tracking_support_cases_mark_unfollowed before insert on public.tracking_support_cases
  for each row execute function public.mark_unfollowed_tracking_review();
create trigger tracking_routing_signals_mark_unfollowed before insert on public.tracking_routing_signals
  for each row execute function public.mark_unfollowed_tracking_review();

-- The last parcel to stop following a number starts its entries' clock; a parcel following
-- it stops the clock. An account's deletion takes its parcels, so it starts the clock too.
create function public.follow_tracking_review()
returns trigger language plpgsql security definer set search_path = pg_catalog as $$
begin
  if TG_OP = 'DELETE' or (TG_OP = 'UPDATE' and OLD.tracking_number is distinct from NEW.tracking_number) then
    if not exists(select 1 from public.packages where tracking_number = OLD.tracking_number) then
      update public.tracking_support_cases set unfollowed_at = now()
      where tracking_number = OLD.tracking_number and unfollowed_at is null;
      update public.tracking_routing_signals set unfollowed_at = now()
      where tracking_number = OLD.tracking_number and unfollowed_at is null;
    end if;
  end if;
  if TG_OP <> 'DELETE' then
    update public.tracking_support_cases set unfollowed_at = null
    where tracking_number = NEW.tracking_number and unfollowed_at is not null;
    update public.tracking_routing_signals set unfollowed_at = null
    where tracking_number = NEW.tracking_number and unfollowed_at is not null;
  end if;
  return null;
end;
$$;
create trigger packages_follow_tracking_review after insert or delete or update of tracking_number on public.packages
  for each row execute function public.follow_tracking_review();

revoke all on function public.mark_unfollowed_tracking_review(), public.follow_tracking_review()
  from public, anon, authenticated;

-- Entries whose number no parcel follows today, from a number checked without saving it or a
-- parcel deleted earlier, start their clock now.
update public.tracking_support_cases as support_case set unfollowed_at = now()
where not exists(select 1 from public.packages as parcel where parcel.tracking_number = support_case.tracking_number);
update public.tracking_routing_signals as routing_signal set unfollowed_at = now()
where not exists(select 1 from public.packages as parcel where parcel.tracking_number = routing_signal.tracking_number);

-- Deletes the entries of numbers no parcel has followed for 10 days, checked last 10 days ago.
create function public.forget_unfollowed_tracking_review()
returns jsonb
language sql
security definer
set search_path = ''
as $$
  with cases as (
    delete from public.tracking_support_cases as support_case
    where support_case.unfollowed_at < pg_catalog.now() - interval '10 days'
      and support_case.last_seen < pg_catalog.now() - interval '10 days'
      and not exists(select 1 from public.packages as parcel where parcel.tracking_number = support_case.tracking_number)
    returning 1
  ), signals as (
    delete from public.tracking_routing_signals as routing_signal
    where routing_signal.unfollowed_at < pg_catalog.now() - interval '10 days'
      and routing_signal.last_seen < pg_catalog.now() - interval '10 days'
      and not exists(select 1 from public.packages as parcel where parcel.tracking_number = routing_signal.tracking_number)
    returning 1
  )
  select pg_catalog.jsonb_build_object('cases', (select pg_catalog.count(*) from cases),
    'signals', (select pg_catalog.count(*) from signals));
$$;
revoke all on function public.forget_unfollowed_tracking_review() from public, anon, authenticated;
grant execute on function public.forget_unfollowed_tracking_review() to service_role;
notify pgrst, 'reload schema';

insert into public.applied_migrations (name) values ('20261016220000_unfollowed_tracking_review') on conflict do nothing;
