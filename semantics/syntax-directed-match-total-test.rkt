#lang racket

(require "shared-test-cases.rkt"
         "common.rkt"
         "syntax-directed-match-total.rkt"
         rackunit)

(define test-syntax-directed-total
  (match-lambda
    [(test:match _ G p t)
     (not (empty? (matches G p t)))]
    [(test:no-match _ G p t)
     (empty? (matches G p t))]
    [(test:bind _ G p t bs)
     (equal-bindings? (map raw-bindings (matches G p t)) bs)]))

(run-tests test-syntax-directed-total)

(let ([W? (λ (t)
            (not
             (empty?
              (matches '([W (:hole (:in-hole (:nt W) (:cons :hole 1)))])
                       '(:nt W)
                       t))))])
  (check-true (W? ':hole))
  (check-true (W? '(:cons :hole 1)))
  (check-true (W? '(:cons (:cons :hole 1) 1)))
  (check-false (W? '(:cons 1 (:cons :hole 1)))))

(let ([A? (λ (t)
            (not
             (empty?
              (matches '([L (:hole (:in-hole (:cons (:nt L) e) (:cons λ :hole)))]
                         [A (:hole (:in-hole (:nt L) (:nt A)))])
                       '(:nt A)
                       t))))])
  (check-true (A? ':hole))
  (check-true (A? '(:cons (:cons (:cons λ (:cons λ :hole)) e) e)))
  (check-false (A? '(:cons (:cons (:cons λ :hole) e) e)))
  (check-false (A? '(:cons (:cons λ (:cons λ :hole)) e)))
  (check-true (A? '(:cons (:cons λ (:cons (:cons (:cons λ (:cons λ :hole)) e) e)) e)))
  (check-false (A? '(:cons (:cons λ (:cons (:cons λ (:cons λ :hole)) e)) e)))
  (check-false (A? '(:cons (:cons (:cons λ (:cons (:cons λ (:cons λ :hole)) e)) e) e))))

(check-equal? (grammar-keywords '([n (a 1)] [m (a b)]))
              (set 'a 'b))
(check-equal? (matches '([n (a)]) ':variable 'a)
              '())
(check-equal? (matches '([n (a)]) ':variable 'b)
              '((set)))

(check-equal? (matches '() ':number 7.5) '((set)))