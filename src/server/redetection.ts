import 'server-only';
import { recognitionCandidates } from 'universal-parcel-scraper';
import { universalCarrierHints } from 'universal-parcel-scraper/app';
import { detectCarrierMatch } from '../lib/carriers';
import { AUTOMATIC_CARRIER_IDS } from './carriers';
import { catalogRules, directCarrier, routingState } from './trackingRouting';
import { isRecord, type JsonObject } from './types';

/** Only parcels added this recently are looked at again, as carrier recognition only asks for them. */
export const REDETECTION_WINDOW_MS = 30 * 24 * 60 * 60 * 1_000;

/**
 * The carrier the catalog's current rules point an open parcel to, when the
 * parcel was last routed with other rules and has not asked that carrier yet:
 * one added or last checked before a scraper release brought a detection rule,
 * a carrier name or an adapter, which nobody may check any more (a lookup
 * whose link nobody opens), or one filed under a carrier that only
 * recognition asked before. A parcel filed under no carrier gets its detected
 * or named carrier, or else the first carrier its check's recognition would
 * ask, asked before or not, once that carrier's wait is over: a release may
 * have taught it the number, and its last answer may have been a passing
 * failure such as a rate limit. Null otherwise. Only parcels filed under no
 * carrier, or showing a universal provider's history, are looked at. Nothing
 * is sent: the check queued for the parcel asks the carrier.
 */
export function rerouteCarrier(parcel: JsonObject, rules = catalogRules(), now = Date.now()): string | null {
  const data = isRecord(parcel.carrier_data) ? parcel.carrier_data : {};
  const routing = routingState(parcel);
  const filed = String(parcel.carrier);
  const number = String(parcel.tracking_number ?? '');
  const unfiled = filed === 'unknown' || filed === 'intl-post';
  const provider = typeof data.tracking_provider === 'string';
  if (routing.rules === rules || data.original_carrier || (!unfiled && !provider)
    || ['delivered', 'returned'].includes(String(parcel.current_stage))) return null;
  const asked = (carrier: string) => carrier === routing.confirmed_carrier || Boolean(routing.failures[carrier])
    || Boolean(routing.candidate_probes?.[carrier]);
  const waiting = (carrier: string) => Date.parse(routing.candidate_probes?.[carrier]?.retry_at ?? '') > now
    || Date.parse(routing.failures[carrier]?.retry_at ?? '') > now;
  // A carrier with an adapter of its own that the parcel never asked, or an unfiled parcel
  // can ask again, or one an unfiled parcel's check asks the providers about.
  const leads = (carrier: string | undefined): carrier is string => carrier !== undefined && carrier !== filed
    && AUTOMATIC_CARRIER_IDS.has(carrier) && (!directCarrier(carrier) ? unfiled
      : unfiled ? carrier !== routing.confirmed_carrier && !waiting(carrier) : !asked(carrier));
  const detected = detectCarrierMatch(number);
  if (detected.confidence === 'high' && leads(detected.carrier)) return detected.carrier;
  // The names a provider gave, read with today's aliases and number rules.
  const names = Array.isArray(data.reported_carriers)
    ? data.reported_carriers.filter((name): name is string => typeof name === 'string') : [];
  const named = names.length ? universalCarrierHints(names, number).discovered_carrier : undefined;
  if (named !== routing.discovered_carrier && leads(named)) return named;
  if (unfiled) {
    const [first] = recognitionCandidates(number, { hint: routing.discovered_carrier, skip: waiting });
    if (first) return first.carrier;
  }
  // The filed carrier's own adapter, new since the provider took over, or one only
  // recognition asked before the parcel was filed under it: such a probe drops an
  // answer on local clocks, which the filed carrier's own lookup keeps.
  return provider && !unfiled && directCarrier(filed) && filed !== routing.confirmed_carrier && !routing.failures[filed]
    ? filed : null;
}
