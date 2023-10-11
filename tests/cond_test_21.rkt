;; type-check 7
(let ([y (read)]) (if (let ([x (read)]) (> x 15)) (+ y 5) y))