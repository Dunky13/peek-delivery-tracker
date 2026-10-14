---
title: Royal Mail tracking: numbers, statuses and redelivery
description: Track a Royal Mail parcel: where the tracking number is, what Royal Mail's statuses mean, Something for You cards, redelivery, customs fees and who to contact.
slug: royal-mail-tracking
published: 2026-10-13
updated: 2026-10-13
---

Royal Mail is the UK's postal service, and its Track your item tool on royalmail.com covers Royal Mail and Parcelforce items alike. Type the reference number there (you may have to pass a quick CAPTCHA) or paste it in the box above. The number comes from the sender: look in the shop's order confirmation, shipping email or invoice.

## Royal Mail tracking number: format and where to find it

Royal Mail says its numbers are 9 to 27 characters long and may be called a barcode or a reference. It's on the label, the Post Office receipt or the shop's order confirmation. Royal Mail can't track by name or address. More in [how to find a tracking number](guide:find-tracking-number).

| Shape (invented) | What it is |
| --- | --- |
| `AB123456785GB` | The usual tracked number: 2 letters, 9 digits, `GB`. |
| `0A1234567000000000ABC` | A 21-character reference from a 2D barcode, on domestic labels. |
| `1234567890ABCDEF` | A 16-character reference of digits and the letters A to F. |

Lookalikes:

- `EA`, `EB`, `EC`, `ED`, `EE` or `CP` followed by 9 digits and `GB` belong to [Parcelforce](carrier:parcelforce), tracked on the same site.
- The same shape ending in another country's code (`RR123456785FR`) is the sending post's number. Royal Mail can follow it once the item reaches the UK.
- Sixteen digits only, with no letters, are not Royal Mail's; [Evri](carrier:evri) and others use them.

Special Delivery Guaranteed, Tracked 24, Tracked 48 and the International Tracked and Signed services are tracked. Signed For, Royal Mail 24 and 48, and 1st and 2nd Class parcels only confirm delivery.

## What Royal Mail tracking statuses mean

Royal Mail writes its tracking in English (Track your item also has a Cymraeg switch). These are the messages you'll usually meet, roughly in the order a parcel meets them:

| Royal Mail says | What it means for you |
| --- | --- |
| `Sender preparing item` | The sender has made the label. Royal Mail doesn't have the item yet. |
| `We're expecting it` | The sender says it's on its way to Royal Mail; it updates once Royal Mail processes it. |
| `Item received` | Royal Mail has it. The same words return at hubs and, from abroad, at the UK's office of exchange. |
| `In transit` | Moving through the network; one message can cover several stages. |
| `Customs charges raised` | A customs charge must be paid before delivery. |
| `Despatched to delivery office` | Heading to the office that delivers to you. |
| `Ready for delivery` | At your local delivery office, to be delivered the next time Royal Mail comes to your address. |
| `Out for delivery` | With your postie today. |
| `Delivery attempted` | Nobody could take it. |
| `Ready for redelivery or collection` | Delivery was tried and a Something for You card left. |
| `Delivered` | Delivered. A line may name who signed, perhaps a neighbour. |
| `Returned to sender` | On its way back to the sender. |

`Pending` confuses many people. Royal Mail says it means the number is known but no scan has been recorded yet; after a missed delivery it can also stay `Pending` while the item waits at the delivery office or goes back. `Request received` means Royal Mail has your delivery or redelivery request. Signed For items are scanned only twice, when received and when delivered, so the status may not change for a few days.

## Missed delivery: Something for You card and redelivery

Royal Mail aims to deliver to most addresses by 4:30pm, Monday to Saturday; some parcels come in the evening or on a Sunday. Tracked 24 aims for the next working day, Tracked 48 for two to three.

If you're out, the postie may leave the item with a neighbour either side or opposite and leaves a card saying which one. Special Delivery Guaranteed, items from abroad needing a signature and age- or ID-checked items never go to a neighbour.

Otherwise you get a [Something for You card](guide:missed-delivery), and Royal Mail tries again automatically the next working day. You can't collect after the first attempt, only after the second, from the following working day. Redelivery is free: book it at [royalmail.com/receiving-mail/redelivery](https://www.royalmail.com/receiving-mail/redelivery) or in the Royal Mail app, with 48 working hours' notice, to your address, another address in your postcode area, a Royal Mail Shop or Parcel Locker there, or your local Post Office.

To collect, bring the card and ID in the addressee's name, or the code from the email or text for a Shop or Locker. Royal Mail holds items for 18 calendar days, or 21 when a customs charge is due; a Parcel Locker keeps them 3 days, then the delivery office 18 more. After that the item goes back to the sender.

