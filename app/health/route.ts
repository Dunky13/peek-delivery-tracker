import { apiRoute, expectedFailure, json, noContent } from '../../src/server/api';
import { deliveryServiceReadiness } from '../../src/server/readiness';

export const dynamic = 'force-dynamic';
export const runtime = 'nodejs';

// A server shutting down answers 503 until it exits, by design: its request lines log at info.
export const GET = apiRoute(async () => {
  const readiness = await deliveryServiceReadiness();
  if (readiness === 'draining') return expectedFailure(json({ ok: false, draining: true }, 503));
  const ok = readiness === 'ready';
  return json({ ok }, ok ? 200 : 503);
}, { authenticated: false, loadService: false, quiet: true });

export const HEAD = apiRoute(async () => {
  const readiness = await deliveryServiceReadiness();
  if (readiness === 'draining') return expectedFailure(noContent(503));
  return noContent(readiness === 'ready' ? 200 : 503);
}, { authenticated: false, loadService: false, quiet: true });
