\set ON_ERROR_STOP on
begin;
insert into auth.users (id, email) values ('19000000-0000-0000-0000-000000000024', 'forwarder-carriers-test@example.test');
select set_config('request.jwt.claim.sub', '19000000-0000-0000-0000-000000000024', true);
set local role authenticated;
do $$
declare
  parcel public.packages;
  carrier_id text;
  index integer := 0;
begin
  foreach carrier_id in array array[
    '17feia', 'celeritas', 'dhlink', 'geodis-pl', 'gzyl', 'hywl',
    'jhgj', 'jrt', 'ktd', 'swiftx', 'thhy', 'tsjy'
  ] loop
    index := index + 1;
    parcel := test_support.add_parcel('FWD' || lpad(index::text, 9, '0'), 'Forwarder fixture', carrier_id);
    if parcel.carrier <> carrier_id then raise exception '% was lost on creation', carrier_id; end if;
  end loop;
  perform public.change_owned_package_carrier(parcel.id, '17feia');
  if (select carrier from public.packages where id = parcel.id) <> '17feia' then
    raise exception 'Carrier change to 17FEIA failed';
  end if;
  -- They ask for no postcode.
  begin
    perform test_support.add_parcel('FWD900000001', 'With a postcode', 'swiftx', null, '75001');
    raise exception 'A SwiftX postcode was accepted';
  exception when sqlstate '22023' then null;
  end;
  -- Paack tracks without its postcode too, and still checks one that is given.
  parcel := test_support.add_parcel('PK000000000000000001', 'Paack without a postcode', 'paack');
  if parcel.dpd_postcode is not null then raise exception 'Paack invented a postcode'; end if;
  perform public.change_owned_package_carrier(parcel.id, 'paack', null, '1234 567');
  if (select dpd_postcode from public.packages where id = parcel.id) <> '1234567' then
    raise exception 'Paack postcode was not saved on a carrier change';
  end if;
  perform public.change_owned_package_carrier(parcel.id, 'paack');
  if (select dpd_postcode from public.packages where id = parcel.id) is not null then
    raise exception 'Paack postcode could not be removed';
  end if;
  begin
    perform test_support.add_parcel('PK000000000000000002', 'Malformed postcode', 'paack', null, '12--345');
    raise exception 'A malformed Paack postcode was accepted';
  exception when sqlstate '22023' then null;
  end;
end;
$$;
rollback;
