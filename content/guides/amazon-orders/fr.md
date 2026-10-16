---
title: Suivi de commande Amazon : Amazon, vendeurs, transporteurs
description: Qui expédie ta commande Amazon, quel transporteur la livre, pourquoi le numéro de suivi change ou manque, et quand passer par le vendeur ou la garantie A à Z.
slug: suivi-commande-amazon
picture: Un téléphone affiche l'avancée d'une commande, deux camionnettes se passent un colis, et Pip regarde.
published: 2026-10-16
updated: 2026-10-16
---

Pour suivre une commande Amazon, ouvre Vos commandes, choisis la commande puis « Suivre le colis » : Amazon y montre le transporteur, le numéro de suivi et chaque étape. Qui t'aide en cas de souci dépend de qui expédie. Amazon s'occupe de ses propres commandes et des articles « Expédié par Amazon », alors qu'un vendeur qui expédie lui-même choisit son transporteur et répond de la livraison.

## Qui expédie ma commande Amazon : Amazon ou un vendeur tiers ?

Regarde les lignes « Expédié par » et « Vendu par » sous le bouton « Acheter maintenant », ou le nom du vendeur dans Vos commandes.

| Ce qu'affiche la page | Ce que ça veut dire | Qui t'aide pour la livraison |
| --- | --- | --- |
| Vendu par Amazon, Expédié par Amazon | Le stock d'Amazon | Amazon |
| Vendu par un vendeur, Expédié par Amazon | « Expédié par Amazon » : le stock du vendeur, emballé et envoyé depuis un centre de distribution Amazon | Amazon |
| Vendu par et Expédié par le même vendeur | Le vendeur envoie lui-même, avec le transporteur de son choix | Le vendeur d'abord |

Amazon le dit ainsi : si un article est affiché « Expédié par (nom du vendeur) », « le vendeur gère son propre service client ». Sauf si la commande est admissible à Prime : là, c'est Amazon.

**En Belgique**, tu commandes sur amazon.com.be, en français. Les délais de la garantie A à Z et les conseils en cas de retard y sont les mêmes qu'en France.

**En Suisse**, il n'y a pas de boutique Amazon : amazon.ch renvoie vers amazon.de. Amazon.fr « expédie des millions de produits à l'international, y compris en Suisse ». Ce qu'Amazon expédie arrive en 3 à 5 jours ouvrables en livraison standard, 1 à 3 en envoi rapide, et le prix final inclut les droits et la TVA : « Vous n'avez rien à payer à la douane. » Si tu as quand même payé des droits de douane pour un article « Expédié par Amazon », demande le remboursement au service client. Pour un vendeur qui expédie lui-même, ses propres règles s'appliquent. Plus de détails : [colis bloqué en douane](guide:customs).

## Quel transporteur livre mon colis Amazon ?

« Suivre le colis » le nomme, et chaque colis peut avoir le sien. Quand c'est Amazon, il s'agit d'[Amazon Logistics](carrier:amazon-logistics), son propre réseau de livraison. Voici les transporteurs qu'Amazon cite sur ses pages de contact :

| Pays | Boutique | Transporteurs cités par Amazon |
| --- | --- | --- |
| France | amazon.fr | Amazon, [La Poste Colissimo](carrier:la-poste), [Chronopost](carrier:chronopost), [Colis Privé](carrier:colis-prive), [DPD France](carrier:dpd-fr), [GLS](carrier:gls-fr), [Mondial Relay](carrier:mondial-relay), [Paack](carrier:paack), France Express ([Geodis](carrier:geodis)), DHL France, [UPS](carrier:ups), JP Home |
| Belgique | amazon.com.be | Amazon, [bpost](carrier:bpost) (Taxipost), Colis Privé, Chronopost, DPD, UPS |
| Suisse | amazon.fr, amazon.de | [La Poste suisse](carrier:swiss-post) (« Poste Suisse », liste d'amazon.fr), [Quickpac](carrier:quickpac) (liste d'amazon.de) |

Un vendeur qui expédie lui-même peut passer par l'un d'eux ou par un autre. Où se trouve le numéro sur chaque boutique : [trouver ton numéro de suivi](guide:find-tracking-number).

## À quoi ressemble un numéro de suivi Amazon ?

Il y en a deux sortes, plus un numéro de commande qui n'est ni l'un ni l'autre.

Amazon ne publie pas le format de ses propres numéros. Voici les formes que Peek reconnaît comme celles d'Amazon, ici avec des chiffres inventés :

:::anatomy TBA 123456789012
- TBA | Lettres d'Amazon. `TBC` et `TBM` fonctionnent pareil
- 123456789012 | Douze chiffres
:::

