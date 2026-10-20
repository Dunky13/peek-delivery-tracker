import 'server-only';

import { captureOperationalError } from './observability';
import { placesForEvents, type EventPoint } from 'universal-parcel-scraper/places';
import { scanDay, UNWORDED_STEP } from './eventIdentity';
import { DIRECT_HISTORY, providerCopies } from './providerCopies';
import { relayCopies } from './relayCopies';
import { isRecord, type JsonObject } from './types';

let reported = false;

/**
 * The stored point only feeds the place, and the source and provider only tell
 * Peek's own rows, relay copies and provider copies apart: the API returns none
 * of them. A relay copy names the
 * scan it repeats instead. A scan dated by its day alone names that day. A stage
 * change Peek saw with no words from the carrier (AliExpress's undated record) is
 * served without Peek's stand-in, so the apps name the stage.
 */
function served(event: JsonObject, relayOf?: string): JsonObject {
  const rest: JsonObject = { ...dated(event), ...(relayOf ? { relay_of: relayOf } : {}),
    ...(event.observed === true && event.description === UNWORDED_STEP ? { description: '' } : {}) };
  delete rest.point;
  delete rest.provider_event_id;
  delete rest.universal_provider;
  return rest;
}

/** A scan with the times it was stored with read: the day it names, if any, and nothing else of them. */
function dated(event: JsonObject): JsonObject {
  const day = event.observed === true ? null : scanDay(event);
  const rest: JsonObject = { ...event, ...(day ? { day } : {}) };
  for (const key of ['time', 'local_time', 'observed']) delete rest[key];
  return rest;
}

/** A row Peek writes itself (`app:` source), such as "Tracking added". */
function isOwnRow(event: JsonObject): boolean {
  return typeof event.provider_event_id === 'string' && event.provider_event_id.startsWith('app:');
}

/**
 * The timeline is the carrier's story. Peek's own row, "Tracking added" or a
 * new carrier still to answer, only opens it: once a carrier scan is as old
 * as that row or older, the row is left out, so it never sits among the
 * scans or above a delivery. The stored row, the stage and alerts are not
 * affected.
 */
export function timeline(events: JsonObject[]): JsonObject[] {
  const time = (event: JsonObject) => Date.parse(String(event.occurred_at));
  const firstScan = Math.min(...events.filter((event) => !isOwnRow(event)).map(time).filter(Number.isFinite));
  return events.filter((event) => !isOwnRow(event) || !(firstScan <= time(event)));
}

/** A package row without the carrier data that only the service reads. */
function withoutServiceData(row: JsonObject): JsonObject {
  const stored = isRecord(row.carrier_data) ? row.carrier_data : null;
  if (!stored || !('add_recognition_pending' in stored || DIRECT_HISTORY in stored)) return row;
  const data = { ...stored };
  delete data.add_recognition_pending;
  delete data[DIRECT_HISTORY];
  return { ...row, carrier_data: data };
}

/** The scans of a stored package row its timeline shows: without a provider's copies of its carrier's scans, then as `timeline` keeps them. */
export function shownEvents(row: JsonObject): JsonObject[] {
  const copied = providerCopies(row);
  return timeline((Array.isArray(row.tracking_events) ? row.tracking_events.filter(isRecord) : [])
    .filter((event) => !copied.has(String(event.id))));
}

/** A stored package row with its events' sources left out, every row kept: the account's export. */
export function withoutEventSources(row: JsonObject): JsonObject {
  row = withoutServiceData(row);
  if (!Array.isArray(row.tracking_events)) return row;
  return {
    ...row,
    tracking_events: row.tracking_events.map((event) => {
      if (!isRecord(event)) return event;
      const rest = dated(event);
      delete rest.provider_event_id;
      delete rest.universal_provider;
      return rest;
    }),
  };
}

function eventPoint(value: unknown): EventPoint | null {
  if (!isRecord(value)) return null;
  const { latitude, longitude } = value;
  return typeof latitude === 'number' && typeof longitude === 'number' ? { latitude, longitude } : null;
}

/**
 * An API package row as it is served. Every scan gets a `place`: where its
 * free text locates it, or null. Places are worked out when the package is
 * served, so improving the gazetteer improves every parcel, old ones
 * included. A universal provider's copy of a confirmed carrier's scan is left
 * out (providerCopies.ts), so is Peek's own opening row once carrier scans
 * reach back to it (see `timeline`), and an earlier carrier's relay copy of a
 * scan names that scan (`relay_of`, see relayCopies.ts).
 */
export function withEventPlaces(row: JsonObject): JsonObject {
  const stored = row;
  row = withoutServiceData(row);
  if (!Array.isArray(row.tracking_events) || !row.tracking_events.length) return row;
  const events = shownEvents(stored);
  const relays = relayCopies({ ...row, tracking_events: events });
  const shown = (event: JsonObject) => served(event, relays.get(String(event.id)));
  const carrierData = isRecord(row.carrier_data) ? row.carrier_data : {};
  try {
    const ordered = [...events].sort((a, b) => String(a.occurred_at).localeCompare(String(b.occurred_at)));
    const places = placesForEvents(ordered.map((event) => typeof event.location === 'string' ? event.location : null), {
      destinationCountry: typeof carrierData.destination_country === 'string' ? carrierData.destination_country : null,
      // Their countries and their own hubs. The carrier delivering now says more than the one the parcel was added with.
      carriers: [carrierData.active_tracking_carrier, row.carrier].filter((carrier): carrier is string => typeof carrier === 'string'),
      points: ordered.map((event) => eventPoint(event.point)),
      // Paperwork filed where the parcel is not, such as customs at the destination's office, gets no place; the scan keeps its text.
      stages: ordered.map((event) => typeof event.stage === 'string' ? event.stage : null),
      times: ordered.map((event) => typeof event.occurred_at === 'string' ? event.occurred_at : null),
    });
    const byEvent = new Map(ordered.map((event, index) => [event, places[index]]));
    return {
      ...row,
      tracking_events: events.map((event) => ({ ...shown(event), place: byEvent.get(event) ?? null })),
    };
  } catch (error) {
    // A map is a nice extra: the parcel still loads without one.
    if (!reported) captureOperationalError(error, { component: 'api', operation: 'locate_event_places' });
    reported = true;
    return { ...row, tracking_events: events.map(shown) };
  }
}
