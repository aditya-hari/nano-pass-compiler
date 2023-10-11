(let ([v (vector 1 20 30 40 1)])
    (if (> (vector-length v) (read))
        (vector-ref v 2)
        (vector-ref v 1)))