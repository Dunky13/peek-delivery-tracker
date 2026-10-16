import { describe, expect, it } from 'vitest';
import { authConfigFromEnvironment } from './authConfig';

const environment = (values: Record<string, string> = {}) => values;

describe('authConfigFromEnvironment', () => {
  it('requires both public Supabase values', () => {
    expect(authConfigFromEnvironment(environment())).toBeNull();
    expect(authConfigFromEnvironment(environment({
      supabaseUrl: 'https://project.supabase.co',
    }))).toBeNull();
  });

  it('returns trimmed browser-safe configuration', () => {
    expect(authConfigFromEnvironment(environment({
      supabaseUrl: ' https://project.supabase.co ',
      supabasePublishableKey: ' publishable-key ',
    }))).toEqual({
      url: 'https://project.supabase.co',
      publishableKey: 'publishable-key',
      googleEnabled: false,
      appleEnabled: false,
      emailOtpEnabled: true,
      oidc: null,
    });
  });

  it('allows a sole custom provider and trims its identifier and label', () => {
    expect(authConfigFromEnvironment({
      supabaseUrl: 'https://project.supabase.co', supabasePublishableKey: 'publishable-key',
      googleEnabled: 'false', appleEnabled: 'false', emailOtpEnabled: 'false',
      oidcProvider: ' custom:authentik ', oidcName: ' Authentik ',
    })).toMatchObject({ googleEnabled: false, appleEnabled: false, emailOtpEnabled: false,
      oidc: { provider: 'custom:authentik', name: 'Authentik' } });
  });

  it('supports mixed providers and the maximum-length custom identifier', () => {
    const provider = `custom:${'a'.repeat(43)}`;
    expect(authConfigFromEnvironment({
      supabaseUrl: 'https://project.supabase.co', supabasePublishableKey: 'publishable-key',
      googleEnabled: 'true', appleEnabled: 'true', oidcProvider: provider, oidcName: 'Company sign-in',
    })).toMatchObject({ googleEnabled: true, appleEnabled: true, emailOtpEnabled: true,
      oidc: { provider, name: 'Company sign-in' } });
  });

  it('leaves whitespace-only OIDC values disabled', () => {
    expect(authConfigFromEnvironment({
      supabaseUrl: 'https://project.supabase.co', supabasePublishableKey: 'publishable-key',
      oidcProvider: ' ', oidcName: ' ',
    })?.oidc).toBeNull();
  });

  it('rejects partial and malformed custom provider configuration', () => {
    for (const [oidcProvider, oidcName] of [
      ['', 'Authentik'], ['custom:authentik', ''], ['google', 'Authentik'], ['custom:', 'Authentik'],
      ['custom:Authentik', 'Authentik'], ['custom:bad_provider', 'Authentik'], ['custom:bad/provider', 'Authentik'],
      [`custom:${'a'.repeat(44)}`, 'Authentik'],
    ]) {
      expect(authConfigFromEnvironment({
        supabaseUrl: 'https://project.supabase.co', supabasePublishableKey: 'publishable-key', oidcProvider, oidcName,
      })).toBeNull();
    }
  });

  it('rejects malformed and credential-bearing Supabase origins', () => {
    for (const supabaseUrl of [
      'not-a-url',
      'ftp://project.supabase.co',
      'https://user:password@project.supabase.co',
      'https://project.supabase.co/rest/v1',
      'https://project.supabase.co?token=private',
    ]) {
      expect(authConfigFromEnvironment(environment({
        supabaseUrl,
        supabasePublishableKey: 'publishable-key',
      }))).toBeNull();
    }
  });

  it('selects public sign-in methods from explicit build flags', () => {
    expect(authConfigFromEnvironment(environment({
      supabaseUrl: 'https://project.supabase.co',
      supabasePublishableKey: 'publishable-key',
      googleEnabled: 'true',
      appleEnabled: 'true',
      emailOtpEnabled: 'false',
    }))).toMatchObject({ googleEnabled: true, appleEnabled: true, emailOtpEnabled: false });
  });
});
