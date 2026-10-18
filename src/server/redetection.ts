import 'server-only';
import { recognitionCandidates } from 'universal-parcel-scraper';
import { universalCarrierHints } from 'universal-parcel-scraper/app';
import { detectCarrierMatch } from '../lib/carriers';
import { AUTOMATIC_CARRIER_IDS } from './carriers';
import { localClockCarrier } from './directLocalHistory';
import { refusesNumber } from './numberRefusal';
import { catalogRules, directCarrier, routingState } from './trackingRouting';
import { isRecord, type JsonObject } from './types';

/** Only parcels added this recently are looked at again, as carrier recognition only asks for them. */
export const REDETECTION_WINDOW_MS = 30 * 24 * 60 * 60 * 1_000;

/**
 * How long after a parcel's last check a release waits before asking again a carrier the
 * parcel already asked: its answer would most likely come back the same, and some of these
 * lookups open a browser.
 */
export const RELEASE_REASK_MS = 12 * 60 * 60 * 1_000;

/**
 * The carrier the catalog's current rules point an open parcel to, when the
 * parcel was last routed with other rules and has not asked that carrier yet:
 * one added or last checked before a scraper release brought a detection rule,
 * a carrier name or an adapter, which nobody may check any more (a lookup
 * whose link nobody opens), one filed under a carrier that only
 * recognition asked before, or one whose filed carrier answered on local
 * clocks that the catalog now dates. A parcel filed under no carrier gets its detected
 * or named carrier, or else the first carrier its check's recognition would
 * ask, asked before or not, once that carrier's wait is over: a release may
 * have taught it the number, and its last answer may have been a passing
 * failure such as a rate limit. A carrier the parcel already asked waits until
 * the parcel has gone RELEASE_REASK_MS without a check, unless the answer it
 * gave, set aside as older than the parcel, would now be taken. Null otherwise.
 * Only parcels filed under no carrier, or showing a universal provider's
 * history, are looked at. Nothing is sent: the check queued for the parcel asks
 * the carrier. Carriers in `refused` are passed over (rerouteAskable).
 */
export function rerouteCarrier(parcel: JsonObject, rules = catalogRules(), now = Date.now(),
  refused: ReadonlySet<string> = new Set()): string | null {
  return rerouteLead(parcel, rules, now, refused)?.carrier ?? null;
}

/**
 * The carrier a release's check would ask, and how likely that check is to change the
 * parcel's answer, the most likely first: 0, the carrier's own answer is now dated, it
 * refused the number under an older release, or the parcel's newest scan has come back to
 * the answer it gave that was set aside as older; 1, a carrier the parcel never asked; 2,
 * one a parcel filed under no carrier asks again, or the first its recognition would ask.
 */
export interface RerouteLead { carrier: string; rank: 0 | 1 | 2 }

