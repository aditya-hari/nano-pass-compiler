;; explicate - 2
(let ([x 17]) (+ (+ 29 (let([y (let ([x 8]) (+ x 12))]) y)) x))