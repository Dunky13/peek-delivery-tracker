---
title: Seguimiento de pedidos Amazon: vendedores y transportistas
description: Quién envía tu pedido de Amazon, qué transportista lo entrega, por qué el seguimiento cambia o no aparece y cómo funciona la Garantía de la A a la Z.
slug: seguimiento-pedido-amazon
picture: Un móvil muestra el avance de un pedido, dos furgonetas se pasan un paquete y Pip lo observa.
published: 2026-10-16
updated: 2026-10-16
---

Para seguir un pedido de Amazon, abre Mis pedidos, elige el pedido y pulsa "Localiza tu paquete": ahí Amazon muestra el transportista, el número de seguimiento y cada novedad. Quién te ayuda si algo falla depende de quién lo envía. Amazon se ocupa de sus propios pedidos y de los "enviados por Amazon", mientras que un vendedor que envía por su cuenta elige el transportista y responde de la entrega.

## ¿Quién envía mi pedido de Amazon: Amazon o un vendedor externo?

Mira el nombre del vendedor en la página del producto o en Mis pedidos, dentro de "Ver detalles del pedido", debajo del nombre del producto. Y fíjate en el distintivo de Prime.

| Caso | Qué significa | Quién te ayuda con la entrega |
| --- | --- | --- |
| Vendido y enviado por Amazon | Stock de Amazon | Amazon |
| Vendido por un vendedor, enviado por Amazon | Logística de Amazon: el vendedor lo ofrece, pero Amazon lo empaqueta y envía desde un centro logístico | Amazon |
| Vendido y enviado por un vendedor, sin Prime | El vendedor lo envía con el transportista que elige | Primero el vendedor |

Amazon.es lo dice así: "En el caso de pedidos del Marketplace sin el distintivo de Prime, el vendedor es responsable de gestionar el pedido, tramitar la entrega" y la atención al cliente. Con Prime, se encarga Amazon.

## ¿Qué transportista entrega mi paquete de Amazon?

Lo indica "Localiza tu paquete", junto con el número de seguimiento. Cuando el transportista es Amazon, se trata de [Amazon Logistics](carrier:amazon-logistics), su propia red de reparto. Estos son los transportistas habituales que Amazon.es cita en su página de contacto, que da los datos de cada uno:

- Amazon, con el seguimiento en Mis pedidos.
- [Correos](carrier:correos-spain) y [Correos Express](carrier:correos-express).
- [SEUR](carrier:seur), [GLS](carrier:gls-es) (ASM), [CTT Express](carrier:ctt-express) y [UPS](carrier:ups).
- [Paack](carrier:paack), Celeritas/SGEL, Método y Pilot.

Un vendedor que envía por su cuenta puede usar cualquiera de ellos u otro. Dónde está el número en cada tienda: [encontrar tu número de seguimiento](guide:find-tracking-number).

## ¿Cómo es un número de seguimiento de Amazon?

Hay dos tipos, y además un número de pedido que no es ninguno de los dos.

Amazon no publica el formato de sus números. Estas son las formas que Peek reconoce como de Amazon, aquí con cifras inventadas:

:::anatomy TBA 123456789012
- TBA | Letras de Amazon. `TBC` y `TBM` funcionan igual
- 123456789012 | Doce cifras
:::

| Forma (inventada) | Qué es |
| --- | --- |
| `TBA123456789012` | Amazon: `TBA`, `TBC` o `TBM` y 12 cifras |
| `ES1234567890` | Amazon en Europa: un código de país (`ES` y otros) y 10 cifras |
| `123-1234567-1234567` | Tu número de pedido de Amazon: 3, 7 y 7 cifras. No es un número de seguimiento |
| Todo lo demás | El número del transportista, por ejemplo de Correos o SEUR |

El número de un transportista funciona en su web, como explica [los formatos de números de seguimiento](guide:tracking-number-formats). ¿No sabes cuál tienes? Escríbelo aquí:

:::checker
:::

## ¿Por qué ha cambiado mi número de seguimiento de Amazon, o por qué tengo dos?

