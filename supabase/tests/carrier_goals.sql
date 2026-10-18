\set ON_ERROR_STOP on
begin;

-- Grafana reads the goals' counts, never the parcels the gaps are made of.
do $$
begin
  if not has_table_privilege('metrics_reader', 'metrics.goals_daily', 'SELECT')
      or not has_table_privilege('metrics_reader', 'metrics.carrier_gaps', 'SELECT')
      or not has_table_privilege('metrics_reader', 'metrics.releases', 'SELECT') then
    raise exception 'Grafana cannot read the goals';
  end if;
  if has_table_privilege('metrics_reader', 'private.tracking_gaps', 'SELECT')
      or has_table_privilege('metrics_reader', 'metrics.goals_daily', 'INSERT')
      or has_function_privilege('metrics_reader', 'metrics.record_goals(date)', 'EXECUTE')
      or has_table_privilege('anon', 'private.tracking_gaps', 'SELECT')
      or has_table_privilege('authenticated', 'private.tracking_gaps', 'SELECT')
      or has_table_privilege('service_role', 'metrics.goals_daily', 'SELECT') then
    raise exception 'The goals are reachable beyond Grafana''s counts';
  end if;
end;
$$;

create temp table goals_before on commit drop as
select * from metrics.goals_daily where false;
do $$
begin
  perform metrics.record_goals((now() at time zone 'UTC')::date);
  insert into goals_before select * from metrics.goals_daily where day = (now() at time zone 'UTC')::date;
end;
$$;

insert into auth.users (id, email) values ('f4000000-0000-4000-8000-000000000001', 'goals@example.com');

-- direct: an account's parcel its carrier answered half an hour ago.
-- provider: a lookup ParcelsApp answered, no carrier known.
-- stale: an account's parcel its carrier last answered 30 h ago; captcha since.
-- waiting: no scan yet. finished: delivered. dormant: a lookup nobody followed for days.
-- set aside, not asked: lookups ParcelsApp answers, filed under a carrier whose answer was set
-- aside as older than the parcel, and under one that was not asked; neither part of the gap.
insert into public.packages (id, user_id, one_off, tracking_number, carrier, current_stage, sync_status, created_at, last_synced_at, carrier_data)
values
  ('f4000000-0000-4000-8000-00000000000a', 'f4000000-0000-4000-8000-000000000001', false, 'GOALS0001', 'la-poste',
    'in_transit', 'ok', now() - interval '3 days', now() - interval '30 minutes', '{}'),
  ('f4000000-0000-4000-8000-00000000000b', null, true, 'GOALS0002', 'unknown',
    'in_transit', 'ok', now() - interval '3 days', now() - interval '3 minutes', '{"tracking_provider": "ParcelsApp"}'),
  ('f4000000-0000-4000-8000-00000000000c', 'f4000000-0000-4000-8000-000000000001', false, 'GOALS0003', 'la-poste',
    'in_transit', 'error', now() - interval '3 days', now() - interval '4 minutes',
    '{"routing": {"failures": {"la-poste": {"kind": "verification", "count": 3, "user_error": "carrier:challenge"}}}}'),
  ('f4000000-0000-4000-8000-00000000000d', null, true, 'GOALS0004', 'unknown',
    'pending', 'waiting', now() - interval '3 days', now() - interval '5 minutes', '{}'),
  ('f4000000-0000-4000-8000-00000000000e', 'f4000000-0000-4000-8000-000000000001', false, 'GOALS0005', 'la-poste',
    'delivered', 'ok', now() - interval '3 days', now() - interval '2 days', '{}'),
  ('f4000000-0000-4000-8000-00000000000f', null, true, 'GOALS0006', 'la-poste',
    'in_transit', 'ok', now() - interval '3 days', now() - interval '3 days', '{}'),
  ('f4000000-0000-4000-8000-000000000010', null, true, 'GOALS0007', 'la-poste',
    'in_transit', 'ok', now() - interval '3 days', now() - interval '6 minutes',
    '{"tracking_provider": "ParcelsApp", "routing": {"set_aside": {"la-poste": {"checked_at": "2026-10-08T11:00:00Z",
      "newest": "2026-10-07T23:01:00Z", "watermark": "2026-10-08T05:46:00Z", "count": 1}}}}'),
  ('f4000000-0000-4000-8000-000000000011', null, true, 'GOALS0008', 'la-poste',
    'in_transit', 'ok', now() - interval '3 days', now() - interval '6 minutes', '{"tracking_provider": "ParcelsApp"}');

