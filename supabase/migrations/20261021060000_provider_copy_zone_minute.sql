-- A universal provider that reads the carrier's scans a zone away tells every
-- scan of that minute on the same clock (providerCopies.ts): its other rows of
-- the minute of a copy only whole hours from the carrier's scans are copies too,
-- in any stage. Swiss Post dates a London office's scans on Swiss time, and
-- ParcelsApp tells the departure twice, an hour from Swiss Post's scan.

-- Whether a stored row is such a copy, as providerCopies.ts tells it: on a
-- parcel with a confirmed carrier, a row only a universal provider wrote (it
-- names the provider, or lies in the time the carrier's answers covered and
-- none of them held it), at the minute of one of the carrier's scans, or in its
-- stage within 15 minutes or whole hours up to 14 h away; for a scan dated by
-- its day on a wall clock in no zone, in its stage and words at a time showing
-- that wall clock, whole quarter hours away up to 14 h; or a row of the minute
-- of the same provider's copy that is only whole hours from the carrier's scans.
create or replace function public.hidden_provider_copy(p_event_id uuid)
returns boolean
language sql
stable
set search_path = ''
as $$
  with target as (
    select
      event.package_id,
      event.occurred_at,
      coalesce(event.raw_data ->> 'universal_provider', '') as provider,
      case when pg_input_is_valid(history ->> 'from', 'timestamptz') and pg_input_is_valid(history ->> 'to', 'timestamptz')
        then history end as history
    from public.tracking_events as event
    join public.packages as package on package.id = event.package_id
    cross join lateral (select package.carrier_data -> 'direct_history' as history) as stored
    where event.id = p_event_id
      and jsonb_typeof(package.carrier_data -> 'routing' -> 'confirmed_carrier') = 'string'
      and package.carrier_data -> 'routing' ->> 'confirmed_carrier' <> 'unknown'
  ), copied as (
    -- The row and its provider's other rows of its minute, each when only a universal provider wrote it.
    select
      provider_row.id,
      provider_row.id = p_event_id as self,
      provider_row.package_id,
      provider_row.stage,
      provider_row.occurred_at,
      lower(btrim(regexp_replace(coalesce(provider_row.description, ''), '\s+', ' ', 'g'))) as wording,
      coalesce(target.history -> 'held', '[]'::jsonb) as held
    from target
    join public.tracking_events as provider_row
      on provider_row.package_id = target.package_id
     and date_trunc('minute', provider_row.occurred_at, 'UTC') = date_trunc('minute', target.occurred_at, 'UTC')
     and coalesce(provider_row.raw_data ->> 'universal_provider', '') = target.provider
    where provider_row.provider_event_id like 'unknown:%'
      and provider_row.raw_data -> 'observed_without_provider_timestamp' is distinct from 'true'::jsonb
      and not (coalesce(target.history -> 'held', '[]'::jsonb) ? provider_row.provider_event_id)
      and (target.provider <> '' or (target.history is not null
        and provider_row.occurred_at between (target.history ->> 'from')::timestamptz and (target.history ->> 'to')::timestamptz))
  ), repeated as (
    -- Each carrier scan a row repeats, and whether only whole hours from it.
    select
      copied.id,
      copied.self,
      not clock.by_day and clock.minutes_apart <> 0 and mod(clock.minutes_apart, 3600) = 0 as hours_away
    from copied
    join public.tracking_events as scan on scan.package_id = copied.package_id
    cross join lateral (select
      coalesce(btrim(scan.raw_data ->> 'time'), '') = ''
        and coalesce(scan.raw_data ->> 'local_time', '') ~ '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2})?$'
        and pg_input_is_valid(left(scan.raw_data ->> 'local_time', 10), 'date') as by_day,
      extract(epoch from date_trunc('minute', copied.occurred_at, 'UTC') - date_trunc('minute', scan.occurred_at, 'UTC')) as minutes_apart
    ) as clock
    where scan.occurred_at is not null
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
  select exists (select 1 from repeated where self)
    or (exists (select 1 from copied where self)
      and exists (select 1 from repeated where not self group by id having bool_and(hours_away)));
$$;

revoke all on function public.hidden_provider_copy(uuid) from public, anon, authenticated;
grant execute on function public.hidden_provider_copy(uuid) to service_role;

insert into public.applied_migrations (name) values ('20261021060000_provider_copy_zone_minute') on conflict do nothing;
