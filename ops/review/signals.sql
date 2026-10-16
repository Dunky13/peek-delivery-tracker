-- What the review queues learnt in the last hours, grouped by type, carrier and provider,
-- each with the lane that acts on it: carriers (number formats, detection, the catalog),
-- adapters (no adapter, a failing one, unmapped wording) or delivery-tracker (the app's
-- routing). Numbers appear only as their shape. Read-only; see docs/OBSERVABILITY.md.
--
--   psql "$DATABASE_URL" -v hours=1 -f ops/review/signals.sql
\set ON_ERROR_STOP on
\set QUIET on
\if :{?hours}
\else
  \set hours 1
\endif
set session characteristics as transaction read only;
\pset null '-'
\pset footer off
\set since '(now() - make_interval(hours => :hours))'

\echo
\echo '== Routing signals: numbers seen in the window (new: first seen in it)'
select signal, carrier, subject,
       case when signal = 'direct_support_opportunity' then 'adapters' else 'carriers' end as lane,
       count(*) filter (where first_seen >= :since) as new, count(*) as numbers,
       array_to_string((array_agg(distinct private.tracking_number_pattern(tracking_number)))[1:3], '; ') as patterns
from public.tracking_routing_signals
where last_seen >= :since and reviewed_at is null
group by signal, carrier, subject
order by new desc, numbers desc, signal, carrier, subject;

\echo '== Sync anomalies: checks in the window'
select a.configured_carrier as carrier, coalesce(a.source_carrier, '-') as served_by, code as anomaly,
       -- A worker that died mid-check is the app's; every other anomaly is a carrier's or provider's answer.
       case when code = 'worker_abandoned_attempt' then 'delivery-tracker' else 'adapters' end as lane,
       count(*) as checks, count(distinct a.package_id) as parcels
from public.tracking_sync_attempts a cross join unnest(a.anomaly_codes) as code
where a.started_at >= :since
group by 1, 2, 3, 4
order by checks desc, carrier, anomaly;

\echo '== Unmapped wording: first seen in the window'
-- Wording can quote another number: runs of eight letters and digits or more with a digit are masked.
select carrier, coalesce(provider_code, '-') as code,
       left(regexp_replace(description_normalized, '\m(?=[[:alnum:]]*[0-9])[[:alnum:]]{8,}\M', '<number>', 'g'), 80) as wording,
       chosen_stage as read_as, 'adapters' as lane, count as sightings
from public.tracking_status_observations
where reviewed_at is null and first_seen >= :since
order by count desc, carrier, wording
limit 50;

\echo '== Support cases: opened in the window and still open'
select configured_carrier as carrier, detection_carrier as detected, array_to_string(reasons, ',') as reasons,
       array_to_string(array_remove(array[
         case when reasons && array['unknown_shape', 'ambiguous_shape', 'generic_postal', 'carrier_mismatch',
           'recognition_unknown', 'recognition_choice'] then 'carriers' end,
         case when 'no_direct_adapter' = any(reasons) then 'adapters' end], null), '+') as lane,
       count(*) as cases,
       array_to_string((array_agg(distinct private.tracking_number_pattern(tracking_number)))[1:3], '; ') as patterns
from public.tracking_support_cases
where first_seen >= :since and fix_status = 'open'
group by 1, 2, 3, 4
order by cases desc, carrier;

\echo '== Health incidents: notified in the window, or still failing'
select i.kind, i.subject, case when i.active then 'failing' else 'recovered' end as state,
       'adapters' as lane, to_char(i.last_notified_at, 'YYYY-MM-DD HH24:MI') as notified,
       count(s.*) filter (where not s.healthy) as failures, count(s.*) as checks
from public.tracking_health_incidents i
left join public.tracking_health_samples s
  on s.kind = i.kind and s.subject = i.subject and s.observed_at >= :since
where i.last_notified_at >= :since or i.active or i.pending is not null
group by i.kind, i.subject, i.active, i.last_notified_at
order by i.active desc, i.last_notified_at desc;

\echo '== Unfinished parcels a provider tracks, by the carrier that could take them (new: added in the window)'
\echo '   carriers: no carrier known; adapters: no direct answer for that carrier in 30 days;'
\echo '   delivery-tracker: its adapter answers other parcels, so why these stay with a provider'
with direct as (
  select distinct source_carrier as carrier
  from public.tracking_sync_attempts
  where started_at >= now() - interval '30 days' and outcome in ('updated', 'unchanged')
    and source_carrier is not null and source_carrier not in ('unknown', 'intl-post')
), parcels as (
  select p.carrier, coalesce(nullif(p.carrier_data->>'discovered_carrier', ''), p.carrier) as target,
         p.carrier_data->>'tracking_provider' as provider, p.tracking_number, p.created_at
  from public.packages p
  where p.carrier_data->>'tracking_provider' is not null and p.archived_at is null
    and coalesce(p.current_stage, '') not in ('delivered', 'returned')
)
select p.carrier, p.target as could_take, p.provider,
       case when p.target in ('unknown', 'intl-post') then 'carriers'
            when p.target in (select carrier from direct) then 'delivery-tracker'
            else 'adapters' end as lane,
       count(*) filter (where p.created_at >= :since) as new, count(*) as parcels,
       array_to_string((array_agg(distinct private.tracking_number_pattern(p.tracking_number)))[1:3], '; ') as patterns
from parcels p
group by 1, 2, 3, 4
order by parcels desc, could_take, provider;
