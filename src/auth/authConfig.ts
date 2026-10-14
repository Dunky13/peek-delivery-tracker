import type { AuthConfig } from './AuthContext';

export interface OidcConfig {
  provider: `custom:${string}`;
  name: string;
}

/** Supabase custom-provider identifiers, including their required prefix. */
function isCustomProvider(value: string): value is OidcConfig['provider'] {
  return value.length <= 50 && /^custom:[a-z0-9:-]+$/.test(value);
}

export interface PublicAuthEnvironment {
  supabaseUrl?: string;
  supabasePublishableKey?: string;
  googleEnabled?: string;
  appleEnabled?: string;
  emailOtpEnabled?: string;
  oidcProvider?: string;
  oidcName?: string;
}

export function authConfigFromEnvironment(
  environment: PublicAuthEnvironment,
): AuthConfig | null {
  const rawUrl = environment.supabaseUrl?.trim() ?? '';
  const publishableKey = environment.supabasePublishableKey?.trim() ?? '';
  if (!rawUrl || !publishableKey) return null;
  let url: URL;
  try {
    url = new URL(rawUrl);
  } catch {
    return null;
  }
  if (
    !['http:', 'https:'].includes(url.protocol)
    || !url.hostname
    || url.username
    || url.password
    || (url.pathname !== '/' && url.pathname !== '')
    || url.search
    || url.hash
  ) return null;
  const provider = environment.oidcProvider?.trim() ?? '';
  const name = environment.oidcName?.trim() ?? '';
  if ((provider || name) && (!isCustomProvider(provider) || !name)) return null;
  return {
    url: url.origin,
    publishableKey,
    googleEnabled: environment.googleEnabled === 'true',
    appleEnabled: environment.appleEnabled === 'true',
    emailOtpEnabled: environment.emailOtpEnabled !== 'false',
    oidc: isCustomProvider(provider) && name ? { provider, name } : null,
  };
}
