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
\echo '   carriers: no carrier known; adapters: the adapter refuses, fails or half-answers the number, or gave no direct'
\echo '   answer in 30 days; dormant: not checked for 24 h; none: the carrier answers and the provider history is kept;'
\echo '   delivery-tracker: its adapter answers other parcels and was not asked for these'
\echo '   could_take: the carrier that answered or a provider names, else the one detection names for an unfiled parcel'
with direct as (
  select distinct source_carrier as carrier
  from public.tracking_sync_attempts
  where started_at >= now() - interval '30 days' and outcome in ('updated', 'unchanged')
    and source_carrier is not null and source_carrier not in ('unknown', 'intl-post')
), parcels as (
  -- The summary names a carrier once one answers; routing keeps a provider's naming before that.
  select p.carrier, coalesce(nullif(p.carrier_data->>'discovered_carrier', ''),
           nullif(p.carrier_data->'routing'->>'discovered_carrier', ''), d.carrier, p.carrier) as target,
         p.carrier_data->>'tracking_provider' as provider, p.tracking_number, p.created_at, p.last_synced_at,
         p.carrier_data->>'carrier_answered' = 'true' as answered, p.carrier_data->'routing' as routing
  from public.packages p
  -- An unfiled parcel's support case keeps what today's detection names for its number.
  left join lateral (
    select c.detection_carrier as carrier
    from public.tracking_support_cases c
    where c.tracking_number = p.tracking_number and p.carrier in ('unknown', 'intl-post')
      and c.detection_confidence = 'high' and c.detection_carrier not in ('unknown', 'intl-post')
    order by c.last_seen desc
    limit 1
  ) d on true
  where p.carrier_data->>'tracking_provider' is not null and p.archived_at is null
    and coalesce(p.current_stage, '') not in ('delivered', 'returned')
), reasons as (
  select p.*, p.routing->'failures'->p.target as failure
  from parcels p
), lanes as (
  select r.*,
         case when r.target in ('unknown', 'intl-post') then 'no carrier known'
              when r.answered then 'carrier answered in part'
              when r.failure->>'user_error' = 'carrier:invalid_input' then 'adapter refuses the number'
              when r.failure is not null then 'adapter ' || coalesce(r.failure->>'kind', 'failed')
              when r.target not in (select carrier from direct) then 'no direct answer in 30 days'
              when r.routing->>'confirmed_carrier' = r.target then 'carrier answers, history kept'
              when r.last_synced_at < now() - interval '24 hours' then 'not checked for 24 h'
              else 'carrier not asked' end as why
  from reasons r
)
select l.carrier, l.target as could_take, l.provider,
       case when l.why = 'no carrier known' then 'carriers'
            when l.why = 'carrier answers, history kept' then 'none'
            when l.why = 'not checked for 24 h' then 'dormant'
            when l.why = 'carrier not asked' then 'delivery-tracker'
            else 'adapters' end as lane,
       l.why,
       count(*) filter (where l.created_at >= :since) as new, count(*) as parcels,
       array_to_string((array_agg(distinct private.tracking_number_pattern(l.tracking_number)))[1:3], '; ') as patterns
from lanes l
group by 1, 2, 3, 4, 5
order by parcels desc, could_take, provider;
