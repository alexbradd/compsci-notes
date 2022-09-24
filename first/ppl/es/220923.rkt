#lang racket

(define (len x)
  (define (len-int x i)
    (if (null? x)
      i
      (len-int (cdr x) (+ 1 i))))
  (len-int x 0))

;; Not tail recursive, but more efficient
(define (prefix n L)
  (if (= n 0)
    '()
    (cons (car L) (prefix (- n 1) (cdr L)))))

;; Tail recursive, but less efficient
;; (define (prefix n L)
;;   (define (p n L a)
;;     (if (= n 0)
;;       a
;;       (p (- n 1) (cdr L) (append a (list (car L))))))
;;   (p n L '()))

(define (ref k L)
  (if (= k 0)
    (car L)
    (ref (- 1 k) (cdr L))))

(define (ran s . e)
  (define (r s e)
    (if (= s e)
      (list s)
      (cons s (r (+ s 1) e))))
  (if (null? e)
    (r 0 s)
    (r s (car e))))

; Tip: use lambdas to prevent evaluation (thunks)
(define (while c b)
  (when (c)
    (b)
    (while c b)))

;; (define (test-while)
;;   (define x 0)
;;   (while (lambda () (< x 10))
;;          (lambda () (displayln x) (set! x (+ x 1)))))

;; Quadratic, can we try and make it linear?
;; (define (tsil l)
;;   (if (null? l)
;;     '()
;;     (append (tsil (cdr l)) (list (car l)))))

;; Linear and tail recursive reverse
(define (tsil l)
  (define (int l acc)
    (if (null? l)
      acc
      (int (cdr l) (cons (car l) acc))))
  (int l '()))
(tsil '(1 2 3 4 5 6))

(define (flat L)
  (if (null? L)
    '()
    (append
      (if (list? (car L))
          (flat (car L))
          (list (car L)))
      (flat (cdr L)))))

;; (flat '(1 (2 (3 4) (4 5)) (4 5)))

