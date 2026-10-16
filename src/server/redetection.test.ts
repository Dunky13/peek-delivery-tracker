import { expect, it } from 'vitest';
import { rerouteCarrier } from './redetection';
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
  expect(rerouteCarrier(parcel({ tracking_number: 'MY1234567890US' }, { reported_carriers: ['Mayi Yinfu', 'DHL eCommerce'] })))
    .toBe('mayiyinfu');
  // No provider has answered for it yet: its check asks them about that carrier.
  expect(rerouteCarrier(parcel({ tracking_number: 'MY1234567890US' }, { tracking_provider: undefined }))).toBe('mayiyinfu');
  // A parcel filed under a carrier keeps it.
  expect(rerouteCarrier(parcel({ carrier: 'dhl', tracking_number: 'MY1234567890US' }, { routing: { failures: { dhl: { kind: 'not_found' } } } })))
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

it('points a parcel a provider tracks back to its own carrier when that carrier was never asked', () => {
  const filed = { carrier: 'royal-mail', tracking_number: 'RR123456785GB' };
  expect(rerouteCarrier(parcel(filed))).toBe('royal-mail');
  expect(rerouteCarrier(parcel(filed, { routing: { failures: { 'royal-mail': { kind: 'transport' } } } }))).toBeNull();
  // The carrier answers it directly.
  expect(rerouteCarrier(parcel(filed, { tracking_provider: undefined }))).toBeNull();
});

it.each<[string, JsonObject, JsonObject]>([
  ['routed with the current rules', {}, { routing: { rules: catalogRules() } }],
  ['delivered', { current_stage: 'delivered' }, {}],
  ['returned', { current_stage: 'returned' }, {}],
  ['corrected from another carrier', {}, { original_carrier: 'dhl' }],
  ['whose carrier already failed', {}, { routing: { failures: { ups: { kind: 'not_found' } } } }],
  ['whose carrier was probed', {}, { routing: { candidate_probes: { ups: { count: 1, retry_at: '2026-09-10T11:00:00Z' } } } }],
  ['whose carrier is confirmed', {}, { routing: { confirmed_carrier: 'ups' } }],
])('leaves alone a parcel %s', (_name, values, data) => {
  expect(rerouteCarrier(parcel(values, data))).toBeNull();
});
