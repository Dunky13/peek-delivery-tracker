import { useEffect, useState } from 'react';
import type { ApiNumberRefusalRequest, ApiNumberRefusalResponse } from '../generated/apiContract';
import type { CarrierId } from '../types';

/** A carrier's refusal of a number does not change: each pair is asked once per page. */
const answers = new Map<string, boolean>();

/**
 * Whether a carrier picked by hand refuses the number as one it does not
 * issue, so the pickers can say so before tracking starts. The server asks the
 * carrier's adapter, which checks the number without sending it anywhere.
 * Nothing is refused until it answers, or when it cannot.
 */
export function useNumberRefusal(carrier: CarrierId | null, trackingNumber: string | null): boolean {
  const key = carrier && trackingNumber ? `${carrier}:${trackingNumber}` : '';
  const [, setAnswered] = useState(0);
  useEffect(() => {
    if (!carrier || !trackingNumber || answers.has(`${carrier}:${trackingNumber}`)) return;
    const controller = new AbortController();
    const body: ApiNumberRefusalRequest = { carrier, trackingNumber };
    void fetch('/api/public/refusal', {
      method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body),
      cache: 'no-store', credentials: 'omit', referrerPolicy: 'no-referrer', signal: controller.signal,
    }).then(async (response) => {
      const answer = response.ok ? await response.json() as ApiNumberRefusalResponse : null;
      if (typeof answer?.refused !== 'boolean') return;
      answers.set(`${carrier}:${trackingNumber}`, answer.refused);
      setAnswered((count) => count + 1);
    }).catch(() => undefined);
    return () => controller.abort();
  }, [carrier, trackingNumber]);
  return key ? answers.get(key) ?? false : false;
}
