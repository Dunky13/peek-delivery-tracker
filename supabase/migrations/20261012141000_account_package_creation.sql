-- Add a parcel to an account for the server, which first charges the account's daily
-- lookup allowance. create_owned_package acts for the signed-in user; once the server
-- calls this instead, a later migration takes it away from the user's own role.

create or replace function public.create_account_package(
  p_user_id uuid,
  p_tracking_number text,
  p_label text,
  p_carrier text,
  p_tracking_url text default null,
  p_dpd_postcode text default null
)
returns public.packages
language plpgsql
security definer
set search_path = pg_catalog
as $$
declare
  created public.packages;
begin
  if p_user_id is null then
    raise exception 'A permanent account is required' using errcode = '42501';
  end if;
  -- auth.uid() reads this first: create_owned_package acts for the account named here.
  perform set_config('request.jwt.claim.sub', p_user_id::text, true);
  created := public.create_owned_package(p_tracking_number, p_label, p_carrier, p_tracking_url, p_dpd_postcode);
  perform set_config('request.jwt.claim.sub', '', true);
  return created;
end;
$$;
revoke all on function public.create_account_package(uuid, text, text, text, text, text) from public, anon, authenticated;
grant execute on function public.create_account_package(uuid, text, text, text, text, text) to service_role;

notify pgrst, 'reload schema';

insert into public.applied_migrations (name) values ('20261012141000_account_package_creation') on conflict do nothing;
