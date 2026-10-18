/**
 * Stored event identity when a scan reaches the parcel more than once.
 *
 * A stored event is keyed by `provider_event_id`: the source carrier and a hash
 * of the scan's time, place and wording strings (`providerEventId` in
 * trackingSync.ts). The sync upserts on it, so a scan whose strings change gets
 * a second row, and the push views announce that row again.
 *
 * A new scan may instead take over a stored row: it gets that row's identity,
 * and the upsert updates the row in place (same row id, `created_at` and push
 * receipts), so nothing is copied or announced twice. Such a row's identity no
 * longer hashes its own strings (and a universal row's prefix no longer names
 * the source that worded it), so a repair that finds rows by recomputing
 * identities from their strings misses it.
 *
 * - The scraper opts sources into same-instant matching and declares whether
 *   their provider codes or other scan evidence must agree. A unique matching
 *   scan takes over the stored row at its instant (`sameInstantIdentities`).
 *   A policy that names the zone its source once read every wall clock in
 *   lets a scan whose wall clock now carries its own offset take over the row
 *   stored under the old label (India Post's scans abroad).
 * - A row taken over keeps its old identity while its strings follow the
 *   scan. When a later check meets the scan again, a policy that matched the
 *   old strings (AliExpress's town in brackets) no longer matches, so a scan
 *   whose source, time, place and wording equal a stored row's takes over
 *   that row whatever its identity (`restatedIdentities`).
 * - A universal provider copies a carrier's scans while the carrier's own
 *   lookup is down, sometimes only to the minute, sometimes in a zone it
 *   misread (Ship24 keeps GOFO's Pacific offset on Eastern clocks), sometimes
 *   in its own wording as well (ParcelsApp put Paack's scans two hours early). A universal copy of a stored scan is
 *   left out of the batch, and a carrier's scan takes over the universal copy
 *   stored while it was down (`sharedScans`). The other copies at its instant
 *   are absorbed: the sync deletes them, and leaves out a provider's later
 *   copy of a scan a carrier holds.
 * - A row only a universal provider has written names that provider
 *   (`UNIVERSAL_PROVIDER`), and follows the provider's clock when a scraper
 *   fix moves it. A carrier's scan writes the row without the name, so the
 *   row keeps the carrier's instant from then on.
 * - A handoff's batch carries the earlier carrier's scans too, and that
 *   carrier may relay the delivery carrier's scans in its own words. Both are
 *   stored (relayCopies.ts), but only the delivery carrier's scan takes over a
 *   universal copy (`relayedScans`).
 */
import { DateTime } from 'luxon';
import { sameInstantIdentityPolicy, trackingPlace, type SameInstantIdentityPolicy, type SameInstantScan } from 'universal-parcel-scraper/app';
import { isRecord, type JsonObject } from './types';

/**
 * The `raw_data` key that names the universal provider (`tracking_provider`)
 * whose reading a row holds, set on its scans when they are built. A carrier's
 * scan replaces the row's raw data without it, a universal scan that rewrites
 * a row without it leaves it out (`withIdentities`), and rows stored before
 * the key existed have none.
 */
export const UNIVERSAL_PROVIDER = 'universal_provider';

function providerCode(row: JsonObject): string {
  const code = row.provider_code ?? (isRecord(row.raw_data) ? row.raw_data.provider_code : undefined);
  return typeof code === 'string' ? code : '';
}

function scanEvidence(row: JsonObject): SameInstantScan {
  return {
    stage: typeof row.stage === 'string' ? row.stage : '',
    description: typeof row.description === 'string' ? row.description : '',
    location: typeof row.location === 'string' ? row.location : '',
    providerCode: providerCode(row),
  };
}

function identity(row: JsonObject): string {
  return typeof row.provider_event_id === 'string' ? row.provider_event_id : '';
}

