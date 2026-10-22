# iPhone app

Peek on the iPhone is a native SwiftUI app (not a web view) for iOS 18+, with a Share
extension and Home Screen widgets. It uses Liquid Glass on iOS 26 and materials on older
versions. It talks to the same `/api` as the web app: signed in, or without an account through the
public parcel links, whose owner keys it keeps in the keychain.

## Run the demo

Open `PeekDeliveryTracker.xcodeproj` in Xcode 27, pick the `PeekDeliveryTracker` scheme
and an iPhone simulator, and press Run. That's it: the checked-in configuration starts in
demo mode, so you need no account, no network and no Apple team. Refresh moves the
made-up parcels along, and Account resets them.

## Connect to a server

Copy `Configuration/Local.xcconfig.example` to `Configuration/Local.xcconfig` (gitignored)
and set the API origin, Supabase URL and publishable key. Never put a service-role key,
APNs key, OAuth secret or SMTP credential in the app.

- Add `peekdeliverytracker://auth-callback` to the Supabase redirect allow list.
- Supabase is used only for sign-in. All parcel changes go through the API.
- Building from a temporary checkout? Copy `Local.xcconfig` into its `ios/Configuration/`
  first. Before installing an account build, check it with
  `node scripts/validate-ios-install.mjs /path/to/PeekDeliveryTracker.app`.
  `scripts/refresh-ios-app.sh` runs this for you and refuses unconfigured builds.
- The carrier catalog refreshes from `/api/carriers` (ETag-cached) at launch and on
  foreground, with the generated catalog bundled as offline fallback. New carriers don't
  need an app release.

## Links that open in the app

Parcel links (`/p/…`) and invitations (`/i/…`, `/invite`) open in the app when it is
installed. Two things make that work, both set in `Configuration/Shared.xcconfig`:

- **Associated Domains** (`SDT_ASSOCIATED_DOMAIN`, `SDT_ASSOCIATED_DOMAIN_LEGACY`) tell iOS
  which hosts hand their links to the app. Each host must serve
  `/.well-known/apple-app-site-association` naming this app
  ([DEPLOYMENT.md](../docs/DEPLOYMENT.md)).
- **Accepted hosts**: the app opens a link only from the host of `SDT_API_BASE_URL` or from
  `SDT_LINK_HOSTS`, the hosts the site answered on before. It never calls those hosts and
  never shares a link on them.

Elsewhere, `peekdeliverytracker://p/<id>` and `peekdeliverytracker://invite#<key>` open
the same screens.

A parcel's detail shares the parcel through such a link, built on the host of
`SDT_API_BASE_URL`. The name, a gift's note and who it is from travel after the link's `#`:
they stay on the device and never reach the API. In the demo the link is made up and leads
nowhere.

## The deliveries

A long press on a parcel's card, or a secondary click, opens its menu; a pointer lights the
card up. The menu opens and shares the parcel and does what its page's ••• menu does: rename
it, copy its tracking number, change its carrier, archive it with Undo as a swipe does or
bring it back, and delete it once confirmed.

Text or a link dropped on the deliveries or on + opens Add with it, as a paste or the Share
extension does. A drop with no tracking number in it is refused.

With a keyboard, ⌘N adds a parcel, ⌘F searches, ⌘R refreshes where its button shows, ⌘1 to ⌘3
choose the tabs and ⌘, opens Settings. On the parcel shown, beside the list or over it, ⇧⌘C
copies its tracking number, ⌃⌘A archives it or brings it back and ⌘⌫ deletes it once confirmed;
while a keyboard is connected, its menus show these keys. ⌘Z undoes an archive while its toast
shows. Beside a parcel, ↑ and ↓ open the card before or after it, as a tap would, and Return
opens the one shown by itself; Esc goes back from a parcel over the list. A key acts only on the
screen in front, with no sheet, alert or popover over it, and the search field keeps the keys it
edits with.

## Signing for a device

1. Select your team for the app, `ShareExtension` and `DeliveryWidget` targets.
2. Register the three bundle ids (`com.plhery.PeekDeliveryTracker` and its extensions),
   or change them to your own.
3. Create the App Group, set `SDT_APP_GROUP_IDENTIFIER` in `Shared.xcconfig`, and enable
   it on all three targets.
