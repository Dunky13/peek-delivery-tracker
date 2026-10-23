import { afterEach, describe, expect, it } from 'vitest';
import { LINK_ID, OWNER_KEY } from '../test/parcelLinks';
import { appParcelURL, appStoreVisited, noteAppStoreVisit } from './appLink';

afterEach(() => localStorage.clear());

describe('the way into the iPhone app', () => {
  it('opens a link in the app through another of the server’s sites, with the owner key and the name after the #', () => {
    expect(appParcelURL(LINK_ID, { key: OWNER_KEY, name: ' New sneakers 👟 ', origin: 'https://old.example/' }))
      .toBe(`https://old.example/p/${LINK_ID}#k=${OWNER_KEY}&n=New%20sneakers%20%F0%9F%91%9F`);
    expect(appParcelURL(LINK_ID, { key: null, name: 'Boots', origin: 'https://old.example' })).toBe(`https://old.example/p/${LINK_ID}#n=Boots`);
  });

  it('falls back to the app’s own scheme without another site, and writes no # with nothing to carry', () => {
    expect(appParcelURL(LINK_ID, { key: OWNER_KEY, name: null, origin: null })).toBe(`peekdeliverytracker://p/${LINK_ID}#k=${OWNER_KEY}`);
    expect(appParcelURL(LINK_ID, { key: null, name: '  ', origin: undefined })).toBe(`peekdeliverytracker://p/${LINK_ID}`);
  });

  it('remembers that this browser went to the App Store', () => {
    expect(appStoreVisited()).toBe(false);
    noteAppStoreVisit();
    expect(appStoreVisited()).toBe(true);
  });
});
