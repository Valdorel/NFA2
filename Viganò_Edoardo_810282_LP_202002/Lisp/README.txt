Lisp: Compilazione d’espressioni regolari in automi non deterministici (Progetto Universitario)

Studenti:
- Mattia Beolchi 844911
- Luca Melgiovanni 844631
- Edoardo Viganò 810282

README relativo a nfa.lisp

Il presente documento contiene una spiegazione dettagliata del funzionamento del compilatore da espressione regolare ad automa non deterministico.
Gli automi sono realizzati secondo un'implementazione che permette di riconoscere se la lista in input fa parte dell'insieme dei risultati validi 
accettati dell'espressione regolare (ossia se è parte del linguaggio rappresentato dalla regexp).


== Funzioni ==

Descrizione dei predicati pubblici e dei relativi predicati privati:

- is-regexp
Controlla se la lista in input contiene un'espressione regolare, analizzando l'input elemento per elemento.
Il riconoscimento avviene analizzando i vari elementi della regexp attraverso le varie condizioni, prima verificando che in input
sia stato inserito un atomo lisp, poi con dei controlli sul primo elemento della lista e successivamente attraverso chiamate ricorsive eseguite
sul resto degli elementi della lista.


- nfa-regexp-comp
Riconosce l'espressione regolare in input e la traduce in una serie di funzioni di transizione che rappresentano l'automa, inoltre stabilisce
uno stato iniziale e uno stato finale per quell'automa. L'espressione regolare può contenere le operazioni di star (chiusura di Kleene), 
or e plus oltre alla sequenza.
Questa funzione è quindi un metodo generativo: serve a stabilire le regole che compongono la grammatica di un linguaggio determinando 
tutte e sole le stringhe accettabili.
Differenziando i vari casi componiamo le varie transizioni dell'automa relativo a una determinata espressione in input, ci avvaliamo delle seguenti
sotto funzioni per la creazione di questi stati:

    - apply-atom
    Viene creato un automa che ha come unica transizione la transizione con il relativo atomo inserito in precedenza.
    Vengono usate inoltre delle epsilon transizioni dal primo stato verso il secondo e dal penultimo verso il finale. 

    - apply-[]
    Ci cono diverse condizioni per diversificare i diversi casi che possiamo avere. Nel caso non si passasse nulla la transizione sarà
    una semplice epsilon tra stato iniziale e finale; altrimenti verranno create, oltre all'iniziale epsilon transizione e alla finale,
    delle transizioni per ogni simbolo in sequanza presente. Viene controllato inoltre se all'interno ci sono degli eventuali simboli
    riservati (/,*,+).

    - apply-/
    Inizialmente viene verificato se all'interno vi è un simbolo che richiama la sequenza, altrimenti procede col cotrollare se c'è un simbolo
    / per poi creare la transizione dell'automa. Controlla inoltre se ci sono all'interno simboli di * o +, e infine si può trovare il caso in cui 
    ci sia un atomo.

    - apply-*
    Soliti controlli sugli operatori interni alla lista suddivisi nelle varie condizioni.
    All'interno di questa funzione vengono crate le transizioni che soddisfano lo star e il plus (se dovessero esserci) nel caso i simboli siano
    applicati all'atomo (ultima condizione); altrimenti seguiranno chiamate ricorsive all'interno per risolvere altri eventuali * e +.
    La ripetizione dei simboli a cui è applicato * deve essere di zero o più volte.

    - apply-+
    Funziona all'incirca come la precedente funzione sopra citata, con la differenza che la ripetizione del simbolo a cui è stato 
    applicato il + deve essere di almeno una volta.


- nfa-rec
Prende in input una stringa e un automa creato da nfa-regexp-comp e controlla che la stringa appartenga al linguaggio di quell'automa
usando le funzioni di transizione. Questa funzione svolge quindi il compito di compilatore.
Controlla che l'input inserito per l'automa, avente identificatore FA, sia consumato tutto correttamente e quindi al termine della computazione
l'automa si troverà in uno stato finale accettante. Questa funzione chiama un'altra funzione: nfa-rec2.

    - nfa-rec2
    che ha come argomenti anche lo stato attuale
    e gli stati finali dell'automa in questione, ritornando vero con stringa vuota e stato finale. Attraverso le varie condizioni viene controllato il caso di:
    stringa accettata e stringa non accettata come casi base, come passo ricorsivo controllo se esiste la funzione attuale iniziando una computazione
    controllando tutti gli elementi che compongono la lista.


== Note ==

All'interno del file nfa.lisp vi sono dei commenti in blocchi di isruzioni che dicono:
- Qual'è il comportamento della funzione;
- Il numero di argomenti che deve avere.
