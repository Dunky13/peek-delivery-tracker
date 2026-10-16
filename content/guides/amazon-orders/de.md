---
title: Amazon-Sendungsverfolgung: Amazon, Verkäufer, Zusteller
description: Wer deine Amazon-Bestellung versendet, welcher Zusteller sie bringt, warum die Sendungsnummer wechselt oder fehlt und wann die A-bis-z-Garantie hilft.
slug: amazon-sendungsverfolgung
picture: Ein Handy zeigt den Fortschritt einer Bestellung, zwei Lieferwagen reichen sich ein Paket weiter, und Pip schaut zu.
published: 2026-10-16
updated: 2026-10-16
---

Eine Amazon-Bestellung verfolgst du unter „Meine Bestellungen“: Bestellung wählen, dann „Sendung verfolgen“. Dort zeigt Amazon das Transportunternehmen, die Sendungsverfolgungsnummer und jeden Schritt. Wer dir bei Problemen hilft, hängt davon ab, wer versendet: Amazon kümmert sich um eigene Bestellungen und um „Versand durch Amazon“, ein Verkäufer mit eigenem Versand wählt den Zusteller selbst und ist für die Lieferung zuständig.

## Wer versendet meine Amazon-Bestellung: Amazon oder ein Verkäufer?

Schau unter der Schaltfläche „Jetzt kaufen“ auf „Verkauft von“ und „Versand von“, oder in „Meine Bestellungen“ auf den Verkäufernamen.

| Was auf der Seite steht | Was es heißt | Wer bei der Lieferung hilft |
| --- | --- | --- |
| Verkauft von Amazon, Versand von Amazon | Amazons eigene Ware | Amazon |
| Verkauft von einem Verkäufer, Versand von Amazon | „Versand durch Amazon“: Ware des Verkäufers, verpackt und verschickt aus einem Amazon-Versandzentrum | Amazon |
| Verkauft von und Versand von demselben Verkäufer | Der Verkäufer verschickt selbst, mit einem Zusteller seiner Wahl | Zuerst der Verkäufer |

Amazon schreibt dazu: Steht dort „Versand von (Verkäufername)“, „kümmert sich der Verkäufer in der Regel selbst um seinen Kundenservice“. Ausnahme: Marketplace-Verkäufer betreuen ihre Bestellungen selbst, „es sei denn, der Artikel ist mit Amazon Prime bestellbar“.

Ein weiterer Fall: **Zustellung abgewickelt von Amazon.** Der Verkäufer bietet den Artikel an und versendet ihn, aber Amazon wickelt die Lieferung ab. „Amazon kann externe Transportdienstleister mit der Lieferung beauftragen.“

**In Österreich** bestellst du auf amazon.de. Kommt der Artikel aus einem Versandzentrum außerhalb Deutschlands, kann die Zustellung bis zu zwei Tage länger dauern.

**In der Schweiz** gibt es keinen eigenen Amazon-Shop: amazon.ch leitet auf amazon.de weiter. Amazon.de liefert auch in die Schweiz. Was Amazon versendet, kommt im Standardversand in 3 bis 5 Werktagen, per Express in 1 bis 3, und der Endpreis enthält Zollgebühren und Umsatzsteuer: „Du musst nichts an die Zollbehörden zahlen.“ Verkauft und versendet ein Verkäufer selbst, können Zoll und Umsatzsteuer fällig werden, wenn er sie nicht im Preis hat. Mehr dazu: [Paket beim Zoll](guide:customs). Auch amazon.fr liefert in die Schweiz.

## Welches Transportunternehmen liefert mein Amazon-Paket?

„Sendung verfolgen“ nennt es. Amazon sagt klar: „Für jedes Paket kann ein anderes Transportunternehmen zuständig sein.“ Steht dort Amazon, ist es [Amazon Logistics](carrier:amazon-logistics), Amazons eigenes Zustellnetz. Diese Zusteller nennt Amazon auf seinen Kontaktseiten:

| Land | Shop | Transportunternehmen laut Amazon |
| --- | --- | --- |
| Deutschland | amazon.de | Amazon, [DHL](carrier:dhl), [DHL Express](carrier:dhl-express), DHL 2-Mann-Handling, Deutsche Post, [DPD](carrier:dpd-de), [Hermes](carrier:hermes-de), Hermes Einrichtungs-Service, Stadtbote, [UPS](carrier:ups) |
| Österreich | amazon.de | Amazon, DHL Österreich, DPD Österreich, [Österreichische Post](carrier:austrian-post), UPS |
| Schweiz | amazon.de, amazon.fr | [Quickpac](carrier:quickpac) (Liste von amazon.de), [Die Post](carrier:swiss-post) („Poste Suisse“ auf der Liste von amazon.fr) |

