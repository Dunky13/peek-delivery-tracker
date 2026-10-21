import { describe, expect, it } from 'vitest';
import type { CarrierResult } from 'universal-parcel-scraper';
import { carrierMovedAt, showsDelivery, withoutDisputedDelivery } from './disputedDelivery';

// Wording and clocks are invented. Both carriers read local clocks: BRT's catalog zone is UTC, SEUR's Europe/Madrid.
const provider = (delivered: string): CarrierResult => ({ status: 'delivered', current_stage: 'delivered', last_status_text: 'Delivered',
  delivered_at: delivered, last_update: delivered, events: [
    { time: delivered, description: 'Delivered', stage: 'delivered' },
    { time: '2026-10-15T17:13:00Z', description: 'Processed', stage: 'in_transit' },
  ] });
const own = (...events: CarrierResult['events'] & object): CarrierResult => ({ status: 'in_transit', current_stage: 'in_transit',
  last_status_text: 'Delivered by airline', events });

describe('a delivery the parcel\'s own carrier disputes', () => {
  it('goes when the carrier read the same scan as another stage', () => {
    const answer = own({ local_time: '2026-10-15T20:00:00', description: 'Delivered by airline', stage: 'in_transit' });
    expect(withoutDisputedDelivery(provider('2026-10-15T20:00:00Z'), 'unknown', 'brt', answer)).toEqual({
      status: 'in_transit', current_stage: 'in_transit', current_stage_source: undefined, last_status_text: 'Delivered by airline',
      last_update: '2026-10-15T20:00:00Z', events: [{ time: '2026-10-15T17:13:00Z', description: 'Processed', stage: 'in_transit' }],
    });
  });

  it('stands when the carrier last moved the parcel before it, in the carrier\'s zone', () => {
    // 09:53 in Madrid is 07:53 UTC, before the delivery at 08:30 UTC.
    const answer = own({ local_time: '2026-10-20T09:53:00', description: 'En reparto', stage: 'out_for_delivery' });
    expect(withoutDisputedDelivery(provider('2026-10-20T08:30:00Z'), 'unknown', 'seur', answer)).toBeNull();
    expect(withoutDisputedDelivery(provider('2026-10-20T07:30:00Z'), 'unknown', 'seur', answer)).not.toBeNull();
  });

  it('stands when the carrier\'s newer scan has no stage, or the carrier shows a delivery', () => {
    const unread = own({ local_time: '2026-10-20T20:00:00', description: 'Entregado', stage: 'pending' },
      { local_time: '2026-10-20T07:00:00', description: 'En reparto', stage: 'out_for_delivery' });
    expect(carrierMovedAt('seur', unread)).toBe(Date.parse('2026-10-20T05:00:00Z'));
    expect(withoutDisputedDelivery(provider('2026-10-20T18:00:00Z'), 'unknown', 'seur', unread)).toBeNull();
    const delivered = own({ local_time: '2026-10-21T10:00:00', description: 'Consegnata', stage: 'delivered' });
    expect(showsDelivery(delivered)).toBe(true);
    expect(withoutDisputedDelivery(provider('2026-10-20T18:00:00Z'), 'unknown', 'brt', delivered)).toBeNull();
  });

  it('stands when a delivery scan has no date to compare', () => {
    const answer = own({ local_time: '2026-10-21T10:00:00', description: 'In viaggio', stage: 'in_transit' });
    const undated = { ...provider('2026-10-20T18:00:00Z'), events: [{ description: 'Delivered', stage: 'delivered' }] };
    expect(withoutDisputedDelivery(undated, 'unknown', 'brt', answer)).toBeNull();
  });
});
