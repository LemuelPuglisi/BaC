# Meccanica dei Bitcoin

In questo capitolo copriremo nello specifico l'implementazione dei meccanismi di Bitcoin. 



## Le transazioni

La prima idea che ci viene in mente quando pensiamo ad un ledger è qualcosa di **account based**, dove ogni record ha un mittente, un destinatario ed un quantitativo di bitcoin, e la transazione è firmata dal mittente, oppure una creazione di bitcoin consentita dai miners. 

![image-20220326110253869](Ch_3_meccanica_dei_bitcoin.assets/image-20220326110253869.png)

Il problema è che per capire se una transazione è valida dobbiamo tener conto del saldo di un certo utente (indirizzo). Per fare questo senza utilizzare strumenti terzi, dobbiamo risalire a tutte le transazioni che riceve ed effettua Alice in ordine di inserimento.

A causa di questa inefficienza, Bitcoin utilizza un altro approccio chiamato **transaction-based**. Nel ledger vengono inserite solo transazioni, che hanno un certo numero **input** ed **output**. Pensiamo ai coin in input come dei coin che vengono distrutti, mentre a quelli in output come dei coin creati. L'output di una transazione che non è ancora stato speso prende il nome di **UTXO** (unspent transaction output). Ogni transazione ha un **identificativo unico**. Ogni output è indicizzato a partire da 0, quindi ci riferiremo al primo output come l'output 0. Vediamo un esempio: 

![image-20220326110950883](Ch_3_meccanica_dei_bitcoin.assets/image-20220326110950883.png)

Nella transazione 1 Alice guadagna 25 BTC senza alcun input, grazie agli incentivi. Questa transazione non necessita di firma, essendo concordata con il protocollo di consenso. Nella transazione 2, l'input è 1[0], ovvero l'UTXO di indice 0 della transazione 1. Dato che Alice deve pagare 17 BTC a Bob, l'output della transazione sarà 17 BTC all'indirizzo di Bob, e gli 8 rimanenti all'indirizzo di Alice. La transazione viene infine firmata da Alice. Non considerando le transaction fees, l'input e l'output della transazione devono coincidere. Alice avrebbe potuto mandare gli 8 BTC ad un altro indirizzo di sua appartenenza, e questo viene chiamato **change address**.

**Efficient verification**
Per verificare che una transazione sia valida, basta utilizzare l'hash pointer dell'input (o degli input, come vedremo) e verificare che la somma in output sia uguale alla somma in input. Dopodiché bisogna verificare che tali coin non siano stati consumati controllando tutte le transazioni partendo da quest'ultima e risalendo fino alla head della block chain. Rispetto al metodo precedente, non è necessario arrivare fino al genesis block, ma solo alle transazioni referenziate. 

**Consolidating funds**
Supponiamo che Bob riceva 17 BTC da una transazione, e 3 BTC da un'altra, e che voglia consolidare i 20 BTC totali in una sola transazione. Allora Bob potrà creare una nuova transazione che ha come input le prime due, e come output 20 BTC ad un indirizzo a lui appartenente. 

**Joint payments**
Risulta semplice anche fare dei pagamenti congiunti: supponiamo che Alice e Bob vogliano effettuare un pagamento a David, allora nella transazione vi saranno input appartenenti ad Alice ed input appartenenti a Bob. L'unica differenza è che la transazione deve contenere le firme di entrambi i paganti. 



### Formato transazione

Vediamo il contenuto di una transazione in json, pur sapendo che la transazione viene serializzata e inviata come una stringa di bit. La transazione è composta da 3 parti: i metadati, gli input e gli output: 

 ![image-20220326144152600](Ch_3_meccanica_dei_bitcoin.assets/image-20220326144152600.png)

**Metadati**
Tra i metadati troviamo la dimensione della transazione (size), il numero di input (vin_sz), il numero di output (vout_sz). L'hash dell'intera transazione (hash) è calcolato e viene utilizzato come identificativo univoco. Questo ci permette di utilizzare gli hash pointer per referenziare transazioni. 

**Input**
Le transazioni in input sono disposte in un array, e ogni input ha la stessa forma. L'input specifica la transazione da cui proviene (prev_out) attraverso l'hash e l'indice (n). L'hash funziona da hash pointer. All'input viene aggiunta la firma valida di chi detiene i bitcoin.

