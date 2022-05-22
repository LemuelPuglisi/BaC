# Ethereum

Ethereum è una cryptocurrency intesa a fornire un linguaggio di programmazione Turing-completo, utilizzabile per lo sviluppo di Smart Contracts, allo scopo di codificare vari sistemi decentralizzati (non-fungible assets, DAOs, smart propriety e molto altro). 

> **Intro completa dal whitepaper.**
> The intent of Ethereum is to create an alternative protocol for building decentralized applications, providing a different set of tradeoffs that we believe will be very useful for a large class of decentralized  applications, with particular emphasis on situations where rapid  development time, security for small and rarely used applications, and  the ability of different applications to very efficiently interact, are  important. Ethereum does this by building what is essentially the  ultimate abstract foundational layer: a blockchain with a built-in  Turing-complete programming language, allowing anyone to write smart  contracts and decentralized applications where they can create their own arbitrary rules for ownership, transaction formats and state transition functions. A bare-bones version of Namecoin can be written in two lines of code, and other protocols like currencies and reputation systems can be built in under twenty. Smart contracts, cryptographic "boxes" that  contain value and only unlock it if certain conditions are met, can also be built on top of the platform, with vastly more power than that  offered by Bitcoin scripting because of the added powers of  Turing-completeness, value-awareness, blockchain-awareness and state.



## Un po' di storia

