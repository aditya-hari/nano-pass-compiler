;; rco 1
(if (and (> (let ([x (read)]) x) 5) (eq? (let ([y (read)]) (+ y 5)) 10)) 5 10)