# Interactive protocols & Zero-Knowledge proofs

[TOC]

## Preliminari

Un classico scenario crittografico è quello in cui due parti (che non si fidano l'uno dell'altra) devono rivelare qualche informazione segreta in maniera sicura. Ad esempio, Alice deve provare di avere determinati requisiti a Bob. Il problema sta nel non rivelare informazioni che non vorremmo diffondere durante il processo di verifica.



### Dimostrazioni

Una dimostrazione (proof) è qualcosa che ci convince della validità di un asserto. In matematica, tale concetto è spesso inteso in senso statico. In altre aree una dimostrazione può essere qualcosa di molto diverso, come un **processo interattivo**. In ogni caso, si possono distinguere due entità:  

* Un prover $P$ (provatore) vuole provare che un certo statement $S$ (dichiarazione) è vero. 
* Un verifier $V$ (verificatore) è addetto a controllare che esso sia vero ed emettere la sentenza.

In genere, verificare è più facile che dimostrare da zero. Tale asimmetria è catturata perfettamente dalla classe NP: ogni linguaggio $L$ in NP ha una procedura di verifica efficiente per enunciati del tipo $x \in L$. Provare che $x \in L$ può invece essere difficile. 



### NP e IP

Sia IP la classe di tutti i linguaggi risolvibili da un sistema di interactive proof con un verificatore polinomiale. La classe IP può essere vista come una variante interattiva e randomizzata della classe di complessità NP. NP si ottiene da IP restringendo le dimostrazioni ad essere non interattive (statiche) e deterministiche, quindi con completeness e soundness error pari a 0. Si dimostra che la classe IP è uguale alla classe PSPACE (polynomial space, insieme dei problemi risolvibili da una macchina di Touring deterministica). 



### Completeness e Soundness

Richiediamo due proprietà: 

* **Completeness**: $P$ dovrebbe essere in grado di convincere $V$ della validità di asserti veri. 
* **Soundness**: Un $P$ disonesto non dovrebbe essere in grado di convincere $V$ della validità di un asserto falso. 



### Definire il guadagno di conoscenza

Consideriamo il seguente scenario: Alice parla e Bob ascolta. Possiamo dire che: 

* Alice certamente non guadagna nessuna conoscenza. 
* Non necessariamente Bob acquisisce conoscenza. 

Diciamo che Bob acquisisce conoscenza se la sua capacità computazionale è in qualche modo arricchita dalla conversazione. Bob non acquisisce conoscenza se la sua capacità computazionale rimane inalterata. Dunque Bob acquisisce conoscenza solo se riceve il risultato di una computazione che non era in grado di compiere da solo. 



### Sistemi di prove interattive

$(P,V)$ è un proof system interattivo per il linguaggio $L$ se $V$ è polinomialmente limitato e le seguenti condizioni sono verificate: 

**Completeness**.
$$
\forall x \in L \hspace{.5cm} Pr[\langle P,V \rangle(x) = 1] \ge \frac{2}{3}
$$
 **Soundness**. 
$$
\forall x \notin L, \forall B \hspace{.5cm} Pr[\langle B, V\rangle(x) = 1] \le \frac{1}{3} 
$$


## Zero-knowledge proof

$P$ potrebbe non voler dimostrare in maniera diretta che lo statement $S$ sia vero. Il suo obiettivo è quello di mostrare la validità di $S$ a $V$ senza che esso impari nulla dal processo di verifica. La definizione di **zero-knowledge proof** cattura proprio l'idea che durante il processo di verifica, il verifier $V$ non apprenda nulla sullo statement $S$ meno che la validità dello statement $S$, e **(1)** che ogni cosa che apprende può essere appresa anche al di fuori del processo di verifica, non consultando il prover $P$.

Definiamo **transcript** (trascrizione) di un protocollo interattivo la lista dei messaggi scambiati tra il prover $P$ ed il verifier $V$ durante l'esecuzione del protocollo. L'ultimo asserto **(1)** è formalizzato attraverso un algoritmo chiamato **simulatore**, che preso in input lo statement $S$ da provare, produce lo stesso transcript prodotto dal processo di verifica tra $P$ ed $S$. 

> 🚨 Attenzione: il libro parla di "distribution over transcript", quindi l'ultima parte potrebbe avere un significato diverso da quello descritto. 

Sia $view$ la variabile aleatoria che denota ciò che "vede" il verifier $V$ durante l'esecuzione di $(P,V)(x)$, ovvero i messaggi scambiati da $P$ e $V$, ovvero ancora il transcript. 



### Definizione informale di ZK proof

