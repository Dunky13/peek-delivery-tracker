import { afterEach, expect, it, vi } from 'vitest';

import { refusesNumber } from './numberRefusal';

afterEach(() => vi.restoreAllMocks());

it("asks a carrier's adapter whether it issues a number without sending a request", async () => {
  const fetch = vi.spyOn(globalThis, 'fetch');
  // Not a China Post number, and a China Post form with a failed check digit.
  await expect(refusesNumber('china-post', 'ZZ12345678901')).resolves.toBe(true);
  await expect(refusesNumber('china-post', 'AB100000001CN')).resolves.toBe(true);
  await expect(refusesNumber('china-post', 'RR123456785CN')).resolves.toBe(false);
  expect(fetch).not.toHaveBeenCalled();
});

it('refuses nothing for a carrier without its own adapter', async () => {
  await expect(refusesNumber('unknown', 'ZZ12345678901')).resolves.toBe(false);
});
