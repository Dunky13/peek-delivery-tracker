-- A scraper release's re-check of a parcel is recorded as its own trigger, not as a refresh.

alter table public.tracking_sync_attempts
  drop constraint if exists tracking_sync_attempts_trigger_check,
  add constraint tracking_sync_attempts_trigger_check check (trigger in ('package', 'scheduled', 'release'));
