# Ethereum 

[TOC]

Nell'universo Ethereum esiste un singolo, computer canonimo chiamato Ethereum Virtual Machine (EVM), il cui stato è stabilito da un consenso omogeneo nella rete. Chiunque voglia partecipare alla rete Ethereum (Ethereum node) tiene una copia di tale stato nel proprio computer. Ogni partecipante può inviare in broadcast una richiesta per effettuare una computazione arbitraria. Alla sottomissione della richiesta, gli altri partecipanti verificano, validano ed eseguono la computazione. Questa esecuzione causa la transizione della EVM ad un nuovo stato, che viene propagato (commitment) alla rete in broadcast. Le richieste di computazione prendono il nome di **transaction request** ed insieme allo **stato della EVM** vengono conservate nella blockchain, il cui contenuto è confermato attraverso un protocollo di consenso. 



## 1. Cosa è un ether?

L'ether (ETH) è la cryptocurrency nativa di Ethereum. Lo scopo dell'ether è quello di consentire un mercato per la computazione. Un mercato di questo tipo fornisce un incentivo economico affinché i partecipanti verifichino ed eseguano le richieste di transazione e forniscano risorse di calcolo alla rete. Ogni partecipante che trasmette una richiesta deve anche offrire alla rete un certo importo in ether a titolo di ricompensa (transaction fees). Il costo della fee cresce con la complessità della computazione da eseguire e dalle risorse richieste. 

|  nome  |   1 ETH   |
| :----: | :-------: |
| ether  |     1     |
| finney |  $10^3$   |
| szabo  |  $10^6$   |
|  wei   | $10^{18}$ |





## 2. Gli account

In Ethereum, lo stato è costituito da **account**, ognuno di essi possiede un indirizzo di 20 byte. Per transizione di stato ci si riferisce al *trasferimento diretto di informazioni* tra account. Esistono due tipi di account: 

* **External Owned Account** (**EOA**): controllato da chiunque abbia la chiave privata
* **Smart Contracts**: un agente intelligente controllato dal codice. 

Entrambi i tipi di account hanno l'abilità di ricevere, conservare ed inviare ETH e token, e di interagire con gli altri smart contract. Vediamo le differenze sostanziali: 

| EOA                                                          | Smart Contract                                               |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| Creare un account non costa nulla.                           | Creare un contratto ha un costo, poiché utilizza l'archiviazione di rete. |
| Può avviare transazioni.                                     | Può inviare transazioni solo in risposta alla ricezione di una transazione. |
| Le transazioni tra EOA possono riguardare unicamente trasferimenti di ETH / token. | Le transazioni da EOA a Smart Contract possono innescare un codice che può eseguire le azioni più svariate, come il trasferimento di token o persino la creazione di un nuovo contratto. |

Gli account Ethereum hanno principalmente quattro campi: 

| Nome          | Descrizione                                                  |
| ------------- | ------------------------------------------------------------ |
| *nonce*       | un contatore che indica il numero di tx inviate dall'account. Questo assicura che le tx siano elaborate una volta. In un account Contract, questo numero rappresenta il numero di contratti creati dallo Smart Contract. |
| *balance*     | Il numero di wei posseduti da questo indirizzo. Ricordiamo che 1 ETH = 1e+18 wei. |
| *codeHash*    | Questo hash si riferisce al frammento di codice (in bytecode) di uno Smart Contract sulla EVM. Ogni volta che il contratto riceve un messaggio, questo frammento viene eseguito. Il codice **non può essere modificato in futuro**. Negli EOA questo campo è vuoto. |
| *storageRoot* | Hash a 256 bit della root di un Merkle Patricia Trie che codifica il contenuto dello spazio di archiviazione dell'account. Negli EOA questo campo è vuoto. |

L'indirizzo dell'account varia in base al tipo. Se l'account è un EOA allora l'indirizzo è l'hash della chiave pubblica, mentre se l'account è uno Smart Contract allora l'indirizzo è l'hash della concatenazione tra indirizzo del creatore e la nonce del creatore. 

![Un diagramma mostra la composizione di un conto](Ch_8_ethereum.assets/accounts.png)



### 2.1 ⚒️ Approfondire gli Smart Contracts

