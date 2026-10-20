import { describe, expect, it } from 'vitest';
import { directHistory, providerCopies } from './providerCopies';

const scan = (id: string, source: string, occurredAt: string, extra: Record<string, unknown> = {}) => ({
  id, stage: 'in_transit', description: `Scan ${id}`, location: null, occurred_at: occurredAt,
  provider_event_id: `${source}:${id}`, ...extra,
});
const named = { universal_provider: 'ParcelsApp' };
const confirmed = { routing: { confirmed_carrier: 'posti' } };

describe('providerCopies', () => {
  it('leaves out a named provider row copying a confirmed carrier\'s scan, reworded, a zone away or minutes off', () => {
    const row = {
      carrier_data: confirmed,
      tracking_events: [
        scan('c1', 'posti', '2026-10-01T11:09:18Z'),
        scan('c2', 'posti', '2026-10-01T16:48:10Z', { stage: 'registered' }),
        scan('c3', 'posti', '2026-10-02T20:06:44Z', { stage: 'delivered' }),
        // An hour off to the minute, in its own words.
        scan('u1', 'unknown', '2026-10-01T12:09:00Z', { ...named, description: 'Your package is on its way' }),
        // Two minutes off, in the scan's stage.
        scan('u2', 'unknown', '2026-10-01T16:50:00Z', { ...named, stage: 'registered' }),
        // At the scan's minute, read as another stage.
        scan('u3', 'unknown', '2026-10-02T20:06:00Z', { ...named, stage: 'pending' }),
      ],
    };
    expect([...providerCopies(row)].sort()).toEqual(['u1', 'u2', 'u3']);
  });

  it('keeps a provider\'s own step, the carrier\'s rows and every row without a confirmed carrier', () => {
    const events = [
      scan('c1', 'posti', '2026-10-01T11:09:18Z'),
      scan('c2', 'posti', '2026-10-03T09:00:00Z'),
      // Another leg's departure, in no stage or time of the carrier's scans.
      scan('u1', 'unknown', '2026-10-02T03:15:00Z', named),
      // An hour and a half away in the same stage, and three hours away in another.
      scan('u2', 'unknown', '2026-10-01T12:39:00Z', named),
      scan('u3', 'unknown', '2026-10-01T14:09:00Z', { ...named, stage: 'customs' }),
      // Peek's own row and a sighting at a scan's minute.
      scan('a1', 'app', '2026-10-01T11:09:00Z'),
      scan('o1', 'unknown', '2026-10-01T11:09:00Z', { ...named, observed: true }),
    ];
    expect(providerCopies({ carrier_data: confirmed, tracking_events: events })).toEqual(new Set());
    const copy = scan('u4', 'unknown', '2026-10-01T11:09:00Z', named);
    expect(providerCopies({ carrier_data: confirmed, tracking_events: [...events, copy] })).toEqual(new Set(['u4']));
    expect(providerCopies({ carrier_data: {}, tracking_events: [...events, copy] })).toEqual(new Set());
    expect(providerCopies({ carrier_data: { routing: { confirmed_carrier: 'unknown' } }, tracking_events: [...events, copy] }))
      .toEqual(new Set());
  });

  it('tells an unnamed provider row from a carrier\'s by the rows the carrier\'s answers held', () => {
    const events = [
      scan('c1', 'posti', '2026-10-01T11:09:18Z'),
      // A row the carrier's scan took over, and one stored before rows named their provider.
      scan('u1', 'unknown', '2026-10-01T15:09:18Z'),
      scan('u2', 'unknown', '2026-10-01T12:09:00Z'),
      scan('c2', 'posti', '2026-10-02T09:00:00Z'),
    ];
    // Without the carrier's history, neither can be told from the carrier's.
    expect(providerCopies({ carrier_data: confirmed, tracking_events: events })).toEqual(new Set());
    const history = { from: '2026-10-01T11:09:18.000Z', to: '2026-10-02T09:00:00.000Z', held: ['unknown:u1'] };
    expect(providerCopies({ carrier_data: { ...confirmed, direct_history: history }, tracking_events: events }))
      .toEqual(new Set(['u2']));
    // Outside the time the carrier's answers covered, an unnamed row stays.
    const before = scan('u3', 'unknown', '2026-10-01T10:09:00Z');
    expect(providerCopies({ carrier_data: { ...confirmed, direct_history: history }, tracking_events: [...events, before] }))
      .toEqual(new Set(['u2']));
  });
});

describe('directHistory', () => {
  it('keeps the time a carrier\'s dated scans cover and the universal rows they hold, with the earlier answers\'', () => {
    const scans = [
      scan('c1', 'posti', '2026-10-01T11:09:18Z'),
      scan('c2', 'posti', '2026-10-02T09:00:00Z'),
      scan('c3', 'posti', '2026-10-02T10:00:00Z', { raw_data: { observed_without_provider_timestamp: true } }),
    ];
    const persisted = [{ ...scans[0], provider_event_id: 'unknown:u1' }, scans[1], scans[2]];
    const previous = { from: '2026-09-30T08:00:00.000Z', to: '2026-10-01T11:09:18.000Z', held: ['unknown:u0', 'unknown:gone'] };
    const stored = [{ provider_event_id: 'unknown:u0' }, { provider_event_id: 'unknown:u1' }];
    expect(directHistory(scans, persisted, previous, stored)).toEqual({
      from: '2026-09-30T08:00:00.000Z', to: '2026-10-02T09:00:00.000Z', held: ['unknown:u0', 'unknown:u1'],
    });
    expect(directHistory(scans, persisted, undefined, stored)).toEqual({
      from: '2026-10-01T11:09:18.000Z', to: '2026-10-02T09:00:00.000Z', held: ['unknown:u1'],
    });
  });

  it('is none for a check that stores no carrier\'s dated scan', () => {
    const universal = [scan('u1', 'unknown', '2026-10-01T11:09:18Z', named), scan('a1', 'app', '2026-10-01T10:00:00Z')];
    expect(directHistory(universal, universal, undefined, [])).toBeNull();
    expect(directHistory([], [], { from: '2026-10-01T00:00:00Z', to: '2026-10-02T00:00:00Z', held: [] }, [])).toBeNull();
  });
});
