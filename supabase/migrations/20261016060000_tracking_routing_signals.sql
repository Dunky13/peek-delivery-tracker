-- What a check learnt that the catalog, detection or the adapters could act on: a provider
-- naming a carrier the catalog lacks, a carrier correction detection did not expect, a
-- carrier detection neither names nor offers first tracking the parcel, and a carrier
-- served by a provider for want of an adapter. Each opened a Sentry issue; they are kept
-- here instead, one row per signal, carrier, subject and number, for the hourly review.
create table public.tracking_routing_signals (
  id uuid primary key default gen_random_uuid(),
  signal text not null,
  -- The parcel's carrier when the signal fired.
  carrier text not null,
  -- What it is about: the carrier the provider named, the carrier the parcel moved to,
  -- the carrier that confirmed it, or the carrier without an adapter.
  subject text not null,
  tracking_number text not null,
  package_id uuid references public.packages(id) on delete set null,
  last_attempt_id uuid,
  count integer not null default 1,
  first_seen timestamptz not null default now(),
  last_seen timestamptz not null default now(),
  reviewed_at timestamptz,
  review_note text,
  constraint tracking_routing_signals_signal_check check (signal in (
    'carrier_coverage_discovered', 'carrier_auto_swapped', 'carrier_mismatch_confirmed', 'direct_support_opportunity')),
  constraint tracking_routing_signals_labels_check check (
    length(carrier) between 1 and 100 and length(subject) between 1 and 100
    and length(tracking_number) between 1 and 64
    and (review_note is null or length(review_note) between 1 and 500)),
  constraint tracking_routing_signals_count_check check (count >= 1 and first_seen <= last_seen),
  constraint tracking_routing_signals_key unique (signal, carrier, subject, tracking_number)
);
create index tracking_routing_signals_first_seen_idx on public.tracking_routing_signals (first_seen desc);
create index tracking_routing_signals_last_seen_idx on public.tracking_routing_signals (last_seen);
alter table public.tracking_routing_signals enable row level security;
revoke all on public.tracking_routing_signals from public, anon, authenticated;
grant select, insert, update, delete on public.tracking_routing_signals to service_role;

-- A check's signals, written once it completes. A repeat adds to its row's count. A parcel
-- deleted meanwhile leaves its signals without a package. Rows unseen for 90 days go.
create function public.record_tracking_routing_signals(
  p_attempt_id uuid, p_package_id uuid, p_tracking_number text, p_signals jsonb
)
returns integer language plpgsql security definer set search_path = pg_catalog as $$
declare
  number text := upper(regexp_replace(coalesce(p_tracking_number, ''), '[[:space:].-]', '', 'g'));
  parcel uuid;
  s jsonb;
  recorded integer := 0;
begin
  if length(number) not between 1 and 64 or jsonb_typeof(p_signals) <> 'array' or jsonb_array_length(p_signals) > 32 then
    raise exception 'Invalid tracking routing signals' using errcode = '22023';
  end if;
  delete from public.tracking_routing_signals where last_seen < now() - interval '90 days';
  select id into parcel from public.packages where id = p_package_id;
  for s in select value from jsonb_array_elements(p_signals) loop
    if jsonb_typeof(s) <> 'object'
        or coalesce(s->>'signal', '') not in ('carrier_coverage_discovered', 'carrier_auto_swapped',
          'carrier_mismatch_confirmed', 'direct_support_opportunity')
        or length(coalesce(s->>'carrier', '')) not between 1 and 100
        or length(coalesce(s->>'subject', '')) not between 1 and 100 then
      raise exception 'Invalid tracking routing signal' using errcode = '22023';
    end if;
    insert into public.tracking_routing_signals as stored (signal, carrier, subject, tracking_number, package_id, last_attempt_id)
    values (s->>'signal', s->>'carrier', s->>'subject', number, parcel, p_attempt_id)
    on conflict (signal, carrier, subject, tracking_number) do update set
      count = stored.count + 1, last_seen = now(), last_attempt_id = excluded.last_attempt_id,
      package_id = coalesce(excluded.package_id, stored.package_id);
    recorded := recorded + 1;
  end loop;
  return recorded;
end;
$$;
revoke all on function public.record_tracking_routing_signals(uuid,uuid,text,jsonb) from public, anon, authenticated;
grant execute on function public.record_tracking_routing_signals(uuid,uuid,text,jsonb) to service_role;

-- A number's shape without the number, as reviews show it: "MY + 10 digits + US". Runs of
-- up to three letters stay, longer ones and every digit run are counted. Clients cannot
-- reach the private schema; a read-only reviewer can.
create function private.tracking_number_pattern(p_number text)
returns text language sql immutable parallel safe set search_path = pg_catalog as $$
  select coalesce(string_agg(case
      when m.parts[1] ~ '^[0-9]' then length(m.parts[1]) || case when length(m.parts[1]) = 1 then ' digit' else ' digits' end
      when length(m.parts[1]) <= 3 then m.parts[1]
      else length(m.parts[1]) || ' letters' end, ' + ' order by m.n), '')
  from regexp_matches(upper(regexp_replace(coalesce(p_number, ''), '[^A-Za-z0-9]', '', 'g')), '[0-9]+|[A-Z]+', 'g')
    with ordinality as m(parts, n);
$$;

notify pgrst, 'reload schema';

insert into public.applied_migrations (name) values ('20261016060000_tracking_routing_signals') on conflict do nothing;