Der Hermes Einrichtungs-Service bietet keine Online-Sendungsverfolgung: Solche Speditionsartikel verfolgst du über „Mein Konto“. Ein Verkäufer mit eigenem Versand kann jeden dieser Zusteller nehmen, oder einen anderen. Wo die Nummer bei jedem Shop steht: [Sendungsnummer finden](guide:find-tracking-number).

## Wie sieht eine Amazon-Sendungsnummer aus?

Es gibt zwei Arten, und dazu eine Bestellnummer, die keine von beiden ist.

Amazon veröffentlicht das Format seiner eigenen Nummern nicht. Diese Formen erkennt Peek als Amazon-Nummern, hier mit erfundenen Ziffern:

:::anatomy TBA 123456789012
- TBA | Amazon-Buchstaben. `TBC` und `TBM` funktionieren genauso
- 123456789012 | Zwölf Ziffern
:::

| Form (erfunden) | Was es ist |
| --- | --- |
| `TBA123456789012` | Amazon: `TBA`, `TBC` oder `TBM` und 12 Ziffern |
| `DE1234567890` | Amazon in Europa: ein Ländercode (`DE`, `AT`, `CH` und andere) und 10 Ziffern |
| `123-1234567-1234567` | Deine Amazon-Bestellnummer: 3, 7 und 7 Ziffern. Keine Sendungsnummer |
| Alles andere | Die Nummer des Zustellers, etwa von DHL oder Hermes |

Die Nummer eines Zustellers funktioniert auf dessen Seite, siehe [Sendungsnummern-Formate](guide:tracking-number-formats). Unsicher, welche du hast? Tipp sie hier ein:

:::checker
:::

## Warum hat sich meine Amazon-Sendungsnummer geändert, oder warum gibt es zwei?

Meist aus einem dieser Gründe:

- **Mehrere Artikel, mehrere Pakete.** „Wenn du mehr als einen Artikel bestellt hast, haben diese Artikel möglicherweise separate Lieferdaten und Sendungsverfolgungsinformationen.“ Fehlt ein Artikel im Paket, wurde er möglicherweise separat versendet.
- **Ein anderer Zusteller übernimmt.** „In der ersten Phase der Sendung kann ein Zwischenzusteller eingesetzt werden“, und dessen Daten stehen dann nicht auf der Website. Bei „Zustellung abgewickelt von Amazon“ kann Amazon ein externes Transportunternehmen beauftragen.
- **Der Verkäufer nimmt seinen eigenen Zusteller.** Dann ist die Nummer die von DHL, Hermes oder einem anderen, nicht von Amazon.

:::journey
- warehouse | Amazon oder Verkäufer | Mehrere Artikel können als mehrere Pakete losgehen, jedes mit eigener Nummer
- label | Etikett erstellt | Nicht immer sofort verfolgbar: Die Datenbank hinkt manchmal hinterher
- handover | Zwischenzusteller | Erste Phase oft ohne Daten auf der Website
- truck | In Zustellung | Manche Zusteller liefern bis 22 Uhr
- home | Du | Kann schon vor der Ankunft als zugestellt gescannt sein
:::

Nennt der erste Zusteller den Partner, der übernimmt, behält [Peek](/) den ersten Verlauf, folgt dem Partner, sobald dessen Tracking neue Schritte zeigt, und zeigt auf der Karte Namen und Nummer des Partners.

## Warum gibt es keine Sendungsverfolgung für meine Amazon-Bestellung?

Amazon nennt auf der Seite „Fehlende Details zum Sendungsverlauf“ diese Gründe:

- **Nicht verfolgbare Versandart.** „Einige Sendungen wie Großbriefe der Deutschen Post und internationale Standardlieferungen sind nicht verfolgbar.“
- **Verzögerte Daten.** Die Sendungsverfolgungs-Datenbank wird manchmal verspätet aktualisiert.
- **Zwischenzusteller.** In der ersten Phase gibt es dann keine Daten auf der Website.
- **Der Verkäufer hat nichts übermittelt.** „Marketplace-Verkäufer übermitteln nicht immer die Details zum Sendungsverlauf für ihre Bestellungen an Amazon.“ Verkäufer-Sendungen sind nur verfolgbar, wenn der Verkäufer die Daten teilt und du eine verfolgbare Versandart gewählt hast.

