// Generated from content/carriers by scripts/generate-guides.mjs. Do not edit.
import type { Locale } from '../lib/locale';

/**
 * A carrier's page in one language: the carrier's id, its id in Universal Parcel Scraper's catalog, its name
 * and brand colour in every language, and the page's address and title in this one.
 */
export interface CarrierLink { id: string; catalog: string; slug: string; title: string; name: string; color: string }

export const CARRIER_LINKS: Record<Locale, readonly CarrierLink[]> = {
  "en": [
    {
      "id": "quickpac",
      "catalog": "quickpac",
      "slug": "quickpac-tracking",
      "title": "Quickpac tracking: find your parcel and what to do next",
      "name": "Quickpac",
      "color": "#ed1c24"
    },
    {
      "id": "planzer",
      "catalog": "planzer",
      "slug": "planzer-tracking",
      "title": "Planzer tracking: what each status means and what to do",
      "name": "Planzer",
      "color": "#e30613"
    },
    {
      "id": "colis-prive",
      "catalog": "colis-prive",
      "slug": "colis-prive-tracking",
      "title": "Colis Privé tracking: French statuses and what to do",
      "name": "Colis Privé",
      "color": "#aa78ff"
    },
    {
      "id": "brt",
      "catalog": "brt",
      "slug": "brt-tracking",
      "title": "BRT tracking: numbers, statuses and missed deliveries",
      "name": "BRT",
      "color": "#dc0032"
    },
    {
      "id": "correos-express",
      "catalog": "correos-express",
      "slug": "correos-express-tracking",
      "title": "Correos Express tracking: statuses in English and contact",
      "name": "Correos Express",
      "color": "#ffcd00"
    },
    {
      "id": "nacex",
      "catalog": "nacex",
      "slug": "nacex-tracking",
      "title": "NACEX tracking: number, statuses in English and contact",
      "name": "NACEX",
      "color": "#fe5000"
    },
    {
      "id": "yunexpress",
      "catalog": "yunexpress",
      "slug": "yunexpress-tracking",
      "title": "YunExpress tracking: YT numbers, statuses and who delivers",
      "name": "YunExpress",
      "color": "#008284"
    },
    {
      "id": "cainiao",
      "catalog": "aliexpress",
      "slug": "cainiao-tracking",
      "title": "Cainiao tracking: numbers, statuses and who to contact",
      "name": "Cainiao",
      "color": "#e62e04"
    },
    {
      "id": "mondial-relay",
      "catalog": "mondial-relay",
      "slug": "mondial-relay-tracking",
      "title": "Mondial Relay tracking: statuses in English and pickup",
      "name": "Mondial Relay",
      "color": "#ef3026"
    },
    {
      "id": "gls-de",
      "catalog": "gls-de",
      "slug": "gls-tracking-germany",
      "title": "GLS tracking in Germany: statuses, ParcelShops and contact",
      "name": "GLS Germany",
      "color": "#ffdd00"
    },
    {
      "id": "dpd-de",
      "catalog": "dpd-de",
      "slug": "dpd-tracking-germany",
      "title": "DPD tracking in Germany: what statuses mean and what to do",
      "name": "DPD Germany",
      "color": "#dc0032"
    },
    {
      "id": "hermes-de",
      "catalog": "hermes-de",
      "slug": "hermes-tracking",
      "title": "Hermes tracking: German statuses explained in English",
      "name": "Hermes",
      "color": "#0091cd"
    },
    {
      "id": "gls-ch",
      "catalog": "gls-ch",
      "slug": "gls-switzerland-tracking",
      "title": "GLS Switzerland tracking: statuses, Swiss Post and contact",
      "name": "GLS Switzerland",
      "color": "#ffdd00"
    },
    {
      "id": "dpd-ch",
      "catalog": "dpd",
      "slug": "dpd-switzerland-tracking",
      "title": "DPD Switzerland tracking: statuses, delivery and contact",
      "name": "DPD Switzerland",
      "color": "#dc0032"
    },
    {
      "id": "inpost",
      "catalog": "inpost",
      "slug": "inpost-tracking",
      "title": "InPost tracking: numbers, statuses and locker pickup",
      "name": "InPost",
      "color": "#ffcc05"
    },
    {
      "id": "paack",
      "catalog": "paack",
      "slug": "paack-tracking",
      "title": "Paack tracking: order number, postcode and delivery slots",
      "name": "Paack",
      "color": "#5b2dee"
    },
    {
      "id": "evri",
      "catalog": "evri-uk",
      "slug": "evri-tracking",
      "title": "Evri tracking: statuses, ParcelShops and missed deliveries",
      "name": "Evri",
      "color": "#00014d"
    }
  ],
  "de": [
    {
      "id": "quickpac",
      "catalog": "quickpac",
      "slug": "quickpac-tracking",
      "title": "Quickpac Tracking: Paket verfolgen und Status verstehen",
      "name": "Quickpac",
      "color": "#ed1c24"
    },
    {
      "id": "planzer",
      "catalog": "planzer",
      "slug": "planzer-sendungsverfolgung",
      "title": "Planzer Sendungsverfolgung: Status, Zustellung und Hilfe",
      "name": "Planzer",
      "color": "#e30613"
    },
    {
      "id": "yunexpress",
      "catalog": "yunexpress",
      "slug": "yunexpress-sendungsverfolgung",
      "title": "YunExpress Sendungsverfolgung: Status, Zusteller, Kontakt",
      "name": "YunExpress",
      "color": "#008284"
    },
    {
      "id": "cainiao",
      "catalog": "aliexpress",
      "slug": "cainiao-sendungsverfolgung",
      "title": "Cainiao Sendungsverfolgung: Nummern, Status und Kontakt",
      "name": "Cainiao",
      "color": "#e62e04"
    },
    {
      "id": "gls-de",
      "catalog": "gls-de",
      "slug": "gls-sendungsverfolgung-deutschland",
      "title": "GLS Sendungsverfolgung Deutschland: Status und Paketshop",
      "name": "GLS Germany",
      "color": "#ffdd00"
    },
    {
      "id": "dpd-de",
      "catalog": "dpd-de",
      "slug": "dpd-sendungsverfolgung-deutschland",
      "title": "DPD Sendungsverfolgung Deutschland: Status und Hilfe",
      "name": "DPD Germany",
      "color": "#dc0032"
    },
    {
      "id": "hermes-de",
      "catalog": "hermes-de",
      "slug": "hermes-sendungsverfolgung",
      "title": "Hermes Sendungsverfolgung: Status, PaketShop und Kontakt",
      "name": "Hermes",
      "color": "#0091cd"
    },
    {
      "id": "gls-ch",
      "catalog": "gls-ch",
      "slug": "gls-schweiz-sendungsverfolgung",
      "title": "GLS Schweiz Sendungsverfolgung: Status, Post und Kontakt",
      "name": "GLS Switzerland",
      "color": "#ffdd00"
    },
    {
      "id": "dpd-ch",
      "catalog": "dpd",
      "slug": "dpd-schweiz-tracking",
      "title": "DPD Schweiz Tracking: Status, Zustellung und Kontakt",
      "name": "DPD Switzerland",
      "color": "#dc0032"
    }
  ],
  "fr": [
    {
      "id": "quickpac",
      "catalog": "quickpac",
      "slug": "quickpac-tracking",
      "title": "Quickpac tracking\u00a0: suivi du colis, statuts et contact",
      "name": "Quickpac",
      "color": "#ed1c24"
    },
    {
      "id": "planzer",
      "catalog": "planzer",
      "slug": "planzer-suivi-colis",
      "title": "Planzer suivi colis\u00a0: statuts, livraison et contact",
      "name": "Planzer",
      "color": "#e30613"
    },
    {
      "id": "colis-prive",
      "catalog": "colis-prive",
      "slug": "suivi-colis-prive",
      "title": "Colis Privé suivi\u00a0: statuts, relais et service client",
      "name": "Colis Privé",
      "color": "#aa78ff"
    },
    {
      "id": "yunexpress",
      "catalog": "yunexpress",
      "slug": "yunexpress-suivi",
      "title": "YunExpress suivi\u00a0: numéro YT, statuts et qui livre",
      "name": "YunExpress",
      "color": "#008284"
    },
    {
      "id": "cainiao",
      "catalog": "aliexpress",
      "slug": "cainiao-suivi",
      "title": "Cainiao suivi\u00a0: numéros, statuts et qui contacter",
      "name": "Cainiao",
      "color": "#e62e04"
    },
    {
      "id": "mondial-relay",
      "catalog": "mondial-relay",
      "slug": "mondial-relay-suivi",
      "title": "Mondial Relay suivi\u00a0: statuts, Point Relais et contact",
      "name": "Mondial Relay",
      "color": "#ef3026"
    },
    {
      "id": "gls-ch",
      "catalog": "gls-ch",
      "slug": "gls-suisse-suivi-colis",
      "title": "GLS Suisse suivi colis\u00a0: statuts, La Poste et contact",
      "name": "GLS Switzerland",
      "color": "#ffdd00"
    },
    {
      "id": "dpd-ch",
      "catalog": "dpd",
      "slug": "suivi-dpd-suisse",
      "title": "DPD Suisse suivi colis\u00a0: statuts, livraison et contact",
      "name": "DPD Switzerland",
      "color": "#dc0032"
    },
    {
      "id": "paack",
      "catalog": "paack",
      "slug": "paack-suivi",
      "title": "Paack suivi colis\u00a0: numéro, code postal et statuts",
      "name": "Paack",
      "color": "#5b2dee"
    }
  ],
  "it": [
    {
      "id": "quickpac",
      "catalog": "quickpac",
      "slug": "quickpac-tracking",
      "title": "Quickpac tracking: segui il pacco e capisci gli stati",
      "name": "Quickpac",
      "color": "#ed1c24"
    },
    {
      "id": "planzer",
      "catalog": "planzer",
      "slug": "planzer-tracking",
      "title": "Planzer tracking: stati del pacco, ritiro e contatti",
      "name": "Planzer",
      "color": "#e30613"
    },
    {
      "id": "brt",
      "catalog": "brt",
      "slug": "brt-tracking",
      "title": "BRT tracking: dov'è il pacco e cosa fare se non arriva",
      "name": "BRT",
      "color": "#dc0032"
    },
    {
      "id": "yunexpress",
      "catalog": "yunexpress",
      "slug": "yunexpress-tracking",
      "title": "YunExpress tracking: stati, consegna in Italia e contatti",
      "name": "YunExpress",
      "color": "#008284"
    },
    {
      "id": "cainiao",
      "catalog": "aliexpress",
      "slug": "cainiao-tracking",
      "title": "Cainiao tracking: numero, stati e pacco che non arriva",
      "name": "Cainiao",
      "color": "#e62e04"
    },
    {
      "id": "gls-ch",
      "catalog": "gls-ch",
      "slug": "gls-svizzera-tracking",
      "title": "GLS Svizzera tracking: stati, Posta Svizzera e contatti",
      "name": "GLS Switzerland",
      "color": "#ffdd00"
    },
    {
      "id": "dpd-ch",
      "catalog": "dpd",
      "slug": "dpd-svizzera-tracking",
      "title": "DPD Svizzera tracking: stati, giacenza e contatti",
      "name": "DPD Switzerland",
      "color": "#dc0032"
    },
    {
      "id": "inpost",
      "catalog": "inpost",
      "slug": "inpost-tracking",
      "title": "InPost tracking: codice, stati e ritiro al locker",
      "name": "InPost",
      "color": "#ffcc05"
    }
  ],
  "es": [
    {
      "id": "correos-express",
      "catalog": "correos-express",
      "slug": "correos-express-seguimiento",
      "title": "Correos Express seguimiento: estados, entrega y teléfono",
      "name": "Correos Express",
      "color": "#ffcd00"
    },
    {
      "id": "nacex",
      "catalog": "nacex",
      "slug": "seguimiento-nacex",
      "title": "NACEX seguimiento: número de envío, estados y teléfono",
      "name": "NACEX",
      "color": "#fe5000"
    },
    {
      "id": "yunexpress",
      "catalog": "yunexpress",
      "slug": "yunexpress-seguimiento",
      "title": "YunExpress seguimiento: estados, quién entrega y contacto",
      "name": "YunExpress",
      "color": "#008284"
    },
    {
      "id": "cainiao",
      "catalog": "aliexpress",
      "slug": "cainiao-seguimiento",
      "title": "Cainiao seguimiento en España: estados, entregas y teléfono",
      "name": "Cainiao",
      "color": "#e62e04"
    },
    {
      "id": "mondial-relay",
      "catalog": "mondial-relay",
      "slug": "mondial-relay-seguimiento",
      "title": "Mondial Relay seguimiento: estados, Punto Pack e InPost",
      "name": "Mondial Relay",
      "color": "#ef3026"
    },
    {
      "id": "paack",
      "catalog": "paack",
      "slug": "paack-seguimiento",
      "title": "Paack seguimiento: estados, entrega fallida y teléfono",
      "name": "Paack",
      "color": "#5b2dee"
    }
  ],
  "pt": [
    {
      "id": "correos-express",
      "catalog": "correos-express",
      "slug": "correos-express-rastreio",
      "title": "Correos Express rastreio: estados, entregas e contacto",
      "name": "Correos Express",
      "color": "#ffcd00"
    },
    {
      "id": "nacex",
      "catalog": "nacex",
      "slug": "nacex-rastreio",
      "title": "NACEX rastreio: código, estados e contacto em Portugal",
      "name": "NACEX",
      "color": "#fe5000"
    },
    {
      "id": "yunexpress",
      "catalog": "yunexpress",
      "slug": "yunexpress-rastreio",
      "title": "YunExpress rastreio: código YT, estados e contactos",
      "name": "YunExpress",
      "color": "#008284"
    },
    {
      "id": "cainiao",
      "catalog": "aliexpress",
      "slug": "cainiao-rastreio",
      "title": "Cainiao rastreio: números, estados e contactos em Portugal",
      "name": "Cainiao",
      "color": "#e62e04"
    },
    {
      "id": "mondial-relay",
      "catalog": "mondial-relay",
      "slug": "mondial-relay-rastreio",
      "title": "Mondial Relay rastreio: estados, InPost e levantamento",
      "name": "Mondial Relay",
      "color": "#ef3026"
    },
    {
      "id": "inpost",
      "catalog": "inpost",
      "slug": "inpost-rastreio",
      "title": "InPost rastreio: estados, Lockers e prazo para levantar",
      "name": "InPost",
      "color": "#ffcc05"
    },
    {
      "id": "paack",
      "catalog": "paack",
      "slug": "paack-rastreio",
      "title": "Paack rastreio: número, código postal e janela horária",
      "name": "Paack",
      "color": "#5b2dee"
    }
  ],
  "pl": [
    {
      "id": "yunexpress",
      "catalog": "yunexpress",
      "slug": "yunexpress-sledzenie",
      "title": "YunExpress śledzenie przesyłki: statusy, kurier, kontakt",
      "name": "YunExpress",
      "color": "#008284"
    },
    {
      "id": "cainiao",
      "catalog": "aliexpress",
      "slug": "cainiao-sledzenie",
      "title": "Cainiao śledzenie przesyłki: numery, statusy i kontakt",
      "name": "Cainiao",
      "color": "#e62e04"
    },
    {
      "id": "inpost",
      "catalog": "inpost",
      "slug": "inpost-sledzenie-przesylki",
      "title": "InPost śledzenie przesyłki: numer, statusy i Paczkomat",
      "name": "InPost",
      "color": "#ffcc05"
    }
  ]
};
