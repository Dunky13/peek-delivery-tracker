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
    },
    {
      "id": "chronopost",
      "catalog": "chronopost",
      "slug": "chronopost-tracking",
      "title": "Chronopost tracking: numbers, statuses and pickup points",
      "name": "Chronopost",
      "color": "#0056a7"
    },
    {
      "id": "relais-colis",
      "catalog": "relais-colis",
      "slug": "relais-colis-tracking",
      "title": "Relais Colis tracking: statuses, pickup and contact",
      "name": "Relais Colis",
      "color": "#7bb928"
    },
    {
      "id": "poste-italiane",
      "catalog": "poste-italiane",
      "slug": "poste-italiane-tracking",
      "title": "Poste Italiane tracking: numbers, statuses and pickup",
      "name": "Poste Italiane",
      "color": "#eedc00"
    },
    {
      "id": "seur",
      "catalog": "seur",
      "slug": "seur-tracking",
      "title": "SEUR tracking: numbers, statuses and pickup points",
      "name": "SEUR",
      "color": "#0063b3"
    },
    {
      "id": "mrw",
      "catalog": "mrw",
      "slug": "mrw-tracking",
      "title": "MRW tracking: number, statuses in English and contact",
      "name": "MRW",
      "color": "#19133b"
    },
    {
      "id": "ctt",
      "catalog": "ctt",
      "slug": "ctt-tracking",
      "title": "CTT tracking: numbers, statuses and pickup in Portugal",
      "name": "CTT",
      "color": "#df0024"
    },
    {
      "id": "packeta",
      "catalog": "packeta",
      "slug": "packeta-tracking",
      "title": "Packeta tracking: Z numbers, statuses and pickup points",
      "name": "Packeta",
      "color": "#ba1b02"
    },
    {
      "id": "dpd-pl",
      "catalog": "dpd-pl",
      "slug": "dpd-poland-tracking",
      "title": "DPD Poland tracking: statuses, pickup points and contact",
      "name": "DPD Poland",
      "color": "#dc0032"
    },
    {
      "id": "4px",
      "catalog": "four-px",
      "slug": "4px-tracking",
      "title": "4PX tracking: numbers, statuses and who to contact",
      "name": "4PX",
      "color": "#005add"
    },
    {
      "id": "swiss-post",
      "catalog": "swiss-post",
      "slug": "swiss-post-tracking",
      "title": "Swiss Post tracking: statuses, collection notes and contact",
      "name": "Swiss Post",
      "color": "#ffcc00"
    },
    {
      "id": "ctt-express",
      "catalog": "ctt-express",
      "slug": "ctt-express-tracking",
      "title": "CTT Express tracking: statuses in English and contact",
      "name": "CTT Express",
      "color": "#df0024"
    },
    {
      "id": "dpd-fr",
      "catalog": "dpd-fr",
      "slug": "dpd-france-tracking",
      "title": "DPD France tracking: numbers, statuses and Pickup relays",
      "name": "DPD France",
      "color": "#dc0032"
    },
    {
      "id": "gls-fr",
      "catalog": "gls-fr",
      "slug": "gls-france-tracking",
      "title": "GLS France tracking: statuses, Relais GLS and contact",
      "name": "GLS France",
      "color": "#ffdd00"
    },
    {
      "id": "gls-it",
      "catalog": "gls-it",
      "slug": "gls-italy-tracking",
      "title": "GLS Italy tracking: numbers, statuses and missed deliveries",
      "name": "GLS Italy",
      "color": "#ffdd00"
    },
    {
      "id": "poczta-polska",
      "catalog": "poczta-polska",
      "slug": "poczta-polska-tracking",
      "title": "Poczta Polska tracking: numbers, statuses and pickups",
      "name": "Poczta Polska",
      "color": "#c43c2b"
    },
    {
      "id": "orlen-paczka",
      "catalog": "orlen-paczka",
      "slug": "orlen-paczka-tracking",
      "title": "ORLEN Paczka tracking: numbers, statuses and pickups",
      "name": "ORLEN Paczka",
      "color": "#db3830"
    },
    {
      "id": "austrian-post",
      "catalog": "austrian-post",
      "slug": "austrian-post-tracking",
      "title": "Austrian Post tracking: numbers, statuses and pickup",
      "name": "Austrian Post",
      "color": "#ffdc00"
    },
    {
      "id": "tipsa",
      "catalog": "tipsa",
      "slug": "tipsa-tracking",
      "title": "TIPSA tracking: numbers, statuses and missed deliveries",
      "name": "TIPSA",
      "color": "#001e62"
    },
    {
      "id": "yanwen",
      "catalog": "yanwen",
      "slug": "yanwen-tracking",
      "title": "Yanwen tracking: numbers, statuses and who to contact",
      "name": "Yanwen",
      "color": "#8cbe1e"
    },
    {
      "id": "an-post",
      "catalog": "an-post",
      "slug": "an-post-tracking",
      "title": "An Post tracking: statuses, missed deliveries and contact",
      "name": "An Post",
      "color": "#00a76a"
    },
    {
      "id": "vinted-go",
      "catalog": "vinted-go",
      "slug": "vinted-go-tracking",
      "title": "Vinted Go tracking: statuses, lockers and who to contact",
      "name": "Vinted Go",
      "color": "#004654"
    },
    {
      "id": "amazon-logistics",
      "catalog": "amazon-logistics",
      "slug": "amazon-logistics-tracking",
      "title": "Amazon Logistics tracking: where to look and what to do",
      "name": "Amazon Logistics",
      "color": "#ff9900"
    },
    {
      "id": "dpd-uk",
      "catalog": "dpd-uk",
      "slug": "dpd-uk-tracking",
      "title": "DPD UK tracking: statuses, Pickup shops and contact",
      "name": "DPD UK",
      "color": "#dc0032"
    },
    {
      "id": "parcelforce",
      "catalog": "parcelforce",
      "slug": "parcelforce-worldwide-tracking",
      "title": "Parcelforce Worldwide tracking: statuses and redelivery",
      "name": "Parcelforce Worldwide",
      "color": "#9d0f11"
    },
    {
      "id": "bpost",
      "catalog": "bpost",
      "slug": "bpost-tracking",
      "title": "bpost tracking: statuses, Pick-up points and contact",
      "name": "bpost",
      "color": "#ef2637"
    },
    {
      "id": "dpd-ie",
      "catalog": "dpd-ie",
      "slug": "dpd-ireland-tracking",
      "title": "DPD Ireland tracking: statuses, Pickup points and contact",
      "name": "DPD Ireland",
      "color": "#dc0032"
    },
    {
      "id": "gls-es",
      "catalog": "gls-es",
      "slug": "gls-spain-tracking",
      "title": "GLS Spain tracking: statuses, Parcel Shops and contact",
      "name": "GLS Spain",
      "color": "#ffdd00"
    },
    {
      "id": "dhl-ecommerce-es",
      "catalog": "dhl-ecommerce-es",
      "slug": "dhl-ecommerce-iberia-tracking",
      "title": "DHL eCommerce Iberia tracking: statuses and ServicePoints",
      "name": "DHL eCommerce Iberia",
      "color": "#ffcc00"
    },
    {
      "id": "dhl-ecommerce-pl",
      "catalog": "dhl-ecommerce-pl",
      "slug": "dhl-ecommerce-poland-tracking",
      "title": "DHL eCommerce Poland tracking: statuses, pickup and help",
      "name": "DHL eCommerce Poland",
      "color": "#ffcc00"
    },
    {
      "id": "dhl-ecommerce-uk",
      "catalog": "dhl-ecommerce-uk",
      "slug": "dhl-ecommerce-uk-tracking",
      "title": "DHL eCommerce UK tracking: statuses, ServicePoints, contact",
      "name": "DHL eCommerce UK",
      "color": "#ffcc00"
    },
    {
      "id": "gofo-fr",
      "catalog": "gofo-fr",
      "slug": "gofo-france-tracking",
      "title": "\"GOFO France tracking: statuses, delivery and contact\"",
      "name": "GOFO France",
      "color": "#fc4c02"
    },
    {
      "id": "gofo-it",
      "catalog": "gofo-it",
      "slug": "gofo-italy-tracking",
      "title": "GOFO Italy tracking: statuses, delivery and contact",
      "name": "GOFO Italy",
      "color": "#fc4c02"
    },
    {
      "id": "speedpak",
      "catalog": "speedpak",
      "slug": "speedpak-tracking",
      "title": "SpeedPAK tracking: eBay parcels, statuses and who to ask",
      "name": "SpeedPAK",
      "color": "#ee7532"
    },
    {
      "id": "asendia",
      "catalog": "asendia",
      "slug": "asendia-tracking",
      "title": "Asendia tracking: statuses, delivery and who to contact",
      "name": "Asendia",
      "color": "#005d69"
    },
    {
      "id": "colisweb",
      "catalog": "colisweb",
      "slug": "colisweb-tracking",
      "title": "Colisweb tracking: French messages and delivery slots",
      "name": "Colisweb",
      "color": "#15cbe3"
    },
    {
      "id": "ciblex",
      "catalog": "ciblex",
      "slug": "ciblex-tracking",
      "title": "Ciblex tracking: numbers, French statuses and contact",
      "name": "Ciblex",
      "color": "#0160ab"
    },
    {
      "id": "hermes-einrichtungs-service",
      "catalog": "hermes",
      "slug": "hermes-einrichtungs-service-tracking",
      "title": "Hermes Einrichtungs-Service tracking: furniture deliveries",
      "name": "Hermes Einrichtungs-Service",
      "color": "#0091cd"
    },
    {
      "id": "landmark-global",
      "catalog": "landmark-global",
      "slug": "landmark-global-tracking",
      "title": "Landmark Global tracking: statuses, partners and contacts",
      "name": "Landmark Global",
      "color": "#e62337"
    },
    {
      "id": "dhl-ecommerce",
      "catalog": "dhl-ecommerce",
      "slug": "dhl-ecommerce-tracking",
      "title": "DHL eCommerce tracking: GM numbers, statuses and contacts",
      "name": "DHL eCommerce",
      "color": "#ffcc00"
    },
    {
      "id": "allegro-one",
      "catalog": "allegro-one",
      "slug": "allegro-one-tracking",
      "title": "Allegro One tracking: One Box, One Punkt and One Kurier",
      "name": "Allegro One",
      "color": "#006d57"
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
    },
    {
      "id": "4px",
      "catalog": "four-px",
      "slug": "4px-sendungsverfolgung",
      "title": "4PX Sendungsverfolgung: Nummer, Status und Kontakt",
      "name": "4PX",
      "color": "#005add"
    },
    {
      "id": "swiss-post",
      "catalog": "swiss-post",
      "slug": "swiss-post-sendungsverfolgung",
      "title": "Swiss Post Sendungsverfolgung: Status, Abholung, Kontakt",
      "name": "Swiss Post",
      "color": "#ffcc00"
    },
    {
      "id": "austrian-post",
      "catalog": "austrian-post",
      "slug": "austrian-post-sendungsverfolgung",
      "title": "Austrian Post Sendungsverfolgung: Status, Abholung, Hilfe",
      "name": "Austrian Post",
      "color": "#ffdc00"
    },
    {
      "id": "yanwen",
      "catalog": "yanwen",
      "slug": "yanwen-sendungsverfolgung",
      "title": "Yanwen Sendungsverfolgung: Nummern, Status und Kontakt",
      "name": "Yanwen",
      "color": "#8cbe1e"
    },
    {
      "id": "amazon-logistics",
      "catalog": "amazon-logistics",
      "slug": "amazon-logistics-tracking",
      "title": "Amazon Logistics Tracking: Paket verfolgen und Hilfe",
      "name": "Amazon Logistics",
      "color": "#ff9900"
    },
    {
      "id": "speedpak",
      "catalog": "speedpak",
      "slug": "speedpak-sendungsverfolgung",
      "title": "SpeedPAK Sendungsverfolgung: eBay-Pakete, Status, Kontakt",
      "name": "SpeedPAK",
      "color": "#ee7532"
    },
    {
      "id": "asendia",
      "catalog": "asendia",
      "slug": "asendia-sendungsverfolgung",
      "title": "Asendia Sendungsverfolgung: Status, Zustellung, Kontakt",
      "name": "Asendia",
      "color": "#005d69"
    },
    {
      "id": "hermes-einrichtungs-service",
      "catalog": "hermes",
      "slug": "hermes-einrichtungs-service-sendungsverfolgung",
      "title": "Hermes Einrichtungs-Service Sendungsverfolgung: Liefertermin",
      "name": "Hermes Einrichtungs-Service",
      "color": "#0091cd"
    },
    {
      "id": "landmark-global",
      "catalog": "landmark-global",
      "slug": "landmark-global-sendungsverfolgung",
      "title": "Landmark Global Sendungsverfolgung: Status, Partner, Kontakt",
      "name": "Landmark Global",
      "color": "#e62337"
    },
    {
      "id": "dhl-ecommerce",
      "catalog": "dhl-ecommerce",
      "slug": "dhl-ecommerce-sendungsverfolgung",
      "title": "DHL eCommerce Sendungsverfolgung: GM-Nummer, Status, Kontakt",
      "name": "DHL eCommerce",
      "color": "#ffcc00"
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
    },
    {
      "id": "chronopost",
      "catalog": "chronopost",
      "slug": "chronopost-suivi",
      "title": "Chronopost suivi\u00a0: numéro, statuts et point relais",
      "name": "Chronopost",
      "color": "#0056a7"
    },
    {
      "id": "relais-colis",
      "catalog": "relais-colis",
      "slug": "relais-colis-suivi",
      "title": "Relais Colis suivi\u00a0: statuts, retrait en relais et contact",
      "name": "Relais Colis",
      "color": "#7bb928"
    },
    {
      "id": "4px",
      "catalog": "four-px",
      "slug": "4px-suivi",
      "title": "4PX suivi\u00a0: numéro, statuts et qui contacter",
      "name": "4PX",
      "color": "#005add"
    },
    {
      "id": "swiss-post",
      "catalog": "swiss-post",
      "slug": "swiss-post-suivi-colis",
      "title": "Swiss Post\u00a0: suivi colis La Poste suisse et statuts",
      "name": "Swiss Post",
      "color": "#ffcc00"
    },
    {
      "id": "dpd-fr",
      "catalog": "dpd-fr",
      "slug": "dpd-france-suivi-colis",
      "title": "DPD France suivi colis\u00a0: numéro, statuts et relais Pickup",
      "name": "DPD France",
      "color": "#dc0032"
    },
    {
      "id": "gls-fr",
      "catalog": "gls-fr",
      "slug": "gls-france-suivi-colis",
      "title": "GLS France suivi colis\u00a0: statuts, relais et contact",
      "name": "GLS France",
      "color": "#ffdd00"
    },
    {
      "id": "yanwen",
      "catalog": "yanwen",
      "slug": "yanwen-suivi",
      "title": "Yanwen suivi\u00a0: numéros, statuts et qui contacter",
      "name": "Yanwen",
      "color": "#8cbe1e"
    },
    {
      "id": "vinted-go",
      "catalog": "vinted-go",
      "slug": "vinted-go-suivi",
      "title": "Vinted Go suivi\u00a0: statuts, consigne, point relais et contact",
      "name": "Vinted Go",
      "color": "#004654"
    },
    {
      "id": "amazon-logistics",
      "catalog": "amazon-logistics",
      "slug": "amazon-logistics-suivi",
      "title": "Amazon Logistics suivi\u00a0: où suivre ton colis et que faire",
      "name": "Amazon Logistics",
      "color": "#ff9900"
    },
    {
      "id": "bpost",
      "catalog": "bpost",
      "slug": "bpost-suivi",
      "title": "bpost suivi\u00a0: code-barres, statuts et point relais",
      "name": "bpost",
      "color": "#ef2637"
    },
    {
      "id": "gofo-fr",
      "catalog": "gofo-fr",
      "slug": "gofo-france-suivi",
      "title": "GOFO France suivi colis\u00a0: statuts, livraison et contact",
      "name": "GOFO France",
      "color": "#fc4c02"
    },
    {
      "id": "speedpak",
      "catalog": "speedpak",
      "slug": "speedpak-suivi",
      "title": "SpeedPAK suivi\u00a0: colis eBay, statuts et qui contacter",
      "name": "SpeedPAK",
      "color": "#ee7532"
    },
    {
      "id": "asendia",
      "catalog": "asendia",
      "slug": "asendia-suivi",
      "title": "Asendia suivi\u00a0: colis, statuts et qui contacter",
      "name": "Asendia",
      "color": "#005d69"
    },
    {
      "id": "colisweb",
      "catalog": "colisweb",
      "slug": "suivi-colisweb",
      "title": "Suivi Colisweb\u00a0: messages, créneau de livraison et contact",
      "name": "Colisweb",
      "color": "#15cbe3"
    },
    {
      "id": "ciblex",
      "catalog": "ciblex",
      "slug": "suivi-ciblex",
      "title": "Suivi Ciblex\u00a0: numéro, statuts du colis et contact",
      "name": "Ciblex",
      "color": "#0160ab"
    },
    {
      "id": "landmark-global",
      "catalog": "landmark-global",
      "slug": "landmark-global-suivi",
      "title": "Landmark Global suivi\u00a0: statuts, livreur et contact",
      "name": "Landmark Global",
      "color": "#e62337"
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
    },
    {
      "id": "poste-italiane",
      "catalog": "poste-italiane",
      "slug": "poste-italiane-tracking",
      "title": "Poste Italiane tracking: codice, stati, giacenza e ritiro",
      "name": "Poste Italiane",
      "color": "#eedc00"
    },
    {
      "id": "4px",
      "catalog": "four-px",
      "slug": "4px-traccia-pacco",
      "title": "4PX traccia pacco: numero, stati e chi consegna",
      "name": "4PX",
      "color": "#005add"
    },
    {
      "id": "swiss-post",
      "catalog": "swiss-post",
      "slug": "swiss-post-tracking-posta-svizzera",
      "title": "Swiss Post tracking: Posta Svizzera, stati e ritiro",
      "name": "Swiss Post",
      "color": "#ffcc00"
    },
    {
      "id": "gls-it",
      "catalog": "gls-it",
      "slug": "gls-italy-tracking",
      "title": "GLS Italy tracking: pacco, stati, giacenza e contatti",
      "name": "GLS Italy",
      "color": "#ffdd00"
    },
    {
      "id": "yanwen",
      "catalog": "yanwen",
      "slug": "yanwen-tracking",
      "title": "Yanwen tracking: numero, stati e chi consegna in Italia",
      "name": "Yanwen",
      "color": "#8cbe1e"
    },
    {
      "id": "amazon-logistics",
      "catalog": "amazon-logistics",
      "slug": "amazon-logistics-tracking",
      "title": "Amazon Logistics tracking: dove seguire il pacco e contatti",
      "name": "Amazon Logistics",
      "color": "#ff9900"
    },
    {
      "id": "gofo-it",
      "catalog": "gofo-it",
      "slug": "gofo-italy-tracking",
      "title": "GOFO Italy tracking: stati, consegna e contatti",
      "name": "GOFO Italy",
      "color": "#fc4c02"
    },
    {
      "id": "speedpak",
      "catalog": "speedpak",
      "slug": "speedpak-tracking",
      "title": "SpeedPAK tracking: pacchi eBay, stati e chi consegna",
      "name": "SpeedPAK",
      "color": "#ee7532"
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
    },
    {
      "id": "seur",
      "catalog": "seur",
      "slug": "seur-seguimiento",
      "title": "SEUR seguimiento: número, estados y puntos Pickup",
      "name": "SEUR",
      "color": "#0063b3"
    },
    {
      "id": "mrw",
      "catalog": "mrw",
      "slug": "mrw-seguimiento",
      "title": "MRW seguimiento: número de envío, estados y teléfono",
      "name": "MRW",
      "color": "#19133b"
    },
    {
      "id": "4px",
      "catalog": "four-px",
      "slug": "4px-seguimiento",
      "title": "4PX seguimiento: estados, quién entrega y contacto",
      "name": "4PX",
      "color": "#005add"
    },
    {
      "id": "ctt-express",
      "catalog": "ctt-express",
      "slug": "ctt-express-seguimiento",
      "title": "CTT Express seguimiento: número, estados y teléfono",
      "name": "CTT Express",
      "color": "#df0024"
    },
    {
      "id": "tipsa",
      "catalog": "tipsa",
      "slug": "tipsa-seguimiento",
      "title": "TIPSA seguimiento: número, estados y teléfono",
      "name": "TIPSA",
      "color": "#001e62"
    },
    {
      "id": "yanwen",
      "catalog": "yanwen",
      "slug": "yanwen-seguimiento",
      "title": "Yanwen seguimiento: estados, quién entrega y contacto",
      "name": "Yanwen",
      "color": "#8cbe1e"
    },
    {
      "id": "vinted-go",
      "catalog": "vinted-go",
      "slug": "vinted-go-seguimiento",
      "title": "Vinted Go seguimiento: estados, taquillas y contacto",
      "name": "Vinted Go",
      "color": "#004654"
    },
    {
      "id": "amazon-logistics",
      "catalog": "amazon-logistics",
      "slug": "amazon-logistics-seguimiento",
      "title": "Amazon Logistics seguimiento: dónde mirarlo y qué hacer",
      "name": "Amazon Logistics",
      "color": "#ff9900"
    },
    {
      "id": "gls-es",
      "catalog": "gls-es",
      "slug": "gls-spain-seguimiento",
      "title": "GLS Spain seguimiento: estados, Parcel Shop y teléfono",
      "name": "GLS Spain",
      "color": "#ffdd00"
    },
    {
      "id": "dhl-ecommerce-es",
      "catalog": "dhl-ecommerce-es",
      "slug": "dhl-ecommerce-iberia-seguimiento",
      "title": "DHL eCommerce Iberia seguimiento: estados y teléfono",
      "name": "DHL eCommerce Iberia",
      "color": "#ffcc00"
    },
    {
      "id": "speedpak",
      "catalog": "speedpak",
      "slug": "speedpak-seguimiento",
      "title": "SpeedPAK seguimiento: paquetes de eBay, estados y contacto",
      "name": "SpeedPAK",
      "color": "#ee7532"
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
    },
    {
      "id": "seur",
      "catalog": "seur",
      "slug": "seur-encomenda",
      "title": "SEUR encomenda: rastreio, estados e contactos em Portugal",
      "name": "SEUR",
      "color": "#0063b3"
    },
    {
      "id": "mrw",
      "catalog": "mrw",
      "slug": "mrw-rastreio",
      "title": "MRW rastreio: número, estados e contactos em Portugal",
      "name": "MRW",
      "color": "#19133b"
    },
    {
      "id": "ctt",
      "catalog": "ctt",
      "slug": "ctt-rastreio",
      "title": "CTT rastreio: números, estados, levantamento e contactos",
      "name": "CTT",
      "color": "#df0024"
    },
    {
      "id": "4px",
      "catalog": "four-px",
      "slug": "4px-rastreio",
      "title": "4PX rastreio: números, estados e contacto em Portugal",
      "name": "4PX",
      "color": "#005add"
    },
    {
      "id": "ctt-express",
      "catalog": "ctt-express",
      "slug": "ctt-expresso-rastreio",
      "title": "CTT Express (Expresso) rastreio: estados e contactos",
      "name": "CTT Express",
      "color": "#df0024"
    },
    {
      "id": "yanwen",
      "catalog": "yanwen",
      "slug": "rastrear-encomenda-yanwen",
      "title": "Yanwen tracking: rastrear encomenda, estados e contactos",
      "name": "Yanwen",
      "color": "#8cbe1e"
    },
    {
      "id": "vinted-go",
      "catalog": "vinted-go",
      "slug": "vinted-go-encomenda",
      "title": "Vinted Go encomenda: rastreio, cacifos e levantamento",
      "name": "Vinted Go",
      "color": "#004654"
    },
    {
      "id": "amazon-logistics",
      "catalog": "amazon-logistics",
      "slug": "amazon-logistics-rastreio",
      "title": "Amazon Logistics rastreio: onde seguir e o que fazer",
      "name": "Amazon Logistics",
      "color": "#ff9900"
    },
    {
      "id": "dhl-ecommerce-es",
      "catalog": "dhl-ecommerce-es",
      "slug": "dhl-ecommerce-iberia-rastreio",
      "title": "DHL eCommerce Iberia rastreio: estados e ServicePoints",
      "name": "DHL eCommerce Iberia",
      "color": "#ffcc00"
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
    },
    {
      "id": "packeta",
      "catalog": "packeta",
      "slug": "packeta-sledzenie",
      "title": "Packeta śledzenie: numer Z, statusy i punkty odbioru",
      "name": "Packeta",
      "color": "#ba1b02"
    },
    {
      "id": "dpd-pl",
      "catalog": "dpd-pl",
      "slug": "dpd-poland-sledzenie-paczki",
      "title": "DPD Poland śledzenie paczki: statusy, Pickup i kontakt",
      "name": "DPD Poland",
      "color": "#dc0032"
    },
    {
      "id": "4px",
      "catalog": "four-px",
      "slug": "4px-sledzenie-przesylki",
      "title": "4PX śledzenie przesyłki: numery, statusy i kontakt",
      "name": "4PX",
      "color": "#005add"
    },
    {
      "id": "poczta-polska",
      "catalog": "poczta-polska",
      "slug": "poczta-polska-sledzenie",
      "title": "Poczta Polska śledzenie: numer, statusy, awizo i kontakt",
      "name": "Poczta Polska",
      "color": "#c43c2b"
    },
    {
      "id": "orlen-paczka",
      "catalog": "orlen-paczka",
      "slug": "orlen-paczka-sledzenie",
      "title": "ORLEN Paczka śledzenie: numer, statusy i odbiór paczki",
      "name": "ORLEN Paczka",
      "color": "#db3830"
    },
    {
      "id": "yanwen",
      "catalog": "yanwen",
      "slug": "yanwen-sledzenie",
      "title": "Yanwen śledzenie przesyłki: statusy, kurier, kontakt",
      "name": "Yanwen",
      "color": "#8cbe1e"
    },
    {
      "id": "amazon-logistics",
      "catalog": "amazon-logistics",
      "slug": "amazon-logistics-sledzenie-przesylki",
      "title": "Amazon Logistics tracking: gdzie śledzić paczkę Amazon",
      "name": "Amazon Logistics",
      "color": "#ff9900"
    },
    {
      "id": "dhl-ecommerce-pl",
      "catalog": "dhl-ecommerce-pl",
      "slug": "dhl-ecommerce-poland-sledzenie-przesylki",
      "title": "DHL eCommerce Poland śledzenie przesyłki: statusy i punkty",
      "name": "DHL eCommerce Poland",
      "color": "#ffcc00"
    },
    {
      "id": "allegro-one",
      "catalog": "allegro-one",
      "slug": "allegro-one-sledzenie",
      "title": "Allegro One śledzenie przesyłki: statusy i odbiór paczki",
      "name": "Allegro One",
      "color": "#006d57"
    }
  ]
};
