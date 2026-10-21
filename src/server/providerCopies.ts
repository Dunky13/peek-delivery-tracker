/**
 * Universal copies a parcel's timeline leaves out once its own carrier answers.
 *
 * A universal provider copies a carrier's scans, sometimes reworded, a zone
 * away or a few minutes off. The sync stores one row of a scan when it can
 * tell the copy from the carrier's scan (eventIdentity.ts); the copies it
 * cannot tell apart stay stored. Once a direct carrier is confirmed for the
 * parcel, its timeline leaves out such a copy: a row only a universal provider
 * wrote, at the minute of one of the carrier's scans, or in that scan's stage
 * within 15 minutes or a whole number of hours up to 14 h away. A carrier's
 * scan dated by its day, on a wall clock in no zone (YunExpress's), has no
 * instant to compare: a copy in its stage and words whose time shows that wall
 * clock, whole quarter hours away up to 14 h, is left out. A provider's step
 * the carrier never shows, such as another leg's scans, stays. Push leaves the
 * copies unannounced too (push.ts), and the Live Activity queue tells them with
 * the same rules in SQL (`public.hidden_provider_copy`): change both together.
 *
 * A row a carrier's scan took over keeps its universal identity and loses the
 * provider's name, and rows stored before rows named their provider have none
 * either: the two only differ by whether a carrier's answer holds them. Each
 * check that stores a carrier's dated scans keeps the universal rows they hold
 * and the time they cover (`direct_history`), and an unnamed universal row in
 * that time that no answer held counts as the provider's.
 */
import { DateTime } from 'luxon';
import { clockDay } from './eventIdentity';
import { isRecord, type JsonObject } from './types';

/** The `carrier_data` key of the universal rows carrier answers held and the time those answers covered. */
export const DIRECT_HISTORY = 'direct_history';

const UNIVERSAL = 'unknown';
const MINUTE_MS = 60_000;
const NEAR_MS = 15 * MINUTE_MS;
const QUARTER_HOUR_MS = 15 * MINUTE_MS;
const HOUR_MS = 60 * MINUTE_MS;
const MAX_SHIFT_MS = 14 * HOUR_MS;
const MAX_HELD = 500;

function identity(event: JsonObject): string {
  return typeof event.provider_event_id === 'string' ? event.provider_event_id : '';
}

/** Who stored a scan: the carrier its identity starts with (`unknown` for a universal provider, `app` for Peek's own rows). */
function source(event: JsonObject): string {
  const id = identity(event);
  const separator = id.indexOf(':');
  return separator > 0 ? id.slice(0, separator) : '';
}

function instant(event: JsonObject): number {
  return Date.parse(String(event.occurred_at ?? ''));
}

function observed(event: JsonObject): boolean {
  return event.observed === true || event.observed_without_provider_timestamp === true
    || (isRecord(event.raw_data) && event.raw_data.observed_without_provider_timestamp === true);
}

function named(event: JsonObject): boolean {
  const name = event.universal_provider ?? (isRecord(event.raw_data) ? event.raw_data.universal_provider : undefined);
  return typeof name === 'string' && name !== '';
}

function storedHistory(data: unknown): { from: number; to: number; held: Set<string> } | null {
  const history = isRecord(data) ? data : null;
  const from = Date.parse(String(history?.from ?? ''));
  const to = Date.parse(String(history?.to ?? ''));
  if (!history || !Number.isFinite(from) || !Number.isFinite(to)) return null;
  return { from, to, held: new Set(Array.isArray(history.held) ? history.held.filter((id): id is string => typeof id === 'string') : []) };
}

/**
 * The `direct_history` a check leaves: the time its carriers' dated scans
 * cover and the universal rows they hold, with those of the parcel's earlier
 * answers whose rows are still stored. `scans` are the check's scans as they
 * were built and `persisted` the same scans with the identities they are
 * stored under. Null when the check stores no carrier's dated scan.
 */
