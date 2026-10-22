import type { CarrierResult } from 'universal-parcel-scraper';
import persistence from '../server/fixtures/persistenceResults.json';

/** Synthetic scraper responses replayed at the application's persistence boundary. */
export function carrierResult(name: keyof typeof persistence): CarrierResult {
  return structuredClone(persistence[name]) as CarrierResult;
}

/**
 * `result` without the instants the scraper deduced for its wall clocks, as it answers when it
 * cannot date them (a day alone, an impossible clock); `raw` is the adapter's answer it dated.
 */
export function undeduced(result: CarrierResult, raw: CarrierResult): CarrierResult {
  if (!result.events?.some((event) => event.time_zone_basis)) return result;
  const events = result.events.map((event) => {
    if (!event.time_zone_basis) return event;
    const local = { ...event };
    delete local.time;
    delete local.time_zone;
    delete local.time_zone_basis;
    return local;
  });
  return { ...result, last_update: raw.last_update ?? null, events };
}