function byInstant(rows: readonly JsonObject[]): Map<number, JsonObject[]> {
  const grouped = new Map<number, JsonObject[]>();
  for (const row of rows) {
    const instant = Date.parse(String(row.occurred_at ?? ''));
    if (!Number.isFinite(instant)) continue;
    grouped.set(instant, [...(grouped.get(instant) ?? []), row]);
  }
  return grouped;
}

/**
 * Maps the computed identity of each new scan that should update a stored row
 * in place to that row's identity. Empty unless `sourceCarrierId` opted in.
 *
 * Only a scan from `sourceCarrierId` whose own identity is not stored yet is
 * considered. It takes over a stored row at the exact same instant whose
 * identity has an allowed prefix and is not carried by any event of this
 * batch. The scan and stored row must match uniquely in both directions.
 * A required provider code can distinguish scans sharing an instant. Sources
 * without required codes or a per-scan evidence matcher still require exactly
 * one new scan and one candidate there. Ambiguous scans are inserted as before.
 *
 * A policy's `relabelledFrom` zone adds a second pass for the scans and rows
 * left, matched by `relabelled`.
 */
export function sameInstantIdentities(
  events: readonly JsonObject[],
  stored: readonly JsonObject[],
  sourceCarrierId: string,
): Map<string, string> {
  const reused = new Map<string, string>();
  const policy = sameInstantIdentityPolicy(sourceCarrierId, { supportsScanMatching: true });
  if (!policy || stored.length === 0) return reused;
  const prefixes = policy.storedSources.map((source) => `${source}:`);
  const storedIds = new Set(stored.map(identity));
  const claimed = new Set(events.map(identity));
  const unmatched = byInstant(events.filter((event) => (
    identity(event).startsWith(`${sourceCarrierId}:`) && !storedIds.has(identity(event)) && !observedOnly(event)
  )));
  const candidates = byInstant(stored.filter((row) => (
    prefixes.some((prefix) => identity(row).startsWith(prefix)) && !claimed.has(identity(row)) && !observedOnly(row)
  )));
  const matchEach = policy.requireProviderCode || (policy.matchEachScan === true && policy.matches !== undefined);
  for (const [instant, scans] of unmatched) {
    const rows = candidates.get(instant) ?? [];
    if (!matchEach && (scans.length !== 1 || rows.length !== 1)) continue;
    const matches = (scan: JsonObject, row: JsonObject) => {
      const code = providerCode(scan);
      if (policy.requireProviderCode && (!code || code.toLowerCase() === 'unknown' || code !== providerCode(row))) return false;
      return !policy.matches || policy.matches(scanEvidence(scan), scanEvidence(row));
    };
    for (const scan of scans) {
      const matching = rows.filter((row) => matches(scan, row));
      if (matching.length !== 1) continue;
      const saved = matching[0]!;
      if (scans.filter((other) => matches(other, saved)).length !== 1) continue;
      reused.set(identity(scan), identity(saved));
    }
  }
  const zone = relabelledFrom(policy);
  if (!zone) return reused;
  const taken = new Set(reused.values());
  const scans = [...unmatched.values()].flat().filter((scan) => !reused.has(identity(scan)));
  const rows = [...candidates.values()].flat().filter((row) => !taken.has(identity(row)));
  for (const scan of scans) {
    const matching = rows.filter((row) => relabelled(zone, scan, row));
    if (matching.length !== 1) continue;
    const saved = matching[0]!;
    if (scans.filter((other) => relabelled(zone, other, saved)).length !== 1) continue;
    reused.set(identity(scan), identity(saved));
  }
  return reused;
}

/** The zone a policy's source once read every wall clock in. Policies from scraper releases before the field name none. */
function relabelledFrom(policy: SameInstantIdentityPolicy): string | null {
  const zone = (policy as { relabelledFrom?: unknown }).relabelledFrom;
  return typeof zone === 'string' && DateTime.now().setZone(zone).isValid ? zone : null;
}