| Forme (inventée) | Ce que c'est |
| --- | --- |
| `TBA123456789012` | Amazon : `TBA`, `TBC` ou `TBM` et 12 chiffres |
| `FR1234567890` | Amazon en Europe : un code pays (`FR`, `BE`, `CH` et d'autres) et 10 chiffres |
| `123-1234567-1234567` | Ton numéro de commande Amazon : 3, 7 et 7 chiffres. Pas un numéro de suivi |
| Tout le reste | Le numéro du transporteur, par exemple de Colissimo ou de Chronopost |

Le numéro d'un transporteur marche sur le site de celui-ci, comme expliqué dans [les formats de numéros de suivi](guide:tracking-number-formats). Tu ne sais pas lequel tu as ? Tape-le ici :

:::checker
:::

## Pourquoi mon numéro de suivi Amazon a changé, ou pourquoi j'en ai deux ?

En général pour l'une de ces raisons :

- **Plusieurs articles, plusieurs colis.** « Si vous avez commandé plusieurs articles, les dates de livraison et les informations de suivi peuvent être différentes. » Un article absent du carton a peut-être été expédié séparément.
- **Un autre transporteur prend le relais.** Amazon.fr le précise pour DHL France : « les colis DHL sont livrés par La Poste ».
- **Le vendeur a son propre transporteur.** Le numéro est alors celui de Colissimo, de Mondial Relay ou d'un autre, pas celui d'Amazon.

:::journey
- warehouse | Amazon ou le vendeur | Plusieurs articles peuvent partir en plusieurs colis, chacun avec son numéro
- label | Étiquette créée | Le suivi peut tarder : la base de données se met parfois à jour en retard
- handover | Transporteur partenaire | Peut prendre le relais, par exemple La Poste pour DHL France
- truck | En cours de livraison | Certains transporteurs livrent jusqu'à 22 h
- home | Toi | Peut être scanné livré jusqu'à 48 heures trop tôt
:::

Quand le premier transporteur nomme le partenaire qui prend le relais, [Peek](/) garde le premier historique, suit le partenaire dès que son suivi montre du nouveau, et affiche sur la carte le nom et le numéro du partenaire.

## Pourquoi je n'ai pas de suivi pour ma commande Amazon ?

Amazon donne ces raisons sur sa page « Informations de suivi manquantes » :

- **Une mise à jour en retard.** La base de données du suivi peut prendre du retard.
- **Un envoi non suivi.** « Certaines expéditions, comme les expéditions internationales standard, ne sont pas traçables. »
- **Le vendeur ne l'a pas transmis.** « Les vendeurs tiers ne communiquent pas toujours les informations de suivi des commandes à Amazon. » Une commande de vendeur n'est suivie que s'il partage ces infos et si tu as choisi un mode d'expédition avec suivi.

Si la date de livraison estimée est passée et que rien ne bouge, Amazon conseille de « patienter encore un à deux jours ». Pas de suivi du tout sur une commande de vendeur ? Dans Vos commandes, choisis « Problème avec la commande » et écris au vendeur. Quand le suivi reste figé plusieurs jours : [pourquoi le suivi ne bouge plus](guide:tracking-not-updating).

## Que faire si ma commande Amazon est en retard ou dite livrée ?

Les statuts d'Amazon dans Vos commandes sont `Arrivée`, `En cours de livraison`, `Livré` et `Non livrable`. Ce dernier veut dire que le colis repart chez Amazon, qui te rembourse automatiquement à sa réception. Pour le reste, procède dans cet ordre :

:::steps
- Attendre 48 heures | La plupart des colis en retard arrivent dans les 48 heures suivant la date estimée. Un colis peut aussi être scanné livré jusqu'à 48 heures avant d'arriver.
- Chercher autour | Regarde l'endroit indiqué pour la livraison, ta boîte aux lettres, et demande aux voisins. Certains transporteurs livrent jusqu'à 22 h.
- Demander au transporteur | « Suivre le colis » le nomme. La page « Coordonnées des transporteurs » d'Amazon donne le lien de chacun.
- Contacter le vendeur | S'il a vendu et expédié : Vos commandes, « Problème avec la commande ». « Les vendeurs répondent par e-mail dans les 48 heures. »
- Demander à Amazon | Commande expédiée par Amazon : service client, dans les 30 jours suivant la date de livraison estimée. Commande de vendeur : garantie A à Z.
:::

Plus de détails sur chaque cas : [colis livré mais pas reçu](guide:delivered-not-received) et [colis perdu](guide:lost-parcel).

### Quand demander la garantie A à Z ?

Elle couvre les articles qu'un vendeur Marketplace a vendus et expédiés lui-même. Pour un colis jamais arrivé, il faut que trois jours se soient écoulés depuis la dernière date de livraison estimée, ou depuis que le suivi indique une livraison si c'est plus tôt. Il faut aussi avoir contacté le vendeur il y a plus de 48 heures sans réponse ni solution.

| Délai | amazon.fr et amazon.com.be |
| --- | --- |
| Réponse du vendeur | 48 heures |
| Attente après la dernière date estimée | Trois jours |
| Demande possible tant que | La dernière date de livraison possible remonte à 90 jours au plus |

Tu fais la demande dans Vos commandes, via « Problème avec la commande ». Sur amazon.com.be, les articles d'Amazon Global Store et ceux de vendeurs livrés via Prime passent directement par le service client d'Amazon. Si le vendeur ne t'a pas remboursé des frais en plus, comme des frais de douane, tu peux aussi les réclamer.

## Est-ce que je peux suivre un colis Amazon ailleurs que sur Amazon ?

Ça dépend du numéro. Colle-le dans [Peek](/) :

- **Le numéro d'un transporteur** (Colissimo, Chronopost, Mondial Relay, bpost, La Poste suisse…) se suit comme n'importe quel colis.
- **Un numéro Amazon**, ou un lien track.amazon : Peek interroge d'abord le suivi public d'Amazon. S'il répond, le colis voyage avec [Amazon Shipping](carrier:amazon-shipping), le service de livraison d'Amazon pour les e-commerçants, ou avec les Ventes Multi-Sites (MCF), où Amazon envoie des commandes passées sur d'autres sites, souvent dans un emballage neutre. Peek le suit alors tout seul.
- Sinon, c'est Amazon Logistics qui livre une commande Amazon, et Amazon ne la montre que dans ton compte. Peek te le dit et propose « Voir mes commandes Amazon », qui ouvre tes commandes sur le site Amazon qui correspond au numéro : amazon.fr pour `FR`, amazon.com.be pour `BE`. Peek ne te demande jamais tes identifiants Amazon.
- **Un numéro de commande** reçoit « On dirait un numéro de commande Amazon ». Prends plutôt le numéro de suivi de « Suivre le colis » ou de l'e-mail d'expédition.

:::sources
- [Amazon.fr : Coordonnées des transporteurs](https://www.amazon.fr/gp/help/customer/display.html?nodeId=GBPEXEXYULHB5WCH) – transporteurs en France, DHL France livré par La Poste, Poste Suisse
- [Amazon.fr : Commande auprès d'un vendeur Marketplace](https://www.amazon.fr/gp/help/customer/display.html?nodeId=GEF528GN65XSJ7V8) – Expédié par et Vendu par, service client du vendeur
- [Amazon.fr : Expédié par Amazon](https://www.amazon.fr/gp/help/customer/display.html?nodeId=G239KSGYPUFUY8TQ) – stock de vendeurs envoyé depuis Amazon
- [Amazon.fr : Suivre votre colis](https://www.amazon.fr/gp/help/customer/display.html?nodeId=GENAFPTNLHV7ZACW) – colis séparés, statuts, 48 heures, suivi des vendeurs tiers
- [Amazon.fr : Informations de suivi manquantes](https://www.amazon.fr/gp/help/customer/display.html?nodeId=G6ZFEB9ZDU7QHMER) – retards de mise à jour, envois non traçables, un à deux jours
- [Amazon.fr : Livraisons en retard](https://www.amazon.fr/gp/help/customer/display.html?nodeId=GL669SSDXFCJ2ZA6) – 48 heures, 30 jours
- [Amazon.fr : Rechercher un colis manquant qui apparaît comme livré](https://www.amazon.fr/gp/help/customer/display.html?nodeId=GCU8BWGTQNJKQEBS) – 22 h, scan livré jusqu'à 48 heures avant, 30 jours
- [Amazon.fr : Contacter un vendeur Marketplace](https://www.amazon.fr/gp/help/customer/display.html?nodeId=GLC8ZMBWMBTR6QZZ) – 48 heures, exception Prime
- [Amazon.fr : Qu'est-ce que la Garantie A à Z ?](https://www.amazon.fr/gp/help/customer/display.html?nodeId=GQ37ZCNECJKTFYQV) – 90 jours, trois jours, 48 heures
- [Amazon.fr : À propos des livraisons vers la Suisse](https://www.amazon.fr/gp/help/customer/display.html?nodeId=201910940) – délais, droits et TVA inclus, remboursement des droits de douane
- [Amazon.com.be : Coordonnées des transporteurs](https://www.amazon.com.be/gp/help/customer/display.html?nodeId=GBPEXEXYULHB5WCH&language=fr_BE) – transporteurs en Belgique
- [Amazon.com.be : Informations de suivi manquantes](https://www.amazon.com.be/gp/help/customer/display.html?nodeId=G6ZFEB9ZDU7QHMER&language=fr_BE) – mêmes règles qu'en France
- [Amazon.com.be : Livraisons en retard](https://www.amazon.com.be/gp/help/customer/display.html?nodeId=GL669SSDXFCJ2ZA6&language=fr_BE) – 48 heures, 30 jours
- [Amazon.com.be : Garantie A à Z](https://www.amazon.com.be/gp/help/customer/display.html?nodeId=GQ37ZCNECJKTFYQV&language=fr_BE) – 90 jours, trois jours, 48 heures, Global Store et Prime, frais de douane
- [Amazon.de : Ein Transportunternehmen kontaktieren](https://www.amazon.de/gp/help/customer/display.html?nodeId=GBPEXEXYULHB5WCH) – Quickpac
- [Amazon Shipping France](https://shipping.amazon.fr/) – livraison pour les e-commerçants
- [Amazon : Ventes Multi-Sites (MCF)](https://sell.amazon.fr/expedie-par-amazon/expedie-multicanal) – commandes d'autres canaux, emballages neutres
- [Universal Parcel Scraper : données transporteurs](https://github.com/plhery/universal-parcel-scraper/tree/main/carriers) – formes des numéros Amazon, ce que Peek vérifie
:::
