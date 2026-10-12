-- Supabase grants every function and sequence a migration creates in public to anon,
-- authenticated and service_role. These kept a grant their migration never meant to
-- give. None of them did anything for such a caller: a trigger function cannot be called
-- directly, and the account functions act only on the caller's own parcels.

-- Trigger functions run as triggers only.
revoke execute on function public.add_initial_tracking_event() from public, anon, authenticated;
revoke execute on function public.clear_live_activity_state_on_rebind() from public, anon, authenticated;
revoke execute on function public.enforce_live_activity_delivery_owner() from public, anon, authenticated;
revoke execute on function public.enforce_live_activity_token_owner() from public, anon, authenticated;
revoke execute on function public.mark_expected_delivery_change() from public, anon, authenticated;
revoke execute on function public.preserve_live_activity_start_epoch() from public, anon, authenticated;
revoke execute on function public.preserve_live_activity_subscription_epoch() from public, anon, authenticated;
revoke execute on function public.preserve_native_push_subscription_epoch() from public, anon, authenticated;

-- Account functions are for a signed-in user.
revoke execute on function public.delete_owned_archived_package(uuid) from public, anon;
revoke execute on function public.delete_owned_package(uuid) from public, anon;
revoke execute on function public.rename_owned_package(uuid, text) from public, anon;
revoke execute on function public.set_owned_package_archived(uuid, boolean) from public, anon;
revoke execute on function public.set_owned_package_notifications_muted(uuid, boolean) from public, anon;

-- Invitations are numbered by the server.
revoke all on sequence public.friend_invites_id_seq from public, anon, authenticated;

-- A revoke leaves a grant made by another role in place without failing.
do $$
declare
  kept text;
begin
  select string_agg(p.proname, ', ' order by p.proname) into kept
  from pg_proc p
  where p.pronamespace = 'public'::regnamespace
    and (
      (p.prorettype = 'trigger'::regtype
        and (has_function_privilege('anon', p.oid, 'execute') or has_function_privilege('authenticated', p.oid, 'execute')))
      or (p.proname in (
          'delete_owned_archived_package', 'delete_owned_package', 'rename_owned_package',
          'set_owned_package_archived', 'set_owned_package_notifications_muted'
        ) and has_function_privilege('anon', p.oid, 'execute'))
    );
  if kept is not null then
    raise exception 'Still granted to a client role: %', kept;
  end if;
  if has_sequence_privilege('anon', 'public.friend_invites_id_seq', 'usage')
      or has_sequence_privilege('authenticated', 'public.friend_invites_id_seq', 'usage') then
    raise exception 'friend_invites_id_seq is still granted to a client role';
  end if;
end;
$$;

notify pgrst, 'reload schema';

insert into public.applied_migrations (name) values ('20261012190000_revoke_default_grants') on conflict do nothing;