**Output**
Anche gli output sono degli array. Ogni output ha 2 campi ed ogni output ha un valore. La somma dei valori deve essere minore o uguale alla somma dei bitcoin in input. Se la somma è minore, allora la differenza è considerata transaction fee. Il campo "ScriptPubKey" contiene l'hash della public key del destinatario ed un insieme di comandi. 



## Bitcoin scripts

Il campo ScriptPubKey di ogni output nella transazione non specifica una public key, ma bensì uno script. In realtà, anche il campo SigScript degli input contiene uno script e non la mera firma di chi spende i bitcoin. Per capire se un input è corretto, basta concatenare al suo campo SigScript il campo ScriptPubKey dell'output della transazione precedente. Se l'esecuzione dello script finale ritorna true, allora l'input è lecito.  



### Bitcoin scripting language

Il linguaggio di scripting di Bitcoin è chiamato "Script" ed è un linguaggio stack-based. Questo significa che ogni estruzione è eseguita una sola volta, in maniera lineare, senza cicli o salti, e vi è un unico stack dove conservare i dati. Le operazioni built-in contengono operazioni crittografiche non banali, tuttavia il linguaggio non è Turing-completo. Dall'esecuzione di uno Script possiamo ottenere solo due valori: true o false. Se lo script termina senza errori, allora la transazione è valida, altrimenti la transazione non andrebbe accettata nella blockchain. Le istruzioni di Script occupano 1 byte e sono al più 256, di cui 15 disabilitate e 75 riservate per usi futuri, [cliccare qui per la lista completa](https://en.bitcoin.it/wiki/Script). 

> L'istruzione `CHECKMULTISIG` richiede $n$ chiavi (da inserire nello stack) ed una soglia $t$. Per essere eseguita con successo, almeno $t$ firme di $t$ su $n$ chiavi pubbliche devono essere valide affinché la transazione sia valida. Tuttavia, l'implementazione contiene un bug: l'istruzione effettua la pop di un elemento in più dallo stack e lo ignora, per cui per funzionare bisogna mettere un elemento (dummy) in più nello stack. 



### Eseguire uno script

Per eseguire uno script in un linguaggio stack-based, tutto ciò di cui abbiamo bisogno è uno stack e di due operazioni: push e pop, nessun altro tipo di memoria. Ci sono due tipi di istruzioni, **data instructions** e **opcodes**. Quando un data instruction appare nella sequenza dello script, il dato viene semplicemente inserito (push) nello stack. Gli opcodes performano azioni sui dati, prendendo (pop) input dallo stack. Vediamo come viene eseguito il seguente script che consente semplicemente di verificare un input. 

![image-20220326154138268](Ch_3_meccanica_dei_bitcoin.assets/image-20220326154138268.png)

In ordine: 

1. La firma viene inserita nello stack 
2. La public key del firmatario viene inserita nello stack
3. `OP_DUP` duplica la public key e la inserisce nello stack
4. `OP_HASH160` estrae la public key, calcola l'hash e lo inserisce nello stack
5. Si inserisce nello stack l'hash della public key dell'UTXO referenziato
6. `OP_EQUALVERIFY` controlla che i primi due elementi dello stack siano uguali
7.  `OP_CHECKSIG` verifica la firma del pagante attraverso la public key fornita

Un output della transazione non contiene direttamente la public key del destinatario, ma il suo hash. Quindi nella operazione (6) ci si accerta che chi stia firmando detenga la public key a cui si recapitano i soldi, andando a confrontare i due hash. In soldoni chi deve firmare per autorizzare la transazione fornisce la propria public key, che viene verificata al passo 6, e la propria firma dell'**intera transazione precedente**, che viene verificata al passo 7. 

> L'elasticità del linguaggio non prende piede nella pratica, di fatto i nodi hanno una whitelist di script standard che possono eseguire, mentre rifiutano gli altri. 

### Proof of burn

Uno script proof-of-burn è uno script che elimina dei bitcoin, ovvero li rende inutilizzabili. Un caso d'uso è il bootstrap di una nuova valuta, in cui gli utenti distruggono i propri Bitcoin per averli nel nuovo sistema. L'implementazione consiste in uno script contenente l'istruzione `OP_RETURN`, che ritorna sempre falso. 

