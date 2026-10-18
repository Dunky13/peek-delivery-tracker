import { carrierErrorKind } from 'universal-parcel-scraper';

/**
 * A carrier's own tracking that does not know the item: Ukrposhta's status API
 * or portal, myDSV's search, Ecoscooting's order query. The source answered,
 * but may not prove absence, so the adapter raises these as inconclusive with
 * these reasons.
 */
export const UNKNOWN_ITEM_REASONS: ReadonlySet<string> = new Set(['status_api_not_found', 'portal_not_found']);

/** Stable public copy codes. Full diagnostics remain in the tracking audit. */
export function trackingFailureCode(error: unknown): string | null {
  const kind = carrierErrorKind(error);
  return kind ? `carrier:${kind}` : null;
}

/** Do not blame one provider when several failed for different reasons. */
export function deferredTrackingFailure(
  failures: Record<string, { user_error?: string; kind: string }>,
  configuredCarrier: string,
): string | null {
  // The parcel's own carrier needs an input, or refuses the number: only the parcel's details can change that.
  const own = failures[configuredCarrier]?.user_error;
  if (own === 'carrier:input_required' || own === 'carrier:invalid_input') return own;
  const codes = Object.values(failures).map(failure => failure.user_error
    ?? ({ rate_limited: 'carrier:rate_limited', verification: 'carrier:challenge', not_found: 'carrier:not_found' } as Record<string, string>)[failure.kind]);
  return codes.length && codes[0] && codes.every(code => code === codes[0]) ? codes[0] : null;
}
