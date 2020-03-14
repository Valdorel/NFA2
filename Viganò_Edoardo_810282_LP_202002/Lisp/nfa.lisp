;;;; -*- Mode: Lisp -*-

;;	Studenti: Mattia Beolchi 844911,
;;            Luca Melgiovanni 844631,
;;            Edoardo Viganò 810282


;; Progetto Lisp:
;; "Compilazione d'espressioni regolari in automi non deterministici"

;;;; ------------------------------------------------------------------


; is-regexp(RE)
; True se RE è una espressione regolare

(defun is-regexp (RE)
  (cond ((listp RE)
        (cond
        ((equal '+ (first RE))
            (and (eql 1 (length (rest RE))) (is-regexp (second RE))))
        ((equal '* (first RE))
                (and (eql 1 (length (rest RE))) (is-regexp (second RE))))
        ((equal '/ (first RE))
            (and (<= 2 (length (rest RE)))
                 (every #'identity (mapcar 'is-regexp (rest RE)))))
        ((equal '[] (first RE))
            (and (<= 2 (length (rest RE)))
                 (every #'identity (mapcar 'is-regexp (rest RE)))))
        ))
    ((atom RE) T)))

; nfa-regexp-comp(RE)
; Ritorna l'automa ottenuto dalla compilazione di RE

(defun nfa-regexp-comp (RE)
  (if (is-regexp RE)
      (let ((automa (list (gensym)(gensym))))
        (cond ((atom  RE) (append automa
                                  (apply-atom  RE
                                               (first automa)
                                               (second automa))))
              ((eql '[] (car RE)) (append automa
                                           (apply-[] (rest RE)
                                                     (first automa)
                                                     (second automa)
                                                     nil)))
              ((eql '/ (car RE)) (append automa
                                         (apply-/ (rest RE)
                                                  (first automa)
                                                  (second automa))))
              ((eql '* (car RE)) (append automa
                                         (apply-* (rest RE)
                                                  (first automa)
                                                  (second automa))))
              ((eql '+ (car RE)) (append automa
                                         (apply-+ (rest RE)
                                                  (first automa)
                                                  (second automa))))
              (t nil)))
    nil))


; apply-atom(RE initial final)
; Ritorna la lista dell'automa relativo all'atomo passato.
; Ausiliaria a nfa-regexp-comp(RE)

(defun apply-atom (RE init final)
  (let ((init-atom (gensym))
        (final-atom (gensym)))
    (append (list (list init 'epsilon init-atom))
            (list (list init-atom RE final-atom))
            (list (list final-atom 'epsilon final)))))


; apply-[](RE initial final initial-conn)
; Ritorna la lista dell'automa relazivo al simbolo di [].
; Ausiliaria a nfa-regexp-comp(RE)

(defun apply-[] (RE init final init-conn)
  (let ((nuovo-stato1 (gensym))
        (nuovo-stato2 (gensym))
        (nuovo-stato3 (gensym)))
    (cond ((null RE)
           (list (list init 'epsilon final)))
          ((listp (car RE))
           (cond ((and (equal (car (car RE)) '[])
                       (null init-conn))
                  (append (list (list init 'epsilon nuovo-stato1))
                          (apply-[] (rest (car RE)) 
                                nuovo-stato1 nuovo-stato2 nil)
                          (list (list nuovo-stato2 'epsilon nuovo-stato3))
                          (apply-[] (rest RE) nuovo-stato3 final t)))
                 ((equal (car (car RE)) '[])
                  (append (apply-[] (rest (car RE)) 
                                init nuovo-stato2 init-conn)
                          (list (list nuovo-stato2 'epsilon nuovo-stato3))
                          (apply-[] (rest RE) nuovo-stato3 final init-conn)))
                 ((and (equal (car (car RE)) '/)
                       (null init-conn))
                  (append (list (list init 'epsilon nuovo-stato1))
                          (apply-/ (rest (car RE)) nuovo-stato1 nuovo-stato2)
                          (list (list nuovo-stato2 'epsilon nuovo-stato3))
                          (apply-[] (rest RE) nuovo-stato3 final t)))
                 ((equal (car (car RE)) '/)
                  (append (apply-/ (rest (car RE)) init nuovo-stato2)
                          (list (list nuovo-stato2 'epsilon nuovo-stato3))
                          (apply-[] (rest RE) nuovo-stato3 final init-conn)))
                 ((and (equal (car (car RE)) '*)
                       (null init-conn))
                  (append (list (list init 'epsilon nuovo-stato1))
                          (apply-* (rest (car RE)) nuovo-stato1 nuovo-stato2)
                          (list (list nuovo-stato2 'epsilon nuovo-stato3))
                          (apply-[] (rest RE) nuovo-stato3 final t)
                          ))
                 ((equal (car (car RE)) '*)
                  (append (list (list init 'epsilon nuovo-stato1))
                          (apply-* (rest (car RE)) nuovo-stato1 nuovo-stato2)
                          (list (list nuovo-stato2 'epsilon nuovo-stato3))
                          (apply-[] (rest RE) nuovo-stato3 final init-conn)))
                 ((and (equal (car (car RE)) '+)
                       (null init-conn))
                  (append (list (list init 'epsilon nuovo-stato1))
                          (apply-+ (rest (car RE)) nuovo-stato1 nuovo-stato2)
                          (list (list nuovo-stato2 'epsilon nuovo-stato3))
                          (apply-[] (rest RE) nuovo-stato3 final t)
                          ))
                 ((equal (car (car RE)) '+)
                  (append (list (list init 'epsilon nuovo-stato1))
                          (apply-+ (rest (car RE)) nuovo-stato1 nuovo-stato2)
                          (list (list nuovo-stato2 'epsilon nuovo-stato3))
                          (apply-[] (rest RE) nuovo-stato3 final init-conn)
                          ))
                 ))
          ((and (atom (car RE))
                (null init-conn))
           (append (list (list init 'epsilon nuovo-stato1))
                   (apply-atom (car RE) nuovo-stato1 nuovo-stato2)
                   (apply-[] (rest RE) nuovo-stato2 final t)))
          ((atom (car RE))
           (append (apply-atom (car RE) init nuovo-stato1)
                   (apply-[] (rest RE) nuovo-stato1 final init-conn))))))


; apply-/(RE initial final)
; Ritorna la lista dell'automa relazivo al simbolo di /.
; Ausiliaria a nfa-regexp-comp(RE)

(defun apply-/ (RE init final)
  (let ((nuovo-stato1 (gensym))
        (nuovo-stato2 (gensym)))
    (cond ((listp (car RE))
           (cond ((equal (car (car RE)) '[])
                  (append (list (list init 'epsilon nuovo-stato1))
                          (list (list nuovo-stato2 'epsilon final))
                          (apply-[] (rest (car RE)) 
                                nuovo-stato1 nuovo-stato2 nil)
                          (apply-/ (rest RE) init final)))
                 ((equal (car (car RE)) '/)
                  (append (list (list init 'epsilon nuovo-stato1))
                          (list (list nuovo-stato2 'epsilon final))
                          (apply-/ (rest (car RE)) nuovo-stato1 nuovo-stato2)
                          (apply-/ (rest RE) init final)))
                 ((equal (car (car RE)) '*)
                  (append (list (list init 'epsilon nuovo-stato1))
                          (apply-* (rest (car RE)) nuovo-stato1 nuovo-stato2)
                          (list (list nuovo-stato2 'epsilon final))
                          (apply-/ (rest RE) init final)))
                 ((equal (car (car RE)) '+)
                  (append (list (list init 'epsilon nuovo-stato1))
                          (apply-+ (rest (car RE)) nuovo-stato1 nuovo-stato2)
                          (list (list nuovo-stato2 'epsilon final))
                          (apply-/ (rest RE) init final)))))
          ((atom (car RE))
           (append (apply-atom (car RE) init final)
                   (apply-/ (rest RE) init final))))))


; apply-*(RE initial final)
; Ritorna la lista dell'automa relazivo al simbolo di *.
; Ausiliaria a nfa-regexp-comp(RE)

(defun apply-* (RE init final)
    (cond ((listp (car RE))
           (cond ((equal (car (car RE)) '[])
                  (append (list (list init 'epsilon final))
                          (list (list final 'epsilon init))
                          (apply-[] (rest (car RE)) init  final nil)))
                 ((equal (car (car RE)) '/)
                  (append (list (list init 'epsilon final))
                          (list (list final 'epsilon init))
                          (apply-/ (rest (car RE)) init final)))
                 ((equal (car (car RE)) '*)
                  (append (list (list init 'epsilon final))
                          (list (list final 'epsilon init))
                          (apply-* (rest (car RE)) init final)))
                 ((equal (car (car RE)) '+)
                  (append (list (list init 'epsilon final))
                          (list (list final 'epsilon init))
                          (apply-+ (rest (car RE)) init final)))))
          ((atom (car RE))
           (append (list (list init 'epsilon final))
                   (list (list final 'epsilon init))
                   (apply-atom (car RE) init final)))))


; apply-+(RE initial final)
; Ritorna la lista dell'automa relazivo al simbolo di +.
; Ausiliaria a nfa-regexp-comp(RE)

(defun apply-+ (RE init final)
    (cond ((listp (car RE))
           (cond ((equal (car (car RE)) '[])
                  (append (list (list final 'epsilon init))
                          (apply-[] (rest (car RE)) init  final nil)))
                 ((equal (car (car RE)) '/)
                  (append (list (list final 'epsilon init))
                          (apply-/ (rest (car RE)) init final)))
                 ((equal (car (car RE)) '*)
                  (append (list (list final 'epsilon init))
                          (apply-* (rest (car RE)) init final)))
                 ((equal (car (car RE)) '+)
                  (append (list (list final 'epsilon init))
                          (apply-+ (rest (car RE)) init final)))))
          ((atom (car RE))
           (append (list (list final 'epsilon init))
                   (apply-atom (car RE) init final)))))

; nfa-rec(FA Input)
; True quando l'input per l'automa FA viene consumato copletamente
; e l'automa si trova in uno sato finale. Input è una lista
; di simboli

(defun nfa-rec (FA Input)
  (cond
   ((listp Input)
    (nfa-rec2 (cdr (cdr FA)) () Input (cadr FA) (car FA)))
   (t nil)))


; nfa-rec2(FA Resto Input Finali s)
; Funzione con argomenti anche lo stato attuale e gli stati finali,
; è qui dove viene svolto il "lavoro" di verificare se l'input
; è accettato dall'automa.
; True con stringa vuota e stato finale.
; Ausiliaria a nfa-rec(RE)

(defun nfa-rec2 (FA Resto Input Fin S)
  (cond
   ((and
     (equal S Fin)
     (equal Input ()))
    t)
   ((equal FA ())
    nil)
   ((and
     (equal (car (car FA)) S)
     (equal (cadr (car FA)) (car Input))
     (nfa-rec2 (append Resto FA) () (cdr Input) Fin (cadr (cdr (car FA)))))
    t)
   ((and
     (equal (car (car FA)) S)
     (equal (cadr (car FA)) 'epsilon)
     (cond
      ((equal (car FA) (reverse (cadr FA)))
       (nfa-rec2 (append Resto (cdr FA)) () Input Fin (cadr (cdr (car FA)))))
      (t
       (nfa-rec2 (append Resto FA) () Input Fin (cadr (cdr (car FA)))))))
    t)
   ((nfa-rec2 (cdr FA) (append Resto (list (car FA))) Input Fin S)
    t)))