> È possibile inserire una frase a caso nella blockchain attraverso uno script di tipo proof-of-burn, inserendo la stringa dopo l'istruzione `OP_RETURN`. 



### Pay-to-Script-Hash

In Bitcoin è il sender dei coin a specificare lo script. Ipotizziamo che uno shop online richieda uno script molto complesso per l'acquisto di un prodotto. Il compratore (sender) potrebbe non essere d'accordo e potrebbe richiedere un semplice indirizzo a cui inviare i Bitcoin. La soluzione è lo script **P2SH** (pay-to-script-hash): anziché inviare i Bitcoin all'hash di una chiave pubblica, si inviano i Bitcoin all'hash del complesso script. Si impone che per redimere i Bitcoin sia necessario rivelare lo script che corrisponde all'hash e provvedere i dati affinché esso restituisca `true`. Lo script P2SH esegue i seguenti passi:

1. Calcola l'hash del primo valore nello stack (lo script passato)
2. Controlla che l'hash dello script e l'hash calcolato coincidano
3. Prende lo script estratto dallo stack e lo interpreta come sequenza di istruzioni

Nello stack ci saranno anche i dati necessari ad eseguire il complesso script. P2SH aumenta anche l'efficienza del sistema: i miners devono tenere traccia degli OUTX non ancora redenti, ed in questo caso anziché conservare un lungo script, si conserva il suo hash. 



## Applicazioni di Script

Vediamo alcune delle più comuni applicazioni realizzabili con il linguaggio Script. 



### Escrow Transactions

Alice vuole comprare da Bob un prodotto, Alice non invia i soldi finché il prodotto non arriva, e Bob non invia il prodotto finché non riceve i soldi. Per risolvere questo problema, si chiama in causa un terzo, David, di cui entrambi si fidano, e si sviluppa una **escrow transaction**. Alice crea una transazione `MULTISIG` con $n=3$ e $t=2$, dove quindi sono richieste almeno 2 firme per utilizzare la UTXO. Quando la transazione viene inclusa nella blockchain, Bob invia il prodotto. Alice non può tentare di versare i soldi su un suo indirizzo, poiché oltre alla sua serve un'altra firma, quella di Bob o quella di David. Allo stesso tempo, Bob non può cercare di truffare Alice, poiché anche lui ha bisogno di due firme. Quando la vendita ha avuto successo, le parti firmeranno la transazione. Se Bob non invia il prodotto, David insieme ad Alice firmeranno per riversare i soldi su un indirizzo di Alice. Le monete stazionano sulla blockchain finché la vendita non viene risolta in qualche modo. 



### Green Addresses

I **green addresses** sono indirizzi fidati (es. banche, exchange) che hanno una buona reputazione nella blockchain, ovvero non hanno mai effettuato double spending o altri comportamenti disonesti. Se Alice vuole pagare Bob e Bob non può materialmente controllare la blockchain o aspettare le conferme, Alice può pagare Bob utilizzando un qualche servizio che dispone di un green address. Essendo un green address, Bob si fiderà e non dovrà controllare l'effettivo pagamento. Se il servizio dovesse non rispettare l'accordo, allora la fiducia in esso crollerebbe e gli utenti smetterebbero di utilizzarlo. 



### Efficient micropayments

Supponiamo che Alice paghi al suo operatore telefonico un certo numero di bitcoin per ogni minuto di chiamata effettuata. Anziché fare una transazione al minuto, Alice potrebbe creare una transazione `MULTISIG` in cui include la sua chiave e quella dell'operatore e carica tutto il suo credito disponibile. Quando la transazione è nella blockchain, l'operatore abilita il servizio ad Alice. Da qui iniziano i micropagamenti: dopo ogni minuto di chiamata Alice firma una transazione `MULTISIG` che ha come input la UTXO con il massimo credito, e in output ha due UTXO, una con l'importo corrente (BTC al minuto x minuti trascorsi) ed un'altra con il resto da ritornare ad un suo indirizzo. Si noti che la transazione non viene inserita nella blockchain, ma viene inviata all'operatore. Quando Alice finisce, smette di inviare micro-transazioni all'operatore. Quest'ultimo firma l'ultimo micropagamento arrivato (dove chiaramente guadagna di più) e sottomette la transazione alla blockchain (con le due firme necessarie).



### Lock Time 

