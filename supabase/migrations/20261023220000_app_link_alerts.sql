-- The iPhone app's notifications for one parcel link, for people without an
-- account: an alert holds an APNs device token in place of a browser's push
-- subscription, and is otherwise the same alert. Built on
-- 20261002120000_parcel_sharing, the last that defined the table, its view and
-- its functions.

alter table public.parcel_link_alerts
  alter column endpoint drop not null,
  alter column p256dh drop not null,
  alter column auth drop not null,
  add column apns_token text,
  add column apns_environment text,
  add constraint parcel_link_alerts_channel_check check (
    (endpoint is not null and p256dh is not null and auth is not null
      and apns_token is null and apns_environment is null)
    or (endpoint is null and p256dh is null and auth is null
      and apns_token is not null and apns_environment is not null)
  ),
  add constraint parcel_link_alerts_apns_token_check check (
    apns_token is null or (
      char_length(apns_token) between 32 and 512
      and char_length(apns_token) % 2 = 0
      and apns_token ~ '^[0-9a-f]+$'
    )
  ),
  add constraint parcel_link_alerts_apns_environment_check check (
    apns_environment is null or apns_environment in ('development', 'production')
  );

create unique index parcel_link_alerts_link_id_apns_token_key
  on public.parcel_link_alerts (link_id, apns_token)
  where apns_token is not null;

comment on table public.parcel_link_alerts is
  'Browser push subscriptions and iPhone app device tokens for one parcel link, kept until the parcel is delivered, the browser or iPhone unsubscribes or the link goes. Service role only.';

-- account_endpoint now also marks an alert on an iPhone the parcel's owner
-- already gets the app's account notifications on.
create or replace view public.pending_parcel_link_alerts
with (security_invoker = true) as
select
  alert.id as alert_id,
  alert.link_id,
  alert.endpoint,
  alert.p256dh,
  alert.auth,
  alert.locale,
  alert.preset,
  alert.owner,
  alert.failures,
  link.gift,
  event.id as event_id,
  event.package_id,
  event.stage,
  event.location,
  event.occurred_at,
  event.created_at as event_created_at,
  package.current_stage as package_stage,
  package.expected_delivery,
  (
    package.expected_delivery is not null
    and package.expected_delivery_changed_at is not null
    and package.expected_delivery_changed_at >= event.created_at
  ) as expected_delivery_changed,
  (
    event.raw_data -> 'observed_without_provider_timestamp' is distinct from 'true'::jsonb
    and coalesce(event.raw_data ->> 'time' ~ '[T ][0-9]{2}:[0-9]{2}', false)
  ) as event_has_time,
  (
    exists (
      select 1 from public.push_subscriptions as own
      where own.user_id = package.user_id
        and own.endpoint = alert.endpoint
        and own.disabled_at is null
    )
    or exists (
      select 1 from public.native_push_devices as own
      where own.user_id = package.user_id
        and own.token = alert.apns_token
        and own.disabled_at is null
    )
  ) as account_endpoint,
  alert.apns_token,
  alert.apns_environment
from public.parcel_link_alerts as alert
join public.parcel_links as link on link.id = alert.link_id
join public.packages as package on package.id = link.package_id
join public.tracking_events as event
  on event.package_id = package.id
 and event.created_at > alert.created_at
 and (event.provider_event_id is null or event.provider_event_id not like 'app:%')
 and event.stage <> 'pending'
left join public.parcel_link_alert_deliveries as delivery
  on delivery.alert_id = alert.id
 and delivery.event_id = event.id
where delivery.event_id is null
  and (link.shared or alert.owner);

revoke all on public.pending_parcel_link_alerts from public, anon, authenticated;
grant select on public.pending_parcel_link_alerts to service_role;

-- Turns on an alert in the iPhone app for a link, or updates the one its
-- iPhone already has. Answers as add_parcel_link_alert does, and shares its
-- limit of ten alerts from viewers and ten from the owner. The application
-- has validated the token.
create function public.add_parcel_link_app_alert(
  p_link_id text,
  p_owner_key_hash text,
  p_token text,
  p_environment text,
  p_locale text,
  p_preset text
)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  link public.parcel_links;
  is_owner boolean;
begin
  -- One alert at a time per link, so the count below holds.
  select * into link from public.parcel_links where id = p_link_id for update;
  if not found or public.parcel_link_forget_at(link) <= now() then return null; end if;
  is_owner := coalesce(link.owner_key_hash = p_owner_key_hash, false);
  if not link.shared and not is_owner then return 'stopped'; end if;
  if exists (
    select 1 from public.packages
    where id = link.package_id and current_stage in ('delivered', 'returned')
  ) then
    return 'finished';
  end if;

  update public.parcel_link_alerts
  set apns_environment = p_environment, locale = p_locale, preset = p_preset,
    owner = owner or is_owner, failures = 0
  where link_id = link.id and apns_token = p_token;
  if found then return 'updated'; end if;

  if (
    select count(*) from public.parcel_link_alerts where link_id = link.id and owner = is_owner
  ) >= 10 then
    return 'full';
  end if;
  insert into public.parcel_link_alerts (link_id, apns_token, apns_environment, locale, preset, owner)
  values (link.id, p_token, p_environment, p_locale, p_preset, is_owner);
  return 'added';
end;
$$;

-- Turns an iPhone's alert off. Knowing the token is the right to do so: only
-- the iPhone and the server know it.
create function public.remove_parcel_link_app_alert(p_link_id text, p_token text)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.parcel_link_alerts where link_id = p_link_id and apns_token = p_token;
  return found;
end;
$$;

revoke all on function public.add_parcel_link_app_alert(text, text, text, text, text, text) from public, anon, authenticated;
revoke all on function public.remove_parcel_link_app_alert(text, text) from public, anon, authenticated;
grant execute on function public.add_parcel_link_app_alert(text, text, text, text, text, text) to service_role;
grant execute on function public.remove_parcel_link_app_alert(text, text) to service_role;

insert into public.applied_migrations (name) values ('20261023220000_app_link_alerts') on conflict do nothing;
