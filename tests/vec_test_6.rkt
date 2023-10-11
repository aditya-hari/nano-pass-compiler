(let ([v (vector 1 20 30 40 1)])
    (begin 
        (vector-set! v 4 (read))
        (+ (vector-ref v 4) (vector-ref v 4))))