insert into public.tracking_sync_attempts (id, package_id, trigger, configured_carrier, source_carrier, outcome, selected_stage, anomaly_codes, started_at, completed_at)
values
  ('f4000000-0000-4000-8000-0000000000a1', 'f4000000-0000-4000-8000-00000000000a', 'scheduled', 'la-poste', 'la-poste',
    'updated', 'in_transit', '{provider_clock_offset}', now() - interval '2 minutes', now() - interval '2 minutes'),
  ('f4000000-0000-4000-8000-0000000000b1', 'f4000000-0000-4000-8000-00000000000b', 'scheduled', 'unknown', 'unknown',
    'unchanged', 'in_transit', '{}', now() - interval '3 minutes', now() - interval '3 minutes'),
  ('f4000000-0000-4000-8000-0000000000c1', 'f4000000-0000-4000-8000-00000000000c', 'scheduled', 'la-poste', 'la-poste',
    'updated', 'in_transit', '{}', now() - interval '30 hours', now() - interval '30 hours'),
  ('f4000000-0000-4000-8000-0000000000c2', 'f4000000-0000-4000-8000-00000000000c', 'scheduled', 'la-poste', null,
    'error', null, '{}', now() - interval '4 minutes', now() - interval '4 minutes'),
  ('f4000000-0000-4000-8000-0000000000d1', 'f4000000-0000-4000-8000-00000000000d', 'scheduled', 'unknown', null,
    'waiting', 'pending', '{}', now() - interval '5 minutes', now() - interval '5 minutes'),
  ('f4000000-0000-4000-8000-0000000000e1', 'f4000000-0000-4000-8000-00000000000e', 'scheduled', 'la-poste', 'la-poste',
    'updated', 'delivered', '{}', now() - interval '2 days', now() - interval '2 days'),
  ('f4000000-0000-4000-8000-0000000000f1', 'f4000000-0000-4000-8000-00000000000f', 'scheduled', 'la-poste', 'la-poste',
    'updated', 'in_transit', '{}', now() - interval '3 days', now() - interval '3 days');
insert into public.tracking_sync_steps (attempt_id, sequence, step, status, details)
values ('f4000000-0000-4000-8000-0000000000b1', 6, 'complete', 'succeeded', '{"support_provider": "ParcelsApp"}');

-- A universal copy of the direct parcel's scan at the same second, and one readers judged.
insert into public.tracking_events (package_id, stage, description, occurred_at, provider_event_id, raw_data, created_at)
values
  ('f4000000-0000-4000-8000-00000000000a', 'in_transit', 'Colis en transit', now() - interval '1 hour', 'goals-scan',
    '{"stage_source": "carrier_map"}', now() - interval '2 minutes'),
  ('f4000000-0000-4000-8000-00000000000a', 'in_transit', 'In transit', now() - interval '1 hour', 'goals-copy',
    '{"stage_source": "none", "universal_provider": "17TRACK"}', now() - interval '3 minutes');
insert into public.parcel_feedback (id, tracking_number, carrier, answer, reasons, asked, via, app, locale, shown, created_at)
values
  ('f4000000-0000-4000-8000-0000000000aa', 'GOALS0001', 'la-poste', 'right', '{}', 'page', 'account', 'web', 'fr', '{}',
    now() - interval '1 day'),
  ('f4000000-0000-4000-8000-0000000000ab', 'GOALS0002', 'unknown', 'wrong', '{status}', 'page', 'link', 'web', 'fr', '{}',
    now() - interval '1 day');

-- Each goal counts the parcels it is about: answered directly, by a provider, gone stale,
-- shown with a copy; the waiting, delivered and dormant parcels count nowhere.
do $$
declare
  before goals_before;
  after metrics.goals_daily;
begin
  select * into strict before from goals_before;
  perform metrics.record_goals((now() at time zone 'UTC')::date);
  select * into strict after from metrics.goals_daily where day = (now() at time zone 'UTC')::date;

  if after.parcels - before.parcels <> 4
      or after.parcels_own_adapter - before.parcels_own_adapter <> 3
      or after.parcels_parcelsapp - before.parcels_parcelsapp <> 1
      or after.parcels_other_provider <> before.parcels_other_provider then
    raise exception 'Parcels were not counted by who answered them last: % then %', before, after;
  end if;
  if after.followed_parcels - before.followed_parcels <> 3 or after.stale_parcels - before.stale_parcels <> 1 then
    raise exception 'Only the followed parcel without an answer for 30 h is stale: % then %', before, after;
  end if;
  if after.copied_parcels - before.copied_parcels <> 1 then
    raise exception 'The universal copy shown beside its carrier''s scan was missed: % then %', before, after;
  end if;
  if after.feedback_7d - before.feedback_7d <> 2 or after.feedback_right_7d - before.feedback_right_7d <> 1 then
    raise exception 'Readers'' answers were miscounted: % then %', before, after;
  end if;
  if after.scans - before.scans <> 2 or after.scans_unmapped - before.scans_unmapped <> 1 then
    raise exception 'Scans no map read were miscounted: % then %', before, after;
  end if;
  -- Late enough in the day that the checks of the last minutes are today's.
  if (now() at time zone 'UTC')::time >= time '00:10' and (
      after.checks - before.checks <> 4 or after.failed_checks - before.failed_checks <> 1
      or after.answered_checks - before.answered_checks <> 2 or after.direct_checks - before.direct_checks <> 1
      or after.anomalous_checks - before.anomalous_checks <> 1) then
    raise exception 'Today''s checks were miscounted: % then %', before, after;
  end if;
