#lang racket

;; TDE 220121
(define-syntax block
  (syntax-rules (where then <-)
    ((_ (b1 ...) then (b2 ...) where (var <- x y) ...)
      (begin
        (let ((var x) ...)
          b1 ...)
        (let ((var y) ...)
          b2 ...)))))

;; TDE 220706
(define-syntax define-dispatcher
  (syntax-rules (methods: parent:)
    ((_ methods: (m ...) parent: p)
     (lambda (name . args)
       (case name
        ((m) (apply name args)) ...
        (else (apply p (cons name args))))))
    ((_ methods: methods)
     (define-dispatcher
       methods: methods
       parent: (lambda (name . args)
                 (error "Unknown method"))))))

;; Continuations yee
(define (break-negative l)
  (call/cc (lambda (break)
             (for-each
               (lambda (x)
                 (if (< x 0)
                   (break x)
                   (displayln x)))
                l))))

(define (continue-negative l)
  (for-each
    (lambda (x)
      (call/cc (lambda (c)
                 (if (< x 0)
                   (c x)
                   (displayln x)))))
    l))

;; TDE 210714
(define *storage* '())
(define (ret v)
  ((car *storage*) v))

(define-syntax defun
  (syntax-rules ()
    ((_ f (par ...) expr ...)
     (define (fname par ...)
       (let ((out (call/cc (lambda (c)
                    (set! *storage* (cons c *storage*))
                    expr ...))))
         (set! *storage* (cdr *storage*))
         out)))))

