-- A scraper release's re-check of a parcel is recorded as its own trigger, not as a refresh.

alter table public.tracking_sync_attempts
  drop constraint if exists tracking_sync_attempts_trigger_check,
  add constraint tracking_sync_attempts_trigger_check check (trigger in ('package', 'scheduled', 'release'));

insert into public.applied_migrations (name) values ('20261017080000_release_check_trigger') on conflict do nothing;
