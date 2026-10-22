// @vitest-environment node
import { existsSync, readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

type Manifest = { version: string; dependencies?: Record<string, string>; peerDependencies?: Record<string, string> };
type Lockfile = { packages?: Record<string, { resolved?: string }> };
const json = <T>(path: string) => JSON.parse(readFileSync(new URL(path, import.meta.url), 'utf8')) as T;
const app = json<Manifest>('../../package.json');
const scraper = json<Manifest>('../../node_modules/universal-parcel-scraper/package.json');
const pin = app.dependencies?.['universal-parcel-scraper'];

// Where npm last installed the scraper from: node_modules/.package-lock.json records every
// install, `--no-save` ones included, which leave package.json and package-lock.json alone.
const hiddenLockfile = new URL('../../node_modules/.package-lock.json', import.meta.url);
const installedFrom = existsSync(hiddenLockfile)
  ? json<Lockfile>(hiddenLockfile.href).packages?.['node_modules/universal-parcel-scraper']?.resolved
  : undefined;

describe('the scraper dependency', () => {
  // A release, or a prerelease of the scraper's main branch.
  it('is an exact release', () => {
    expect(pin).toMatch(/^\d+\.\d+\.\d+(-main\.\d+)?$/);
  });

  // A scraper change is tried on the app with its packed tarball, `npm install --no-save
  // <tarball>`, so another version than the pin is installed: outside CI, which installs
  // the pin with `npm ci`, this skips and says so.
  it('is the one installed', (context) => {
    if (!process.env.CI && scraper.version !== pin && /^file:.+\.tgz$/.test(installedFrom ?? '')) {
      const note = `universal-parcel-scraper ${scraper.version} is installed from a packed tarball, not the pinned ${pin}`;
      console.warn(`Pin check skipped: ${note}. CI checks the pin.`);
      context.skip(note);
    }
    expect(scraper.version).toBe(pin);
  });

  // `.npmrc` sets legacy-peer-deps, so npm does not check the scraper's peers.
  it('comes with the transports it asks for, at its versions', () => {
    expect(app.dependencies).toMatchObject(scraper.peerDependencies ?? {});
  });
});