const WALL_CLOCK = "yyyy-LL-dd'T'HH:mm:ss";
const NUMERIC_OFFSET = /[+-]\d{2}:?\d{2}$/;

function timeOf(row: JsonObject): string {
  const time = row.time ?? (isRecord(row.raw_data) ? row.raw_data.time : undefined);
  return typeof time === 'string' ? time : '';
}

/** The wall clock a row's time shows under an offset of its own: not UTC's label, nor the zone's. */
function ownWallClock(zone: string, row: JsonObject): string | null {
  const time = timeOf(row);
  if (!NUMERIC_OFFSET.test(time)) return null;
  const shown = DateTime.fromISO(time, { setZone: true });
  if (!shown.isValid || shown.offset === shown.setZone(zone).offset) return null;
  return shown.toFormat(WALL_CLOCK);
}

/** The wall clock the zone shows at a row's instant, for a row labelled in it. */
function zoneWallClock(zone: string, row: JsonObject): string | null {
  const instant = instantOf(row);
  if (!Number.isFinite(instant) || ownWallClock(zone, row) !== null) return null;
  return DateTime.fromMillis(instant, { zone }).toFormat(WALL_CLOCK);
}

/**
 * One scan read on two clocks: one row shows a wall clock under an offset of
 * its own, the other carries the same wall clock under the zone's label. The
 * provider code must agree, and the location too; wording may differ.
 */
function relabelled(zone: string, scan: JsonObject, row: JsonObject): boolean {
  const code = providerCode(scan);
  if (!code || code.toLowerCase() === 'unknown' || code !== providerCode(row)) return false;
  if (String(scan.location ?? '').trim() !== String(row.location ?? '').trim()) return false;
  const shown = ownWallClock(zone, scan);
  const saved = ownWallClock(zone, row);
  return (shown !== null && shown === zoneWallClock(zone, row)) || (saved !== null && saved === zoneWallClock(zone, scan));
}

function stringsOf(row: JsonObject): string {
  return JSON.stringify([timeOf(row), String(row.location ?? '').trim(), String(row.description ?? '').trim()]);
}

/**
 * Maps the computed identity of each new scan to the stored row an earlier
 * take-over left under another identity: the same source, the same instant,
 * and the time, place and wording the scan's identity hashes. Only a scan
 * whose own identity is not stored is considered, against rows no event of
 * the batch carries, never an observation, and the match must be unique.
 */
export function restatedIdentities(
  events: readonly JsonObject[],
  stored: readonly JsonObject[],
): Map<string, string> {
  const restated = new Map<string, string>();
  const storedIds = new Set(stored.map(identity));
  const claimed = new Set(events.map(identity));
  const rows = stored.filter((row) => (
    sourceOf(identity(row)) !== '' && !claimed.has(identity(row)) && !observedOnly(row) && timeOf(row) !== ''
  ));
  for (const event of events) {
    const id = identity(event);
    const source = sourceOf(id);
    if (source === '' || source === 'app' || storedIds.has(id) || observedOnly(event) || timeOf(event) === '') continue;
    const matching = rows.filter((row) => (
      sourceOf(identity(row)) === source && instantOf(row) === instantOf(event) && stringsOf(row) === stringsOf(event)
    ));
    if (matching.length === 1) restated.set(id, identity(matching[0]!));
  }
  return restated;
}

const UNIVERSAL = 'unknown';
const MINUTE_MS = 60 * 1_000;
const QUARTER_HOUR_MS = 15 * MINUTE_MS;
const HOUR_MS = 60 * 60 * 1_000;
const MAX_ZONE_SHIFT_MS = 14 * HOUR_MS;

/**
 * Whole quarter hours apart, up to 14 h: one scan read in the wrong zone. A
 * copy may drop the milliseconds a carrier keeps (Vinted Go, InPost), so a
 * time in whole seconds is compared to the other's second.
 */