> DA SVILUPPARE: [LINK ALLA DOCUMENTAZIONE](https://ethereum.org/it/developers/docs/smart-contracts/)



### 2.2 External Owned Accounts

Un EOA è costituito da una coppia di chiavi crittografiche di firma digitale: pubblica e privata. Una chiave privata si compone di 64 caratteri esadecimali (256 bit) ed è codificabile con una password. La chiave pubblica è generata dalla chiave privata usando ECDSA (Elliptic Curve Digital Signature Algorithm). Si può ottenere l'indirizzo pubblico dell'account attraverso gli ultimi 20 byte dell'hash Kekkak-256 della chiave pubblica e aggiungendo `0x` all'inizio.



## 3. Le transazioni

Le transazioni sono istruzioni firmate crittograficamente da account. Un account avvia una transazione per aggiornare lo stato della rete Ethereum. La transazione più semplice è il trasferimento di ETH da un  account ad un altro. Per transazione Ethereum si intende un'azione iniziata da un account EOA, in altre parole gestito dall'uomo e non da un contratto. La transazione modifica lo stato dell'EVM. Le transazioni devono essere trasmesse all'intera rete. Ogni nodo può trasmettere una richiesta di esecuzione di una transazione sull'EVM; in seguito, un miner eseguirà la transazione e propagherà il  cambiamento di stato che ne risulta al resto della rete. Le transazioni richiedono una commissione e deve essere eseguito il  mining affinché siano valide. Per semplificare questa spiegazione,  parleremo in altra sede di commissioni e di mining. Una tx inviata contiene le seguenti informazioni: 

| Campo                  | Descrizione                                                  |
| ---------------------- | ------------------------------------------------------------ |
| *recipient*            | L'indirizzo ricevente (se si tratta di un account di proprietà esterna,  la transazione trasferirà valore. Se si tratta di un contratto, la  transazione eseguirà il codice del contratto) |
| *signature*            | Identificatore del mittente. Viene generata quando la chiave privata del mittente firma la transazione e conferma che il mittente ha autorizzato la transazione. |
| *value*                | Quantità di ETH da trasferire dal mittente al destinatario (in WEI, un taglio dell'ETH) |
| *data*                 | Campo opzionale per includere dati arbitrari                 |
| *gasLimit*             | Importo massimo di unità di gas che possono essere consumate  dalla transazione. Le unità di carburante rappresentano fasi di calcolo |
| *maxPriorityFeePerGas* | la quantità massima di carburante da includere come mancia al miner |
| maxFeePerGas           | la quantità massima di carburante che si è disposti a pagare per la transazione (comprensiva di *baseFeePerGas* e *maxPriorityFeePerGas*) |

Vediamo un esempio di transazione: 

```json
{
  from: "0xEA674fdDe714fd979de3EdF0F56AA9716B898ec8",
  to: "0xac03bb73b6a9e108530aff4df5077c2b3d481e5a",
  gasLimit: "21000",
  maxFeePerGas: "300",
  maxPriorityFeePerGas: "10",
  nonce: "0",
  value: "10000000000",
}

```

Su Ethereum esistono due diversi tipi di transazione: 

* Ordinary transaction: una transazione da un account ad un altro
* Contract Distribution Transaction: una tx senza campo `to`, in cui il campo data contiene il codice del contratto da creare. 



### 3.1 Costo in gas delle transazioni

Come accennato, le transazioni hanno un costo in gas per essere eseguite. Semplici transazioni di trasferimento richiedono 21000 unità di carburante. Per poter inviare 1 ETH ad Alice con una baseFeePerGas di 190 gwei ed una maxPriorityFeePerGas di 10gwei, Bob dovrà pagare la seguente commissione: 

```py
(190 + 10) * 21000 = 4,200,000 gwei = 0.0042 ETH
```

In questo caso: 

1. A Bob verranno addebitati -1,0042 ETH
2. Ad Alice verrà accreditato +1.0 ETH
3. La commissione base brucerà -0.00399 ETH
4. Il miner riceverà una mancia di +0.000210 ETH

Il carburante è richiesto anche per ogni interazione con Smart Contract. Il carburante non utilizzato viene **rimborsato** all'utente. 

![Diagramma che mostra come viene rimborsato il carburante inutilizzato](Ch_8_ethereum.assets/gas-tx.png)

### 3.2 Ciclo di vita delle transazioni

Una volta inviata una transazione, succede quanto segue: 

1. Viene generato un hash crittografico della transazione
2. Viene inviata in broadcast e inclusa nel mempool dei miner 
3. Il miner sceglie la tx da inserire nel blocco per verificarla e considerarla riuscita
4. La tx riceverà un certo numero di conferme (blocchi creati dopo il blocco che la contiene)

Più alto è il numero di conferme, maggiore è la certezza che la rete abbia elaborato e riconosciuto la transazione. 



### 3.3 I messaggi

Per messaggio si intende in generale una comunicazione tra account Ethereum. Una transazione è un messaggio, firmato da un EOA. Anche una chiamata `CALL` effettuata da un contratto ad un altro contratto è un messaggio, ma questo non ha bisogno di firme o convalidazioni, essendo un codice deterministico è possibile riprodurre i messaggi inviati data una transazione in input.  



## 4. ⚒️ Gas e commissioni

>  **ROBA GIÀ SCRITTA**
>
>  primi tre campi sono standard in ogni crypto. Il campo **data** può essere utilizzato per interagire con i contratti, nel caso di un contratto che implementa un DNS distribuito potremmo utilizzare il campo data per specificare la coppia \<dominio/ip\> e inviarla al contratto. I campi **STARTGAS** e **GASPRICE** sono essenziali per il sistema anti-DoS di Ethereum. Per contrastare dei loop infiniti intenzionali o accidentali, ad ogni transazione si associa un numero massimo di step computazionali da eseguire. L'unità di computazione è chiamata **gas**, spesso uno step computazionale costa 1 gas, ma esistono operazioni che ne richiedono di più poiché computazionalmente costose o poiché richiedono di conservare un certo quantitativo di dati nello stato. Esiste anche una fee di 5 gas per ogni byte nel campo transaction data. L'intento del sistema di fee è quello di far pagare all'attaccante un costo proporzionale ad ogni risorsa consumata, includendo il calcolo, la banda e lo storage. In sintesi: 
>
>  * Si pagano 5 gas per ogni byte nel campo dati
>  * Si paga 1 gas circa per ogni step computazionale
>  * Si paga >1 gas per step computazionalmente o spazialmente onerosi.





## 5. La Ethereum Virtual Machine (EVM)

L'EVM esiste come entità singola gestita da migliaia di computer collegati, che eseguono un client Ethereum. Il protocollo Ethereum stesso esiste unicamente allo scopo di garantire un funzionamento continuo, ininterrotto e immutabile di questa speciale macchina a stati. Essa è l'ambiente in cui sono presenti tutti gli account Ethereum (EOA e Smart Contracts). In ognuno dei blocchi della blockchain, Ethereum ha uno ed un solo stato "canonico", e la EVM è ciò che definisce le regole per calcolare un nuovo stato valido da blocco a blocco.  Mentre Bitcoin è considerabile un libro mastro distribuito, dato che quello che principalmente si può fare sono delle transazioni, Ethereum è da considerarsi una macchina a stati distribuita, che permette anche di eseguire dei programmi chiamati Smart Contract. Lo stato di Ethereum è una enorme struttura dati che contiene non solo gli account e i rispettivi saldi, ma anche una macchina a stati che può cambiare da blocco a blocco in base ad un set prefissato di regole, e che può eseguire codice macchina arbitrario. Le regole specifiche di cambio stato da blocco a blocco sono definite dall'EVM. 

![Ddiagramma che mostra la composizione dell'EVM](Ch_8_ethereum.assets/evm.png)



### 5.1 La funzione di transizione di stato

![Ether state transition](Ch_8_ethereum.assets/ether-state-transition.png)

L'EVM si comporta come una funzione matematica: dato un input, produce un output deterministico. Quindi è più utile descrivere formalmente Ethereum come avente una funzione di transizione di stato: 
$$
Y(S, T) = S'
$$
Dato un vecchio stato valido $S$ ed un nuovo set di transizioni valide $T$, la funzione di transito di stato di Ethereum $Y(S, T)$ produce un nuovo stato di output valido $S'$. Nell'ambito di Ethereum, lo **stato** è un enorme struttura di dati chiamata **Modified Merkle Patricia Trie** (di cui parleremo in seguito) che tiene tutti gli account collegati tramite hash e riducibili ad un singolo hash della root, memorizzato sulla blockchain. La funzione di transizione di stato `Y(S, T) -> S'` può essere definita come segue: 

* Controllare se la transazione è sintatticamente valida, che la sua firma sia valida e che la nonce combaci con la nonce conservata nell'account del mittente. Altrimenti ritorna errore. 
* Calcolare la transaction fee come `STARTGAS * GASPRICE` e determina l'indirizzo del mittente dalla firma. Sottrarre la fee dal bilancio dell'account del sender e incrementare la nonce del sender. Se il sender non ha abbastanza ether, ritornare errore. 
* Inizializzare `GAS = STARTGAS` e rimuovere una certa quantità di gas per byte per pagare i byte della transazione. 
* Trasferire il valore da transare dall'account del mittente all'account del destinatario. Se l'account destinatario non esiste, crealo. Se l'account destinatario è un contratto, esegui il codice del contratto fino a completamento o fine ad esaurimento del gas. 
* Se il trasferimento fallisce a causa della mancanza di soldi del mittente, o dell'esaurimento di gas, esegui un revert di tutti i cambiamenti di stato eccetto per il pagamento delle fees, e inserisci le fees nell'account del miner.
* Se il trasferimento ha successo, ritorna le fees del gas rimanente al mittente, e invia le fees per il gas consumato al miner. 



#### 5.1.1 Esempio di transazione di stato

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



### 5.2 Code execution e memorie

Il codice di un contratto Ethereum è scritto in un linguaggio bytecode di basso livello e stack-based, chiamato "Ethereum virtual machine code" o "EVM code". Il codice consiste in una serie di byte, dove ogni byte rappresenta una operazione. In generale, l'esecuzione del codice consiste in un loop infinito che seleziona l'operazione indicata dal program counter e la esegue, incrementando poi il program counter di 1 (esso parte da 0), fino alla fine del codice o fino ad una istruzione STOP o RETURN. Le operazioni possono accedere a 3 tipi di spazio in cui conservare i dati: 

*  Lo **stack**, un contenitore LIFO 
*  In **Memoria**, un byte array espandibile all'infinito
*  Il **long-term storage** del contratto, uno storage key-value.

Al contrario dello stack e della memoria, il long-term storage non si resetta alla fine dell'esecuzione del codice, ma mantiene i dati. Il codice può anche accedere ai campi legati al messaggio in arrivo (valore, sender, etc) o anche ai valori del block-header, e il codice può ritornare un byte array di dati come output.



### 5.3 Execution model

Il modello di esecuzione del codice EVM è sorpendentemente semplice. Mentre la EVM esegue codice, il suo stato computazione è definibile dalla tupla: 

```python
(block_state, transaction, message, code, memory, stack, pc, gas)
```

Dove `block_state` è lo stato globale contenente tutti gli account con i relativi dati, bilanci e storage. All'inizio di ogni iterazione, la `pc`-esima operazione è eseguita andando a selezionare il `pc`-esimo byte di codice (o 0 se `pc >= len(code)`).  Ogni istruzione è definita nei termini in cui modifica la tupla. Per esempio: 

* `ADD` spila 2 item dallo stack e impila la loro somma, riduce il gas di 1 e incrementa il program counter di 1.
* `SSTORE` spila 2 item `(a, b)` dello stack e inserisce all'indice `a` dello storage del contratto il valore `b`.



### 5.4 ⚒️ Modified Merkle Patricia Tree

> DA SVILUPPARE: [LINK ALLA DOCUMENTAZIONE](https://eth.wiki/en/fundamentals/patricia-tree).



## 6. Blockchain e mining

La blockchain di Ethereum è simile alla blockchain di Bitcoin, ma ha delle differenze. Quella principale è che i blocchi di Ethereum contengono una copia sia della lista di transazioni, che dello **stato globale** più recente. Inoltre, altri due valori sono conservati nel blocco: la **difficulty** ed il **block number**. Come già sappiamo, il mining è il processo di creazione di un blocco di transazioni, da aggiungere alla blockchain di Ethereum. Al momento, Ethereum utilizza un meccanismo di consenso basato su **proof-of-work**, ma verrà sostituito in futuro con il proof of stake. Il mining delle transazioni su Ethereum avviene nel seguente modo: 

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



### 6.1 Ethash, l'algoritmo di mining

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

Vediamo adesso **come funziona l'algoritmo Ethash** di Ethereum 1.0: esiste un seed che può essere calcolato per ogni blocco andando a scansionare i block headers fino al blocco di interesse. Dal seed, è possibile calcolare una cache pseudorandom con $J_{\text{cacheinit}}$ byte iniziali. I light client conservano tale cache. Dalla cache, è possibile generare un dataset con $J_{\text{datasetinit}}$ byte iniziali, con la proprietà che ogni item nel dataset dipende da un piccolo numero di item nella cache. I full client ed i miner conservano il dataset. Il dataset cresce in maniera lineare con il tempo. Il mining consiste nel selezionare pezzi random del dataset ed effettuare l'hash della loro concatenazione, insieme agli header del blocco indicati sopra. La verifica può essere fatta con poca memoria, andando a generare i pezzi utilizzati attraverso la cache (per questo i light client conservano le cache). Il dataset è aggiornato ogni $J_{\text{epochs}}$ blocchi, così che la maggior parte della difficolta del mining stia nel leggere il dataset più che computarlo. I parametri sono presenti nello yellow-paper e sono i seguenti: 



![image-20220522134918625](Ch_8_ethereum.assets/image-20220522134918625.png)













