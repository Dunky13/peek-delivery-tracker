-- Support cases and routing signals outlive a deleted parcel, for the review. Deleting an
-- account deletes those of its parcels' numbers, unless another parcel, an account's or a
-- lookup's, still follows the number. It runs before the cascade takes the parcels.
create function public.forget_account_tracking_review()
returns trigger language plpgsql security definer set search_path = pg_catalog as $$
begin
  delete from public.tracking_support_cases as support_case
  using public.packages as parcel
  where parcel.user_id = OLD.id and support_case.tracking_number = parcel.tracking_number
    and not exists(select 1 from public.packages as other
      where other.tracking_number = parcel.tracking_number and other.user_id is distinct from OLD.id);
  delete from public.tracking_routing_signals as routing_signal
  using public.packages as parcel
  where parcel.user_id = OLD.id and routing_signal.tracking_number = parcel.tracking_number
    and not exists(select 1 from public.packages as other
      where other.tracking_number = parcel.tracking_number and other.user_id is distinct from OLD.id);
  return OLD;
end;
$$;
revoke all on function public.forget_account_tracking_review() from public, anon, authenticated;
create trigger forget_account_tracking_review before delete on auth.users
  for each row execute function public.forget_account_tracking_review();

insert into public.applied_migrations (name) values ('20261016190000_forget_account_tracking_review') on conflict do nothing;
