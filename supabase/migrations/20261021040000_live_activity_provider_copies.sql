-- A delivery-day activity starts once per stretch out for delivery: another scan
-- of the parcel in another stage starts a new stretch. A universal provider's
-- copy of the carrier's scan that the timeline leaves out (providerCopies.ts),
-- such as 17TRACK reading an out-for-delivery scan as in transit, is no new
-- stretch, so it no longer lets a second activity start.

-- Whether a stored row is such a copy, as providerCopies.ts tells it: on a
-- parcel with a confirmed carrier, a row only a universal provider wrote (it
-- names the provider, or lies in the time the carrier's answers covered and
-- none of them held it), at the minute of one of the carrier's scans, or in its
-- stage within 15 minutes or whole hours up to 14 h away; for a scan dated by
-- its day on a wall clock in no zone, in its stage and words at a time showing
-- that wall clock, whole quarter hours away up to 14 h.
create or replace function public.hidden_provider_copy(p_event_id uuid)
returns boolean
language sql
stable
set search_path = ''
as $$
  with copy as (
    select
      event.package_id,
      event.stage,
      event.occurred_at,
      lower(btrim(regexp_replace(coalesce(event.description, ''), '\s+', ' ', 'g'))) as wording,
      case when pg_input_is_valid(history ->> 'from', 'timestamptz') and pg_input_is_valid(history ->> 'to', 'timestamptz')
        then history end as history,
      event.provider_event_id,
      coalesce(event.raw_data ->> 'universal_provider', '') <> '' as named
    from public.tracking_events as event
    join public.packages as package on package.id = event.package_id
    cross join lateral (select package.carrier_data -> 'direct_history' as history) as stored
    where event.id = p_event_id
      and jsonb_typeof(package.carrier_data -> 'routing' -> 'confirmed_carrier') = 'string'
      and package.carrier_data -> 'routing' ->> 'confirmed_carrier' <> 'unknown'
      and event.occurred_at is not null
      and event.raw_data -> 'observed_without_provider_timestamp' is distinct from 'true'::jsonb
  ), provider_row as (
    select copy.*, coalesce(copy.history -> 'held', '[]'::jsonb) as held
    from copy
    where copy.provider_event_id like 'unknown:%'
  )
  select coalesce((
    select (
        not (copied.held ? copied.provider_event_id)
        and (copied.named or (copied.history is not null
          and copied.occurred_at between (copied.history ->> 'from')::timestamptz and (copied.history ->> 'to')::timestamptz))
      )
      and exists (
        select 1
        from public.tracking_events as scan
        cross join lateral (select
          coalesce(btrim(scan.raw_data ->> 'time'), '') = ''
            and coalesce(scan.raw_data ->> 'local_time', '') ~ '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2})?$'
            and pg_input_is_valid(left(scan.raw_data ->> 'local_time', 10), 'date') as by_day,
          extract(epoch from date_trunc('minute', copied.occurred_at, 'UTC') - date_trunc('minute', scan.occurred_at, 'UTC')) as minutes_apart
        ) as clock
        where scan.package_id = copied.package_id
          and scan.occurred_at is not null
          and scan.raw_data -> 'observed_without_provider_timestamp' is distinct from 'true'::jsonb
          and position(':' in coalesce(scan.provider_event_id, '')) > 1
          and split_part(scan.provider_event_id, ':', 1) <> 'app'
          and (scan.provider_event_id not like 'unknown:%' or copied.held ? scan.provider_event_id)
          and case
            when clock.by_day then
              scan.stage = copied.stage
              and lower(btrim(regexp_replace(coalesce(scan.description, ''), '\s+', ' ', 'g'))) = copied.wording
              and mod(extract(epoch from date_trunc('minute', copied.occurred_at, 'UTC')
                - date_trunc('minute', (scan.raw_data ->> 'local_time')::timestamp at time zone 'UTC', 'UTC')), 900) = 0
              and abs(extract(epoch from date_trunc('minute', copied.occurred_at, 'UTC')
                - date_trunc('minute', (scan.raw_data ->> 'local_time')::timestamp at time zone 'UTC', 'UTC'))) <= 50400
            else
              clock.minutes_apart = 0
              or (scan.stage = copied.stage and (
                abs(extract(epoch from copied.occurred_at - scan.occurred_at)) <= 900
                or (mod(clock.minutes_apart, 3600) = 0 and abs(clock.minutes_apart) <= 50400)
              ))
          end
      )
    from provider_row as copied
  ), false);