4. Enable Push Notifications, Associated Domains and App Attest on the app id.
5. Create an APNs key and set `APNS_TEAM_ID`, `APNS_KEY_ID`, `APNS_PRIVATE_KEY` and
   `APNS_BUNDLE_ID` on the server. The bundle id must match the installed app.

`scripts/refresh-ios-app.sh` can also install with a free Personal Team. Apple doesn't
allow App Groups, push or Associated Domains there, so the widget can't read parcels and links
open in the browser first: the invitation page then offers "Open in the iOS app". Sign in with Apple also needs a paid
team ([AUTHENTICATION.md](../docs/AUTHENTICATION.md)). App Attest also needs a
paid team. The Personal Team project disables it and uses Turnstile for anonymous
lookups instead. No paid Cloudflare account is needed.

New anonymous lookups verify silently with App Attest when the server enables it.
Otherwise a small Turnstile sheet appears when needed; its proof lasts fifteen
minutes in memory. Cancelling keeps the form intact. Detection while typing uses an existing proof
or silent App Attest and never opens the sheet. Saved parcels and local
carrier detection do not need a check. Signed in, parcel additions, detection
that asks carriers and refreshes are signed with the registered key when the
signature is ready within two seconds, and go unsigned otherwise; they never open
the sheet or register a key. A refused one is signed again once, and a refusal
never signs the user out. Debug uses development App Attest keys,
Release uses production keys; only a separate development server accepts the
former. Server settings are in [DEPLOYMENT.md](../docs/DEPLOYMENT.md).

## App Store builds

- Each of the three targets carries a `PrivacyInfo.xcprivacy`. The app's lists the data
  [PRIVACY.md](../PRIVACY.md) describes; change the two together.
- The App Store doesn't take Google sign-in without Sign in with Apple: set
  `SDT_APPLE_AUTH_ENABLED = YES` in `Local.xcconfig` along with Google.
- The app and its extensions share one version, `MARKETING_VERSION` in the project.
- `scripts/upload-ios-app.sh` archives Release and uploads it to App Store Connect with an
  API key: `ASC_KEY_ID`, `ASC_ISSUER_ID`, and the `.p8` in
  `~/.appstoreconnect/private_keys/`. `--export` only writes the signed `.ipa`. The build
  number is the commit count. It needs a production `Local.xcconfig`, a clean `ios/`, the
  App Group on the three identifiers and the app record in App Store Connect.
- The listing, review notes and privacy answers are in
  [docs/app-store](../docs/app-store/README.md).

## Notifications and widgets

- The app asks for notification permission only after the user taps Enable (from a small
  prompt above the tab bar, or from Account). The device token goes to the API and isn't
  stored locally. Debug builds use the APNs sandbox and Release builds use production.
- **Live Activities** are switched off (`ParcelStore.offersLiveActivities`, and
  `NSSupportsLiveActivities` in `Info.plist`). Settings has no switch for them, and the
  app ends any still showing and withdraws the iPhone's registration, so the server
  starts none.
- **The widget** shows the next parcel and up to two out-for-delivery parcels. Tapping one
  opens it.
- **The delivery email** belongs to the account, not the device. Settings › Delivery updates
  has its switch, which saves the moment it is flipped. While it is on, the bell of a parcel
  still on its way opens that parcel's alerts, where notifications and the email are switched
  for it alone. A delivered parcel offers the email once to an account that has never chosen.
  None of this shows unless the server says it can email the account, and never in the demo.

## Resources and tests

After changing the API contract, carriers or copy:

```bash
npm run contract:generate   # Swift models and catalog from contracts/openapi.json
npm run ios:resources       # translations, message map, analytics catalog, map data
```

Build from `ios/`:

```bash
xcodebuild -project PeekDeliveryTracker.xcodeproj -scheme PeekDeliveryTracker \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```

To run the unit tests, swap `build` for `test` and name a real simulator, for example
`-destination 'platform=iOS Simulator,name=iPhone 18 Pro'`. Push itself can only be tried
with a signed build on a real phone.

Analytics (optional) follows [ANALYTICS.md](../docs/ANALYTICS.md). Simulator and demo
builds never send events.
