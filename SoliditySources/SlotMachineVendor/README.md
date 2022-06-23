# Slot machine vendor

Il venditore vende slot machine ai clienti. Le slot machine hanno due caratteristiche: 

- Un numero di ruote $n$
- Un numero massimo di giocate $m$

Il prezzo della slot machine è formulato come segue: 

$$
1 \text{ ETH} \times n + 1\times 10^{-3} \text{ ETH} \times m
$$

Metà di questi ETH va alla slot, l'altra metà va al venditore. Dopo $m$ giocate, il contratto della slot si distrugge ed i soldi rimanenti vanno all'owner. 

Tutti possono giocare ad una certa slot puntando una cifra minima specificata dall'owner a tempo di creazione del contratto. Si vince quando tutte le ruote combaciano. Ogni ruota ha 3 segni: 1, 2, 3

- Combo di 1: ottieni la cifra puntata
- Combo di 2: ottieni la cifra puntata x2 
- Combo di 3: ottieni la cifra puntata x3

Se l'utente vince tutti i soldi della macchinetta, il contratto si autodistrugge. 

