(let ([v (vector 30)])
    (let ([x (vector 10)])
        (begin (set! x (vector 12)) (+ (vector-ref x 0) (vector-ref v 0)))))