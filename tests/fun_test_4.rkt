(define (f1 [f : (Integer -> Integer)]) : Integer
    (f 5)
)

(define (f [x : Integer]) : Integer
    (+ x 10)
)

(f1 f)