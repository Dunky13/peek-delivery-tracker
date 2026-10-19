-- A reader's check names why it was queued: adding the parcel, a refresh, its link opened, or a
-- carrier or input changed. A scraper release's re-check is named too. The check log records the
-- reason as its trigger; `package` stays for the checks queued before.

alter table public.sync_jobs
  add column if not exists reason text,
  drop constraint if exists sync_jobs_reason_check,
  add constraint sync_jobs_reason_check check (
    reason is null or (kind = 'package' and reason in ('added', 'refresh', 'opened', 'changed', 'release'))
  );

alter table public.tracking_sync_attempts
  drop constraint if exists tracking_sync_attempts_trigger_check,
  add constraint tracking_sync_attempts_trigger_check check (
    trigger in ('package', 'scheduled', 'release', 'added', 'refresh', 'opened', 'changed')
  );

notify pgrst, 'reload schema';

insert into public.applied_migrations (name) values ('20261019200000_sync_check_reasons') on conflict do nothing;