When import VAT or duty is due, Royal Mail pays it, then leaves a grey Fee to Pay card, letter, text or email. It adds a handling fee of £8 for Royal Mail items. Pay at [royalmail.com/receiving-mail/pay-a-fee](https://www.royalmail.com/receiving-mail/pay-a-fee). See [parcels held at customs](guide:customs).

## Royal Mail parcel not moving, late or lost

**No tracking details yet.** The seller may have created a number without handing the item over. After more than a day, contact the sender. See [why tracking stops updating](guide:tracking-not-updating).

**Late or lost.** Contact the sender, who holds the contract and makes enquiries with Royal Mail for you. Claims go through the sender, and not too early: from the due date plus 7 working days for Tracked 24 and 48, plus 10 for 1st and 2nd Class, plus 20 for international items in Europe and 25 elsewhere.

**Delivered but not received.** If it was scanned as delivered today, allow an extra day. Check the signatory's name, your household, neighbours, your Safeplace and any post room, then contact the sender.

## Royal Mail contact number and customer service

Royal Mail's pages list these channels for recipients (read 13 October 2026):

- **Customer Services** on 03457 740 740, given for missing signatures and delivered items that can't be found.
- **Help and Support Hub** at [help.royalmail.com](https://help.royalmail.com/personal/s/), with a [contact form](https://help.royalmail.com/s/contactsupport).
- **Redelivery and fees** online, through the pages above or the Royal Mail app.

> Royal Mail only texts or emails you when the sender asked for tracking updates, and never asks for bank details or for unpaid postage by text or email: it leaves a grey Fee to Pay card. Forward scam texts to 7726 and scam emails to reportascam@royalmail.com.

## Tracking Royal Mail parcels with Peek

[Peek](/) names Royal Mail at once for a valid `AB123456785GB`-style number; if the check digit fails, check the number or press "Change". For 21- and 16-character references it asks tracking services first and Royal Mail's site last, so this can take a little while; if nothing answers, or a rare reference is named Australia Post, pick Royal Mail with "Change". A royalmail.com link with `trackNumber=` works with any of these numbers; a `#/tracking-results/` link only with a number ending `GB`.

Peek opens royalmail.com in a browser on its own server. Royal Mail often refuses automated visits, so a Royal Mail parcel is checked at most once an hour, even on delivery day, and tracking services hold little of its history: it can stay on its last status for hours.

You see the status, each scan on a map with its place (postcodes removed), the expected delivery day, the delivery time and the destination country. UK scans carry exact times. Delivered lines read "Delivered", without who signed, and the recipient, address and photo are dropped. Other statuses keep Royal Mail's wording. You can be notified of every update, important steps only or delivery day only.

A parcel from abroad with a postal number can be followed on Royal Mail once Royal Mail shows progress. Redelivery and fee payment stay on royalmail.com.

## Questions about Royal Mail tracking

### How long does Royal Mail tracking take to update?

There's no fixed time: an item updates at its next scan. Signed For items are scanned only twice, so they can look still for a few days.

### Is Royal Mail redelivery free?

Yes. Royal Mail redelivers free of charge to your address, a nearby address, a Royal Mail Shop, a Parcel Locker or your local Post Office, with 48 working hours' notice.

### What is a Royal Mail Something for You card?

It's the card left when nobody could take an item. It says Royal Mail will try again the next working day, or that the item waits at your delivery office.

### Is my Royal Mail tracking number fake?

Probably not, if Track your item shows no details yet: the seller may not have handed the item over. After more than a day, ask the sender.

:::sources
- [Royal Mail: Track your Item](https://www.royalmail.com/track-your-item) – tracking tool, Parcelforce, Cymraeg
- [Royal Mail: What is Track your item and how do I use it?](https://www.royalmail.com/help/how-to-track-your-item) – tracked services, CAPTCHA
- [Royal Mail: I need help with my reference number](https://www.royalmail.com/help/tracking-reference-number) – 9 to 27 characters, where to find it
- [Royal Mail: URL links, using the tracking reference number](https://www.royalmail.com/royal-mail-you/intellectual-property-rights/linking-our-website) – GB format, Parcelforce prefixes
- [Royal Mail: What does my tracking message mean?](https://www.royalmail.com/help/postage-tracking-terms-explained) – status glossary
- [Royal Mail: Pending message](https://www.royalmail.com/royal-mail-pending-message) – Pending, help hub
- [Royal Mail: My tracking message looks wrong](https://www.royalmail.com/help/tracking-message-looks-wrong) – no details yet, two scans, missed scans
- [Royal Mail: Tracking items posted to the UK from another country](https://www.royalmail.com/help/tracking-items-sent-to-uk-from-abroad) – inbound tracking
- [Royal Mail: What time and days do you deliver?](https://www.royalmail.com/help/when-will-my-item-arrive) – 4:30pm, evenings, Sundays
- [Royal Mail: Item left with a neighbour](https://www.royalmail.com/help/item-left-with-neighbour) – neighbours, exclusions
- [Royal Mail: Changes to our redelivery service](https://www.royalmail.com/auto-redelivery) – automatic redelivery, collection after second attempt, 03457 740 740
- [Royal Mail: Redelivery](https://www.royalmail.com/receiving-mail/redelivery) – free redelivery, options, holding times, ID
- [Royal Mail: What happens if you can't deliver my mail?](https://www.royalmail.com/help/what-happens-if-royal-mail-cant-deliver) – 18 and 21 days, return
- [Royal Mail: Pay a Fee](https://www.royalmail.com/receiving-mail/pay-a-fee) – Fee to Pay, £8 handling fee
- [Royal Mail: My item hasn't arrived yet](https://www.royalmail.com/help/lost-items-parcels-letters) – delivery aims, claims, contact the sender
- [Royal Mail: Item shown as delivered but it hasn't been](https://www.royalmail.com/help/item-shown-as-delivered-but-has-not-been) – checks, extra day
- [Royal Mail: Signatures for Track your item](https://www.royalmail.com/help/signatures-on-track-your-item) – 72 hours, Customer Services
- [Royal Mail: Scam advice](https://www.royalmail.com/help/scam-protection) – genuine messages, 7726, reporting
- [Universal Parcel Scraper](https://github.com/plhery/universal-parcel-scraper) – what Peek reads from Royal Mail
:::
