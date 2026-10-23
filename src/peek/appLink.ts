import { cleanParcelName } from './recents';

/** The iPhone app's own scheme: it opens the app from any page, once the app is installed. */
const APP_SCHEME = 'peekdeliverytracker';
const VISITED = 'peek.appStoreVisited';

/**
 * The address that opens a parcel link in the iPhone app, carrying this
 * browser's owner key, so the parcel comes along as the person's own, and its
 * name. iPhone Safari opens a link in the app only when it leads to another
 * site: `origin` names one of this server's, and without one the app's own
 * scheme stands in. The key and the name stay in the fragment, which no
 * server reads.
 */
export function appParcelURL(linkId: string, { key, name, origin }: { key: string | null; name: string | null; origin: string | null | undefined }): string {
  const cleaned = cleanParcelName(name);
  const words = [key ? `k=${key}` : '', cleaned ? `n=${encodeURIComponent(cleaned)}` : ''].filter(Boolean).join('&');
  const base = origin ? `${origin.replace(/\/+$/, '')}/p/${linkId}` : `${APP_SCHEME}://p/${linkId}`;
  return words ? `${base}#${words}` : base;
}

/** Whether this browser went to the App Store for the app, so the app is likely there to open. */
export function appStoreVisited(): boolean {
  try {
    return localStorage.getItem(VISITED) === '1';
  } catch {
    return false;
  }
}

export function noteAppStoreVisit(): void {
  try {
    localStorage.setItem(VISITED, '1');
  } catch {
    // A browser that keeps nothing offers the App Store again next time.
  }
}
