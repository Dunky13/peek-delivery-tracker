-- A universal provider's own notices were stored as scans before the scraper read them as
-- notices: ParcelsApp's check of the number's characters ("Tracking number must contain only
-- capital letters and digits"), its prompt to track on a partner's site, a drop-off place the
-- recipient booked, Postal Ninja's "Shipment parameters updated". The scraper now drops these
-- (`isNotice`, providers/shared/result.ts), so a later answer neither repeats nor replaces them.
-- This removes the universal rows in the wording that rule drops. Each removed row is kept, with
-- its receipts as they were, in private.universal_provider_notices.
create table if not exists private.universal_provider_notices (
  like public.tracking_events,
  receipts jsonb not null,
  removed_at timestamptz not null default now()
);
alter table private.universal_provider_notices enable row level security;
revoke all on private.universal_provider_notices from public, anon, authenticated;
comment on table private.universal_provider_notices is
  'Universal providers'' notices stored as scans before the scraper read them as notices, with the removed row''s receipts.';

do $$
begin
  lock table public.tracking_events in share row exclusive mode;

  create temporary table provider_notices as
  select id from public.tracking_events
  where provider_event_id like 'unknown:%'
    and description ~* ('enter .*?(?:postal|post|zip|phone)|select (?:a |the )?(?:carrier|destination country)'
      || '|no information about your (?:package|parcel|shipment)|tracking (?:is |temporarily )?unavailable'
      || '|tracking number (?:not found|is incorrect|must (?:only )?(?:contain|consist|be)\y)'
      || '|check that (?:the |your )?tracking number is correct|no tracking (?:information|data)|delivery preference'
      || '|captcha|verify (?:you|your)|enable javascript|try again later|by tapping the button'
      || '|^shipment parameters updated[.!]?$|^a preferred drop-off location was booked\y');

  insert into private.universal_provider_notices
  select event.*, jsonb_build_object(
    'push_deliveries', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from public.push_deliveries r where r.event_id = event.id),
    'native_push_deliveries', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from public.native_push_deliveries r where r.event_id = event.id),
    'parcel_link_alert_deliveries', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from public.parcel_link_alert_deliveries r where r.event_id = event.id),
    'live_activity_event_deliveries', (select coalesce(jsonb_agg(to_jsonb(r)), '[]') from public.live_activity_event_deliveries r where r.event_id = event.id),
    'delivery_emails', (select coalesce(jsonb_agg(r.id), '[]') from public.delivery_emails r where r.event_id = event.id),
    'tracking_status_observations', (select coalesce(jsonb_agg(r.observation_key), '[]') from public.tracking_status_observations r where r.sample_event_id = event.id)
  ), now()
  from public.tracking_events event join provider_notices notice on notice.id = event.id;

  delete from public.tracking_events event using provider_notices notice where event.id = notice.id;

  drop table provider_notices;
end;
$$;

insert into public.applied_migrations (name) values ('20261020233000_universal_provider_notices') on conflict do nothing;
