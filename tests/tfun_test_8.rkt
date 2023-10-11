(define (multiply [a : Integer] [b : Integer]) : Integer 
  (let ([x a])
    (begin 
      (while (> b 1)
        (begin 
        (set! x (+ x a))
        (set! b (- b 1))))
      x)))
(multiply 4 5)