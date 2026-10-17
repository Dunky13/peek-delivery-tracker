import 'server-only';
import { backgroundState } from './background';
import { serviceClient } from './runtime';

/**
 * Ready means both the database and this process's job worker are usable.
 * Otherwise the process is shutting down (`draining`), its job worker has not
 * polled for 120 s (`worker`), or the database does not answer (`database`).
 */
export type Readiness = 'ready' | 'draining' | 'worker' | 'database';

export async function deliveryServiceReadiness(): Promise<Readiness> {
  try {
    const state = backgroundState();
    if (state?.draining) return 'draining';
    const heartbeat = state?.workerHeartbeat;
    if (!heartbeat || Date.now() / 1_000 - heartbeat > 120) return 'worker';
    const client = serviceClient();
    return client && await client.probeReadiness() ? 'ready' : 'database';
  } catch {
    return 'database';
  }
}
