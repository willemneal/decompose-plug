#lang racket

(require "syntax-directed-match.rkt"
         "shared-test-cases.rkt"
         redex)

(define test-syntax-directed
  (match-lambda
    [(test:match _ L p t)
     (not (empty? (term (matches ,L ,p ,t))))]
    [(test:no-match _ L p t)
     (empty? (term (matches ,L ,p ,t)))]
    [(test:bind _ L p t bs)
     (equal-bindings? (term (matches ,L ,p ,t)) bs)]))

(run-tests test-syntax-directed)