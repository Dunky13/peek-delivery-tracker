import 'server-only';
import { routingState } from './trackingRouting';
import { isRecord, type JsonObject } from './types';

/**
 * A number nobody has seen yet is checked hourly for this long after it was
 * added, then every six hours. A one-off lookup then leaves the schedule.
 */
export const UNSEEN_HOURLY_MS = 6 * 60 * 60 * 1_000;

/**
 * How long ago a parcel was added when no carrier or provider has answered
 * for its number yet: no carrier identified or recognised, no history and
 * nothing asked of the user. Null once one has.
 */
export function unseenFor(parcel: JsonObject, now: Date): number | null {
  if (!['unknown', 'intl-post'].includes(String(parcel.carrier)) || String(parcel.current_stage ?? 'pending') !== 'pending') return null;
  const data = isRecord(parcel.carrier_data) ? parcel.carrier_data : {};
  const routing = routingState(parcel);
  if (data.original_carrier || data.universal_input || routing.last_success_at || routing.last_event_at
    || routing.confirmed_carrier || routing.discovered_carrier || routing.input_needed || routing.provider_input_needed) return null;
  const added = Date.parse(String(parcel.created_at ?? ''));
  return Number.isFinite(added) ? Math.max(0, now.getTime() - added) : 0;
}

/**
 * A one-off lookup that left the schedule before any carrier or provider answered for
 * its number. Only opening its link, or the re-check after a scraper release, checks it again.
 */
export function leftScheduleUnseen(parcel: JsonObject, now: Date): boolean {
  const unseen = parcel.one_off === true ? unseenFor(parcel, now) : null;
  return unseen !== null && unseen >= UNSEEN_HOURLY_MS;
}