Normalmente por uno de estos motivos:

- **Varios productos, varios paquetes.** Si pides más de un producto, cada uno puede tener fechas de entrega e información de seguimiento distintas. Si falta un producto en la caja, puede que se haya enviado por separado.
- **El transportista de tu zona.** Amazon avisa de que a veces "el pedido llegará a tiempo, pero el transportista de tu área no lo ha recibido": hasta que lo recibe, no hay novedades.
- **El vendedor usa su propio transportista.** Entonces el número es de Correos, SEUR u otro, no de Amazon.

:::journey
- warehouse | Amazon o el vendedor | Varios productos pueden salir en varios paquetes, cada uno con su número
- label | Etiqueta creada | Algunos envíos internacionales no tienen seguimiento
- handover | Transportista de tu zona | Sin novedades hasta que recibe el paquete
- truck | En reparto | Algunos transportistas entregan hasta las 22:00
- home | Tú | La mayoría de los retrasos llegan en 48 horas
:::

Cuando el primer transportista indica el socio que toma el relevo, [Peek](/) conserva el primer historial, sigue al socio en cuanto su seguimiento muestra novedades y enseña en la tarjeta su nombre y su número.

## ¿Por qué no hay seguimiento de mi pedido de Amazon?

Amazon da estos motivos en su página "Información de seguimiento no disponible":

- **Aún no hay escaneo.** En pedidos de Amazon, el número puede tardar en aparecer porque el pedido todavía va camino del transportista.
- **Retraso en los datos.** La base de datos de seguimiento puede ir con retraso.
- **El transportista de tu área aún no lo tiene.** El pedido llegará a tiempo, pero sin novedades hasta entonces.
- **El vendedor no lo ha compartido.** Los pedidos de vendedores solo tienen seguimiento si el vendedor comparte la información con Amazon y elegiste un envío con seguimiento.

Si no ves la opción de seguimiento en un pedido de un vendedor, ve a Mis pedidos, elige "Problema con el pedido" y luego "Ponerse en contacto con el vendedor". "Espera 48 horas para que el vendedor responda." Si ya pasó la fecha prevista y nada cambia, Amazon aconseja esperar uno o dos días. Si el seguimiento sigue parado días: [por qué no se actualiza el seguimiento](guide:tracking-not-updating).

## ¿Qué hago si mi pedido de Amazon llega tarde o sale como entregado?

Los estados de Amazon en Mis pedidos son `Llegará`, `En reparto`, `Entregado` y `No se ha podido entregar`. El último significa que el paquete vuelve a Amazon, que te reembolsa automáticamente cuando lo recibe. Para lo demás, sigue este orden:

:::steps
- Espera 48 horas | "La mayoría de los paquetes con retraso llegan dentro de las 48 horas" tras la fecha prevista. Amazon también cita retrasos en la aduana de paquetes internacionales.
- Busca alrededor | Mira en el lugar seguro, en el buzón y pregunta a los vecinos. Algunos transportistas entregan hasta las 22:00.
- Pregunta al transportista | "Localiza tu paquete" te dice cuál es. La página "Información de contacto del transportista" de Amazon.es enlaza a cada uno.
- Contacta con el vendedor | Si lo vendió y envió él: Mis pedidos, "Problema con el pedido". "Te responderá por correo electrónico en un plazo de 48 horas."
- Acude a Amazon | Pedidos enviados por Amazon: atención al cliente, dentro de los 30 días siguientes a la fecha de entrega prevista. Pedidos de vendedores: Garantía de la A a la Z.
:::

Más sobre cada caso: [entregado pero no recibido](guide:delivered-not-received) y [paquete perdido](guide:lost-parcel). Para envíos que pasan por aduana: [paquete retenido en aduanas](guide:customs).

### ¿Cuándo puedo pedir la Garantía de la A a la Z?

Cubre los productos que un vendedor externo vendió y envió por su cuenta. Para un paquete que nunca llegó, tienen que haber pasado tres días desde la última fecha de entrega estimada o la entrega confirmada, lo que ocurra primero. Además, tienes que haber contactado con el vendedor sin que respondiera en 48 horas ni resolviera el problema.

