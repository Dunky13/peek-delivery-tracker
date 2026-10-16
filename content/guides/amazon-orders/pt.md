---
title: Seguir encomendas da Amazon: vendedores e transportadoras
description: Quem envia a tua encomenda da Amazon, que transportadora a entrega, porque é que o número de seguimento muda ou não aparece e como funciona a Garantia de A a Z.
slug: seguimento-encomenda-amazon
picture: Um telemóvel mostra o progresso de uma encomenda, duas carrinhas passam uma encomenda de uma para a outra e o Pip observa.
published: 2026-10-16
updated: 2026-10-16
---

Para seguir uma encomenda da Amazon, abre Os meus pedidos, escolhe o pedido e seleciona "Acompanhar embalagem": é aí que a Amazon mostra a transportadora, o número de seguimento e cada atualização. Quem te ajuda quando algo corre mal depende de quem envia. A Amazon trata das suas próprias encomendas e dos produtos "Enviados pela Amazon", enquanto um vendedor que envia por conta própria escolhe a transportadora e responde pela entrega.

## Em Portugal compra-se na Amazon.es?

Sim. Não há loja portuguesa: amazon.pt reencaminha para amazon.es, em português. A Amazon.es tem uma página própria de "Taxas e opções de envio para Portugal": o Envio Premium chega 2 dias após o envio e o Envio standard 3 dias úteis após o envio, em quase todos os envios para Portugal continental. Para as ilhas, os prazos aparecem na finalização da compra. Os custos de envio dos vendedores externos podem ser outros.

## Quem envia a minha encomenda da Amazon: a Amazon ou um vendedor?

Vê o nome do vendedor na página do produto ou em Os meus pedidos, e repara no emblema Prime.

| Caso | O que significa | Quem te ajuda com a entrega |
| --- | --- | --- |
| Vendido e enviado pela Amazon | Stock da Amazon | Amazon |
| Vendido por um vendedor, enviado pela Amazon | "Enviados pela Amazon": o vendedor oferece o produto, a Amazon envia-o a partir de um centro de distribuição | Amazon |
| Vendido e enviado por um vendedor, sem Prime | O vendedor envia com a transportadora que escolhe | Primeiro o vendedor |

A Amazon explica: "Se o produto do vendedor na loja não estiver marcado com o emblema Prime, o vendedor é responsável por satisfazer o pedido", incluindo a entrega. Com Prime, trata a Amazon.

## Que transportadora entrega a minha encomenda da Amazon?

Diz-te "Acompanhar embalagem", com o número de referência. Quando a transportadora é a própria Amazon, trata-se da [Amazon Logistics](carrier:amazon-logistics), a rede de entregas da Amazon. Na página de contactos das transportadoras, a Amazon.es indica:

- **Transportadoras comuns:** Amazon, Correos, [Correos Express](carrier:correos-express), [CTT Express](carrier:ctt-express), [SEUR](carrier:seur), GLS (ASM), [Paack](carrier:paack) (com assistência em português), Celeritas/SGEL, Método, Pilot e [UPS](carrier:ups).
- **Outras transportadoras:** entre elas, os [CTT](carrier:ctt) (CTT Portugal).

Um vendedor que envia por conta própria pode usar qualquer uma destas ou outra. Onde está o número em cada loja: [encontrar o número de seguimento](guide:find-tracking-number).

## Como é um número de seguimento da Amazon?

Há dois tipos, e ainda um número de pedido que não é nenhum deles.

A Amazon não publica o formato dos seus números. Estas são as formas que o Peek reconhece como da Amazon, aqui com algarismos inventados:

:::anatomy TBA 123456789012
- TBA | Letras da Amazon. `TBC` e `TBM` funcionam da mesma maneira
- 123456789012 | Doze algarismos
:::

| Forma (inventada) | O que é |
| --- | --- |
| `TBA123456789012` | Amazon: `TBA`, `TBC` ou `TBM` e 12 algarismos |
| `PT1234567890` | Amazon na Europa: um código de país (`PT`, `ES` e outros) e 10 algarismos |
| `123-1234567-1234567` | O teu número de pedido da Amazon: 3, 7 e 7 algarismos. Não é um número de seguimento |
| Tudo o resto | O número da transportadora, por exemplo dos CTT ou da SEUR |

O número de uma transportadora funciona no site dela, como explica [formatos de números de seguimento](guide:tracking-number-formats). Não sabes qual tens? Escreve-o aqui:

