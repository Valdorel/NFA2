Prolog: Compilazione d’espressioni regolari in automi non deterministici

Studenti:
- Mattia Beolchi 844911
- Luca Melgiovanni 844631
- Edoardo Viganò 810282

README relativo a nfa.pl

Il presente documento contiene una spiegazione dettagliata del funzionamento del compilatore da espressione regolare ad automa non deterministico.
Gli automi sono realizzati secondo un'implementazione che permette di riconoscere se la lista in input fa parte dell'insieme dei risultati validi
accettati della espressione regolare (ossia se è parte del linguaggio rappresentato dalla regexp).
Abbiamo inoltre pensato di lasciare dei commenti all'inizio di ogni predicato usato nel file nfa.pl per rendere più comprensibile la lettura
del codice, evitando quindi di dover "cercare di capire" cosa è stato fatto.


Descrizione dei predicati fondamentali implementati e i relativi predicati ausiliari:

- is_regexp/1
Analiza l'input del predicato contiene o meno un'espressione regolare. Usa i seguenti predicati ausiliari:

	-is_regexp_ok/1
	Controlla due casi:
	1)Se RE è termine compound, controlla il simbolo del funtore tramite il predicato check_symbol/1
	2)Se RE non è un termine compound, invoca il predicato is_regexp_case/1.

	-check_symbol/1
	Controlla che il simbolo passatogli in input non sia un funtore privato.

	-is_regexp_case/1
	Controlla che la lista ricevuta in input sia formata da espressioni regolari e simboli validi.
	Nel caso in cui l'operatore possa avere più argomenti, viene invocato il predicato is_regexp_list/1

	-is_regexp_list/1
	Controlla che lista passatagli sia composta da espressioni regolari



- nfa_regexp_comp/2
Compone l'automa inserendo nella base di dati Prolog i predicati relativi allo stato iniziale, a tutte le mosse possibili ed agli stati terminali.
La composizione dell'automa avviene creando per ogni operatore l'automa corrispondente e nel caso in cui un operatore sia argomento di un altro operatore,
l'automa del primo sarà interno all'automa del secondo.
Possiamo avere due casi, cioè quello in cui l'espressione regolare passata in input sia un termine
composto, e la verifica avviene tramite il termine compound/1, oppure che l'input non sia un termine composto
ma vieene riconosciuto dal predicato is_regexp/1.
Descriviamo i vari casi che vengono trattati, tramite il predicato ausiliario nfa_regexp_check/4:

	- nfa_regexp_check/4
	Si occupa di 3 casi:
	1) L'input è un elemento semplice ed in questo caso inserisce una delta dallo stato iniziale a quello finale
	2) L'input è  il primo elemento di una lista e anche in questo caso inserisce una delta dallo stato iniziale a quello finale
	3) L'input è un termine composto e quindi si va a controllare il simbolo del funtore tramite la funzione check_symbol/1 e
	   va a creare la basi di dati con lo stato finale ed iniziale dell'automa. Infine inserisce anche la delta-

	- nfa_regexp_check/4(caso seq)
	Crea lo stato iniziale dell'automa e poi invoca il predicato ausiliario nfa_regexp_seq/4

	- nfa_regexp_check/4(caso or)
	Crea lo stato iniziale e quello finale e poi invoca il predicato ausiliario nfa_regexp_or/4

	-nfa_regexp_check/4(caso star)
	Crea lo stato iniziale e finale dell'automa, poi verifica la correttezza dell'espressione regolare
	trasformata in sequenza andando a costruire l'automa apposita con le eventuali epsilon mosse e nfa_delta

	- nfa_regexp_check/4(caso plus)
		Il plus sarà come l'automa di una seq con due argomenti, dove:
		1) Il primo è l'automa dell'argomento stesso.
		2) Il secondo è l'automa dello star dell'argomento stesso.

	-nfa_regexp_seq/4
	Questo predicato, oltre a gestire i 2 casi base, deve gestirne altri due:

	1)La sequenza è composta da un solo elemento, quindi andrò a verificare questo
	e poi a costruire lo stato finale, andando a considerare le varie epsilon mosse

	2)La sequenza è composta da più elementi, quindi andrò a verificare come prima l'elemento
	di testa, costruisco la delta e poi invocherò la nfa_regexp_seq/4 sul resto della sequenza

	-nfa_regexp_or/4
	A parte il caso base, anche questo predicato verifica prima sul primo parametro, inserisce le
	epsilon mosse ed infine invoca ricorsivamente se stesso sugli altri parametri


-nfa_rec/2
Questo predicato esegue i seguenti controlli:
1) Che l'input sia una lista tramite il predicato is_list/1
2) Controlla lo stato iniziale già presente nella base di predicati
3) Invoca il predicato nfa_rec/4
4) Controlla lo stato finale
I predicati ausiliari che usa sono i seguenti:

	-nfa_rec/4(input vuoto e i due stati sono quelli finali)
	controlla che lo stato finale sia quello corretto

	-nfa_rec/4(input vuoto e i due stati sono diversi)
	Inserisce un'epsilon mossa tra lo stato iniziale ed un nuovo
	stato e poi invoca ricorsivamente nfa_rec/4, sempre con lo stesso
	input, con il nuovo stato appena creato e poi lo stato finale

	-nfa_rec/4(input è un singolo elemento e gli stati sono diversi)
	Inserisce un'epsilon mossa tra lo stato iniziale ed un nuovo
	stato e poi invoca ricorsivamente nfa_rec/4, sempre con lo stesso
	input, con il nuovo stato appena creato e poi lo stato finale

	-nfa_rec/4(input è una lista e gli stati sono diversi)
	Inserisce una delta tra lo stato iniziale e un nuovo stato appena creato
	e poi invoca in maniera ricorsiva il predicato nfa_rec/4 con il resto della lista
	e come stati quello appena creato e quello finale

- nfa_clear/0
Ripulisce la base dati prolog da tutte le implementazioni di automi.

- nfa_clear/1
Ripulisce la base dati prolog dall'implementazione dell'automa il cui identificatore unifica con l'identificatore dato in input.


== Note ==

Per ogni predicato definito nel file nfa.pl ci sono dei commenti che dicono quando ogni
singolo predicato vale True e il numero di argomenti che deve avere.