function zoneApart(left: number, right: number): boolean {
  const second = (at: number) => Math.floor(at / 1_000) * 1_000;
  const shift = left % 1_000 === 0 || right % 1_000 === 0 ? second(left) - second(right) : left - right;
  return shift !== 0 && shift % QUARTER_HOUR_MS === 0 && Math.abs(shift) <= MAX_ZONE_SHIFT_MS;
}

function sourceOf(id: string): string {
  const separator = id.indexOf(':');
  return separator > 0 ? id.slice(0, separator) : '';
}

function instantOf(row: JsonObject): number {
  return Date.parse(String(row.occurred_at ?? ''));
}

function wordingOf(row: JsonObject): string {
  return String(row.description ?? '').replace(/\s+/g, ' ').trim().toLocaleLowerCase('en-US');
}

function stageOf(row: JsonObject): string {
  return typeof row.stage === 'string' ? row.stage : '';
}

function providerOf(row: JsonObject): string {
  const name = row[UNIVERSAL_PROVIDER] ?? (isRecord(row.raw_data) ? row.raw_data[UNIVERSAL_PROVIDER] : undefined);
  return typeof name === 'string' ? name : '';
}

/** A stored row that only the scan's universal provider has written, so it follows that provider's clock. */
function followsClock(row: JsonObject, scan: JsonObject): boolean {
  return providerOf(row) !== '' && providerOf(row) === providerOf(scan);
}

/** A stage change the sync stamped with the time it saw it, not a provider scan. */
function observedOnly(row: JsonObject): boolean {
  return row.observed_without_provider_timestamp === true
    || (isRecord(row.raw_data) && row.raw_data.observed_without_provider_timestamp === true);
}

/**
 * The same wording, or one with a further sentence after it (GOFO's support
 * line) or before it (ParcelsApp's heading for an Ecoscooting scan).
 */
function sameWording(left: string, right: string): boolean {
  if (!left || !right) return false;
  if (left === right) return true;
  const [shorter, longer] = left.length < right.length ? [left, right] : [right, left];
  return (/[.!?]$/.test(shorter) && longer.startsWith(`${shorter} `))
    || (longer.endsWith(` ${shorter}`) && /[.!?]$/.test(longer.slice(0, -shorter.length - 1)));
}

/**
 * Two times of one second or minute, one of them that whole second or minute:
 * a source that keeps only seconds (ParcelsApp's copy of Nova Poshta's
 * milliseconds) or only minutes.
 */
function sameTruncated(left: number, right: number): boolean {
  return left !== right && [1_000, MINUTE_MS].some((unit) => {
    const whole = (at: number) => Math.floor(at / unit) * unit;
    return whole(left) === whole(right) && (left === whole(left) || right === whole(right));
  });
}

/** Stages that can name one scan: the same, or one source left it unclassified. */
function stagesAgree(left: string, right: string): boolean {
  return left === right || [left, right].some((stage) => stage === '' || stage === 'pending');
}

/**
 * The words of a scan's place, without accents, case or countries ("Paris, FR"
 * and "PARIS CDG" share paris), umlauts spelt out (ZUERICH is Zürich). A word
 * with letters beyond a to z (Cyrillic, Chinese, ł) is left out.
 */
function placeWords(row: JsonObject): string[] {
  return trackingPlace(String(row.location ?? '')).place.normalize('NFD').replace(/\p{Diacritic}/gu, '').toLowerCase()
    .split(/[^\p{L}\p{N}]+/u)
    .filter((word) => /^[a-z0-9]+$/.test(word) && trackingPlace(word.toUpperCase()).country === null)
    .map((word) => word.replace(/([aou])e/g, '$1'));
}

/** Two places named with no word in common. A place that names no more than a country conflicts with none. */
function placesConflict(left: readonly string[], right: readonly string[]): boolean {
  return left.length > 0 && right.length > 0 && !left.some((word) => right.includes(word));
}