$$;

revoke all on function public.hidden_provider_copy(uuid) from public, anon, authenticated;
grant execute on function public.hidden_provider_copy(uuid) to service_role;

create or replace view public.pending_live_activity_events
with (security_invoker = true) as
select
  device.id as device_id,
  device.token as push_to_start_token,
  device.environment,
  device.locale,
  update_token.id as update_token_id,
  update_token.activity_id,
  update_token.token as update_token,
  event.id as event_id,
  event.package_id,
  package.label,
  package.carrier,
  package.expected_delivery,
  event.stage,
  event.description,
  event.location,
  event.occurred_at,
  event.created_at as event_created_at,
  coalesce(preference.timezone, 'Europe/Zurich') as timezone,
  (
    event.raw_data -> 'observed_without_provider_timestamp' is distinct from 'true'::jsonb
    and coalesce(event.raw_data ->> 'time' ~ '[T ][0-9]{2}:[0-9]{2}', false)
  ) as event_has_time
from public.live_activity_devices as device
join public.packages as package
  on package.user_id = device.user_id
join public.tracking_events as event
  on event.package_id = package.id
 and event.created_at > device.subscribed_at
 and event.provider_event_id is distinct from 'app:registered'
 and event.provider_event_id is distinct from 'app:pending'
 and event.stage <> 'pending'
left join public.live_activity_update_tokens as update_token
  on update_token.device_id = device.id
 and update_token.package_id = package.id
left join public.live_activity_event_deliveries as delivery
  on delivery.device_id = device.id
 and delivery.event_id = event.id
left join public.notification_preferences as preference
  on preference.user_id = device.user_id
where device.disabled_at is null
  and delivery.event_id is null
  and (
    (
      update_token.id is not null
      and event.created_at >= update_token.started_at
    )
    or (
      update_token.id is null
      and package.archived_at is null
      and package.current_stage = 'out_for_delivery'
      and event.stage = 'out_for_delivery'
      and package.id in (
        select candidate.id
        from public.packages as candidate
        where candidate.user_id = device.user_id
          and candidate.archived_at is null
          and candidate.current_stage = 'out_for_delivery'
        order by
          exists (
            select 1
            from public.live_activity_update_tokens as active_token
            where active_token.device_id = device.id
              and active_token.package_id = candidate.id
          ) desc,
          candidate.expected_delivery asc nulls last,
          (
            select max(candidate_event.occurred_at)
            from public.tracking_events as candidate_event
            where candidate_event.package_id = candidate.id
          ) desc nulls last,
          candidate.label asc,
          candidate.id asc
        limit 2
      )
      and not exists (
        select 1
        from public.live_activity_event_deliveries as prior_delivery
        where prior_delivery.device_id = device.id
          and prior_delivery.package_id = package.id
          and prior_delivery.delivery_kind = 'start'
          and prior_delivery.event_created_at > coalesce(
            (
              select max(reset_event.created_at)
              from public.tracking_events as reset_event
              where reset_event.package_id = package.id
                and reset_event.stage <> 'out_for_delivery'
                and reset_event.created_at < event.created_at
                and not public.hidden_provider_copy(reset_event.id)
            ),
            '-infinity'::timestamptz
          )
      )
    )
  );

revoke all on public.pending_live_activity_events from public, anon, authenticated;
grant select on public.pending_live_activity_events to service_role;

notify pgrst, 'reload schema';

insert into public.applied_migrations (name) values ('20261021040000_live_activity_provider_copies') on conflict do nothing;
