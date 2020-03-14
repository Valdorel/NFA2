%%%%    -*- Mode: Prolog -*-

%%	Studenti: Mattia Beolchi 844911,
%%            Luca Melgiovanni 844631,
%%            Edoardo Viganò 810282

%%	Progetto Prolog:
%%	"Compilazione d'espressioni regolari in automi non deterministici"

%%%% ---------------------------------------------------------------------

%   is_regexp/1
%
% is_regexp(Regular Expression)
%
% True se RE � un espressione regolare.


is_regexp(RE) :-
  atomic(RE), !.

is_regexp(RE) :-
  nonvar(RE),
  is_regexp_ok(RE), !.


%   is_regexp_ok(RE)
%
% True se RE contiene un operatore valido.
% Si tratta di un predicato ausiliario per is_regexp/1


is_regexp_ok(RE) :-
  compound(RE),
  functor(RE, Symbol, _),
  check_symbol(Symbol).

is_regexp_ok(RE) :-
  RE =.. Rs,
  is_regexp_case(Rs), !.


%   check_symbol(RE)
%
% True se il Symbol è diverso dai funtori privati
% Si tratta di un predicato ausiliario per is_regexp/1

check_symbol(Symbol) :-
  Symbol \= '+',
  Symbol \= '*',
  Symbol \= '/',
  Symbol \= '[|]'.


%   is_regexp_case(Rs)
%
% True se Rs contiene una regexp valida.
% Si tratta di un predicato ausiliario per is_regexp_ok/1

is_regexp_case(['+'|[Rs]]) :-
  is_regexp(Rs), !.

is_regexp_case(['*'|[Rs]]) :-
  is_regexp(Rs), !.

is_regexp_case(['/'|Rs]) :-
  is_regexp_list(Rs), !.

is_regexp_case(['[|]'|Rs]) :-
  is_regexp_list(Rs), !.

%   is_regexp_list(Regular Expression List)
%
% True se la lista contiene regexp.
% Si tratta di un predicato ausiliario per is_regexp_list/1


is_regexp_list([]).


is_regexp_list([RE|Rs]) :-
  is_regexp(RE),
  is_regexp_list(Rs), !.


%   nfa_regexp_comp/2
%
% nfa_regexp_comp(FA_Id, RE)
%
% True se FA_Id � un identificatore valido
% e RE � una regexp


nfa_regexp_comp(FA_Id, RE) :-
  nonvar(FA_Id),
  is_regexp(RE),
  RE =.. Rs,
  nfa_regexp_check(FA_Id, Rs, Initial, Final),
  assert(nfa_initial(FA_Id, Initial)),
  assert(nfa_final(FA_Id, Final)), !.


nfa_regexp_comp(FA_Id, RE) :-
  nonvar(FA_Id),
  compound(RE),
  nfa_regexp_check(FA_Id, RE, Initial, Final),
  assert(nfa_initial(FA_Id, Initial)),
  assert(nfa_final(FA_Id, Final)), !.


%   nfa_regexp_check(FA_Id, RS, Initial, Final)
%
% True se FA_Id � un identificatore valido e RE � una regexp
% Si tratta di un predicato ausiliario per nfa_regexp_comp/2


nfa_regexp_check(FA_Id, Rs, Initial, Final) :-
  atomic(Rs),
  gensym(q_, Initial),
  gensym(q_, Final),
  assert(nfa_delta(FA_Id, Rs, Initial, Final)), !.


nfa_regexp_check(FA_Id, [Rs], Initial, Final) :-
  atomic(Rs),
  gensym(q_, Initial),
  gensym(q_, Final),
  assert(nfa_delta(FA_Id, Rs, Initial, Final)), !.

nfa_regexp_check(FA_Id, Rs, Initial, Final) :-
  compound(Rs),
  functor(Rs, Symbol, _),
  check_symbol(Symbol),
  gensym(q_, Initial),
  gensym(q_, Final),
  assert(nfa_delta(FA_Id, Rs, Initial, Final)), !.


nfa_regexp_check(FA_Id, ['[|]'|Rs], Initial, Final) :-
  gensym(q_, Initial),
  nfa_regexp_seq(FA_Id, Rs, Initial, Final), !.


nfa_regexp_check(FA_Id, ['/'|Rs], Initial, Final) :-
  gensym(q_, Initial),
  gensym(q_, Final),
  nfa_regexp_or(FA_Id, Rs, Initial, Final), !.


nfa_regexp_check(FA_Id, ['*'|Rs], Initial, Final) :-
  gensym(q_, Initial),
  gensym(q_, Final),
  Rs =.. ['[|]',Rx|_],
  Rx =.. Ry,
  nfa_regexp_check(FA_Id, Ry, I, F),
  assert(nfa_delta(FA_Id, epsilon, Initial, Final)),
  assert(nfa_delta(FA_Id, epsilon, Initial, I)),
  assert(nfa_delta(FA_Id, epsilon, F, Final)),
  assert(nfa_delta(FA_Id, epsilon, F, I)), !.