export interface SharedScans {
  /**
   * A scan's computed identity → the stored row it takes over in place: a
   * carrier's scan the universal copy, a universal scan a row only its
   * provider wrote, on another clock (its own row maps to itself).
   */
  reused: Map<string, string>;
  /** A universal scan left out of the batch → the stored identity it repeats. */
  skipped: Map<string, string>;
  /** The scans of `reused` and `skipped` whose row stands at another instant, beyond the minute: one source's clock is off. */
  shifted: Set<string>;
  /** Stored universal copies of the carrier's scans at their instant that no scan takes over: deleted with the sync. */
  absorbed: Set<string>;
}

/** A row written by a carrier: its prefix, or a universal row that names no provider, which a carrier's scan took over or an earlier release wrote. */
function heldByCarrier(row: JsonObject): boolean {
  const source = sourceOf(identity(row));
  return source !== '' && source !== 'app' && (source !== UNIVERSAL || providerOf(row) === '');
}

/** The other source's copy of a classified scan at its instant: stages that agree and no conflicting place. */
function copies(scan: JsonObject, row: JsonObject): boolean {
  return instantOf(scan) === instantOf(row) && stageOf(scan) !== '' && stagesAgree(stageOf(row), stageOf(scan))
    && !placesConflict(placeWords(scan), placeWords(row));
}

/**
 * Keeps one row per scan when a carrier and a universal provider report it.
 *
 * Only scans whose own identity is not stored are matched, against stored rows
 * that no event of this batch carries and `reused` has not taken, never the
 * app's own rows, and never a scan the sync observed without a provider time.
 * A row matches a scan at the exact same instant when it is the only row there
 * with the same wording, or the only row there at all, with a stage that
 * agrees (La Poste's French scan and a provider's unclassified English copy),
 * and the scan the only new scan there. With no row at that instant, a row at
 * an instant no scan of the batch shows matches when one of the two is dated
 * to the second or minute the other falls in (UPS to the second, a provider to
 * the minute): with the same wording, or else alone in other wording when a
 * provider's copy to the minute meets a carrier's scan to the second, with a
 * stage that agrees and no conflicting place (FedEx's own wording of a scan a
 * provider copied). Failing that, the same wording matches a
 * whole number of quarter hours up to 14 h away: the same scan read in the
 * wrong zone. Failing that, a carrier's row for a universal scan, or a
 * universal row for a carrier's scan, at least an hour away matches in any
 * wording when the stages agree and the time has seconds other than zero: a provider whose clock is
 * off by a zone's offset from UTC. Times to the minute fall whole quarter
 * hours apart too often by chance, and carriers stamp some scans 15 or 30
 * minutes after another to the second (Swiss Post sorts a parcel a quarter
 * hour after customs clear it). Across a zone's offset, two places that share
 * no word, countries aside, are two scans. A row that two scans match is
 * ambiguous and stays unmatched.
 *
 * A carrier's scan takes over the universal row it matches. A universal scan
 * that matches any row is left out, and so is one whose own identity is stored
 * at another instant: a carrier's scan has taken that row over and corrected
 * its time. At the same instant a universal scan still rewrites its own row,
 * so a row DPD took over follows whichever source answered last.
 *
 * At each instant of the batch's carrier scans, every other universal row with
 * a stage that agrees with one of those classified scans, and no conflicting
 * place, copies one of them: a provider that reads a scan twice (Speedaf's
 * ParcelsApp rows), or two providers that each copied it (InPost). A scan
 * that matched no row takes one over, in its own stage when one is, and the
 * others are absorbed. Which of several scans at the instant takes which copy
 * does not matter, as the scan rewrites the row; the carrier's own scans there
 * stay apart (FedEx's departure and "On the way"). A universal scan that copies
 * a row a carrier holds at its instant, by its prefix or because the row names
 * no provider, is left out, so an absorbed copy does not come back with the
 * provider's next answer.
 *
 * A row that only the scan's universal provider has written follows that
 * provider's clock instead (a scraper fix that reads its scans in another
 * zone). A scan whose own row it is moves the row to the scan's instant,
 * unless another row matches the scan by the rules above: that row holds the
 * scan already, so the scan is left out as before. A scan that matches such a
 * row across an offset, not just within a minute, takes it over as a carrier's
 * scan would.
 */
