import { NextRequest } from 'next/server';
import { afterEach, expect, it, vi } from 'vitest';

import { POST } from '../../app/api/public/refusal/route';
import { refusesNumber } from './numberRefusal';

afterEach(() => { vi.restoreAllMocks(); vi.unstubAllEnvs(); });

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

it('tells the pickers, without an account, whether a carrier refuses a number', async () => {
  vi.stubEnv('TRUST_PROXY_HEADERS', 'true');
  vi.spyOn(console, 'log').mockImplementation(() => undefined);
  const fetch = vi.spyOn(globalThis, 'fetch');
  const check = (body: unknown) => POST(new NextRequest('https://delivery.example/api/public/refusal', {
    method: 'POST', headers: { 'content-type': 'application/json', 'x-real-ip': '198.51.100.40' }, body: JSON.stringify(body),
  }), { params: Promise.resolve({}) });
  await expect((await check({ carrier: 'china-post', trackingNumber: 'zz 1234 5678 901' })).json()).resolves.toEqual({ refused: true });
  await expect((await check({ carrier: 'china-post', trackingNumber: 'RR123456785CN' })).json()).resolves.toEqual({ refused: false });
  // A carrier that needs another input first, such as a postcode, does not refuse the number.
  await expect((await check({ carrier: 'heppner', trackingNumber: 'TEST1234' })).json()).resolves.toEqual({ refused: false });
  expect((await check({ carrier: 'no-such-carrier', trackingNumber: 'RR123456785CN' })).status).toBe(400);
  expect((await check({ carrier: 'china-post', trackingNumber: '12' })).status).toBe(400);
  expect(fetch).not.toHaveBeenCalled();
});
