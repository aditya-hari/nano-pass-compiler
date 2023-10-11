(let ([x (read)])
    (let ([n 0])
        (begin
            (while (< n x)
                (begin 
                    (set! n (+ 1 n)))) n)))
