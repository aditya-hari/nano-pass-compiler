;; rco - 2
(if (not (or (> (let ([x (read)]) x) 5) (eq? (let ([y (read)]) (+ y 5)) 10))) 5 10)