Che succede se l'operatore decide di non firmare nessun micropagamento? I bitcoin di Alice resterebbero inutilizzabili nella blockchain per sempre. Per risolvere questo problema, si utilizza il campo `lock_time` presente nei metadati della transazione. Prima che inizino i micropagamenti, sia l'operatore che Alice firmeranno una transazione `MULTISIG` che rimborsa tutti i bitcoin ad Alice, prendendoli dall'UTXO creato nel passo iniziale (massimo credito). Tuttavia, questa transazione sarà bloccata per un certo lasso di tempo $t$. Se entro il tempo $t$ l'operatore non firma nessun micropagamento, allora Alice potrà riavere i suoi soldi attraverso questa transazione. Il campo $t$ comunica ai miners di non pubblicare la transazione prima di un tempo $t$, ma non essendoci una nozione di tempo, $t$ indicherà semplicemente un certo numero di un blocco futuro.



## Bitcoin blocks

Le transazioni sono raggruppate in blocchi. Questa è una ottimizzazione, per vari motivi: 

* Altrimenti i miners dovrebbero stabilire consenso per ogni transazione (throughput minore)
* La blockchain sarebbe molto più lunga, quindi le verifiche sarebbero meno efficienti

I blocchi della blockchain contengono:

- un **block header** 
- un hash pointer alle transazioni
- un hash pointer al blocco precedente. 

Le transazioni del blocco sono disposte su un **Merkle tree**, e questo ci permette di conservare un hash efficiente che le rappresenti. Come discusso nei precedenti capitoli, possiamo possiamo provare l'esistenza di una tx nel blocco fornendo un cammino dell'albero dalla root alla tx la cui lunghezza è logaritmica rispetto al numero totale di transazioni nel blocco.

![image-20220401123058508](Ch_3_meccanica_dei_bitcoin.assets/image-20220401123058508.png)

L'**header** contiene informazioni relative al **mining puzzle**, ad esempio la **nonce** che ha generato l'hash vincente, un timestamp, i bit che indicano la difficolta del puzzle (etc). L'hash generato per vincere il puzzle è calcolato sull'header (hash escluso, ovviamente). I miners devono quindi utilizzare solo l'header del blocco per capire se esso ha vinto o meno il puzzle. Il campo dell'header `mrkl_root_field` contiene l'hash pointer della root dell'albero. Nel Merkle tree esiste una transazione chiamata **coinbase transaction**, ed ha lo scopo di assegnare la block reward e le transaction fees al miner. Essa differisce in vari modi da una transazione normale: 

1. Ha sempre 1 input ed 1 output. 
2. L'input contiene un hash pointer nullo.
3. L'output contiene la somma del block reward e dei transaction fees. 
4. Ha un parametro `coinbase` totalmente arbitrario.



## La rete Bitcoin

La rete Bitcoin è una rete p2p che gira su TCP. Ha una topologia random e dinamica, dove i nodi sono connessi tra loro **in maniera casuale**. Nuovi nodi possono entrare a far parte della rete in qualsiasi momento, e possono altrettanto uscire da essa in qualsiasi momento. Non c'è una procedura da seguire per uscire dalla rete: semplicemente, quando i peer non ricevono segnali da un nodo per **3 ore consecutive** assumono che il nodo non sia più in rete (**oblio**). 



### Ingresso nella rete

Per entrare a far parte della rete basta contattare un **seed node**, ovvero un nodo di cui si conosce l'esistenza (es. un nodo preso da un forum). Bisogna mandare un messaggio speciale, ovvero una richiesta a conoscere gli altri peer della rete. Una volta ricevuta la lista di indirizzi, possiamo ripetere il processo con altri nodi in modo da arricchire il vicinato. L'output ideale è un collegamento con nodi random della rete. E' possibile selezionare i nodi con cui collegarsi e scartare gli altri. Una volta stabilita la connessione con i nodi, si entra a far parte della rete Bitcoin. 



### Gossip protocol

