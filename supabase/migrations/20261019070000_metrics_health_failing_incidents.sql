-- "Peek checks failing across carriers" counted every open health incident, so incidents
-- with no failure left, only waiting to recover or age out, could still set it off. The
-- rule now reads the open incidents that failed in the last 3 hours, the window of its
-- checks. open_health_incidents keeps counting them all.
create or replace view metrics.health as
select
  (select count(*) from public.tracking_sync_attempts as attempt
    where attempt.started_at > now() - interval '3 hours'
      and attempt.outcome not in ('running', 'superseded')) as checks_3h,
  (select count(*) from public.tracking_sync_attempts as attempt
    where attempt.started_at > now() - interval '3 hours' and attempt.outcome = 'error') as failed_checks_3h,
  (select count(distinct attempt.configured_carrier) from public.tracking_sync_attempts as attempt
    where attempt.started_at > now() - interval '3 hours' and attempt.outcome = 'error') as failed_carriers_3h,
  (select coalesce(extract(epoch from now() - max(attempt.completed_at)), 86400)::integer
    from public.tracking_sync_attempts as attempt
    where attempt.started_at > now() - interval '1 day' and attempt.completed_at is not null)
    as seconds_since_check,
  (select coalesce(max(extract(epoch from job.completed_at - job.started_at)), 0)::integer
    from public.sync_jobs as job
    where job.kind = 'scheduled' and job.state in ('succeeded', 'failed')
      and job.completed_at > now() - interval '2 hours') as longest_scheduled_sync_2h,
  (select count(*) from public.tracking_health_incidents as incident where incident.active)
    as open_health_incidents,
  (select count(*) from public.tracking_health_incidents as incident
    where incident.active and exists (
      select 1 from public.tracking_health_samples as sample
      where sample.kind = incident.kind and sample.subject = incident.subject
        and not sample.healthy and sample.observed_at > now() - interval '3 hours'))
    as failing_health_incidents;

comment on view metrics.health is
  'How parcel checks are going: checks, failed checks and the carriers they failed for in the last 3 hours; seconds since a check last finished (86400 when none did in a day); the longest scheduled sync, in seconds, that finished in the last 2 hours; open health incidents, and those of them that failed in the last 3 hours.';

insert into public.applied_migrations (name) values ('20261019070000_metrics_health_failing_incidents') on conflict do nothing;
