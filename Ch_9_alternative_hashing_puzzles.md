# Hashing puzzle alternativi

Un mining puzzle deve essere:

* **rapidamente verificabile** (poiché tutti effettuano ripetutamente le verifiche)
* **parametrizzato**, ovvero bisogna poter calibrare la difficoltà

Il puzzle basato su SHA-256 utilizzato da Bitcoin verifica entrambe le proprietà. Un'altro requisito che potremmo chiedere è il seguente: 

* (**progress freeness**) La probabilità di trovare una soluzione valida al puzzle deve essere circa **proporzionale** all'hash power utilizzato.

Questo implica che grossi miner devono avere un vantaggio che scala solo proporzionalmente rispetto ai piccoli miner. Se il vantaggio scalasse esponenzialmente, i miner più piccoli non avrebbero senso di esistere. 

> Per illustrare l'importanza di tale requisito, facciamo un esempio: supponiamo che il puzzle richieda esattamente $n$ step per essere risolto, dove $n$ è il parametro di difficoltà. Ad esempio, potremmo richiedere di calcolare $n$ volte un hash SHA-256. Anche se tale puzzle non è rapidamente verificabile, tralasciamo questo dettaglio. Il problema principale sta nel determinismo degli step necessari a risolverlo: se il miner A calcola un hash nella metà del tempo rispetto al miner B, allora B non avrà nessuna chance di vincita contro A! Questo implica che un avanzamento in hash power di A provoca un vantaggio totale nei confronti di B, e non proporzionale!

Il requisito sopracitato implica che il puzzle debba essere **progress free**, ovvero la vincita del puzzle non dipende dal lavoro svolto in precedenza! In statistica, si parla di un processo **senza memoria**. 



## ASIC resistance

Richiedere la proprietà di **ASIC resistance** implica la volontà di disincentivizzare l'utilizzo di hardware specifico per il mining, ovvero progettare un puzzle che riduca il gap tra l'hardware specifico per il mining e i computer generici. Vediamo varie soluzioni.



### Memory-Hard puzzles

Anziché o in addizione ad utilizzare intensivamente la CPU, i puzzle memory-hard  richiedono un grande utilizzo di memoria. Un concetto simile è sfruttato dai memory-bound puzzle, dove si sfrutta il tempo di accesso alla memoria che domina sul tempo di calcolo. Vorremmo che il puzzle sia memory hard e memory bound allo stesso tempo. I puzzle memory-hard sono ASIC resistant poiché gli avanzamenti nelle performance della memoria sono molto più lenti rispetto a quelli sulla CPU. Vedremo un esempio con Scrypt.



#### Scrypt

Scrypt è il puzzle memory-hard più famoso, utilizzato il Litecoin. Scrypt può essere utilizzato come una semplice funzione hash, quindi l'implementazione richiederebbe semplicemente di rimpiazzare SHA-256 con Scrypt. Lo pseudocodice di Scrypt è il seguente: 

```python
def scrypt(N, seed):
    # initialization
    V = np.zeros(N)
    # first step
    V[0] = seed
    for i in range(1,N):
        V[i] = sha256(V[i-1])
    # second step
    X = sha256(V[N-1])
    for i in range(N):
        j = X % N
        X = sha256(X ** V[j])
    return X
```

Scrypt lavora in 2 step. 

1. Si riempie una grande $(N)$ porzione di memoria RAM con dati random che dipendono l'uno dal precedente. 
2. Si legge in maniera pseudo-casuale più volte questa porzione e si aggiorna una variabile. 

Il secondo step richiede che tutto sia conservato in memoria, e così facendo viene eseguito in tempo $O(N)$. Se invece non si tiene tutto in memoria (niente o una porzione) allora si può dimostrare che asintoticamente l'algoritmo esegue in tempo $O(N^2)$. Un modo per risparmiare metà della memoria è conservare solo gli indici pari (o dispari) e, nel caso fortunato, fornire l'elemento conservato, in quello sfortunato si può utilizzare il precedente per calcolarlo al volo. Supponendo che il caso sfortunato avvenga circa metà delle volte (distr. uniforme), allora dovremmo eseguire $3N/2$ calcoli (ma stiamo comunque utilizzando $N/2$ di memoria). 

Scrypt purtroppo non sembra essere **rapidamente verificabile**.



### Altri approcci

* Usare X11: 11 diverse hash function (usato da Darkcoin)
* Moving target: cambiare il puzzle periodicamente (cambiarlo COMPLETAMENTE)

Ma difficili da implementare!



## Proof-of-useful work

In sintesi, la computazione è sprecata, come facciamo a utilizzarla in utilmente? Una prima proposta potrebbero essere i progetti di calcolo distributi (es. SETI@Home), ma chi ci lavora non ha interessi speculativi, quindi non vanno bene per le crypto. **Primecoin** implementa il primo proof-of-useful work reale, basato sull'obiettivo di sfruttare la computazione per trovare delle **Cunningham chain**, ovvero delle sequenze di $k$ primi $p_1, \dots, p_k$ tali che $p_i = 2p_{i-1} + 1$ per ogni numero nella catena. 

Per trasformare la ricerca in un puzzle computazionale si utilizzano 3 parametri: $m,n ,k$. Data una certa challenge $x$ (hash del blocco precedente), partiamo da un numero primo di $n$ bit totali che ha i primi $m$ bit uguali a quelli di $x$, e cerchiamo di calcolare una catena di lunghezza $k$. Quest'ultimo è il parametro di difficoltà. L'utilità sta proprio nel computare queste catene, dato che non si conosce una legge matematica che le regoli. 



## Proof of Stake e Virtual Mining

Esiste un ciclo di spesa effettuato dai miner, che consiste nel pagare elettricità e hardware per produrre e guadagnare coin, da spendere poi nelle risorse impiegate. Il **virtual mining** si basa sul concetto di non spendere soldi in risorse, bensì allocare la propria ricchezza direttamente nella piattaforma. L'approccio è green e semplicistico, e ridurrebbe il consumo di energia a 0. Gli attacchi effettuati dai big della piattaforma sono scongiurati dal fatto che i big stessi hanno allocato molti dei loro fondi nella piattaforma stessa, e probabilmente non hanno interesse nel farla perdere di credibilità. Il virtual mining è banalmente **ASIC resistant**.  

> Esempio: **Algorand**
> Ognuno ha una funzione pseudocasuale e la probabilità di vittoria aumenta con lo stake. Sia $\alpha$ un numero direttamente proporzionale al mio stake, allora prendo il numero generato e lo divido per $\alpha$. Più è alto è il denominatore (quindi lo stake), più è alta la probabilità di finire al di sotto del target e vincere. 

Ma cosa da valore ad una crypto che si basa sulla proof of stake? Dipende dal valore di un altra moneta? E altre domande esistenziali. 

> Due tipi di virtual mining: 
>
> * Proof of Stake: il mio mining power cresce tanto quanto lascio inutilizzato il mio stake. 
> * Proof of deposit: il mio mining power cresce proporzionalmente allo stake che prometto di non spendere.