Per inviare una transazione, si utilizza un algoritmo di flooding chiamato **gossip protocol**. La transazione viene inviata in broadcast a tutti i nodi a cui si è collegati. Ogni vicino che riceve la transazione controlla che essa sia valida e, in tal caso, la aggiunge al proprio **transaction pool**, ovvero un pool di transazioni di cui il nodo è a conoscenza e che non sono ancora state inserite nella blockchain, e dopodiché la inoltra a sua volta. Se il nodo ha già la transazione nel proprio pool, allora la scarta (questo garantisce la terminazione dell'algoritmo di flooding). I controlli eseguiti dai nodi prima di accettare una transazione sono i seguenti: 

1. **Validazione della transazione**: viene eseguito lo script di ogni UTXO che si cerca di spendere e ci si assicura che ritorni true.  
2. **Prevenzione del double-spending**: si controlla che la transazione non stia commettendo double spending. 
3. Si controlla che la transazione non sia già nel transaction pool.
4. Si controlla che lo script di output sia in una whitelist di script (facoltativo).

Nessuna regola ci garantisce che tutti i nodi seguano tutti questi step, che servono a mantenere la rete sana. Un nodo potrebbe eseguire un client che non segua nessuna regola, essendo un sistema decentralizzato, nessuno vieta che questo accada. 



### Transaction pool differenti

A causa della latenza di rete i transaction pool dei nodi potrebbero essere differenti. Supponiamo che $A$ provi a fare double-spending pagando $B$ e $C$ con la stessa moneta in due tx diverse. Alcuni nodi della rete conosceranno $A \to B$ e rifiuteranno $A \to C$ ed altri viceversa. Come risultato, i nodi saranno discordanti su quale delle tx dovrebbe andare nella blockchain. Questa prende il nome di **race condition**. Ovviamente a stabilire la transazione vincente sarà il miner che proporrà il successivo blocco. Supponendo che vinca la tx con $A \to B$, allora i nodi che la contenevano scarteranno la tx dal transaction pool, essendo già nella blockchain, mentre chi conteneva $A \to C$ scarterà la tx dal transaction pool poiché tentativo di double spending. Solitamente i nodi tengono la transazione che arriva prima, e questo fa pensare che la posizione del nodo della rete e la sua connettività con il resto dei nodi conti, ma ciò non toglie che questo comportamento non è forzato da nessuna autorità centrale, e i nodi potrebbero muovere le tx dal transaction pool in base ad altri criteri (es. priorità alle tx con fee più alte), 



### Zero confirmation tx e replace-by-fee

Una **zero confirmation transaction** è una tx che non è inclusa in alcun blocco, e che rischia di diventare un double spending. Nel 2013, alcuni partecipanti alla rete hanno espresso il loro interesse nell'includere un meccanismo per rimpiazzare le tx nel pool in base alla generosità del loro fee. Tuttavia, questo potrebbe rendere il double spending molto più semplice (basta mandare due tx con fee molto diverse). Bitcoin ha inserito un meccanismo opzionale di replace-by-fee, dove le tx possono auto-marcarsi come sostituibili in caso di fee più alte. 



### Propagazione del blocco

Quando un miner trova un blocco deve propagarlo, ed il processo è quasi analogo alla propagazione delle transazioni, con lo stesso problema delle race conditions (più blocchi proposti allo stesso momento). Il blocco che viene incluso nella blockchain è ovviamente quello che viene esteso di più, seguendo il criterio del longest branch. Per validare un blocco bisogna: 

1. Validare il suo header, assicurandosi che abbia risolto il puzzle correttamente.
2. Validare ogni transazione contenuta nel blocco.
3. Assicurarsi che estenda il branch più lungo della blockchain. 

Anche in questo caso nessuno ci assicura che i nodi si comportino esattamente in questo modo. 



### Latenza dell'algoritmo di flooding 

La latenza dell'algoritmo di flooding è proporzionale alla dimensione del blocco, dato che il throughput della rete è il collo di bottiglia del sistema. Il seguente grafico mostra il tempo impiegato alla propagazione del blocco in relazione alla sua dimensione. In media il blocco raggiunge il 50% dei nodi in ~3-5s, ed il 90% dei nodi in ~10-15s.  

![image-20220401172904404](Ch_3_meccanica_dei_bitcoin.assets/image-20220401172904404.png)

### Grandezza della rete

La grandezza della rete è difficile da determinare, essendo altamente dinamica. Si stimano circa 1 mln di IP diversi connessi alla rete in un mese, ma solo 5000-10000 nodi rimangono in maniera permanente nella rete per validare le transazioni. Questo numero non sembra crescere o decrescere nel tempo.  