end;
$$;

-- The gap is the provider's parcel, filed under no carrier, and the parcel stuck on a
-- captcha: the direct, waiting and dormant ones are not part of it.
do $$
begin
  if (select array_agg(row(could_take, reason, lane)::text order by could_take)
      from private.tracking_gaps where gap and tracking_number like 'GOALS%')
      is distinct from array[row('la-poste', 'verification or captcha', 'captcha')::text,
        row('unknown', 'no carrier known', 'carriers')::text] then
    raise exception 'The gap''s parcels were misread: %', (select array_agg(row(tracking_number, could_take, reason, lane, gap)::text)
      from private.tracking_gaps where tracking_number like 'GOALS%');
  end if;
  if not exists (select 1 from metrics.carrier_gaps where carrier = 'la-poste' and reason = 'verification or captcha'
      and lane = 'captcha' and parcels >= 1)
      or exists (select 1 from metrics.carrier_gaps where cumulative_percent > 100)
      or (select max(cumulative_percent) from metrics.carrier_gaps) <> 100 then
    raise exception 'The carriers'' share of the gap was miscounted';
  end if;
end;
$$;

-- The review tells a carrier whose answer was set aside as older than the parcel from one not asked.
do $$
begin
  if (select array_agg(row(tracking_number, why, reason, lane, gap is true)::text order by tracking_number)
      from private.tracking_gaps where tracking_number in ('GOALS0007', 'GOALS0008'))
      is distinct from array[
        row('GOALS0007', 'answer older than parcel', 'answer set aside as older', 'delivery-tracker', false)::text,
        row('GOALS0008', 'carrier not asked', 'carrier not asked', 'delivery-tracker', false)::text] then
    raise exception 'A set-aside answer was not told from a carrier not asked: %', (select array_agg(row(tracking_number, why, reason, lane, gap)::text)
      from private.tracking_gaps where tracking_number in ('GOALS0007', 'GOALS0008'));
  end if;
end;
$$;

-- A pass records today's goals at most every ten minutes.
do $$
declare
  first_as_of timestamptz;
begin
  update metrics.goals_daily set as_of = now() - interval '11 minutes' where day = (now() at time zone 'UTC')::date;
  perform public.record_usage_metrics();
  first_as_of := (select as_of from metrics.goals_daily where day = (now() at time zone 'UTC')::date);
  if first_as_of <> now() then
    raise exception 'Goals recorded 11 minutes ago were not recorded again';
  end if;
  update metrics.goals_daily set checks = 999999 where day = (now() at time zone 'UTC')::date;
  perform public.record_usage_metrics();
  if (select checks from metrics.goals_daily where day = (now() at time zone 'UTC')::date) <> 999999 then
    raise exception 'Goals just recorded were recorded again';
  end if;
  if (select as_of from metrics.goals_daily where day = (now() at time zone 'UTC')::date - 1)
      <> (now() at time zone 'UTC')::date::timestamp at time zone 'UTC' then
    raise exception 'Yesterday''s goals were not counted as of its end';
  end if;
end;
$$;

-- A scraper release is marked where it changes; a server restarted on it is not.
insert into public.tracking_review_runs (version, started_at, lease_until) values
  ('universal-parcel-scraper@9.1.0 app@aaaaaaaaaaaa', now() - interval '3 hours', now()),
  ('universal-parcel-scraper@9.1.0 app@bbbbbbbbbbbb', now() - interval '2 hours', now()),
  ('universal-parcel-scraper@9.2.0 app@cccccccccccc', now() - interval '1 hour', now());
do $$
begin
  if (select array_agg(row(scraper, app, scraper_changed)::text order by time) from metrics.releases
      where time >= now() - interval '2 hours')
      is distinct from array[row('9.1.0', 'bbbbbbbbbbbb', false)::text, row('9.2.0', 'cccccccccccc', true)::text] then
    raise exception 'Releases were misread: %', (select array_agg(row(scraper, app, scraper_changed)::text) from metrics.releases);
  end if;
end;
$$;

-- Grafana's role reads the counts, not the parcels behind them.
set local role metrics_reader;
select day, parcels, stale_parcels from metrics.goals_daily order by day desc limit 1;
select rank, carrier, reason, lane, parcels, cumulative_percent from metrics.carrier_gaps order by rank limit 1;
select time, scraper, scraper_changed from metrics.releases order by time desc limit 1;
do $$
begin
  perform 1 from private.tracking_gaps;
  raise exception 'Grafana''s role read the parcels of the gap';
exception when insufficient_privilege then null;
end;
$$;
reset role;

rollback;