export function directHistory(
  scans: readonly JsonObject[], persisted: readonly JsonObject[], previous: unknown, stored: readonly JsonObject[],
): JsonObject | null {
  const own = scans.flatMap((scan, index) => {
    const at = instant(scan);
    return ['', 'app', UNIVERSAL].includes(source(scan)) || observed(scan) || !Number.isFinite(at) ? [] : [{ at, id: identity(persisted[index] ?? scan) }];
  });
  if (!own.length) return null;
  const earlier = storedHistory(previous);
  const kept = new Set(stored.map(identity));
  const times = [...own.map((scan) => scan.at), ...(earlier ? [earlier.from, earlier.to] : [])];
  const held = new Set([...[...earlier?.held ?? []].filter((id) => kept.has(id)),
    ...own.map((scan) => scan.id).filter((id) => id.startsWith(`${UNIVERSAL}:`))]);
  return {
    from: new Date(Math.min(...times)).toISOString(),
    to: new Date(Math.max(...times)).toISOString(),
    held: [...held].slice(-MAX_HELD),
  };
}

function wording(event: JsonObject): string {
  return String(event.description ?? '').replace(/\s+/g, ' ').trim().toLocaleLowerCase('en-US');
}

/** The wall clock of a scan dated by its day (`clockDay`), read as if in UTC; NaN for any other scan. */
function wallClock(event: JsonObject): number {
  return clockDay(event) ? DateTime.fromISO(String(event.local_time), { zone: 'utc' }).toMillis() : Number.NaN;
}

/**
 * Whether `copy` repeats the carrier's `scan`: at its minute, or in its stage close to it or whole
 * hours from it. A scan dated by its day is repeated in its stage and words, at its wall clock in
 * some zone.
 */
function copies(copy: JsonObject, scan: JsonObject): boolean {
  const clock = wallClock(scan);
  if (Number.isFinite(clock)) {
    const shift = Math.floor(instant(copy) / MINUTE_MS) * MINUTE_MS - Math.floor(clock / MINUTE_MS) * MINUTE_MS;
    return copy.stage === scan.stage && wording(copy) === wording(scan)
      && shift % QUARTER_HOUR_MS === 0 && Math.abs(shift) <= MAX_SHIFT_MS;
  }
  const minutes = Math.abs(Math.floor(instant(copy) / MINUTE_MS) - Math.floor(instant(scan) / MINUTE_MS)) * MINUTE_MS;
  if (minutes === 0) return true;
  return copy.stage === scan.stage
    && (Math.abs(instant(copy) - instant(scan)) <= NEAR_MS || (minutes % HOUR_MS === 0 && minutes <= MAX_SHIFT_MS));
}

/** The ids of the stored rows of `row` its timeline leaves out as a universal provider's copies of its carrier's scans. */
export function providerCopies(row: JsonObject): Set<string> {
  const data = isRecord(row.carrier_data) ? row.carrier_data : {};
  const routing = isRecord(data.routing) ? data.routing : {};
  const copied = new Set<string>();
  if (typeof routing.confirmed_carrier !== 'string' || routing.confirmed_carrier === UNIVERSAL
    || !Array.isArray(row.tracking_events)) return copied;
  const history = storedHistory(data[DIRECT_HISTORY]);
  const scans = row.tracking_events.filter(isRecord).filter((event) => !observed(event) && Number.isFinite(instant(event)));
  const universal = (event: JsonObject) => source(event) === UNIVERSAL && !history?.held.has(identity(event));
  const own = scans.filter((event) => !['', 'app'].includes(source(event)) && !universal(event));
  for (const event of scans) {
    const providerOnly = universal(event)
      && (named(event) || (history !== null && history.from <= instant(event) && instant(event) <= history.to));
    if (providerOnly && own.some((scan) => copies(event, scan))) copied.add(String(event.id));
  }
  return copied;
}
