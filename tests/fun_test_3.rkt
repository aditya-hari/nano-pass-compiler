(define (f [a : Integer]
           [b : Integer]
           [c : Integer]
           [d : Integer]
           [e : Integer]
           [f : Integer])
        : Integer
  (begin (set! f 42) (set! e 10) (set! f (+ e f))
         f))

(f 0 0 0 0 0 0)
