#lang racket
; We want to define a ++ operator. Using a function does not work since `x` must
; be evaluated
;
; (define (++ x) (set! x (+ 1 x)))
; (display (++
;            (begin
;               (display "bbb")
;               (newline)
;               x)))
(define x 10)
(define-syntax ++
  (syntax-rules ()
    ((_ var)
     (begin
       (set! var (+ var 1))))))

;;;;;;;;;
; We want to define a construct that returns the n-th element in its invocation
; e.g. `(proj 2 v1 v2 v3) -> v2`
(define-syntax proj
  (syntax-rules ()
    ((_ n e1) e1)
    ((_ n e1 e2 ...)
     (if (= n 0)
       e1
       (proj (- n 1) e2 ...)))))

;;;;;;;;;
; Define the construct define-with-types, that is used to define a procedure with
; type constraints, both for the parameters and for the return value. The type
; constraints are the corresponding type predicates, e.g. number? to check if a
; value is a number.
; If the type constraints are violated, an error should be issued.

(define-syntax define-with-types
  (syntax-rules (:)
    ((_ (f : tf (x1 : t1) ...) e1 ...)
     (define (f x1 ...)
       (if (and (t1 x1) ...)
           (let ((res (begin
                        e1 ...)))
             (if (tf res)
                 res
                 (error "bad return type")))
           (error "bad input types"))))))

(define-with-types (add-to-char : integer? (x : integer?) (y : char?))
  (+ x (char->integer y)))