export function sharedScans(
  events: readonly JsonObject[],
  stored: readonly JsonObject[],
  reused: ReadonlyMap<string, string> = new Map(),
): SharedScans {
  const shared: SharedScans = { reused: new Map(), skipped: new Map(), shifted: new Set(), absorbed: new Set() };
  if (stored.length === 0) return shared;
  const storedById = new Map(stored.map((row) => [identity(row), row] as const));
  const taken = new Set([...events.map(identity), ...reused.values()]);
  const rows = stored.filter((row) => {
    const source = sourceOf(identity(row));
    return source !== '' && source !== 'app' && !taken.has(identity(row)) && !observedOnly(row)
      && Number.isFinite(instantOf(row));
  });
  const pending: JsonObject[] = [];
  // Universal scans whose own row, which only their provider wrote, stands at another instant.
  const moving: JsonObject[] = [];
  for (const event of events) {
    const id = identity(event);
    const source = sourceOf(id);
    if (source === '' || source === 'app' || reused.has(id) || observedOnly(event) || !Number.isFinite(instantOf(event))) continue;
    const own = storedById.get(id);
    if (!own) pending.push(event);
    else if (source === UNIVERSAL && instantOf(own) !== instantOf(event)) {
      if (followsClock(own, event)) moving.push(event);
      else shared.skipped.set(id, id);
      if (!sameTruncated(instantOf(own), instantOf(event))) shared.shifted.add(id);
    }
  }
  const newAt = new Map<number, number>();
  for (const event of pending) newAt.set(instantOf(event), (newAt.get(instantOf(event)) ?? 0) + 1);
  const occupied = new Set(rows.map(instantOf));
  // A row the batch shows at its own instant is that scan's, not a shifted copy's.
  const shown = new Set(events.map(instantOf));
  /** The row a scan repeats; `alone` when no other new scan stands at its instant. */
  const matchOf = (event: JsonObject, alone: boolean): JsonObject | undefined => {
    const universal = sourceOf(identity(event)) === UNIVERSAL;
    const at = instantOf(event);
    const wording = wordingOf(event);
    const eligible = universal ? rows : rows.filter((row) => sourceOf(identity(row)) === UNIVERSAL);
    const exact = eligible.filter((row) => instantOf(row) === at);
    const worded = exact.filter((row) => sameWording(wordingOf(row), wording));
    const place = placeWords(event);
    const truncated = occupied.has(at) ? [] : eligible.filter((row) => sameTruncated(at, instantOf(row)) && !shown.has(instantOf(row)));
    const minuted = truncated.filter((row) => sameWording(wordingOf(row), wording));
    // Other wording only for a provider's copy to the minute of a carrier's scan to the second.
    // An earlier carrier's relay of a delivery scan (India Post's, Nova Poshta's) is no such pair.
    const restaged = stageOf(event) === '' ? [] : truncated.filter((row) => (
      (sourceOf(identity(row)) === UNIVERSAL) !== universal && (universal ? at : instantOf(row)) % MINUTE_MS === 0
      && stagesAgree(stageOf(row), stageOf(event)) && !placesConflict(place, placeWords(row))
    ));
    const zoned = occupied.has(at) ? [] : eligible.filter((row) => (
      zoneApart(at, instantOf(row)) && !shown.has(instantOf(row)) && !placesConflict(place, placeWords(row))
    ));
    const shifted = zoned.filter((row) => sameWording(wordingOf(row), wording));
    const reclocked = Math.floor(at / 1_000) % 60 === 0 ? [] : zoned.filter((row) => (
      (sourceOf(identity(row)) === UNIVERSAL) !== universal && Math.abs(at - instantOf(row)) >= HOUR_MS
      && stagesAgree(stageOf(row), stageOf(event))
    ));
    const staged = exact.length === 1 && alone && stageOf(event) !== '' && stagesAgree(stageOf(exact[0]!), stageOf(event));
    return worded.length === 1 ? worded[0]
      : worded.length === 0 && staged ? exact[0]
        : minuted.length > 0 ? (minuted.length === 1 ? minuted[0] : undefined)
          : restaged.length > 0 ? (restaged.length === 1 ? restaged[0] : undefined)
            : shifted.length === 1 ? shifted[0]
              : shifted.length === 0 && reclocked.length === 1 ? reclocked[0] : undefined;
  };
  const picks = new Map<string, JsonObject[]>();
  for (const event of pending) {
    const match = matchOf(event, newAt.get(instantOf(event)) === 1);
    if (match) picks.set(identity(match), [...(picks.get(identity(match)) ?? []), event]);
  }
  for (const [rowId, scans] of picks) {
    if (scans.length !== 1) continue;
    const scan = scans[0]!;
    const id = identity(scan);
    const row = storedById.get(rowId)!;
    const offset = instantOf(scan) !== instantOf(row) && !sameTruncated(instantOf(scan), instantOf(row));
    if (sourceOf(id) !== UNIVERSAL || (offset && followsClock(row, scan))) shared.reused.set(id, rowId);
    else shared.skipped.set(id, rowId);
    if (offset) shared.shifted.add(id);
  }
  // Each copy at a carrier's instant goes: a scan that matched no row takes one over, and the others are absorbed.
  const kept = new Set([...shared.reused.values(), ...shared.skipped.values()]);
  const waiting = new Set(pending.map(identity));
  const carrierScans = byInstant(events.filter((event) => (
    !['', 'app', UNIVERSAL].includes(sourceOf(identity(event))) && !observedOnly(event)
  )));
  for (const [at, scans] of carrierScans) {
    const copied = rows.filter((row) => (
      instantOf(row) === at && sourceOf(identity(row)) === UNIVERSAL && !kept.has(identity(row))
      && scans.some((scan) => copies(scan, row))
    ));
    for (const scan of scans) {
      const id = identity(scan);
      if (!waiting.has(id) || shared.reused.has(id)) continue;
      const fit = copied.filter((row) => copies(scan, row));
      const row = fit.find((candidate) => stageOf(candidate) === stageOf(scan)) ?? fit[0];
      if (!row) continue;
      shared.reused.set(id, identity(row));
      copied.splice(copied.indexOf(row), 1);
    }
    for (const row of copied) shared.absorbed.add(identity(row));
  }
  // A copy of a scan a carrier holds stays out, so the copies it absorbed do not come back.
  const held = stored.filter((row) => heldByCarrier(row) && !observedOnly(row));
  const heldCopy = (event: JsonObject) => held.find((row) => copies(event, row));
  for (const event of pending) {
    const id = identity(event);
    if (sourceOf(id) !== UNIVERSAL || shared.skipped.has(id) || shared.reused.has(id)) continue;
    const twin = heldCopy(event);
    if (twin) shared.skipped.set(id, identity(twin));
  }
  // Moving its own row beside another row that holds the scan would store the scan twice.
  for (const event of moving) {
    const id = identity(event);
    if (matchOf(event, !newAt.has(instantOf(event))) || heldCopy(event)) shared.skipped.set(id, id);
    else shared.reused.set(id, id);
  }
  return shared;
}

