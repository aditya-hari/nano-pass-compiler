(define (is10 [x : Integer]) : Integer
    (if (eq? x 10) x
        (if (< x 10)
            (is10 (+ x 1))
            (is10 (- x 1)))))

(is10 15)