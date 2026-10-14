import 'server-only';

import { carrierErrorKind } from 'universal-parcel-scraper';
import { AdapterRegistry, NOOP_RECORDER, REGISTRY } from 'universal-parcel-scraper/node';

/** Adapters that cannot reach anyone: every request fails, no browser is configured and nothing is recorded. */
let numberChecks: AdapterRegistry | undefined;

/**
 * Whether a carrier's adapter refuses the number as one it does not issue.
 * Adapters check the number before their first request, so the lookup starts
 * with its signal already aborted and nothing is sent. An adapter that checks
 * later, or needs another input first, does not refuse.
 */
export async function refusesNumber(carrier: string, number: string): Promise<boolean> {
  numberChecks ??= new AdapterRegistry(REGISTRY, { fetcher: () => Promise.reject(new Error('Number check only')),
    trawl: null, browserExecutablePath: null, recorder: NOOP_RECORDER, env: process.env });
  const adapter = numberChecks.has(carrier) ? numberChecks.for(carrier) : null;
  if (!adapter) return false;
  try { await adapter.track({ number }, { signal: AbortSignal.abort(), budgetMs: 1 }); }
  catch (error) { return carrierErrorKind(error) === 'invalid_input'; }
  return false;
}
