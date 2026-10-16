import { generateKeyPairSync } from 'node:crypto';
import { jwtVerify, SignJWT } from 'jose';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { appleClientSecret, appleSignInConfiguration, revokeAppleSignIn } from './appleSignIn';

const keys = generateKeyPairSync('ec', { namedCurve: 'prime256v1' });
const pem = keys.privateKey.export({ format: 'pem', type: 'pkcs8' }).toString();
const env = (values: Record<string, string>) => values as unknown as NodeJS.ProcessEnv;
const configured = env({
  APPLE_SIGN_IN_TEAM_ID: 'ABCDE12345',
  APPLE_SIGN_IN_KEY_ID: 'KEY1234567',
  APPLE_SIGN_IN_PRIVATE_KEY: pem.replaceAll('\n', '\\n'),
  APPLE_SIGN_IN_CLIENT_ID: 'com.example.Peek',
});

async function idToken(subject: string): Promise<string> {
  return new SignJWT({}).setProtectedHeader({ alg: 'ES256' }).setSubject(subject).sign(keys.privateKey);
}

const fetchMock = vi.fn<typeof fetch>();
const bodies = () => fetchMock.mock.calls.map(([url, init]) => ({
  url: String(url),
  body: Object.fromEntries(new URLSearchParams(String(init?.body))),
}));

beforeEach(() => {
  vi.stubGlobal('fetch', fetchMock);
  vi.spyOn(console, 'log').mockImplementation(() => {});
  vi.spyOn(console, 'warn').mockImplementation(() => {});
  vi.spyOn(console, 'error').mockImplementation(() => {});
});

afterEach(() => {
  fetchMock.mockReset();
  vi.unstubAllGlobals();
  vi.restoreAllMocks();
});

describe('appleSignInConfiguration', () => {
  it('is absent until the key is set, and refuses half of one', () => {
    expect(appleSignInConfiguration(env({}))).toBeNull();
    expect(() => appleSignInConfiguration(env({ APPLE_SIGN_IN_KEY_ID: 'KEY1234567' }))).toThrow(/all required/);
    expect(() => appleSignInConfiguration(env({ ...configured, APPLE_SIGN_IN_PRIVATE_KEY: 'not a key' }))).toThrow(/P-256/);
  });

  it('reads a key whose line breaks were escaped', () => {
    expect(appleSignInConfiguration(configured)).toMatchObject({ teamId: 'ABCDE12345', clientId: 'com.example.Peek' });
  });
});

describe('appleClientSecret', () => {
  it('signs a short-lived secret for the app, as Apple asks', async () => {
    const secret = await appleClientSecret(appleSignInConfiguration(configured)!, 1_700_000_000_000);
    const { payload, protectedHeader } = await jwtVerify(secret, keys.publicKey, {
      audience: 'https://appleid.apple.com',
      issuer: 'ABCDE12345',
      subject: 'com.example.Peek',
      currentDate: new Date(1_700_000_000_000),
    });
    expect(protectedHeader).toEqual({ alg: 'ES256', kid: 'KEY1234567' });
    expect(payload.exp! - payload.iat!).toBe(300);
  });
});

describe('revokeAppleSignIn', () => {
  const subjects = vi.fn(async () => ['apple-user-1']);

  it('does nothing without a code or a key', async () => {
    expect(await revokeAppleSignIn(undefined, subjects, configured)).toBe('skipped');
    expect(await revokeAppleSignIn('code', subjects, env({}))).toBe('skipped');
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it('trades the code for the account tokens and revokes them', async () => {
    fetchMock
      .mockResolvedValueOnce(Response.json({ id_token: await idToken('apple-user-1'), refresh_token: 'refresh', access_token: 'access' }))
      .mockResolvedValueOnce(new Response(null, { status: 200 }));

    expect(await revokeAppleSignIn('code', subjects, configured)).toBe('revoked');

    const [exchange, revoke] = bodies();
    expect(exchange).toMatchObject({
      url: 'https://appleid.apple.com/auth/token',
      body: { client_id: 'com.example.Peek', code: 'code', grant_type: 'authorization_code' },
    });
    expect(exchange!.body.client_secret).toBeTruthy();
    expect(revoke).toMatchObject({
      url: 'https://appleid.apple.com/auth/revoke',
      body: { client_id: 'com.example.Peek', token: 'refresh', token_type_hint: 'refresh_token' },
    });
  });

  it('leaves another Apple ID alone', async () => {
    fetchMock.mockResolvedValueOnce(Response.json({ id_token: await idToken('apple-user-2'), refresh_token: 'refresh' }));

    expect(await revokeAppleSignIn('code', subjects, configured)).toBe('skipped');
    expect(fetchMock).toHaveBeenCalledTimes(1);
  });

  it('skips an account that never signed in with Apple', async () => {
    expect(await revokeAppleSignIn('code', async () => [], configured)).toBe('skipped');
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it('reports a refusal without throwing, so the account is still deleted', async () => {
    fetchMock.mockResolvedValueOnce(Response.json({ error: 'invalid_grant' }, { status: 400 }));

    expect(await revokeAppleSignIn('code', subjects, configured)).toBe('failed');
    expect(console.error).toHaveBeenCalledWith(expect.stringContaining('invalid_grant'));
  });
});
