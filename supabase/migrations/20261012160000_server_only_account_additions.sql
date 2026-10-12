-- A parcel is added to an account only through create_account_package, which the
-- server calls once the account's daily allowance is charged. A user's own token can
-- no longer add one around it.

revoke execute on function public.create_owned_package(text, text, text, text, text) from public, anon, authenticated;

notify pgrst, 'reload schema';

insert into public.applied_migrations (name) values ('20261012160000_server_only_account_additions') on conflict do nothing;