/**
 * The identities of the earlier carrier's scans in a handoff's batch that
 * relay a delivery scan: Nova Poshta tells each GOFO scan in its own words at
 * the same second and place. A relay falls in the same second as a delivery
 * scan, with stages that agree and places that share a word or name no more
 * than a country; wording may differ. Left out of `sharedScans`, a relay stays
 * a row of the earlier carrier, which relayCopies.ts pairs with the scan, and
 * the delivery scan takes over a universal copy alone.
 */
export function relayedScans(earlier: readonly JsonObject[], delivery: readonly JsonObject[]): Set<string> {
  const scans = delivery.filter((row) => !observedOnly(row) && Number.isFinite(instantOf(row)));
  const second = (row: JsonObject) => Math.floor(instantOf(row) / 1_000);
  return new Set(earlier.filter((row) => !observedOnly(row) && Number.isFinite(instantOf(row)) && scans.some((scan) => (
    second(scan) === second(row) && stagesAgree(stageOf(scan), stageOf(row)) && !placesConflict(placeWords(scan), placeWords(row))
  ))).map(identity));
}

/**
 * A newest-event time (the routing watermark, a result's summary time) that
 * universal copies read in the wrong zone may have set hours late. A skipped
 * copy counts at its stored twin's instant, and a stored copy a scan takes over
 * (a carrier's, or its provider's on a corrected clock) at that scan's
 * instant. The time drops to the newest instant left
 * only when it is later than that and no later than the newest instant a copy
 * claimed, so the copies explain the excess (the router caps a future-dated
 * copy at the time of the check); a time they do not explain stands. The batch
 * always counts, `stored` rows only with `withStored`, and `also` adds instants
 * the batch rows do not carry. The app's own rows ("Tracking added") are no
 * scans: a parcel added after its newest scan keeps that scan's time.
 */
