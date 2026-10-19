-- When the owner changes the postcode or link of the parcel's own carrier, that carrier's
-- wait ends, so the next check asks it with the new input, as a postcode given to the
-- universal providers ends their wait for it. Its answers were to the old input.
-- A trigger rather than change_owned_package_carrier, which every carrier list redefines.

create function public.clear_carrier_wait()
returns trigger
language plpgsql
set search_path = pg_catalog
as $$
begin
  new.carrier_data := new.carrier_data #- array['routing', 'failures', new.carrier]
    #- '{routing,direct_retry_at}' #- '{routing,next_check_at}';
  return new;
end;
$$;

create trigger packages_clear_carrier_wait
  before update of tracking_url, dpd_postcode
  on public.packages
  for each row
  when (old.carrier = new.carrier and (old.tracking_url is distinct from new.tracking_url
    or old.dpd_postcode is distinct from new.dpd_postcode))
  execute function public.clear_carrier_wait();

revoke all on function public.clear_carrier_wait() from public, anon, authenticated;

insert into public.applied_migrations (name) values ('20261019053000_owner_input_clears_carrier_wait') on conflict do nothing;
