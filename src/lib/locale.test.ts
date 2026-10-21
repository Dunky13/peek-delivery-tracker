import { describe, expect, it } from 'vitest';
import {
  ADDRESS_LANGUAGES, documentLanguage, interfaceLanguage, isLocale, isPageOnlyLanguage, languagePath, PAGE_LANGUAGES, PAGE_ONLY_LANGUAGES,
  pathLanguage, SUPPORTED_LOCALES, type PageOnlyLanguage,
} from './locale';

describe('language addresses', () => {
  it('gives every language but English an address of its own, and English `/`', () => {
    expect(ADDRESS_LANGUAGES).toEqual(['de', 'fr', 'it', 'es', 'pt', 'pl']);
    expect(SUPPORTED_LOCALES.map(languagePath)).toEqual(['/', '/de', '/fr', '/it', '/es', '/pt', '/pl']);
  });

  it('reads the language of a language address, and of no other address', () => {
    for (const language of ADDRESS_LANGUAGES) expect(pathLanguage(languagePath(language))).toBe(language);
    for (const path of ['/', '/en', '/home', '/demo', '/DE', '/de/', '/de/more', '/deu', '/xx', '/p/de', 'de', '']) {
      expect(pathLanguage(path), path).toBeNull();
    }
  });
});

describe('languages with pages alone', () => {
  it('are none of the site’s own, each named in its own words with its preview locale', () => {
    const languages = Object.keys(PAGE_ONLY_LANGUAGES);
    expect(languages.filter((language) => isLocale(language))).toEqual([]);
    expect(PAGE_LANGUAGES).toEqual([...SUPPORTED_LOCALES, ...languages]);
    for (const [language, { name, preview }] of Object.entries(PAGE_ONLY_LANGUAGES)) {
      expect(language).toMatch(/^[a-z]{2}$/);
      expect(preview, language).toMatch(new RegExp(`^${language}_[A-Z]{2}$`));
      expect(name.trim(), language).not.toBe('');
      expect(documentLanguage(language as PageOnlyLanguage)).toBe(language);
    }
  });

  it('stand in English around their text, and the site’s own languages in their own', () => {
    expect(isPageOnlyLanguage('fi')).toBe(true);
    for (const value of ['de', 'en', 'xx', 'FI', 'constructor', 'toString', undefined]) expect(isPageOnlyLanguage(value), String(value)).toBe(false);
    expect(interfaceLanguage('fi')).toBe('en');
    expect(interfaceLanguage('el')).toBe('en');
    for (const locale of SUPPORTED_LOCALES) expect(interfaceLanguage(locale)).toBe(locale);
  });
});