nfa_regexp_check(FA_Id, ['+'|Rs], Initial, Final) :-
  gensym(q_, Initial),
  gensym(q_, Final),
  Rs =.. Rx,
  Rx =.. [_, _, Ry|_],
  nfa_regexp_check(FA_Id, Rx, I, F),
  nfa_regexp_check(FA_Id, ['*'|Ry], I1, F1),
  assert(nfa_delta(FA_Id, epsilon, Initial, I)),
  assert(nfa_delta(FA_Id, epsilon, F, I1)),
  assert(nfa_delta(FA_Id, epsilon, F1, Final)), !.


%   nfa_regexp_seq((FA_Id, List, Initial, Final)
%
% True se la lista contiene regexp valide per FA_Id, dove Initial
% e Final sono gli stati iniziali e finali dell'automa
% Si tartta di un predicato ausiliare di nfa_regexp_comp


nfa_regexp_seq(_, [], Final, Final).


nfa_regexp_seq(_, [[]], Final, Final).


nfa_regexp_seq(FA_Id, Head, Initial, Final) :-
  is_regexp(Head),
  nfa_regexp_check(FA_Id, Head, I, F),
  gensym(q_, Final),
  assert(nfa_delta(FA_Id, epsilon, Initial, I)),
  assert(nfa_delta(FA_Id, epsilon, F, Final)), !.


nfa_regexp_seq(FA_Id, [Head], Initial, Final) :-
  nfa_regexp_check(FA_Id, Head, I, F),
  gensym(q_, Final),
  assert(nfa_delta(FA_Id, epsilon, Initial, I)),
  assert(nfa_delta(FA_Id, epsilon, F, Final)), !.


nfa_regexp_seq(FA_Id, [Head|Tail], Initial, Final) :-
  Head =.. Rx,
  nfa_regexp_check(FA_Id, Rx, I, F),
  assert(nfa_delta(FA_Id, epsilon, Initial, I)),
  nfa_regexp_seq(FA_Id, Tail, F, Final), !.


%   nfa_regexp_or((FA_Id, List, Initial, Final)
%
% True se la lista contiene regexp valide per FA_Id, dove Initial
% e Final sono gli stati iniziali e finali dell'Automa
% Si tartta di un predicato ausiliare di nfa_regexp_comp

nfa_regexp_or(_, [], _, _).


nfa_regexp_or(FA_Id, [Head|Tail], Initial, Final) :-
  Head =.. Rx,
  nfa_regexp_check(FA_Id, Rx, I, F),
  assert(nfa_delta(FA_Id, epsilon, Initial, I)),
  assert(nfa_delta(FA_Id, epsilon, F, Final)),
  nfa_regexp_or(FA_Id, Tail, Initial, Final), !.


%   nfa_rec/2
%
% nfa_rec(FA_Id, Input)
% True se Input � una lista di simboli validi per l'automa FA_Id e alla
% della verifica, l'automa si trova nello stato finale


nfa_rec(FA_Id, Input) :-
  nonvar(FA_Id),
  nonvar(Input),
  nfa_initial(FA_Id, Initial),
  nfa_final(FA_Id, Final),
  nfa_rec(FA_Id, Input, Initial, Final), !.


nfa_rec(FA_Id, [], Final, Final) :-
  nfa_final(FA_Id, Final), !.


nfa_rec(FA_Id, [], Initial, Final) :-
  nfa_delta(FA_Id, epsilon, Initial, X),
  nfa_rec(FA_Id, [], X, Final), !.


nfa_rec(FA_Id, Input, Initial, Final) :-
  nfa_delta(FA_Id, epsilon, Initial, X),
  nfa_rec(FA_Id, Input, X, Final), !.


nfa_rec(FA_Id, [Head|Tail], Initial, Final) :-
  nfa_delta(FA_Id, Head, Initial, X),
  nfa_rec(FA_Id, Tail, X, Final), !.


%   nfa_clear/2
%
% nfa_clear(FA_Id, Input)
% True se dalla basi di dati vengono rimossi tutti i vari automi definiti
% oppure l'automa FA_Id


nfa_clear :-
  retractall(nfa_delta(_, _, _, _)),
  retractall(nfa_initial(_, _)),
  retractall(nfa_final(_, _)).


nfa_clear(FA_Id) :-
  retractall(nfa_delta(FA_Id, _, _, _)),
  retractall(nfa_initial(FA_Id, _)),
  retractall(nfa_final(FA_Id, _)).
