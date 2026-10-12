\set ON_ERROR_STOP on
begin;
insert into auth.users (id, email) values ('19000000-0000-0000-0000-000000000014', 'xdp-postcode-test@example.test');
select set_config('request.jwt.claim.sub', '19000000-0000-0000-0000-000000000014', true);
set local role authenticated;
do $$
declare
  parcel public.packages;
begin
  -- XDP takes a delivery postcode when one is given, in GLS Germany's shape.
  parcel := public.create_owned_package('XD000000000001', 'XDP fixture', 'xdp', null, ' ab1  2cd ');
  if parcel.carrier <> 'xdp' or parcel.dpd_postcode <> 'AB1 2CD' then
    raise exception 'XDP lost its postcode on creation';
  end if;
  -- It tracks without one too.
  parcel := public.create_owned_package('XD000000000002', 'Without a postcode', 'xdp');
  if parcel.dpd_postcode is not null then raise exception 'XDP invented a postcode'; end if;
  perform public.change_owned_package_carrier(parcel.id, 'xdp', null, 'SW1A 1AA');
  if (select dpd_postcode from public.packages where id = parcel.id) <> 'SW1A 1AA' then
    raise exception 'XDP postcode was not saved on a carrier change';
  end if;
  begin
    perform public.create_owned_package('XD000000000003', 'Malformed postcode', 'xdp', null, 'AB/12');
    raise exception 'A malformed XDP postcode was accepted';
  exception when sqlstate '22023' then null;
  end;
  perform public.change_owned_package_carrier(parcel.id, 'whistl');
  if (select dpd_postcode from public.packages where id = parcel.id) is not null then
    raise exception 'The XDP postcode followed the parcel to Whistl';
  end if;
end;
$$;
rollback;
