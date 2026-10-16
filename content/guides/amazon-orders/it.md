---
title: Tracciare un ordine Amazon: Amazon, venditori e corrieri
description: Chi spedisce il tuo ordine Amazon, quale corriere lo consegna, perché il tracciamento cambia o manca e come funziona la Garanzia dalla A alla Z.
slug: tracciamento-ordine-amazon
picture: Un telefono mostra l'avanzamento di un ordine, due furgoni si passano un pacco e Pip guarda.
published: 2026-10-16
updated: 2026-10-16
---

Per tracciare un ordine Amazon apri I miei ordini, scegli l'ordine e poi "Traccia il mio pacco": lì Amazon mostra il corriere, il numero di tracciamento e ogni aggiornamento. Chi ti aiuta quando qualcosa va storto dipende da chi spedisce. Amazon segue i propri ordini e quelli "Gestiti da Amazon", mentre un venditore che spedisce da sé sceglie il corriere e risponde della consegna.

## Chi spedisce il mio ordine Amazon: Amazon o un venditore terzo?

Guarda le righe "Spedizione da" e "Venduto da" sotto il pulsante "Acquista ora", oppure il nome del venditore in I miei ordini.

| Cosa dice la pagina | Cosa significa | Chi ti aiuta per la consegna |
| --- | --- | --- |
| Venduto da Amazon, Spedizione da Amazon | Merce di Amazon | Amazon |
| Venduto da un venditore, Spedizione da Amazon | "Gestito da Amazon": merce del venditore, imballata e spedita da un centro logistico Amazon | Amazon |
| Venduto da e Spedizione da lo stesso venditore | Il venditore spedisce da sé, con il corriere che preferisce | Prima il venditore |

Per gli articoli "Gestiti da Amazon" è Amazon a occuparsi del servizio clienti e dei resi.

C'è poi un caso che in Italia Amazon chiama **VOC, Vendor Owned Carrier**: "Amazon consente ad alcuni rivenditori di gestire in autonomia il processo di spedizione. In questi casi, non è possibile tracciare un ordine sulla piattaforma di Amazon.it, ma dovrai seguire le istruzioni fornite dal venditore stesso."

## Quale corriere consegna il mio pacco Amazon?

Te lo dice "Traccia il mio pacco", insieme al codice della spedizione. Quando il corriere è Amazon, si tratta di [Amazon Logistics](carrier:amazon-logistics), la rete di consegna di Amazon. Questi sono i corrieri principali per le spedizioni in Italia secondo Amazon.it:

| Corriere | Cosa dice Amazon.it |
| --- | --- |
| Amazon | Cinque tentativi di consegna automatici, poi giacenza per 72 ore |
| [Poste Italiane](carrier:poste-italiane), SDA | Due tentativi, poi giacenza per 10 giorni |
| [BRT (Bartolini)](carrier:brt) | Due tentativi, poi 10 giorni. Sul sito BRT inserisci il numero in "ID collo cliente" |
| [GLS](carrier:gls-it) | Due tentativi, poi 10 giorni |
| Energo | Dopo due tentativi l'ordine torna indietro per un rimborso completo |
| DHL, Nexive, Hermes, Sailpost, T-GROUP, [UPS](carrier:ups) | Anche loro nella lista |

Un venditore che spedisce da sé può usare uno di questi o un altro. Dove trovare il numero su ogni negozio: [trovare il numero di tracciamento](guide:find-tracking-number). Se non ritiri un pacco in giacenza: [pacco non ritirato](guide:uncollected-parcel).

## Com'è fatto un numero di tracciamento Amazon?

Ce ne sono di due tipi, più un numero d'ordine che non è né l'uno né l'altro.

Amazon non pubblica il formato dei suoi numeri. Queste sono le forme che Peek riconosce come Amazon, qui con cifre inventate:

:::anatomy TBA 123456789012
- TBA | Lettere di Amazon. `TBC` e `TBM` funzionano allo stesso modo
- 123456789012 | Dodici cifre
:::

| Forma (inventata) | Cos'è |
| --- | --- |
| `TBA123456789012` | Amazon: `TBA`, `TBC` o `TBM` e 12 cifre |
| `IT1234567890` | Amazon in Europa: un codice paese (`IT` e altri) e 10 cifre |
| `123-1234567-1234567` | Il tuo numero d'ordine Amazon: 3, 7 e 7 cifre. Non è un numero di tracciamento |
| Tutto il resto | Il numero del corriere, per esempio di Poste Italiane o BRT |

