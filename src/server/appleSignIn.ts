import 'server-only';

import { createPrivateKey, type KeyObject } from 'node:crypto';
import { decodeJwt, SignJWT } from 'jose';
import { logOperationalEvent } from './observability';
import { errorMessage, isRecord } from './types';

const APPLE_ID = 'https://appleid.apple.com';

export interface AppleSignInConfiguration {
  teamId: string;
  keyId: string;
  /** The bundle ID the iPhone app signs in with. */
  clientId: string;
  privateKey: KeyObject;
}

/**
 * The Sign in with Apple key the server revokes an account's Apple sign-in with, from
 * `APPLE_SIGN_IN_TEAM_ID`, `APPLE_SIGN_IN_KEY_ID`, `APPLE_SIGN_IN_PRIVATE_KEY` (the whole
 * `.p8`) and `APPLE_SIGN_IN_CLIENT_ID`. Null when none is set; partial values are rejected.
 */
export function appleSignInConfiguration(env: NodeJS.ProcessEnv = process.env): AppleSignInConfiguration | null {
  const values = {
    teamId: env.APPLE_SIGN_IN_TEAM_ID?.trim() ?? '',
    keyId: env.APPLE_SIGN_IN_KEY_ID?.trim() ?? '',
    privateKey: env.APPLE_SIGN_IN_PRIVATE_KEY?.trim() ?? '',
    clientId: env.APPLE_SIGN_IN_CLIENT_ID?.trim() ?? '',
  };
  if (!Object.values(values).some(Boolean)) return null;
  if (!Object.values(values).every(Boolean)) {
    throw new Error('APPLE_SIGN_IN_TEAM_ID, APPLE_SIGN_IN_KEY_ID, APPLE_SIGN_IN_PRIVATE_KEY and APPLE_SIGN_IN_CLIENT_ID are all required');
  }
  let privateKey: KeyObject;
  try {
    privateKey = createPrivateKey(values.privateKey.replaceAll('\\n', '\n'));
  } catch (error) {
    throw new TypeError('APPLE_SIGN_IN_PRIVATE_KEY must be a P-256 private key', { cause: error });
  }
  if (privateKey.asymmetricKeyType !== 'ec' || privateKey.asymmetricKeyDetails?.namedCurve !== 'prime256v1') {
    throw new TypeError('APPLE_SIGN_IN_PRIVATE_KEY must be a P-256 private key');
  }
  return { ...values, privateKey };
}

/** The short-lived client secret Apple's token endpoints expect. */
export async function appleClientSecret(configuration: AppleSignInConfiguration, now = Date.now()): Promise<string> {
  const issuedAt = Math.floor(now / 1_000);
  return new SignJWT({})
    .setProtectedHeader({ alg: 'ES256', kid: configuration.keyId })
    .setIssuer(configuration.teamId)
    .setSubject(configuration.clientId)
    .setAudience(APPLE_ID)
    .setIssuedAt(issuedAt)
    .setExpirationTime(issuedAt + 300)
    .sign(configuration.privateKey);
}

async function appleRequest(path: string, body: Record<string, string>): Promise<unknown> {
  const response = await fetch(`${APPLE_ID}${path}`, {
    method: 'POST',
    headers: { Accept: 'application/json', 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams(body),
    cache: 'no-store',
    redirect: 'error',
    signal: AbortSignal.timeout(10_000),
  });
  const text = await response.text();
  if (!response.ok) {
    let reason = `HTTP ${response.status}`;
    try {
      const payload: unknown = JSON.parse(text);
      if (isRecord(payload) && typeof payload.error === 'string') reason = payload.error;
    } catch {
      // Apple's error bodies are best effort; the status stands.
    }
    throw new Error(`Apple ${path} answered ${reason}`);
  }
  return text ? JSON.parse(text) : null;
}

/**
 * Ends the Apple sign-in of an account being deleted, as Apple asks: the iPhone app signs in
 * with Apple once more and sends the authorization code, which is traded for the account's
 * tokens and revoked. A code from another Apple ID than the account's is left alone.
 *
 * Best effort: a failure is logged and never keeps the account from being deleted.
 */
export async function revokeAppleSignIn(
  authorizationCode: string | undefined,
  appleSubjects: () => Promise<string[]>,
  env: NodeJS.ProcessEnv = process.env,
): Promise<'revoked' | 'skipped' | 'failed'> {
  if (!authorizationCode) return 'skipped';
  try {
    const configuration = appleSignInConfiguration(env);
    if (!configuration) {
      logOperationalEvent('apple_sign_in_revocation', { outcome: 'unconfigured' }, 'warning');
      return 'skipped';
    }
    const subjects = await appleSubjects();
    if (subjects.length === 0) return 'skipped';
    const clientSecret = await appleClientSecret(configuration);
    const tokens = await appleRequest('/auth/token', {
      client_id: configuration.clientId,
      client_secret: clientSecret,
      code: authorizationCode,
      grant_type: 'authorization_code',
    });
    if (!isRecord(tokens) || typeof tokens.id_token !== 'string') throw new Error('Apple /auth/token answered without an ID token');
    // The token comes straight from Apple over TLS for this client secret; its subject is enough.
    const subject = decodeJwt(tokens.id_token).sub;
    if (!subject || !subjects.includes(subject)) {
      logOperationalEvent('apple_sign_in_revocation', { outcome: 'other_apple_id' }, 'warning');
      return 'skipped';
    }
    const refreshToken = typeof tokens.refresh_token === 'string' ? tokens.refresh_token : null;
    const accessToken = typeof tokens.access_token === 'string' ? tokens.access_token : null;
    if (!refreshToken && !accessToken) throw new Error('Apple /auth/token answered without a token to revoke');
    await appleRequest('/auth/revoke', {
      client_id: configuration.clientId,
      client_secret: clientSecret,
      token: (refreshToken ?? accessToken)!,
      token_type_hint: refreshToken ? 'refresh_token' : 'access_token',
    });
    logOperationalEvent('apple_sign_in_revocation', { outcome: 'revoked' });
    return 'revoked';
  } catch (error) {
    logOperationalEvent('apple_sign_in_revocation', { outcome: 'failed', error: errorMessage(error) }, 'error');
    return 'failed';
  }
}
