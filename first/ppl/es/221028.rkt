#lang racket

; We define a way to choose between various continuations with a value. If the
; value obtained is not wanted we use (fail) (basically backtracking)
(define *paths* '())

(define (choose choices)
  (if (null? choices)
    (fail)
    (call/cc (lambda (cc)
               (set! *paths* (cons
                               (lambda ()
                                 (cc (choose (cdr (choices)))))
                               *paths*))
               (car choices)))))

(define fail #f)
(call/cc (lambda (cc)
           (set! fail
             (lambda ()
               (if (null? *paths*)
                 (cc 'failure)
                 (let ((p1 (car *paths*)))
                   (set! *paths* (cdr *paths*))
                   (p1)))))))
; Example usage
(define (is-sum-of n)
  (let* ((L '(0 1 2 3 4 5))
         (x (choose L))
         (y (choose L)))
    (if (= (+ x y) n)
      (list x y)
      (fail))))
; (is-sum-of 7) => '(3 4)
; (fail) => '(4 3)
; (fail) => '(5 2)
; (fail) => 'failure
