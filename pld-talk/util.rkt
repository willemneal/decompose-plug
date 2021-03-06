#lang racket/base
(require slideshow
         redex
         "../2-models/util.rkt")
(provide pat lesson render-sexp scale-up define-from over-there)

(define to-orig-param (make-channel))

(define orig-param-thread
  (thread
   (λ ()
     (let loop ()
       (define l (channel-get to-orig-param))
       (channel-put (list-ref l 0) ((list-ref l 1)))
       (loop)))))

(define-syntax-rule
  (define-from id file)
  (define id (over-there (λ () (dynamic-require file 'id)))))

(define (over-there thunk) 
  (define c (make-channel))
  (channel-put to-orig-param (list c thunk))
  (channel-get c))

(literal-style "Inconsolata")
(non-terminal-style (literal-style))
(default-style (literal-style))
(non-terminal-subscript-style '(subscript . "Inconsolata"))

(default-font-size 55)
(label-font-size (default-font-size))
(metafunction-font-size (default-font-size))


(define-syntax-rule (pat arg)
  (rr arg))

(define (lesson . args)
  (define p 
    (inset (colorize (ht-append (scale/improve-new-text (bt "Lesson: ") 2)
                                (apply para #:width 400 #:fill? #f args))
                     "white")
           20 10))
  (slide 
   (cc-superimpose
    (colorize (filled-rectangle (pict-width p) (pict-height p))
              "black")
    p)))

(define (render-sexp sexp)
  (define fixed-hole
    (let loop ([sexp sexp])
      (cond
        [(equal? sexp (term hole)) 'hole]
        [(pair? sexp) (cons (loop (car sexp)) (loop (cdr sexp)))]
        [else sexp])))
  (define p (open-input-string (format "~s" fixed-hole)))
  (port-count-lines! p)
  (lw->pict typesetting-lang (to-lw/stx (read-syntax #f p))))

(define (scale-up p)
  (scale p (min (/ client-w (pict-width p))
                (/ client-h (pict-height p)))))