Una dimostrazione (proof) che coinvolge un prover $P$ ed un verifier $V$ per un linguaggio $L$ è detta essere zero-knowledge se per ogni strategia di verifica $\hat{V}$ probabilista e polinomiale esiste un algoritmo $S$ (che può dipendere da $\hat{V}$, chiamato simulatore, tale che $\forall x \in L$, la distribuzione dell'ouput $S(x)$ è indistinguibile da $View_{\hat{v}}(P(x), V(x))$, dove quest'ultimo denota la "distribution over transcript" generata dal processo di verifica, ovvero dall'interazione della strategia di dimostrazione $P$ e da quella di verifica $\hat{V}$.

Prendiamo in considerazione la distribuzione $S(x)$ e $iew_{\hat{v}}(P(x), V(x))$, allora la zero-knowledge proof può essere: 

* **perfect zero-knowledge**: le distribuzioni sono uguali
* **statistical zero-knowledge**: le distribuzioni hanno una distanza statistica trascurabile
* **computational zero-knowledge**: la probabilità di distinguere le distribuzioni è trascurabile



### Perfect zero-knowledge (PZK)

Diciamo che $(P,V)$ è un interactive proof system che fornisce PZK per il linguaggio $L$ se $\exist M$ Probabilistic Polynomial-time Turing Machine (PPTM), tale che $\forall x \in L$, $\forall a > 0$ e $\forall h : |h| < |x|^a$, si ha che $M(x,h)$ e $view$ sono distribuite in modo identico. 



> ### Esempio: Isomorfismo tra grafi fatto in aula
>
> Siano $G_1$ e $G_2$ due grafi aventi $n$ nodi. Vogliamo stabilire se essi siano isomorfi. Tale problema non sembra essere in $P$, ovvero non è noto alcun algoritmo polinomiale. Definiamo l'isomorfismo tra i due grafi come un'applicazione biiettiva $f$ dai vertici di $G_1$ ai vertici di $G_2$ che preserva la "struttura relazionale", nel senso che c'è un arco dal vertice $u$ al vertice $v$ se e solo se c'è un analogo collegamento dal vertice $f(u)$ al vertice $f(v)$ in $H$. 
>
> Supponiamo che Alice (prover $P$) voglia provare a Bob (verifier $V$) di aver trovato un isomorfismo $f$ tra i due grafi $G_1$ e $G_2$. Tiriamo su un protocollo zero-knowledge affinché Alice possa provare a Bob che dice il vero senza mostrare il protocollo $f$ e senza che Bob possa ricostruire l'isomorfismo dallo scambio dei messaggi nel protocollo. 
>
> Supponiamo che $\pi$ sia una permutazione random dei nodi del grafo. Il protocollo interattivo è definito come segue: 
>
> 1. Alice calcola il grafo $H = \pi(G_i)$ con $i \in \{1, 2\}$ e sia $G_j$ l'altro grafo. 
> 2. Alice è a conoscenza dell'isomorfismo $f : G_j \to G_i$ e di $f^{-1}: G_i \to G_j$
> 3. Alice invia il grafo $H$ a Bob 
> 4. Bob sceglie uniformemente un indice random $k \in  \{1, 2\}$ 
> 5. Bob invia $k$ ad Alice
> 6. Distinguiamo due casi:
>    1. Se $k=i$, alice invia la permutazione $\pi$ a Bob
>    2. Se $k=j$, alice invia la permutazione (composta) $\pi \cdot f$ a Bob 
> 7. In entrambi i casi, Bob avrà una permutazione con cui calcolare da se il grafo $H$
>
> Se ad esempio Alice avesse scelto $G_1$ e calcolato $H = \pi(G_1)$, allora nel caso in cui Bob avesse scelto $k=1$ la permutazione sarebbe stata banalmente $\pi$. Per $k=2$ Alice avrebbe dovuto utilizzare una permutazione composta, prima utilizzando l'isomorfismo $f$, che è di fatto una permutazione dei nodi, per mappare i nodi di $G_2$ ai nodi di $G_1$ e dopodiché la permutazione $\pi$, così che Bob possa calcolare il grafo dalla permutazione $H = (\pi \cdot f)(G_2) = \pi(f(G_2)) = \pi(G_1)$.
>
> Se Alice non avesse realmente l'isomorfismo $f$, e quindi stesse provando a imbrogliare Bob, allora riuscirebbe nel suo intento solo con probabilità $P \le \frac 1 2$. Reiterando il processo più volte, la probabilità diminuisce in maniera esponenziale. 
>
> 

### Esempio: PZK per isomorfismo tra grafi

Siano $G_1$ e $G_2$ due grafi aventi $n$ nodi. Vogliamo stabilire se essi siano isomorfi. Tale problema non sembra essere in $P$, ovvero non è noto alcun algoritmo polinomiale. Definiamo l'isomorfismo tra i due grafi come un'applicazione biiettiva $f$ dai vertici di $G_1$ ai vertici di $G_2$ che preserva la "struttura relazionale", nel senso che c'è un arco dal vertice $u$ al vertice $v$ se e solo se c'è un analogo collegamento dal vertice $f(u)$ al vertice $f(v)$ in $H$. 

Supponiamo che il prover $P$ conosca un isomorfismo tra i due grafi e che debba provarlo al verifier $V$ senza fare acquisire conoscenza a quest'ultimo. Il protocollo che stiamo per mostrare è perfect zero-knowledge solo nel caso di honest-verifier (se il verifier agisce in modo disonesto, si dimostra che il protocollo non è PZK). Il protocollo è il seguente: 

> 1. $V$ sceglie random $b \in \{1,2\}$ e sceglie una permutazione $\pi : \{1, \dots, n\} \to \{1, \dots, n\}$. 
> 2. $V$ invia $\pi(G_b)$ a $P$.
> 3. $P$ risponde con $b'$
> 4. $V$ accetta se $b = b'$, altrimenti rigetta.

Il protocollo è completo ed ha un soundness error al più di $\frac 1 2$, vediamo come. 

**Perfect completeness**. 
Se $G_1$ e $G_2$ non sono isomorfi, allora $\pi(G_b)$ è isomorfo a $G_b$ ma non a $G_{3-b}$. Il prover $P$ può identificare $b$ controllando a quale dei due grafi $G_1, G_2$ il nuovo grafo $\pi(G_b)$ è isomorfo. 

**Soundness**. 
Se $G_1$ e $G_2$ sono isomorf, allora $\pi(G_1)$ e $\pi(G_2)$ sono distribuiti allo stesso modo quando $\pi$ è una permutazione scelta uniformemente tra le $n!$ permutazioni degli $n$ nodi. L'invio di $\pi(G_b)$ non fornisce quindi alcuna informazione su quale sia il valore di $b$. Questo implica che a prescindere dalla strategia di $P$, la probabilità che $P$ scelga $b'=b$ non conoscendo alcun isomorfismo $f$ è $\frac{1}{2}$. Il soundness error può essere ridotto a $2^{-k}$ iterando il processo $k$ volte. 

**Perfect honest-verifier zero-knowledge**
Se i grafi non sono isomorfi, il verifier onesto non potrà imparare nulla sul bit $b'$ inviato da $P$. Formalmente, consideriamo un simulatore che dato un input $(G_1, G_2)$ sceglie $b \in \{1,2\}$ e $\pi$ random, e da in output il transcript $(\pi(G_b), b)$. Questo transcript è distribuito in maniera identica alla view dell'interazione tra $P$ e $V$. 



### Esempio: Diffie-Hellman 

Vedasi il capitolo di Crittografia riguardo al problema Diffie-Hellman. Siano $(g, g^x, g^y, g^{xy})$ dei parametri pubblici, il prover $P$ deve dimostrare di conoscere il valore di $x$ o $y$ al verifier (nella dimostrazione d'esempio si suppone conosca $x$). Si suppone che nel gruppo in cui si opera, il problema del logaritmo discreto sia computazionalmente difficile. Sia $m$ l'ordine del gruppo, la dimostrazione zero knowledge funziona nel seguente modo: 

1. $P$ sceglie casualmente $r =_R \{0, \dots, m\}$ 
2. $P$ calcola $R_1 = g^r$ ed $R_2 = (g^y)^r$ e invia $(R_1, R_2)$ a $V$
3. $V$ sceglie casualmente $c =_R \{0, \dots, m\}$ e invia $c$ a $P$
4. $P$ calcola $z= r + cx \mod m$ e invia $z$ a $V$
5. $V$ verifica che $R_1 (g^x)^c = g^z$ e che $R_2(g^{xy})^c = (g^y)^z$ 

Osserviamo che $V$ non può estrarre $x$ dal passo $4$, non conoscendo $r$. 

> TODO: dimostrare completeness, soundness e zero-knowledge. 

### Teorema

Se esistono funzioni unidirezionali allora ogni linguaggio in NP ammette una computational zero-knowledge proof. 

> TODO: approfondire il teorema. 



## Prove di conoscenza

Supponiamo di voler dimostrare a qualcuno di conoscere qualcosa, evitando che la nostra conoscenza possa essere trasferibile. Le domande da porsi sono: 

* Cosa vuol dire conoscere qualcosa?
* Come possiamo formalizzare questo concetto?

Consideriamo le relazioni in NP: Informalmente, NP è la classe dei linguaggi L che ammettono una funzione (relazione) polinomiale $\rho$ tale che: 
$$
\forall x \in L, \exist y : \rho(x,y)=1
$$
Anche in questo contesto la prova di conoscenza è definita da un verificatore. Richiediamo una proprietà di completezza ed una proprietà di zero-knowledge. Il problema è la **condizione di conoscenza**. Richiediamo l'esistenza di un algoritmo **estrattore** $E$, che ha accesso ad $x \in L$ e, via oracolo, alla strategia di $P$. L'algoritmo $E$ può interagire con la randomness utilizzata da $P$ e con $P$. $E$ è diverso da $V$ in quanto può eseguire $P$ più volte costringendolo a utilizzare sempre la stessa randomness. $E$ deve restituire $y$ tale che $\rho (x,y) = 1$. Formalizzare il concetto di prova di conoscenza è ben più complicato. Qui ci siamo limitati a descrivere l'aspetto più intuitivo del problema. 