export function withoutCopyDrift(
  time: number,
  events: readonly JsonObject[],
  stored: readonly JsonObject[],
  matches: { reused: ReadonlyMap<string, string>; skipped: ReadonlyMap<string, string> },
  options: { withStored?: boolean; also?: readonly number[] } = {},
): number {
  if (!Number.isFinite(time)) return time;
  const storedById = new Map(stored.map((row) => [identity(row), row] as const));
  const claimed: number[] = [];
  const retimed = new Map<string, number>();
  const kept: number[] = [...(options.also ?? [])];
  for (const event of events) {
    if (observedOnly(event)) continue;
    const takenOver = storedById.get(matches.reused.get(identity(event)) ?? '');
    if (takenOver) {
      claimed.push(instantOf(takenOver));
      retimed.set(identity(takenOver), instantOf(event));
    }
    const twin = storedById.get(matches.skipped.get(identity(event)) ?? '');
    if (twin) claimed.push(instantOf(event));
    kept.push(instantOf(twin ?? event));
  }
  if (options.withStored) {
    // A row stored when the sync first saw it, a provider having given no instant, holds no scan time.
    for (const row of stored) if (sourceOf(identity(row)) !== 'app' && !observedOnly(row)) kept.push(retimed.get(identity(row)) ?? instantOf(row));
  }
  const newest = Math.max(...kept.filter(Number.isFinite));
  const claimedNewest = Math.max(...claimed.filter(Number.isFinite));
  return Number.isFinite(newest) && time > newest && time <= claimedNewest ? newest : time;
}

/**
 * The events as persisted: a reused identity replaces the computed one. A
 * universal scan that rewrites a stored row naming no provider (a carrier
 * wrote it, or it was stored before rows named one) leaves it unnamed.
 */
export function withIdentities(
  events: readonly JsonObject[],
  identities: ReadonlyMap<string, string>,
  stored: readonly JsonObject[] = [],
): JsonObject[] {
  const unnamed = new Set(stored.filter((row) => providerOf(row) === '').map(identity));
  return events.map((event) => {
    const reused = identities.get(identity(event));
    const persisted = reused ? { ...event, provider_event_id: reused } : event;
    if (!unnamed.has(identity(persisted)) || providerOf(event) === '' || !isRecord(event.raw_data)) return persisted;
    const raw = { ...event.raw_data };
    delete raw[UNIVERSAL_PROVIDER];
    return { ...persisted, raw_data: raw };
  });
}