:::checker
:::

## Porque é que o meu número de seguimento da Amazon mudou, ou porque tenho dois?

Normalmente por uma destas razões:

- **Vários produtos, várias embalagens.** Se encomendaste mais do que um produto, podem ter datas de entrega e números de referência diferentes. Se falta um produto na caixa, pode ter sido enviado separadamente.
- **A transportadora da tua área.** A Amazon avisa que às vezes "o pedido está dentro do prazo, mas ainda não foi recebido pela transportadora na sua área". Até lá, não há novidades.
- **O vendedor usa a sua transportadora.** Então o número é dos CTT, da SEUR ou de outra, não da Amazon.

:::journey
- warehouse | Amazon ou o vendedor | Vários produtos podem sair em várias embalagens, cada uma com o seu número
- label | Etiqueta criada | O seguimento só aparece quando a transportadora lê o pedido pela primeira vez
- handover | Transportadora da tua área | Sem novidades até receber a embalagem
- truck | Para entrega | Algumas transportadoras entregam até às 22h00
- home | Tu | A maioria dos atrasos chega em 48 horas
:::

Quando a primeira transportadora indica o parceiro que fica com a encomenda, o [Peek](/) guarda o primeiro histórico, segue o parceiro assim que o seguimento dele mostra novidades e mostra no cartão o nome e o número do parceiro.

## Porque é que não há seguimento da minha encomenda da Amazon?

A Amazon dá estas razões na página "Informações de referência indisponíveis":

- **Ainda não houve leitura.** Nos pedidos da Amazon, o número só aparece quando a transportadora faz a leitura do pedido pela primeira vez.
- **Atraso nos dados.** A base de dados de seguimento pode ter atrasos.
- **A transportadora da tua área ainda não a tem.** O pedido está dentro do prazo, mas sem novidades até lá.
- **O vendedor não partilhou.** As encomendas de vendedores só têm seguimento se o vendedor partilhar a informação com a Amazon e se escolheste um envio que o permita. Algumas entregas internacionais padrão podem nem ser rastreáveis.

Sem opção de seguimento numa encomenda de vendedor? Vai a Os meus pedidos, escolhe "Problema com o pedido" e depois "Contactar o vendedor". "Aguarde 48 horas para o vendedor responder." Se a data prevista já passou e nada muda, a Amazon aconselha a esperar um ou dois dias. Se o seguimento continua parado há dias: [porque é que o seguimento não atualiza](guide:tracking-not-updating).

## O que fazer se a encomenda da Amazon está atrasada ou aparece como entregue?

Os estados da Amazon em Os meus pedidos são `Chegada`, `Para entrega`, `Entregue` e `Não pode ser entregue`. Este último quer dizer que a embalagem volta para a Amazon, que te reembolsa automaticamente quando a recebe. Para o resto, segue esta ordem:

:::steps
- Espera 48 horas | "A maioria dos pedidos atrasados chega no prazo de 48 horas" a contar da data prevista.
- Procura à volta | Vê no teu lugar seguro e pergunta aos vizinhos. Algumas transportadoras entregam até às 22h00.
- Pergunta à transportadora | "Acompanhar embalagem" diz-te qual é. A página de contactos das transportadoras da Amazon.es tem os dados de cada uma.
- Contacta o vendedor | Se foi ele a vender e enviar: Os meus pedidos, "Problema com o pedido". "O vendedor responderá por e-mail no prazo de 48 horas."
- Fala com a Amazon | Encomendas enviadas pela Amazon: serviço de apoio ao cliente, no prazo de 30 dias a contar da data prevista de entrega. Encomendas de vendedores: Garantia de A a Z.
:::

Mais sobre cada caso: [entregue mas não recebida](guide:delivered-not-received) e [encomenda perdida](guide:lost-parcel).

### Quando posso pedir a Garantia de A a Z?

Cobre produtos que um vendedor do Marketplace vendeu e enviou por conta própria. Para uma embalagem que nunca chegou, têm de ter passado três dias desde a data prevista de entrega mais recente ou desde a data de entrega confirmada, o que ocorrer mais cedo. Também tens de ter contactado o vendedor sem resposta nem solução em 48 horas.

| Prazo | Amazon.es |
| --- | --- |
| Resposta do vendedor | 48 horas |
| Espera após a data prevista mais recente | Três dias |
| Podes pedir enquanto | A última data de entrega tem 90 dias ou menos |

