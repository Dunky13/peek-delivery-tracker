-- A universal provider's copy of a carrier's scan at the scan's instant, in another stage
-- (17TRACK's exception for UPS's out for delivery), reads as a second, alarming scan beside the
-- carrier's row. The sync now leaves such copies out, and a carrier's next answer absorbs one
-- stored before (eventIdentity.ts); this removes those already stored, for parcels no carrier
-- answers any more too. Only a row its provider alone wrote (one that names its
-- `universal_provider`) goes, at the instant of a dated carrier row in another stage whose place
-- it does not contradict: either names no place, both name the same one, or they share a word of
-- at least three letters other than a country's name or code.
do $$
begin
  lock table public.tracking_events in share row exclusive mode;

  delete from public.tracking_events copy
  using public.tracking_events own
  where own.package_id = copy.package_id and own.occurred_at = copy.occurred_at
    and copy.provider_event_id like 'unknown:%' and copy.raw_data ? 'universal_provider'
    and own.provider_event_id like '%:%' and split_part(own.provider_event_id, ':', 1) not in ('unknown', 'app')
    and coalesce(own.stage, '') <> '' and copy.stage is distinct from own.stage
    and coalesce(copy.raw_data->>'observed_without_provider_timestamp', '') <> 'true'
    and coalesce(own.raw_data->>'observed_without_provider_timestamp', '') <> 'true'
    and (
      btrim(coalesce(copy.location, '')) = '' or btrim(coalesce(own.location, '')) = ''
      or lower(regexp_replace(copy.location, '[^[:alnum:]]+', '', 'g')) = lower(regexp_replace(own.location, '[^[:alnum:]]+', '', 'g'))
      or exists (
        select 1 from regexp_split_to_table(lower(copy.location), '[^[:alnum:]]+') as word
        where length(word) >= 3 and word = any(regexp_split_to_array(lower(own.location), '[^[:alnum:]]+'))
          and word not in ('aus', 'aut', 'bel', 'can', 'che', 'chn', 'cze', 'deu', 'dnk', 'esp', 'fin', 'fra', 'gbr', 'grc',
            'hun', 'ind', 'irl', 'ita', 'jpn', 'lux', 'nld', 'nor', 'nzl', 'pol', 'prt', 'rou', 'swe', 'tur', 'ukr', 'usa',
            'america', 'australia', 'austria', 'belgie', 'belgique', 'belgium', 'britain', 'canada', 'china', 'czech',
            'czechia', 'danmark', 'denmark', 'deutschland', 'england', 'espana', 'finland', 'france', 'germany', 'great',
            'greece', 'hungary', 'india', 'ireland', 'italia', 'italy', 'japan', 'kingdom', 'luxembourg', 'nederland',
            'netherlands', 'norway', 'osterreich', 'oesterreich', 'österreich', 'españa', 'poland', 'polska', 'portugal', 'republic', 'romania',
            'schweiz', 'scotland', 'spain', 'states', 'suisse', 'svizzera', 'sweden', 'switzerland', 'turkey', 'ukraine',
            'united', 'wales', 'zealand')
      )
    );
end;
$$;

insert into public.applied_migrations (name) values ('20261019230000_restaged_scan_copies') on conflict do nothing;