function rerouteLead(parcel: JsonObject, rules: string, now: number, refused: ReadonlySet<string>): RerouteLead | null {
  const data = isRecord(parcel.carrier_data) ? parcel.carrier_data : {};
  const routing = routingState(parcel);
  const filed = String(parcel.carrier);
  const number = String(parcel.tracking_number ?? '');
  const unfiled = filed === 'unknown' || filed === 'intl-post';
  const provider = typeof data.tracking_provider === 'string';
  if (routing.rules === rules || data.original_carrier || (!unfiled && !provider)
    || ['delivered', 'returned'].includes(String(parcel.current_stage))) return null;
  // A carrier that refused the number under an older release counts as not asked:
  // this release's adapter may take it (rerouteAskable checks).
  const refusedBefore = (carrier: string) => routing.failures[carrier]?.user_error === 'carrier:invalid_input';
  // An answer set aside as older than the parcel that the parcel's newest scan has since
  // come back to, as a provider's corrected clock brings it: the carrier's check would take it.
  const fits = (carrier: string) => Date.parse(routing.set_aside?.[carrier]?.newest ?? '') >= Date.parse(routing.last_event_at ?? '');
  const asked = (carrier: string) => carrier === routing.confirmed_carrier || Boolean(routing.set_aside?.[carrier])
    || (Boolean(routing.failures[carrier]) && !refusedBefore(carrier)) || Boolean(routing.candidate_probes?.[carrier]);
  const checkedRecently = now - Date.parse(String(parcel.last_synced_at ?? '')) < RELEASE_REASK_MS;
  const waiting = (carrier: string) => Date.parse(routing.candidate_probes?.[carrier]?.retry_at ?? '') > now
    || Date.parse(routing.failures[carrier]?.retry_at ?? '') > now || (checkedRecently && asked(carrier) && !fits(carrier));
  // A carrier with an adapter of its own that the parcel never asked, or an unfiled parcel
  // can ask again, or one an unfiled parcel's check asks the providers about.
  const leads = (carrier: string | undefined): carrier is string => carrier !== undefined && carrier !== filed
    && !refused.has(carrier) && AUTOMATIC_CARRIER_IDS.has(carrier) && (!directCarrier(carrier) ? unfiled
      : unfiled ? carrier !== routing.confirmed_carrier && !waiting(carrier) : !asked(carrier));
  const lead = (carrier: string, rank: 0 | 1 | 2 = asked(carrier) ? 2 : 1): RerouteLead =>
    ({ carrier, rank: refusedBefore(carrier) ? 0 : rank });
  const taken = Object.keys(routing.set_aside ?? {}).find((carrier) => fits(carrier) && carrier !== filed
    && !refused.has(carrier) && AUTOMATIC_CARRIER_IDS.has(carrier) && directCarrier(carrier));
  if (taken) return lead(taken, 0);
  const detected = detectCarrierMatch(number);
  if (detected.confidence === 'high' && leads(detected.carrier)) return lead(detected.carrier);
  // The names a provider gave, read with today's aliases and number rules.
  const names = Array.isArray(data.reported_carriers)
    ? data.reported_carriers.filter((name): name is string => typeof name === 'string') : [];
  const named = names.length ? universalCarrierHints(names, number).discovered_carrier : undefined;
  if (leads(named) && (named !== routing.discovered_carrier || refusedBefore(named))) return lead(named);
  if (unfiled) {
    const [first] = recognitionCandidates(number, { hint: routing.discovered_carrier,
      skip: (carrier) => waiting(carrier) || refused.has(carrier) });
    if (first) return lead(first.carrier, 2);
  }
  // The filed carrier's own adapter, new since the provider took over, or one only
  // recognition asked before the parcel was filed under it: such a probe drops an
  // answer on local clocks, which the filed carrier's own lookup keeps. Or the filed
  // carrier answered on local clocks, which the provider dated, and now dates its scans.
  if (!provider || unfiled || !directCarrier(filed) || refused.has(filed)) return null;
  if (isRecord(data.direct_local_history) && data.direct_local_history.carrier === filed && !localClockCarrier(filed)) return lead(filed, 0);
  return filed !== routing.confirmed_carrier && (!routing.failures[filed] || refusedBefore(filed)) ? lead(filed, 1) : null;
}

/**
 * The carrier rerouteCarrier points the parcel to, with its rank, passing over those
 * whose adapter refuses the number by its own check, which sends nothing: the queued
 * check could not ask them. A later release, whose adapters may take the number, looks again.
 */
export async function rerouteAskable(parcel: JsonObject, rules = catalogRules(), now = Date.now(),
  refuses: (carrier: string, number: string) => Promise<boolean> = refusesNumber): Promise<RerouteLead | null> {
  const number = String(parcel.tracking_number ?? '');
  const refused = new Set<string>();
  // Each refusal leaves that carrier out of the next pick, so the catalog bounds the loop.
  for (let lead = rerouteLead(parcel, rules, now, refused); lead; lead = rerouteLead(parcel, rules, now, refused)) {
    if (!await refuses(lead.carrier, number)) return lead;
    refused.add(lead.carrier);
  }
  return null;
}