Fazes o pedido em Os meus pedidos, com "Problema com pedido". Compras na Loja global da Amazon e produtos de vendedores entregues pelo Prime vão diretamente para o apoio ao cliente da Amazon. Se o vendedor não te reembolsou custos adicionais, como a taxa alfandegária, também os podes pedir.

## Posso seguir uma encomenda da Amazon fora da Amazon?

Depende do número. Cola-o no [Peek](/):

- **O número de uma transportadora** (CTT, CTT Express, SEUR, Correos Express…) segue-se como qualquer outra encomenda.
- **Um número da Amazon**, ou um link track.amazon: o Peek pergunta primeiro ao seguimento público da Amazon. Se responder, a encomenda viaja com a Amazon Shipping, o serviço de entregas da Amazon para lojas online, ou com a Logística Multicanal, em que a Amazon envia encomendas feitas noutros sites, muitas vezes em embalagens sem marca. Aí o Peek segue-a sozinho.
- Se não, é a Amazon Logistics a entregar uma encomenda da Amazon, e a Amazon só a mostra na tua conta. O Peek diz-te isso e propõe "Abrir os meus pedidos Amazon", que abre os teus pedidos no site da Amazon que corresponde ao número: amazon.es para `PT` e `ES`. O Peek nunca te pede os dados de acesso da Amazon.
- **Um número de pedido** recebe "Parece um número de pedido da Amazon". Usa antes o número de seguimento de "Acompanhar embalagem" ou do e-mail de envio.

:::sources
- [Amazon.es: Taxas e opções de envio para Portugal](https://www.amazon.es/gp/help/customer/display.html?nodeId=GVVMYF6KMB3ZVNGR&language=pt_PT) – Envio Premium e standard, Portugal continental, ilhas, vendedores externos
- [Amazon.es: Informações de contacto das transportadoras](https://www.amazon.es/gp/help/customer/display.html?nodeId=GBPEXEXYULHB5WCH&language=pt_PT) – transportadoras comuns, CTT Portugal, Paack em português
- [Amazon.es: Efetuar um pedido a um vendedor do Marketplace](https://www.amazon.es/gp/help/customer/display.html?nodeId=GEF528GN65XSJ7V8&language=pt_PT) – emblema Prime, responsabilidade do vendedor
- [Amazon.es: Pedidos enviados pela Amazon](https://www.amazon.es/gp/help/customer/display.html?nodeId=G239KSGYPUFUY8TQ&language=pt_PT) – produtos de vendedores enviados pela Amazon
- [Amazon.es: Fazer o seguimento da embalagem](https://www.amazon.es/gp/help/customer/display.html?nodeId=GENAFPTNLHV7ZACW&language=pt_PT) – Acompanhar embalagem, embalagens separadas, estados, 48 horas
- [Amazon.es: Informações de referência indisponíveis](https://www.amazon.es/gp/help/customer/display.html?nodeId=G6ZFEB9ZDU7QHMER&language=pt_PT) – primeira leitura, transportadora da área, vendedores, 48 horas, um ou dois dias
- [Amazon.es: Entregas atrasadas](https://www.amazon.es/gp/help/customer/display.html?nodeId=GL669SSDXFCJ2ZA6&language=pt_PT) – 48 horas, transportadora, 30 dias
- [Amazon.es: Encontrar uma embalagem em falta que é apresentada como entregue](https://www.amazon.es/gp/help/customer/display.html?nodeId=GCU8BWGTQNJKQEBS&language=pt_PT) – 22h00, vendedor ou Amazon, 30 dias
- [Amazon.es: Contactar um vendedor do Marketplace](https://www.amazon.es/gp/help/customer/display.html?nodeId=GLC8ZMBWMBTR6QZZ&language=pt_PT) – 48 horas, exceção Prime
- [Amazon.es: Garantia de A a Z](https://www.amazon.es/gp/help/customer/display.html?nodeId=GQ37ZCNECJKTFYQV&language=pt_PT) – 90 dias, três dias, 48 horas, Loja global, Prime, taxa alfandegária
- [Amazon Shipping España](https://shipping.amazon.es/) – entregas para lojas online
- [Amazon: Logística Multicanal](https://sell.amazon.es/logistica-de-amazon/gestion-multicanal) – encomendas de outros canais, embalagens sem marca
- [Universal Parcel Scraper: dados das transportadoras](https://github.com/plhery/universal-parcel-scraper/tree/main/carriers) – formas dos números da Amazon, o que o Peek verifica
:::