Il numero di un corriere funziona sul suo sito, come spiega [i formati dei numeri di tracciamento](guide:tracking-number-formats). Non sai quale hai? Scrivilo qui:

:::checker
:::

## Perché il mio numero di tracciamento Amazon è cambiato, o ne ho due?

Di solito per uno di questi motivi:

- **Più articoli, più pacchi.** Se un ordine contiene più articoli, ognuno può avere date di consegna e tracciamento separati. Un articolo che manca nel pacco potrebbe essere stato spedito separatamente.
- **Un corriere intermedio.** "La prima fase della spedizione potrebbe essere stata affidata a un corriere intermedio", e in quel tratto il tracciamento può mancare.
- **Il venditore usa il suo corriere.** Allora il numero è quello di BRT, GLS o un altro, non di Amazon.

:::journey
- warehouse | Amazon o il venditore | Più articoli possono partire in più pacchi, ognuno con il suo numero
- label | Etichetta creata | Alcune modalità di spedizione non sono tracciabili
- handover | Corriere intermedio | Può gestire la prima fase, a volte senza tracciamento
- truck | In consegna | Alcuni corrieri consegnano fino alle 22:00
- home | Tu | Può risultare consegnato prima che arrivi
:::

Quando il primo corriere indica il partner che subentra, [Peek](/) tiene la prima cronologia, segue il partner appena il suo tracciamento mostra novità e indica sulla scheda nome e numero del partner.

## Perché non c'è il tracciamento del mio ordine Amazon?

Amazon dà questi motivi nella pagina "Informazioni di tracciabilità mancanti":

- **Corriere intermedio.** La prima fase può essere affidata a un altro corriere.
- **Spedizione non tracciabile.** "La modalità di spedizione non consente di tenere traccia del pacco." Anche le consegne internazionali standard potrebbero non essere tracciabili.
- **Il venditore non l'ha condiviso.** Gli ordini dei venditori si tracciano solo se il venditore condivide le informazioni con Amazon e se hai scelto un'opzione di spedizione tracciabile. Altrimenti contatta il venditore, "perché Amazon non è responsabile del processo di spedizione".
- **Venditore VOC.** Sulla pagina dei corrieri Amazon.it aggiunge questo caso: segui le istruzioni del venditore, non Amazon.it.

Se la data di consegna prevista è passata e non cambia nulla, Amazon consiglia di attendere uno o due giorni. Per scrivere al venditore: I miei ordini, poi "Problema con l'ordine". Se il tracciamento resta fermo per giorni: [perché il tracciamento non si aggiorna](guide:tracking-not-updating).

## Cosa fare se l'ordine Amazon è in ritardo o risulta consegnato?

Gli stati di Amazon in I miei ordini sono `In arrivo`, `In consegna`, `Consegnato` e `Non consegnabile`. L'ultimo vuol dire che il pacco torna ad Amazon, che ti rimborsa in automatico quando lo riceve. Per il resto, procedi così:

:::steps
- Aspetta 48 ore | "La maggior parte dei pacchi in ritardo arriva entro 48 ore" dalla data prevista. Un pacco può anche essere scansionato come consegnato prima della consegna effettiva.
- Guardati intorno | Controlla il tuo luogo sicuro e chiedi ai vicini. Alcuni corrieri consegnano fino alle 22:00.
- Chiedi al corriere | "Traccia il mio pacco" ti dice qual è. La pagina "Informazioni di contatto del corriere" di Amazon.it ha i contatti di ognuno.
- Contatta il venditore | Se ha venduto e spedito lui: I miei ordini, "Problema con l'ordine". "I venditori rispondono entro 48 ore."
- Chiedi ad Amazon | Ordini spediti da Amazon: Servizio Clienti, entro 30 giorni dalla data di consegna prevista. Ordini di venditori: Garanzia dalla A alla Z.
:::

Più dettagli su ogni caso: [risulta consegnato ma non è arrivato](guide:delivered-not-received) e [pacco smarrito](guide:lost-parcel).

### Quando puoi chiedere la Garanzia dalla A alla Z?