Ist das voraussichtliche Lieferdatum vorbei und nichts Neues zu sehen, „warte bitte noch ein oder zwei Werktage ab“. Fehlt bei einem Verkäufer-Paket die Verfolgung ganz, geh in „Meine Bestellungen“ auf den Artikel, wähle „Problem bei Bestellung“ und schreib dem Verkäufer. Wenn das Tracking tagelang stillsteht: [warum die Sendungsverfolgung nicht aktualisiert](guide:tracking-not-updating).

## Was tun, wenn die Amazon-Bestellung zu spät ist oder als zugestellt gilt?

Amazons Status in „Meine Bestellungen“ sind `Ankunft`, `In Zustellung`, `Geliefert` und `Nicht zustellbar`. Der letzte heißt: Das Paket geht an Amazon zurück, und du bekommst dein Geld automatisch, sobald es dort ankommt. Sonst gehst du so vor:

:::steps
- 48 Stunden warten | „Die meisten verspäteten Pakete kommen innerhalb von 48 Stunden“ nach dem voraussichtlichen Datum an. Pakete können auch schon vor der Ankunft als zugestellt gescannt werden.
- Umschauen | Prüfe den Ablageort, den Briefkasten und frag die Nachbarn. Manche Zusteller liefern bis 22 Uhr.
- Zusteller fragen | „Sendung verfolgen“ nennt ihn. Amazons Seite „Ein Transportunternehmen kontaktieren“ verlinkt jeden.
- Verkäufer kontaktieren | Hat ein Verkäufer verkauft und versendet: „Meine Bestellungen“, „Problem bei Bestellung“. „Verkäufer antworten innerhalb von 48 Stunden per E-Mail.“
- Amazon fragen | Von Amazon versendet: Kundenservice, innerhalb von 30 Tagen nach der erwarteten Zustellung. Verkäufer-Bestellung: A-bis-z-Garantie.
:::

Mehr zu jedem Fall: [zugestellt, aber nicht angekommen](guide:delivered-not-received) und [Paket verloren](guide:lost-parcel).

### Wann greift die A-bis-z-Garantie?

Sie gilt, wenn ein Marketplace-Verkäufer den Artikel verkauft und selbst versendet hat und das letzte mögliche Lieferdatum 90 Tage oder weniger zurückliegt. Für ein Paket, das nie kam, müssen seit dem letzten voraussichtlichen Lieferdatum (oder der bestätigten Lieferung) drei Tage vergangen sein. Außerdem musst du den Verkäufer kontaktiert haben, und er hat nicht innerhalb von 48 Stunden geantwortet oder das Problem nicht gelöst.

| Frist | Amazon.de (Deutschland, Österreich, Schweiz) |
| --- | --- |
| Antwort des Verkäufers | 48 Stunden |
| Warten nach dem letzten voraussichtlichen Lieferdatum | Drei Tage |
| Antrag möglich bis | 90 Tage nach dem letzten möglichen Lieferdatum |

Du stellst den Antrag in „Meine Bestellungen“ über „Problem mit der Bestellung“. Hat der Verkäufer Zusatzkosten wie eine Zollgebühr nicht erstattet, kannst du auch dafür einen Antrag stellen.

## Kann ich ein Amazon-Paket außerhalb von Amazon verfolgen?

Das hängt von der Nummer ab. Füge sie in [Peek](/) ein:

- **Die Nummer eines Zustellers** (DHL, Hermes, DPD, Österreichische Post, Die Post…) wird wie jedes andere Paket verfolgt.
- **Eine Amazon-Nummer** oder ein track.amazon-Link: Peek fragt zuerst Amazons öffentlichen Tracker. Antwortet Amazon, reist das Paket mit [Amazon Shipping](carrier:amazon-shipping), Amazons Lieferdienst für andere Händler und Amazon-Verkäufer, oder mit dem Multi-Channel-Versand, bei dem Amazon Bestellungen aus anderen Shops oft in neutraler Verpackung verschickt. Dann verfolgt Peek es automatisch.
- Sonst liefert Amazon Logistics eine Amazon-Bestellung, und die zeigt Amazon nur in deinem Konto. Peek sagt dir das und bietet „Meine Amazon-Bestellungen öffnen“ an: Das öffnet deine Bestellübersicht auf der Amazon-Seite, zu der die Nummer passt, bei `DE` und `AT` also amazon.de. Peek fragt nie nach deinem Amazon-Login.
- **Eine Bestellnummer** bekommt „Das sieht nach einer Amazon-Bestellnummer aus“. Nimm stattdessen die Sendungsnummer aus „Sendung verfolgen“ oder der Versandmail.

