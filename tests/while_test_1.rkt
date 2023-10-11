(let ([x 2])
    (let ([y 0])
        (+ y (+ x (begin (set! x 40) (set! y 10) (set! x y) x)))))