import { expect, it } from 'vitest';
import { rerouteAskable, rerouteCarrier } from './redetection';
import { catalogRules } from './trackingRouting';
import type { JsonObject } from './types';

const routing = { version: 1, configured_carrier: 'unknown', failures: {}, probe_cursor: 0, discovery_cursor: 0, rules: 'older' };
const parcel = (values: JsonObject, data: JsonObject = {}): JsonObject => ({
  carrier: 'unknown', tracking_number: '1Z999AA10123456784', current_stage: 'in_transit', ...values,
  carrier_data: { tracking_provider: 'ParcelsApp', ...data, routing: { ...routing, ...data.routing as JsonObject } },
});

it('points an unknown parcel to the carrier its number is now detected as', () => {
  expect(rerouteCarrier(parcel({}))).toBe('ups');
  // Without a provider's history too: the carrier's own adapter is asked.
  expect(rerouteCarrier(parcel({}, { tracking_provider: undefined }))).toBe('ups');
});

// A synthetic number no rule claims and no carrier's recognition is asked about.
const UNCLAIMED = 'ABCD0000000001CN';

it('points an unknown parcel to a carrier a provider named, read with the current aliases', () => {
  expect(rerouteCarrier(parcel({ tracking_number: UNCLAIMED }, { reported_carriers: ['UPS'] }))).toBe('ups');
  // A hint the parcel already holds is asked on its next check anyway.
  expect(rerouteCarrier(parcel({ tracking_number: UNCLAIMED },
    { reported_carriers: ['UPS'], routing: { discovered_carrier: 'ups' } }))).toBeNull();
});

it('points a parcel filed under no carrier to a carrier without an adapter of its own', () => {
  expect(rerouteCarrier(parcel({ tracking_number: 'JMX000000000001' }, { reported_carriers: ['J&T Express Mexico', 'Estafeta'] })))
    .toBe('j-and-t-mx');
  // No provider has answered for it yet: its check asks them about that carrier.
  expect(rerouteCarrier(parcel({ tracking_number: 'JMX000000000001' }, { tracking_provider: undefined }))).toBe('j-and-t-mx');
  // A parcel filed under a carrier keeps it.
  expect(rerouteCarrier(parcel({ carrier: 'dhl', tracking_number: 'JMX000000000001' }, { routing: { failures: { dhl: { kind: 'not_found' } } } })))
    .toBeNull();
});

it('points an unknown parcel to the first carrier its check would ask again, asked before or not', () => {
  const now = Date.parse('2026-09-10T12:00:00Z');
  const probe = (retry: string) => ({ count: 3, retry_at: retry });
  const unseen = (data: JsonObject) => parcel({ tracking_number: '1234567891', current_stage: 'pending' }, { tracking_provider: undefined, ...data });
  expect(rerouteCarrier(unseen({}), 'newer', now)).toBe('dhl-express');
  // A release may have taught its adapter the number since it was asked.
  expect(rerouteCarrier(unseen({ routing: { candidate_probes: { 'dhl-express': probe('2026-09-10T08:00:00Z') } } }), 'newer', now))
    .toBe('dhl-express');
  // One still waiting is asked when its wait is over, and the next one now.
  expect(rerouteCarrier(unseen({ routing: { candidate_probes: { 'dhl-express': probe('2026-09-10T18:00:00Z') } } }), 'newer', now))
    .toBe('relais-colis');
  // Not for a parcel filed under a carrier.
  expect(rerouteCarrier(parcel({ carrier: 'dhl', tracking_number: '1234567891' }, { routing: { failures: { dhl: { kind: 'not_found' } } } }),
    'newer', now)).toBeNull();
});

it('asks an unknown parcel\'s detected carrier again once its wait is over, asked before or not', () => {
  const now = Date.parse('2026-09-10T12:00:00Z');
  const failed = (retry: string) => parcel({}, { routing: { failures: { ups: { kind: 'rate_limited', count: 1, retry_at: retry } } } });
  expect(rerouteCarrier(failed('2026-09-10T11:00:00Z'), 'newer', now)).toBe('ups');
  expect(rerouteCarrier(failed('2026-09-10T13:00:00Z'), 'newer', now)).toBeNull();
});

it('points a parcel a provider tracks back to its own carrier when that carrier was never asked', () => {
  const filed = { carrier: 'royal-mail', tracking_number: 'RR123456785GB' };
  expect(rerouteCarrier(parcel(filed))).toBe('royal-mail');
  expect(rerouteCarrier(parcel(filed, { routing: { failures: { 'royal-mail': { kind: 'transport' } } } }))).toBeNull();
  // The carrier answers it directly.
  expect(rerouteCarrier(parcel(filed, { tracking_provider: undefined }))).toBeNull();
});

it('points a parcel a provider tracks back to its own carrier when only recognition asked it before it was filed', () => {
  const filed = { carrier: 'royal-mail', tracking_number: 'RR123456785GB' };
  const probes = { candidate_probes: { 'royal-mail': { count: 1, retry_at: '2999-01-01T00:00:00Z' } } };
  expect(rerouteCarrier(parcel(filed, { routing: probes }))).toBe('royal-mail');
  expect(rerouteCarrier(parcel(filed, { routing: { ...probes, confirmed_carrier: 'royal-mail' } }))).toBeNull();
});

