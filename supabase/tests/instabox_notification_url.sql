\set ON_ERROR_STOP on
begin;
insert into auth.users (id, email) values ('19000000-0000-0000-0000-000000000018', 'instabox-notification-test@example.test');
select set_config('request.jwt.claim.sub', '19000000-0000-0000-0000-000000000018', true);
set local role authenticated;
do $$
declare
  parcel public.packages;
  notification text := 'https://track.instabox.com/sv/IB9990000001/locker-to-locker-recipient?authCode=synthetic-notification-code';
begin
  parcel := test_support.add_parcel('IB9990000001', 'Instabox fixture', 'instabox', notification);
  if parcel.tracking_url <> notification then raise exception 'Instabox notification was not saved'; end if;
  parcel := test_support.add_parcel('IB9990000002', 'Instabox without notification', 'instabox');
  if parcel.tracking_url is not null then raise exception 'Instabox invented a notification URL'; end if;
  perform public.change_owned_package_carrier(parcel.id, 'instabox',
    'https://track.instabox.com/sv-SE/IB9990000002?c=synthetic-notification-code');
  if (select tracking_url from public.packages where id = parcel.id) is null then
    raise exception 'Instabox legacy notification was not saved';
  end if;
  begin
    perform test_support.add_parcel('IB9990000003', 'Wrong parcel notification', 'instabox', notification);
    raise exception 'Instabox accepted a notification for another parcel';
  exception when sqlstate '22023' then null;
  end;
  begin
    perform public.change_owned_package_carrier(parcel.id, 'instabox',
      'https://example.test/sv/IB9990000002?authCode=synthetic-notification-code');
    raise exception 'Instabox accepted a different notification host';
  exception when sqlstate '22023' then null;
  end;
  begin
    perform public.change_owned_package_carrier(parcel.id, 'instabox',
      'https://track.instabox.com/sv/IB9990000002?authCode=synthetic-notification-code&authCode=another-synthetic-code');
    raise exception 'Instabox accepted duplicate verification codes';
  exception when sqlstate '22023' then null;
  end;
  perform public.change_owned_package_carrier(parcel.id, 'dsv');
  if (select tracking_url from public.packages where id = parcel.id) is not null then
    raise exception 'The Instabox notification followed the parcel to another carrier';
  end if;
end;
$$;
rollback;