Negli anni '80-'90 e-cash fu' il primo protocollo anonimo di pagamento elettronico. Questo sfruttava la primitiva crittografica Chaumiam Blinding. Il protocollo fallì a causa della concorrenza centralizzata. Poco dopo si presentò b-money, la prima proposta contenente la risoluzione di hash puzzles e consenso distribuito. Il primo prototipo di implemenazione arrivo da Hal Finney con le RPOW (reusable proof of work). Nel 2009 arrivò finalmente Bitcoin. Il meccanismo dietro la PoW risolse due problemi: l'implementazione di un algoritmo di consenso totalmente distribuito (1), e come consentire il libero ingresso nel processo di consenso, risolvendo il problema politico di decidere chi può influenzare il consenso (2), prevenendo contemporaneamente i [sybil attacks](https://academy.binance.com/it/articles/sybil-attacks-explained). 



### Bitcoin come uno State Transition System

Da un punto di vista tecnico, il ledger di una cryptocurrency come Bitcoin può essere considerato come un sistema di transizione a stati, dove uno stato consiste nel fotografare chi è il possessore di tutte le UTXO esistenti al momento, mentre una funzione di transizione prende in input uno stato $S$ ed una transazione $tx$ e torna in output un nuovo stato. Da quello che abbiamo visto sino ad ora, possiamo descrivere una ipotetica funzione `apply(S, tx) -> S'` come segue: 

1. Per ogni input nella `tx`: 
   1. Se l'UTXO referenziata non è in `S`, ritorna errore.
   2. Se la firma dell'owner della UTXO non è verificata, ritorna errore. 
2. Se la somma delle UTXO di input è minore alla somma delle UTXO di output, ritorna errore.
3. Ritorna `S` dove vengono rimosse tutte le UTXO di input e aggiunte tutte le UTXO di output. 



## Ethereum accounts

In Ethereum, lo stato è costituito da oggetti chiamati "account", ognuno di essi possiede un indirizzo di 20 byte. Per transizione di stato ci si riferisce al *trasferimento diretto di informazioni* tra account. Un account Ethereum contiene quattro campi: 

* Il **nonce**, un contatore che permette di controllare che ogni tx sia processata 1 volta
* L'**ether balance** dell'account (quantitativo di ether)
* Il  **contract code**, se presente
* L'**account storage**, vuoto di default

L'**ether** è il principale crypto-fuel (benzina) di Ethereum, ed è utilizzato per pagare le transaction fees. In generale, esistono due tipi di account: 

* **Externally Owned Account** (**EOA**): controllato da una chiave privata, non ha codice e può comunicare con altri account creando e firmando una transazione.
* **Contract account**: controllato dal contract code. Ogni volta che riceve un messaggio, il suo codice si attiva permettendogli di leggere e scrivere sul proprio storage e di inviare messaggi ad altri account o creare altri contratti. 

In Ethereum, per contratto si intende un "agente autonomo" che vive all'interno della piattaforma, che esegue un codice stabilito ogni qual volta riceve un messaggio, che può controllare il proprio ether balance e molto altro.  



## Ethereum Virtual Machine (EVM)

L'EVM esiste come entità singola gestita da migliaia di computer collegati, che eseguono un client Ethereum. Il protocollo Ethereum stesso esiste unicamente allo scopo di garantire un funzionamento continuo, ininterrotto e immutabile di questa speciale macchina a stati. Essa è l'ambiente in cui sono presenti tutti gli account Ethereum (EOA e Smart Contracts). In ognuno dei blocchi della blockchain, Ethereum ha uno ed un solo stato "canonico", e la EVM è ciò che definisce le regole per calcolare un nuovo stato valido da blocco a blocco. 

Mentre Bitcoin è considerabile un libro mastro distribuito, dato che quello che principalmente si può fare sono delle transazioni, Ethereum è da considerarsi una macchina a stati distribuita, che permette anche di eseguire dei programmi chiamati Smart Contract. Lo stato di Ethereum è una enorme struttura dati che contiene non solo gli account e i rispettivi saldi, ma anche una macchina a stati che può cambiare da blocco a blocco in base ad un set prefissato di regole, e che può eseguire codice macchina arbitrario. Le regole specifiche di cambio stato da blocco a blocco sono definite dall'EVM. 

![Ddiagramma che mostra la composizione dell'EVM](Ch_8_ethereum.assets/evm.png)

> Da approfondire: 
>
> * https://ethereum.org/it/developers/docs/evm/#top



## Messaggi, transazioni e gas

Il termine "transazione" è utilizzato in Ethereum riferendosi ad un *data package* contenente un messaggio, appositamente firmato ed inviato da un EOA. Una transazione contiene: 

* Il destinatario (**recipient**) del messaggio
* Una **firma** che identifica il mittente (sender)
* La **quantità di ether** da trasferire dal mittente al destinatario
* Un campo **dati** opzionale
* Un campo **STARTGAS** che rappresenta il massimo numero di step computazionali che all'esecuzione della transazione è consentito effettuare. 
* Un campo **GASPRICE**, che rappresenta la fee che il mittente paga in ether per ogni step computazionale.

I primi tre campi sono standard in ogni crypto. Il campo **data** può essere utilizzato per interagire con i contratti, nel caso di un contratto che implementa un DNS distribuito potremmo utilizzare il campo data per specificare la coppia \<dominio/ip\> e inviarla al contratto. 

I campi **STARTGAS** e **GASPRICE** sono essenziali per il sistema anti-DoS di Ethereum. Per contrastare dei loop infiniti intenzionali o accidentali, ad ogni transazione si associa un numero massimo di step computazionali da eseguire. L'unità di computazione è chiamata **gas**, spesso uno step computazionale costa 1 gas, ma esistono operazioni che ne richiedono di più poiché computazionalmente costose o poiché richiedono di conservare un certo quantitativo di dati nello stato. Esiste anche una fee di 5 gas per ogni byte nel campo transaction data. L'intento del sistema di fee è quello di far pagare all'attaccante un costo proporzionale ad ogni risorsa consumata, includendo il calcolo, la banda e lo storage. In sintesi: 

* Si pagano 5 gas per ogni byte nel campo dati
* Si paga 1 gas circa per ogni step computazionale
* Si paga >1 gas per step computazionalmente o spazialmente onerosi.



## Messaggi

I contratti possono inviare messaggi ad altri contratti. I messaggi sono oggetti virtuali che esistono unicamente nell'Ethereum execution environment. Un messaggio contiene: 

* Un sender (implicito)
* Un recipient (destinatario) 
* Un quantitativo di ether da trasferire insieme al messaggio
* Un campo dati opzionale 
* Un campo STARTGAS

Un messaggio è come una transazione, eccetto che viene prodotto da un contratto anziché da un EOA. Un messaggio è prodotto quando durante l'esecuzione del codice di un contratto viene chiamato l'opcode `CALL`, che produce ed esegue un messaggio. Come una transazione, un messaggio raggiunge il contratto destinatario ed esegue il suo codice. Pertanto, i contratti possono avere relazioni con altri contratti esattamente nello stesso modo in cui possono farlo gli attori esterni.

Si noti che la quota di gas assegnata da una transazione o da un contratto si applica al gas totale consumato da tale transazione e a tutte le sottoesecuzioni. Ad esempio, se un attore esterno A invia una transazione a B con 1000 gas e B consuma 600 gas prima di inviare un messaggio a C e l'esecuzione interna di C consuma 300 gas prima di tornare a B, B può spendere altri 100 gas prima di esaurirlo.



## Ethereum State Transition Function

![Ether state transition](Ch_8_ethereum.assets/ether-state-transition.png)



La funzione di transizione di stato `APPLY(S, TX) -> S'` può essere definita come segue: 

* Controllare se la transazione è sintatticamente valida, che la sua firma sia valida e che la nonce combaci con la nonce conservata nell'account del mittente. Altrimenti ritorna errore. 
* Calcolare la transaction fee come `STARTGAS * GASPRICE` e determina l'indirizzo del mittente dalla firma. Sottrarre la fee dal bilancio dell'account del sender e incrementare la nonce del sender. Se il sender non ha abbastanza ether, ritornare errore. 
* Inizializzare `GAS = STARTGAS` e rimuovere una certa quantità di gas per byte per pagare i byte della transazione. 
* Trasferire il valore da transare dall'account del mittente all'account del destinatario. Se l'account destinatario non esiste, crealo. Se l'account destinatario è un contratto, esegui il codice del contratto fino a completamento o fine ad esaurimento del gas. 
* Se il trasferimento fallisce a causa della mancanza di soldi del mittente, o dell'esaurimento di gas, esegui un revert di tutti i cambiamenti di stato eccetto per il pagamento delle fees, e inserisci le fees nell'account del miner.
* Se il trasferimento ha successo, ritorna le fees del gas rimanente al mittente, e invia le fees per il gas consumato al miner. 



### Esempio 

Supponiamo che il codice del contratto sia: 

```python
if !self.storage[calldataload(0)]:
	self.storage[calldataload(0)] = calldataload(32)
```

Notiamo che il codice non è scritto il EVM code, bensì in Serpent (linguaggio di alto livello), successivamente compilato in EVM code. Supponiamo che lo storage del contratto parta inizialmente vuoto, e che una transazione viene inviata con i seguenti campi: 

```json
{
	"ether": 10, 
	"gas": 2000, 
	"ether_gasprice": 0.001, 
	"data": <byte[0,31]: "2", byte[32,63]: "CHARLIE">
}
```

1. Controllare che la tx sia ben formata e valida. 
2. Controllare che il sender ha almeno $2000 * .001 = 2$ ether. Se è così, sottrarre 2 dal bilancio del sender.
3. Inizializzare $gas=2000$, assumendo che la tx sia lunga 170 byte e che il byte-fee sia 5, allora sottraiamo $170 * 5 = 850$ gas, rimangono quindi $2000 - 850=1150$ gas rimanenti. 
4. Sottraiamo 10 ether (valore indicato nella tx) dall'account del sender e inseriamoli nell'account del receiver (il contratto). 
5. Eseguiamo il codice: controlla che nello storage l'indice 2 sia libero, e se non lo è, inserisce nell'indice 2 la stringa "CHARLIE". Supponiamo che questo costi 187 gas, allora l'ammontare rimanente di gas è $1150 - 187 = 963$ gas.
6. Ritornare $963 * 0.001 = 0.963$ ether all'account sender, e ritornare lo stato risultante. 

Se dall'altra parte non ci fosse stato un contratto ma un EOA, allora la transaction fee sarebbe semplicemente il GASPRICE moltiplicato alla lunghezza della transazione in byte, e il campo dati trasferito sarebbe irrilevante. 

Notare che i messaggi funzionano in maniera equivalente per il revert: se l'esecuzione del messaggio termina il gas, allora tale esecuzione e tutte le esecuzioni innestate eseguono il revert, ma l'esecuzione parent non necessita di effettuare il revert. Questo implica che è "sicuro" per un contratto richiamare un altro contratto, dato che se A chiama B con G gas, allora all'esecuzione di A è garantita la perdita di al più G gas. Esiste un opcode `CREATE` che permette di creare contratti: tale meccanismo è simile a `CALL`, con l'eccezione che l'output dell'esecuzione determina il codice del contratto creato.



## Code execution e memoria

Il codice di un contratto Ethereum è scritto in un linguaggio bytecode di basso livello e stack-based, chiamato "Ethereum virtual machine code" o "EVM code". Il codice consiste in una serie di byte, dove ogni byte rappresenta una operazione. In generale, l'esecuzione del codice consiste in un loop infinito che seleziona l'operazione indicata dal program counter e la esegue, incrementando poi il program counter di 1 (esso parte da 0), fino alla fine del codice o fino ad una istruzione STOP o RETURN. Le operazioni possono accedere a 3 tipi di spazio in cui conservare i dati: 

*  Lo **stack**, un contenitore LIFO 
* In **Memoria**, un byte array espandibile all'infinito
* Il **long-term storage** del contratto, uno storage key-value.

Al contrario dello stack e della memoria, il long-term storage non si resetta alla fine dell'esecuzione del codice, ma mantiene i dati. Il codice può anche accedere ai campi legati al messaggio in arrivo (valore, sender, etc) o anche ai valori del block-header, e il codice può ritornare un byte array di dati come output.



### Execution model

Il modello di esecuzione del codice EVM è sorpendentemente semplice. Mentre la EVM esegue codice, il suo stato computazione è definibile dalla tupla: 

```python
(block_state, transaction, message, code, memory, stack, pc, gas)
```

Dove `block_state` è lo stato globale contenente tutti gli account con i relativi dati, bilanci e storage. All'inizio di ogni iterazione, la `pc`-esima operazione è eseguita andando a selezionare il `pc`-esimo byte di codice (o 0 se `pc >= len(code)`).  Ogni istruzione è definita nei termini in cui modifica la tupla. Per esempio: 

* `ADD` spila 2 item dallo stack e impila la loro somma, riduce il gas di 1 e incrementa il program counter di 1.
* `SSTORE` spila 2 item `(a, b)` dello stack e inserisce all'indice `a` dello storage del contratto il valore `b`.