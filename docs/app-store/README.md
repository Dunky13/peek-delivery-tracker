# App Store

What App Store Connect asks for Peek's iPhone app. Building and uploading is in
[ios/README.md](../../ios/README.md).

## Listing

[`listing/`](listing) has the name, subtitle, promotional text, description and keywords for
each language. `en.md` serves English (U.S.), the primary language, and English (U.K.);
`es.md` is Spanish (Spain) and `pt.md` Portuguese (Portugal).

Keywords are counted in bytes (an accented letter counts two) and can't name other
companies. App Store Connect doesn't take What's New for the first version.

Once the app record exists, `ASC_KEY_ID=… ASC_ISSUER_ID=… node scripts/app-store-listing.mjs`
prints what it would set from `listing/` and this page; `--apply` sets it.

## App information

- Bundle ID `com.plhery.PeekDeliveryTracker`; SKU `peek-ios`.
- Category: Utilities. No secondary category.
- Content rights: the app shows third-party content (what carriers publish about a parcel,
  GeoNames and OpenStreetMap places), which it may show.
- Age rating: answer No or None to every question. That gives 4+. Friends see each other's
  delivery counts and stamps, never parcels or messages, so there's no user-generated
  content, social media or chat.
- Price: free, in every country. No in-app purchases.
- Support URL `https://peektracker.com/support.html`, marketing URL
  `https://peektracker.com`, privacy policy URL `https://peektracker.com/privacy.html`.
- Copyright: the year and the account holder's name.
- Export compliance: `ITSAppUsesNonExemptEncryption` is `NO` in the app's `Info.plist`, so
  builds need no answer.

## App Privacy

Follow the app's [`PrivacyInfo.xcprivacy`](../../ios/PeekDeliveryTracker/PrivacyInfo.xcprivacy)
and [PRIVACY.md](../../PRIVACY.md). Nothing is used for tracking.

- Linked to the user, for app functionality: Email Address, Name (from Google sign-in), User
  ID, Device ID (the push token), Other User Content (tracking numbers, parcel names,
  postcodes, feedback), Other Data Types.
- Not linked, for analytics: Coarse Location (the country of a request) and Product
  Interaction.

## App Review

Review notes, in English:

```text
Peek follows parcels from more than 3,500 carriers. It is free and sells nothing.

Without an account: paste or type a tracking number on the first screen (a current one is at the end of these notes). Peek finds the carrier and shows the parcel's journey. These parcels stay on the iPhone.

An account adds notifications, sync with the web app and Friends. Sign in with Apple creates one in a step, so no demo account is needed. Google and a one-time email code are also offered.

Deleting an account: Account, then Delete account, then type the account's email. An account that uses Sign in with Apple is asked to sign in with Apple once more, and the server revokes its Apple tokens before deleting it.

Anonymous lookups are checked with App Attest, or with a short Cloudflare Turnstile check when App Attest isn't available. Links to peektracker.com/p/ and /i/ open in the app.

A tracking number to try:
```

Add a parcel currently in transit after the last line when submitting. Keep it out of the
repository.

## Screenshots

The app is iPhone-only. Take them in the demo, whose parcels are made up, on an iPhone 18 Pro
Max simulator: a Debug build launched with `-sdt.native.experience.v1 demo
-sdt.debug.storeScreenshots YES`, which leaves out the demo's top bar. 1320 × 2868 PNG
without alpha, for the 6.9" display; App Store Connect scales them for smaller iPhones.

## First submission

Once per app, in App Store Connect or the developer portal:

1. The Account Holder accepts the latest Apple Developer Program License Agreement.
2. Register the App Group `group.com.plhery.PeekDeliveryTracker` and assign it to the app
   and its two extensions.
3. Create the app record with the bundle ID above.
4. Create a key with Apple Push Notifications and Sign in with Apple, and set `APNS_*` and
   `APPLE_SIGN_IN_*` on the server ([DEPLOYMENT.md](../DEPLOYMENT.md)).
5. Declare the Digital Services Act trader status, fill in App Privacy and publish it.
6. Choose whether the app is offered on Apple silicon Macs and Apple Vision Pro.
