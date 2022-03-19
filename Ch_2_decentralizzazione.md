# Decentralizzazione

Lo scopo di questo capitolo è quello di introdurre tecniche che permettano di effettuare le azioni di Scrooge in Scroogecoin, ma in maniera decentralizzata. Dividiamo il discorso sulla decentralizzazione di Bitcoin su 5 diverse domande: 

1. Chi mantiene il libro mastro delle transazioni?
2. Chi ha autorita su quali transazioni sono valide?
3. Chi crea nuovi Bitcoin?
4. Chi determina come cambiano le regole del sistema?
5. In che modo i bitcoin acquisiscono valore di scambio?

Le prime tre domande riflettono i dettagli tecnici del protocollo Bitcoin, e saranno il focus di questo capitolo. La rete **peer to peer** raggiunge la quasi totale decentralizzazione, dato che chiunque può eseguire un nodo Bitcoin (non troppo difficilmente, attraverso un client Bitcoin). Anche il **mining di Bitcoin** è teoricamente aperto a tutti, ma richiede un elevato costo computazionale, di conseguenza il mining ha un alto grado di centralizzazione (dato che richiede un grosso investimento). I nodi aggiornano singolarmente il software che permette l'operazione del protocollo (che è aperto), ma quasi tutti utilizzano una implementazione di riferimento, e i maintainers di tale implementazione hanno grande potere. 



## Distributed consensus 

Il consenso distribuito serve a creare affidabilità nei sistemi distribuiti. Formalmente: 

> Supponiamo di avere $n$ nodi, ognuno con un valore di input. Alcuni di questi sono nodi malevoli / corrotti. Un **protocollo di consenso distribuito** ha le seguenti due proprietà: 
>
> 1. Al termine, tutti i nodi onesti devono essere d'accordo sul valore scelto. 
> 2. Il valore scelto deve essere generato da un nodo onesto.



### Concetti di base

Bitcoin è un sistema peer-to-peer: quando Alice vuole pagare Bob, tecnicamente manda in broadcast una transazione a tutta la rete. 

![image-20220319110530239](Ch_2_decentralizzazione.assets/image-20220319110530239.png)

Bob non deve necessariamente essere un nodo della rete per ricevere il pagamento. Esso verrà scritto nella blockchain, per cui esisterà e Bob sarà il legittimo proprietario. Se Bob vuole essere **notificato** del pagamento, allora è una buona idea eseguire un nodo Bitcoin e restare in ascolto. 

Dato che vari utenti eseguono transazioni nello stesso momento, i nodi della rete Bitcoin devono stabilire un consenso su quali transazioni sono state trasmesse e sul loro ordine di effettuazione. Come in Scroogecoin, più transazioni venivano inserite in un blocco, allo stesso modo, in Bitcoin, il consenso avviene blocco per blocco.

In ogni momento, ogni nodo della rete Bitcoin avrà un libro mastro che consiste in una lista di blocchi, ognuno dei quali conterrà transazioni che hanno raggiunto il consenso distribuito. Addizionalmente, ogni nodo può contenere un pool di transazioni di cui è venuto a conoscenza, ma che non sono ancora incluse nella blockchain. Tale pool può essere diverso tra nodi, questo avviene poiché le transazioni non si propagano istantaneamente nella rete peer to peer, ed un nodo può andare spesso offline.  



### Processo di consenso

Ad intervalli regolari (es. 10 minuti) ogni nodo propone al sistema di includere il proprio transaction pool nel nodo successivo. Dopodiché i nodi eseguono qualche protocollo di consenso, dove ogni nodo propone il proprio input da inserire nel blocco. Possiamo supporre che al protocollo partecipino nodi onesti e disonesti. Se il protocollo di consenso riesce, alora il blocco proposto viene selezionato in output (anche se proposto da un solo nodo). Alcune transazioni valide possono essere escluse dal blocco di output, ma questo non è un problema poiché potranno partecipare al blocco successivo. 

Questa è una descrizione a grandi linee, poiché: (1) la rete peer to peer non è totalmente connessa; (2) ci sono problemi di latenza e connettività; (3) alcuni nodi possono cercare di sovvertire il sistema. Una conseguenza della latenza è la **mancanza di un tempo globale**, per cui non tutti i nodi possono essere d'accordo sull'ordine delle transazioni semplicemente osservando i loro timestamp. 



### Risultati di impossibilità

pagina 71.

