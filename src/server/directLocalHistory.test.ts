import { expect, it } from 'vitest';

import { captureDirectLocalHistory, directLocalHistory, hasUnresolvedDirectCurrent } from './directLocalHistory';
import type { JsonObject } from './types';
import type { CarrierResult } from 'universal-parcel-scraper';

const NUMBER = 'GL000000001';
const parcel = (events: JsonObject[]): JsonObject => ({
  tracking_number: NUMBER, carrier: 'gls-it',
  carrier_data: { direct_local_history: { carrier: 'gls-it', number: NUMBER, events } },
});
const answer = (events: JsonObject[]) => ({ direct_local_history: { carrier: 'gls-it', number: NUMBER, events } });
const sorted = { description: 'Parcel sorted', location: 'Milano', stage: 'in_transit' };
const undated = { ...sorted, local_time: '2026-10-14T09:12:00' };
const dated = { ...sorted, time: '2026-10-14T09:12:00+02:00' };
// GLS gives the sender's registration a date and no time: no answer dates it.
const registered = { description: 'Created by the sender', stage: 'registered', local_time: '2026-10-13' };

it('drops a scan kept on its wall clock once an answer dates it', () => {
  const merged = directLocalHistory(parcel([undated, registered]), answer([dated, registered]));
  expect(merged?.events).toEqual([dated, registered]);
});

it('leaves out the undated copies an archive already holds beside the dated scan', () => {
  expect(directLocalHistory(parcel([dated, undated, registered]), {})?.events).toEqual([dated, registered]);
});

it('keeps an undated scan no dated one holds', () => {
  const elsewhere = { ...undated, location: 'Bologna' };
  const otherCode = { ...undated, provider_code: 'SORT' };
  // Not a wall clock a zone shows at the dated scan's instant.
  const otherMinute = { ...undated, local_time: '2026-10-14T09:20:00' };
  const otherDay = { ...registered, local_time: '2026-10-16' };
  const events = [dated, elsewhere, otherCode, otherMinute, otherDay];
  expect(directLocalHistory(parcel(events), {})?.events).toEqual(events);
});

it('keeps copies two scans could be, or two copies of one scan', () => {
  // A quarter of an hour apart, both wall clocks can show 09:12+02:00.
  const twoCopies = [dated, undated, { ...undated, local_time: '2026-10-14T09:27:00' }];
  expect(directLocalHistory(parcel(twoCopies), {})?.events).toEqual(twoCopies);
  // The same words an hour later: either scan shows 09:12 in some zone.
  const twoScans = [dated, { ...dated, time: '2026-10-14T09:12:00+01:00' }, undated];
  expect(directLocalHistory(parcel(twoScans), {})?.events).toEqual(twoScans);
});

it('keeps the carrier\'s group beside its code, and takes it from the next answer for a scan kept without one', () => {
  const collected = { description: 'Collected at the sender', location: 'Madrid', provider_code: 'GO002', local_time: '2026-10-14T09:12:00' };
  const captured = captureDirectLocalHistory('seur', 'SEUR0000000001', { events: [{ ...collected, provider_group: 'RECOGIDA', point: { latitude: 0, longitude: 0 } }] });
  expect(captured.events).toEqual([{ ...collected, provider_group: 'RECOGIDA' }]);
  const kept = { tracking_number: 'SEUR0000000001', carrier: 'seur',
    carrier_data: { direct_local_history: { carrier: 'seur', number: 'SEUR0000000001', events: [collected] } } };
  expect(directLocalHistory(kept, { direct_local_history: captured })?.events).toEqual([{ ...collected, provider_group: 'RECOGIDA' }]);
});

it('leaves no current scan to date when the carrier gives its day alone no clock by design', () => {
  // BRT dates its delivery round by the day alone, after a depot scan on Rome's clock; the wording is invented.
  const round: CarrierResult = { status: 'out_for_delivery', current_stage: 'out_for_delivery', last_update: null, last_update_local: '2026-10-14', events: [
    { local_time: '2026-10-14', description: 'Out for delivery', stage: 'out_for_delivery' },
    { time: '2026-10-14T07:40:00+02:00', local_time: '2026-10-14T07:40:00', description: 'Arrived at the depot', stage: 'in_transit' },
  ] };
  expect(hasUnresolvedDirectCurrent('brt', round)).toBe(false);
  // GLS Italy's scans normally carry a clock: a provider may still date the day it gives alone.
  expect(hasUnresolvedDirectCurrent('gls-it', round)).toBe(true);
  // A wall clock no zone settles, or provider text, is still for a provider to date.
  for (const event of [{ local_time: '2026-10-13T18:00:00' }, { provider_time_text: '13/10 18:00' }]) {
    expect(hasUnresolvedDirectCurrent('brt', { ...round, events: [...round.events!, { ...event, description: 'Departed', stage: 'in_transit' }] })).toBe(true);
  }
});
