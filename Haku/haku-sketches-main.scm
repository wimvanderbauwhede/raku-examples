#lang racket
(define (f x) (* x (+ x 1)))

(define (本)
  (displayln (f 6))
  (displayln (g 6 7))
  )

(define (g x y) (+ 1 (* x y)))

(本)