it('points a parcel a provider dates back to its own carrier once the catalog dates that carrier\'s scans', () => {
  // Tianhui Hengyuan's scans are dated now; BRT's clocks are still local.
  const answered = (carrier: string, tracking_number: string) => parcel({ carrier, tracking_number }, {
    tracking_provider: '17TRACK', carrier_answered: true,
    direct_local_history: { carrier, number: tracking_number, events: [] },
    routing: { configured_carrier: carrier, confirmed_carrier: carrier, confirmed_number: tracking_number, preferred_provider: '17TRACK' },
  });
  expect(rerouteCarrier(answered('thhy', 'AT0000000001TH'))).toBe('thhy');
  expect(rerouteCarrier(answered('brt', '000000000001'))).toBeNull();
  // The carrier already answers it directly.
  expect(rerouteCarrier(parcel({ carrier: 'thhy', tracking_number: 'AT0000000001TH' },
    { tracking_provider: undefined, routing: { confirmed_carrier: 'thhy' } }))).toBeNull();
});

it.each<[string, JsonObject, JsonObject]>([
  ['routed with the current rules', {}, { routing: { rules: catalogRules() } }],
  ['delivered', { current_stage: 'delivered' }, {}],
  ['returned', { current_stage: 'returned' }, {}],
  ['corrected from another carrier', {}, { original_carrier: 'dhl' }],
  ['whose carrier failed and is waiting', {}, { routing: { failures: { ups: { kind: 'not_found', count: 1, retry_at: '2999-01-01T00:00:00Z' } } } }],
  ['whose carrier was probed and is waiting', {}, { routing: { candidate_probes: { ups: { count: 1, retry_at: '2999-01-01T00:00:00Z' } } } }],
  ['whose carrier is confirmed', {}, { routing: { confirmed_carrier: 'ups' } }],
])('leaves alone a parcel %s', (_name, values, data) => {
  expect(rerouteCarrier(parcel(values, data))).toBeNull();
});

it('points a parcel to a carrier that refused its number under an older release', async () => {
  const now = Date.parse('2026-09-10T12:00:00Z');
  const refusal = { kind: 'schema', count: 5, retry_at: '2026-09-09T06:00:00Z', user_error: 'carrier:invalid_input' };
  // The provider's name the parcel already holds, which its next check would ask, but there is none.
  const named = parcel({ tracking_number: UNCLAIMED }, { reported_carriers: ['UPS'],
    routing: { discovered_carrier: 'ups', failures: { ups: refusal } } });
  expect(rerouteCarrier(named, 'newer', now)).toBe('ups');
  // The filed carrier, and the one detection names for a parcel filed under another.
  expect(rerouteCarrier(parcel({ carrier: 'royal-mail', tracking_number: 'RR123456785GB' },
    { routing: { failures: { 'royal-mail': refusal } } }), 'newer', now)).toBe('royal-mail');
  expect(rerouteCarrier(parcel({ carrier: 'dhl' }, { routing: { failures: { ups: refusal } } }), 'newer', now)).toBe('ups');
  // Today's adapter refuses it too.
  expect(await rerouteAskable(named, 'newer', now, async () => true)).toBeNull();
});

it('passes over a carrier whose adapter refuses the number, until a release whose adapter may take it', async () => {
  const refuses = (refusing: string[]) => async (carrier: string) => refusing.includes(carrier);
  // A provider's name the check could not ask, and nothing else to ask.
  const named = parcel({ tracking_number: UNCLAIMED }, { reported_carriers: ['UPS'] });
  expect(await rerouteAskable(named, 'newer', Date.now(), refuses(['ups']))).toBeNull();
  expect(await rerouteAskable(named, 'newer', Date.now(), refuses([]))).toEqual({ carrier: 'ups', rank: 1 });
  // The next carrier the check would ask instead.
  const now = Date.parse('2026-09-10T12:00:00Z');
  const unseen = parcel({ tracking_number: '1234567891', current_stage: 'pending' }, { tracking_provider: undefined });
  expect(await rerouteAskable(unseen, 'newer', now, refuses(['dhl-express']))).toEqual({ carrier: 'relais-colis', rank: 2 });
  // The adapters' own checks, which send nothing: DPD France's takes no 18 digits.
  const dpd = parcel({ tracking_number: '123456789012345678' }, { reported_carriers: ['DPD France'] });
  expect(rerouteCarrier(dpd, 'newer', now)).toBe('dpd-fr');
  expect((await rerouteAskable(dpd, 'newer', now))?.carrier).not.toBe('dpd-fr');
});

it('ranks the checks most likely to change the answer first', async () => {
  const now = Date.parse('2026-09-10T12:00:00Z');
  const lead = (values: JsonObject, data: JsonObject = {}) => rerouteAskable(parcel(values, data), 'newer', now, async () => false);
  const refusal = { kind: 'schema', count: 5, retry_at: '2026-09-09T06:00:00Z', user_error: 'carrier:invalid_input' };
  // The carrier's own answer is now dated, or the number it refused may be taken now.
  expect(await lead({ carrier: 'thhy', tracking_number: 'AT0000000001TH' }, { tracking_provider: '17TRACK',
    direct_local_history: { carrier: 'thhy', number: 'AT0000000001TH', events: [] }, routing: { confirmed_carrier: 'thhy' } }))
    .toEqual({ carrier: 'thhy', rank: 0 });
  expect(await lead({}, { routing: { failures: { ups: refusal } } })).toEqual({ carrier: 'ups', rank: 0 });
  // A carrier never asked.
  expect(await lead({})).toEqual({ carrier: 'ups', rank: 1 });
  // A carrier asked again once a passing failure is over, and recognition's first guess.
  expect(await lead({}, { routing: { failures: { ups: { kind: 'rate_limited', count: 1, retry_at: '2026-09-10T11:00:00Z' } } } }))
    .toEqual({ carrier: 'ups', rank: 2 });
  expect(await lead({ tracking_number: '1234567891', current_stage: 'pending' }, { tracking_provider: undefined }))
    .toEqual({ carrier: 'dhl-express', rank: 2 });
});