| Plazo | Amazon.es |
| --- | --- |
| Respuesta del vendedor | 48 horas |
| Espera tras la última fecha estimada | Tres días |
| Puedes pedirla mientras | La última fecha de entrega fue hace 90 días o menos |

La solicitas en Mis pedidos, con "Problema con el pedido".

## ¿Puedo seguir un paquete de Amazon fuera de Amazon?

Depende del número. Pégalo en [Peek](/):

- **El número de un transportista** (Correos, SEUR, GLS, CTT Express…) se sigue como cualquier otro paquete.
- **Un número de Amazon**, o un enlace de track.amazon: Peek pregunta primero al seguimiento público de Amazon. Si responde, el paquete viaja con [Amazon Shipping](carrier:amazon-shipping), el servicio de paquetería de Amazon para comercios online, "no solo para vendedores en Amazon", o con la Logística Multicanal, donde Amazon envía pedidos de otras webs, a menudo en embalajes sin marca. Entonces Peek lo sigue solo.
- Si no, es Amazon Logistics entregando un pedido de Amazon, y Amazon solo lo muestra en tu cuenta. Peek te lo dice y te ofrece "Abrir mis pedidos de Amazon", que abre tus pedidos en la web de Amazon que corresponde al número: amazon.es para `ES`. Peek nunca te pide tus datos de acceso de Amazon.
- **Un número de pedido** recibe "Parece un número de pedido de Amazon". Usa el número de seguimiento de "Localiza tu paquete" o del correo de envío.

:::sources
- [Amazon.es: Información de contacto del transportista](https://www.amazon.es/gp/help/customer/display.html?nodeId=GBPEXEXYULHB5WCH) – transportistas comunes, nombre y número en Mis pedidos
- [Amazon.es: Pedidos a vendedores Marketplace](https://www.amazon.es/gp/help/customer/display.html?nodeId=GEF528GN65XSJ7V8) – distintivo de Prime, responsabilidad del vendedor
- [Amazon.es: Pedidos enviados por Amazon](https://www.amazon.es/gp/help/customer/display.html?nodeId=G239KSGYPUFUY8TQ) – Logística de Amazon
- [Amazon.es: Localizar un paquete](https://www.amazon.es/gp/help/customer/display.html?nodeId=GENAFPTNLHV7ZACW) – Localiza tu paquete, paquetes separados, estados, 48 horas
- [Amazon.es: Información de seguimiento no disponible](https://www.amazon.es/gp/help/customer/display.html?nodeId=G6ZFEB9ZDU7QHMER) – primer escaneo, transportista de tu área, vendedores, 48 horas, uno o dos días
- [Amazon.es: Entregas con retraso](https://www.amazon.es/gp/help/customer/display.html?nodeId=GL669SSDXFCJ2ZA6) – 48 horas, aduana, 30 días
- [Amazon.es: Encuentra un paquete no recibido que aparece como entregado](https://www.amazon.es/gp/help/customer/display.html?nodeId=GCU8BWGTQNJKQEBS) – 22:00, vendedor o Amazon, 30 días
- [Amazon.es: Contactar con un vendedor del sitio web de Amazon](https://www.amazon.es/gp/help/customer/display.html?nodeId=GLC8ZMBWMBTR6QZZ) – 48 horas, nombre del vendedor en los detalles del pedido
- [Amazon.es: Garantía de la A a la Z](https://www.amazon.es/gp/help/customer/display.html?nodeId=GQ37ZCNECJKTFYQV) – 90 días, tres días, 48 horas
- [Amazon Shipping España](https://shipping.amazon.es/) – paquetería para comercios online
- [Amazon: Logística Multicanal](https://sell.amazon.es/logistica-de-amazon/gestion-multicanal) – pedidos de otros canales, embalajes sin marca
- [Universal Parcel Scraper: datos de transportistas](https://github.com/plhery/universal-parcel-scraper/tree/main/carriers) – formas de los números de Amazon, qué comprueba Peek
:::
