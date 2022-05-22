# Ethereum

Ethereum è una cryptocurrency intesa a fornire un linguaggio di programmazione Turing-completo, utilizzabile per lo sviluppo di Smart Contracts (*Dapps, Decentralized APPs*), allo scopo di codificare vari sistemi decentralizzati (non-fungible assets, DAOs, smart propriety e molto altro). 

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



### Esempi di contratti

Vediamo alcuni esempi di contratti: 

* Creazione di nuovi token ([ERC-20](https://ethereum.org/it/developers/docs/standards/tokens/erc-20/))
* Prodotti finanziari
* DAR ([Distinguishable Assets Registry, Contract for NFTs](https://github.com/ethereum/EIPs/issues/821))
* DAO ([Distributed autonomous organizations](https://ethereum.org/it/dao/))
* giochi ([CryptoKitties](https://www.cryptokitties.co/), [Sorare](https://sorare.com/))



### La valuta digitale di Ethereum

* ether (ETH)
* finney - $1$ ETH = $10^3$ finney
* szabo - $1$ ETH = $10^6$ szabo
* wei - $1$ ETH = $10^{18}$ wei  



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



## Blockchain e Mining

La blockchain di Ethereum è simile alla blockchain di Bitcoin, ma ha delle differenze. Quella principale è che i blocchi di Ethereum contengono una copia sia della lista di transazioni, che dello **stato globale** più recente. Inoltre, altri due valori sono conservati nel blocco: la **difficulty** ed il **block number**. Come già sappiamo, il mining è il processo di creazione di un blocco di transazioni, da aggiungere alla blockchain di Ethereum. Al momento, Ethereum utilizza un meccanismo di consenso basato su proof-of-work, ma verrà sostituito in futuro con il proof of stake. Il mining delle transazioni su Ethereum avviene nel seguente modo: 

1. Un account scrive e firma una richiesta di transazione con la propria chiave privata. 
2. L'utente trasmette la richiesta all'intera rete Ethereum attraverso un nodo. 
3. Ogni nodo che la riceve e la inserisce nel proprio mempool locale. 
4. Un miner aggrega centinaia di tx in un blocco in modo da massimizzare le commissioni sulle transazioni che verranno guadagnate, rimanendo entro il limite di gas per blocco. A questo punto, il miner: 
   1. Verifica la validità di ogni transazione, esegue il codice della richiesta cambiando lo stato della propria copia locale della EVM. Assegna la commissione sulle transazioni per ogni richiesta di transazione al proprio account. 
   2. Inizia il processo di produzione del "certificate of legitimacy" proof-of-work per il potenziale blocco.
5. Se il miner riesce a completare la proof-of-work, e quindi la produzione di tale certificato, allora egli trasmetterà alla rete Ethereum il blocco completo e corredato di certificato e di una checksum del nuovo stato dell'EVM dichiarato. 

> Il mempool locale di un miner è l'elenco delle transazioni non ancora state inviate alla blockchain.

La procedura di block validation più basilare, svolta da chi riceve il blocco proposto, consiste nel: 

1. Controllare se il blocco precedente referenziato esiste ed è valido. 
2. Controllare che il timestamp del blocco è maggiore del blocco precedente e non più avanti di 15 min. 
3. Controllare che il block number, la difficulty, la transaction root, l'uncle root ed il gas limit (concetti low-lever di Ethereum) siano validi. 
4. Controllare che la proof-of-work nel blocco sia valida. 
5. Sia `S[0]` lo stato alla fine del precedente blocco
6. Sia `TX` la lista delle $n$ tx nel blocco, allora: `S[i+1] = APPLY(S[i], TX[i])` per `i=0,...,n-1`. Se almeno una delle applicazioni da errore, o se il gas totale supera il gaslimit, ritornare errore. 
7. Sia `S_FINAL = S[n]`, aggiungere la block reward da pagare al miner. 
8. Controllare che la merkle tree root dello stato `S_FINAL` sia uguale allo stato conservato nel block header. Se è così, allora il blocco è valido, altrimenti è non valido. 



![Ethereum apply block diagram](Ch_8_ethereum.assets/ethereum-apply-block-diagram.png)



Una volta svolti tutti questi passaggi, se il blocco è valido ogni miner lo aggiunge alla propria blockchain e rimuove dalla propria mempool le transazioni che sono già state aggiunte. 

Conservare l'intero stato può sembrare una inefficienza, ma bisogna evidenziare la strategia sottostante. Lo stato è memorizzato in una particolare struttura ad albero, chiamata Merkle Patricia Tree, che permette di aggiungere o rimuovere nodi, oltre che a modificare il contenuto dell'albero (i Merkle tree erano limitati a questo). Tra un blocco e l'altro della blockchain, l'albero cambia nelle piccole parti coinvolte dalle tx. La maggioranza dei nodi saranno uguali tra l'albero di un blocco e quello del precedente, per cui è possibile utilizzare dei puntatori. 



> **Dove viene eseguito il codice del contratto?**
> Ci si chiede "dove" sia eseguito il codice del contratto, in termini di hardware fisico. La risposta è semplice: l'esecuzione fa parte della funzione di transizione tra stati, che a sua volta fa parte dell'algoritmo di convalida del blocco. Quindi se una tx viene aggiunta al blocco B, l'esecuzione del codice generata da quella tx avverrà in tutti i nodi (ora e in futuro) che eseguono e convalidano il blocco B. 



### Proof of work

Il Proof of Work utilizzato da Ethereum è molto simile a quello di Bitcoin: il miner deve calcolare un mixHash che sia minore di una target nonce. 



### Algoritmo di mining: Ethash

L'algoritmo di mining di Ethereum prende il nome di **Ethash**, ed è una versione specifica dell'algoritmo di [Dagger-Hashimoto](https://eth.wiki/concepts/dagger-hashimoto). Tale algoritmo ha due obiettivi principali: 

1. **ASIC-resistance**: il beneficio di creare hardware apposito per l'algoritmo deve essere più piccolo possibile, idealmente al punto tale che il profitto ricavato attraverso un ASIC sia paragonabile a quello ottenuto utilizzando delle CPU. 
2. **Light client verifiability**: un blocco dovrebbe essere facilmente verificabile da un light client. 

Il protocollo venne modificato a scapito della sua semplicità, per raggiungere un terzo obiettivo: 

3. **Full chain storage**: il mining deve richiedere la conservazione dell'intera blockchain.

L'algoritmo di Dagger-Hashimoto è costruito on-top di due famosi lavori: 

* [Hashimoto](http://diyhpl.us/%7Ebryan/papers2/bitcoin/meh/hashimoto.pdf) - Un algoritmo che raggiunge la ASIC-resistance attraverso operazioni IO-bound. 
* [Dagger](http://www.hashcash.org/papers/dagger.html) - Un algoritmo con memory-hard computation, ma memory-easy validation.  

Ethereum utilizza kekkak256 come algoritmo di hashing, talvolta chiamato (erroneamente) SHA3. Per maggiori informazioni consultare il [repository ufficiale](https://github.com/ethereum/eth-hash).

Esistono due metodi per rendere una funzione hash ASIC-resistant: 

* Utilizzare molta memoria e banda, così che le nonce non possano essere calcolate in parallelo. 
* Rendere la funzione da calcolare "general-purpose" così da evitare lo "specialised hardware". 

Nello specifico: 

* Sia $H_{\not n}$ il block header del nuovo blocco ma senza la nonce ed il mix-hash
* Sia $H_n$ la nonce del block header
* Sia $d$ un dataset molto grande necessario a calcolare il mix-hash
* Sia $H_d$ la difficoltà del nuovo blocco

Allora bisogna calcolare il mix-hash $H_m$ tale che: 
$$
m = H_m \and n \le \frac{2^{256}}{H_d} \hspace{1cm} (m,n) = PoW(H_{\not n}, H_n, d)
$$
Dove $m$ è, per l'appunto, il mix-hash ed $n$ è un valore correlato alla funzione $H$ e a $d$. L'algoritmo che calcola tali valori è il sopracitato Ethash. 



