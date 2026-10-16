import 'server-only';
import { detectCarrierMatch, inferStage, type CarrierResult } from 'universal-parcel-scraper';
import { carrierIdFromName, latestResultTime } from 'universal-parcel-scraper/app';
import type { ApiCarrierId } from '../generated/apiContract';
import { AUTOMATIC_CARRIER_IDS, requiredRequirements } from './carriers';

/** Whether the number's own rules point to this carrier alone: it names it, or it is their only candidate. */
function ownsNumber(carrier: string, number: string): boolean {
  const detected = detectCarrierMatch(number);
  return detected.carrier === carrier || (detected.candidates.length === 1 && detected.candidates[0] === carrier);
}

/**
 * Identify an unselected parcel from the carrier a provider names and dated
 * shipment movement. Several names are one journey's legs (Mayi Yinfu and the
 * DHL networks that deliver it): the one the provider settled on counts only
 * when the number's own rules point to it alone. Callers then ask that
 * carrier's adapter whether it refuses the number (numberRefusal.ts).
 */
export function providerCarrier(result: CarrierResult, number: string): ApiCarrierId | undefined {
  const names: unknown[] = Array.isArray(result.reported_carriers) ? result.reported_carriers : [];
  if (result.tracking_provider === 'UPU' || !names.length || names.some((name) => typeof name !== 'string')) return undefined;
  const discovered = typeof result.discovered_carrier === 'string' ? result.discovered_carrier : undefined;
  const carrier = names.length === 1 ? carrierIdFromName(String(names[0]))
    : discovered && ownsNumber(discovered, number) ? discovered : undefined;
  if (!carrier || carrier !== discovered || !AUTOMATIC_CARRIER_IDS.has(carrier)
    || requiredRequirements(carrier, number).length) return undefined;
  const datedProgress = result.events?.some((event) => {
    const stage = event.stage ?? inferStage(event.description ?? '', 'pending');
    const instant = latestResultTime({ events: [event] }, 'unknown');
    return !['pending', 'registered', 'unknown'].includes(stage)
      && typeof event.time === 'string' && /(?:Z|[+-](?:[01]\d|2[0-3]):?[0-5]\d)$/i.test(event.time)
      && instant > 0 && instant <= Date.now() + 3_600_000;
  });
  return datedProgress ? carrier as ApiCarrierId : undefined;
}