:::sources
- [Amazon.de: Ein Transportunternehmen kontaktieren](https://www.amazon.de/gp/help/customer/display.html?nodeId=GBPEXEXYULHB5WCH) – Zusteller in Deutschland und Österreich, Quickpac, Hermes Einrichtungs-Service, ein Zusteller pro Paket
- [Amazon.de: Bestellen bei einem Marketplace-Verkäufer](https://www.amazon.de/gp/help/customer/display.html?nodeId=GEF528GN65XSJ7V8) – Verkauft von, Versand von, Kundenservice des Verkäufers
- [Amazon.de: Versand durch Amazon](https://www.amazon.de/gp/help/customer/display.html?nodeId=G239KSGYPUFUY8TQ) – Ware von Verkäufern, versendet aus Amazon-Versandzentren
- [Amazon.de: Versand abgewickelt von Amazon](https://www.amazon.de/gp/help/customer/display.html?nodeId=GJK6YT2NCPCAV7DC) – Verkäufer versendet, Amazon liefert, externe Transportdienstleister
- [Amazon.de: Sendung verfolgen](https://www.amazon.de/gp/help/customer/display.html?nodeId=GENAFPTNLHV7ZACW) – getrennte Sendungen, Status, 48 Stunden, Verkäufer-Tracking
- [Amazon.de: Fehlende Details zum Sendungsverlauf](https://www.amazon.de/gp/help/customer/display.html?nodeId=G6ZFEB9ZDU7QHMER) – nicht verfolgbare Sendungen, Zwischenzusteller, ein oder zwei Werktage
- [Amazon.de: Ein fehlendes Paket finden, das laut Sendungsverfolgung zugestellt wurde](https://www.amazon.de/gp/help/customer/display.html?nodeId=GCU8BWGTQNJKQEBS) – 22 Uhr, 48 Stunden, 30 Tage
- [Amazon.de: Einen Marketplace-Verkäufer kontaktieren](https://www.amazon.de/gp/help/customer/display.html?nodeId=GLC8ZMBWMBTR6QZZ) – Problem bei Bestellung, 48 Stunden, Prime
- [Amazon.de: A-bis-z-Garantie](https://www.amazon.de/gp/help/customer/display.html?nodeId=GQ37ZCNECJKTFYQV) – 90 Tage, drei Tage, 48 Stunden, Zollgebühr
- [Amazon.de: Versand nach Österreich](https://www.amazon.de/gp/help/customer/display.html?nodeId=GESTJTJG49FEM5SV) – bis zu zwei zusätzliche Tage
- [Amazon.de: Lieferung in die Schweiz](https://www.amazon.de/gp/help/customer/display.html?nodeId=201910940) – Lieferzeiten, Zoll und Umsatzsteuer im Preis, Verkäufer-Artikel
- [Amazon.fr: Coordonnées des transporteurs](https://www.amazon.fr/gp/help/customer/display.html?nodeId=GBPEXEXYULHB5WCH) – Poste Suisse für Lieferungen in die Schweiz
- [Amazon.fr: À propos des livraisons vers la Suisse](https://www.amazon.fr/gp/help/customer/display.html?nodeId=201910940) – amazon.fr liefert in die Schweiz
- [Amazon Shipping UK](https://shipping.amazon.co.uk/) – Zustellung für Händler und Amazon-Verkäufer
- [Amazon: Multi-Channel-Versand](https://sell.amazon.de/versand-durch-amazon/multi-channel-versand) – Bestellungen aus anderen Kanälen, neutrale Verpackung
- [Universal Parcel Scraper: Zustellerdaten](https://github.com/plhery/universal-parcel-scraper/tree/main/carriers) – Formen der Amazon-Nummern, was Peek prüft
:::