Copre gli articoli che un venditore del Marketplace ha venduto e spedito da sé. Per un pacco mai arrivato devono essere passati tre giorni dall'ultima data di consegna prevista, o dalla consegna confermata. Devi anche aver contattato il venditore senza che abbia risposto entro 48 ore o risolto il problema.

| Termine | Amazon.it |
| --- | --- |
| Risposta del venditore | 48 ore |
| Attesa dopo l'ultima data prevista | Tre giorni |
| Richiesta possibile finché | L'ultima data di consegna prevista risale a 90 giorni o meno |

Fai la richiesta da I miei ordini con "Problema con l'ordine". Se il venditore non ti ha rimborsato costi in più, come la tassa doganale, puoi chiederli con la garanzia.

## Posso tracciare un pacco Amazon fuori da Amazon?

Dipende dal numero. Incollalo in [Peek](/):

- **Il numero di un corriere** (Poste Italiane, BRT, GLS, SDA…) si traccia come qualsiasi altro pacco.
- **Un numero Amazon**, o un link track.amazon: Peek interroga prima il tracciamento pubblico di Amazon. Se risponde, il pacco viaggia con [Amazon Shipping](carrier:amazon-shipping), il servizio di spedizioni di Amazon per gli e-commerce, o con la Gestione multicanale, in cui Amazon spedisce ordini fatti su altri siti, spesso in imballaggi neutri. Allora Peek lo segue da solo.
- Altrimenti è Amazon Logistics che consegna un ordine Amazon, e Amazon lo mostra solo nel tuo account. Peek te lo dice e propone "Apri i miei ordini Amazon", che apre i tuoi ordini sul sito Amazon giusto per quel numero: amazon.it per `IT`. Peek non ti chiede mai le credenziali Amazon.
- **Un numero d'ordine** riceve "Sembra un numero d'ordine Amazon". Usa invece il numero di tracciamento di "Traccia il mio pacco" o dell'e-mail di spedizione.

:::sources
- [Amazon.it: Informazioni di contatto del corriere](https://www.amazon.it/gp/help/customer/display.html?nodeId=GBPEXEXYULHB5WCH) – corrieri in Italia, tentativi e giacenza, ID collo cliente BRT, VOC
- [Amazon.it: Effettua un ordine da un venditore Marketplace](https://www.amazon.it/gp/help/customer/display.html?nodeId=GEF528GN65XSJ7V8) – Spedizione da e Venduto da
- [Amazon.it: Gestito da Amazon](https://www.amazon.it/gp/help/customer/display.html?nodeId=G239KSGYPUFUY8TQ) – merce dei venditori spedita da Amazon, servizio clienti e resi
- [Amazon.it: Traccia il tuo pacco](https://www.amazon.it/gp/help/customer/display.html?nodeId=GENAFPTNLHV7ZACW) – pacchi separati, stati, 48 ore, tracciamento dei venditori
- [Amazon.it: Informazioni di tracciabilità mancanti](https://www.amazon.it/gp/help/customer/display.html?nodeId=G6ZFEB9ZDU7QHMER) – corriere intermedio, spedizioni non tracciabili, venditori, uno o due giorni
- [Amazon.it: Consegne in ritardo](https://www.amazon.it/gp/help/customer/display.html?nodeId=GL669SSDXFCJ2ZA6) – 48 ore, 30 giorni
- [Amazon.it: Trova un pacco mancante che risulta essere stato consegnato](https://www.amazon.it/gp/help/customer/display.html?nodeId=GCU8BWGTQNJKQEBS) – 22:00, scansione anticipata, 48 ore
- [Amazon.it: Contatta un venditore del Marketplace](https://www.amazon.it/gp/help/customer/display.html?nodeId=GLC8ZMBWMBTR6QZZ) – Problema con l'ordine, 48 ore
- [Amazon.it: Garanzia dalla A alla Z](https://www.amazon.it/gp/help/customer/display.html?nodeId=GQ37ZCNECJKTFYQV) – 90 giorni, tre giorni, 48 ore, tassa doganale
- [Amazon Shipping Italia](https://shipping.amazon.it/) – spedizioni per gli e-commerce
- [Amazon: Gestione multicanale](https://sell.amazon.it/logistica-di-amazon/gestione-multicanale) – ordini da altri canali, imballaggi neutri
- [Universal Parcel Scraper: dati dei corrieri](https://github.com/plhery/universal-parcel-scraper/tree/main/carriers) – forme dei numeri Amazon, cosa controlla Peek
:::
