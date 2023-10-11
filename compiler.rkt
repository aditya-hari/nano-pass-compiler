#lang racket
(require racket/set racket/stream)
(require racket/fixnum)
(require data/queue)
;(require "interp-Lint.rkt")
;(require "interp-Lvar.rkt")
(require "interp-Lif.rkt")
(require "interp-Cif.rkt")
(require "interp-Lwhile.rkt")
(require "interp-Cwhile.rkt")
(require "interp-Cvec.rkt")
(require "interp-Cfun.rkt")
(require "interp-Lvec.rkt")
(require "interp-Lvec-prime.rkt")
(require "interp-Lfun.rkt")
(require "interp-Lfun-prime.rkt")
(require "type-check-Lif.rkt")
(require "type-check-Lwhile.rkt")
(require "type-check-Lvec.rkt")
(require "type-check-Lfun.rkt")
(require "type-check-Cvec.rkt")
(require "type-check-Cfun.rkt")
(require "utilities.rkt")
(require "interp.rkt")
(require "graph-printing.rkt")
(require "priority_queue.rkt")
(require graph)
(require racket/dict)
(provide (all-defined-out))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Lint examples
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; The following compiler pass is just a silly one that doesn't change
;; anything important, but is nevertheless an example of a pass. It
;; flips the arguments of +. -Jeremy
(define (flip-exp e)
  (match e
    [(Var x) e]
    [(Prim 'read '()) (Prim 'read '())]
    [(Prim '- (list e1)) (Prim '- (list (flip-exp e1)))]
    [(Prim '+ (list e1 e2)) (Prim '+ (list (flip-exp e2) (flip-exp e1)))]))

(define (flip-Lint e)
  (match e
    [(Program info e) (Program info (flip-exp e))]))


;; Next we have the partial evaluation pass described in the book.
;; Bonus 
(define (pe_neg r)
  (match r
  [(Int n) (Int (fx- 0 n))]
  [else (Prim '- (list r))]))

(define (pe_add r1 r2)
  (match* (r1 r2)
  [((Int n1) (Int n2)) (Int (fx+ n1 n2))]
  [(_ _) (Prim '+ (list r1 r2))]))

(define (pe_sub r1 r2)
  (match* (r1 r2)
  [((Int n1) (Int n2)) (Int (fx- n1 n2))]
  [(_ _) (Prim '- (list r1 r2))]))

(define (pe_exp e)
  (match e
  [(Int n) (Int n)]
  [(Var x) (Var x)]
  [(Prim 'read '()) (Prim 'read '())]
  [(Prim '- (list e1)) (pe_neg (pe_exp e1))]
  [(Prim '+ (list e1 e2)) (pe_add (pe_exp e1) (pe_exp e2))]
  [(Prim '- (list e1 e2)) (pe_sub (pe_exp e1) (pe_exp e2))]
  [(Let var rhs body) (Let var (pe_exp rhs) (pe_exp body))]))

(define (pe_Lvar p)
  (match p
  [(Program '() e) (Program '() (pe_exp e))]))

(define (pe-Lint p)
  (match p
    [(Program info e) (Program info (pe_exp e))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; HW1 Passes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define basic-blocks '())
(define num-registers 11)
(define all-registers (set-union callee-save caller-save))

(define (shrink-exp exp)
  (match exp
    [(HasType e t)(HasType (shrink-exp e) t)]
    [(Prim 'vector-ref `(,e,(Int i)))
     (Prim 'vector-ref `(,(shrink-exp e), (Int i)))]
    [(Prim 'vector-set! `(,x,(Int i),y))
     (Prim 'vector-set! `(,(shrink-exp x),(Int i), (shrink-exp y)))]

    [(Prim 'and (list e1 e2)) (If (shrink-exp e1) (shrink-exp e2) (Bool #f))]
    [(Prim 'or (list e1 e2)) (If (shrink-exp e1) (Bool #t) (shrink-exp e2))]
    [(Prim 'not (list e1)) (Prim 'not (list (shrink-exp e1)))]
    [(If e1 e2 e3) (If (shrink-exp e1) (shrink-exp e2) (shrink-exp e3))]
    [(Prim '- (list e1 e2)) (Prim '+ (list (shrink-exp e1) (Prim '- (list (shrink-exp e2)))))]
    [(Prim '> (list e1 e2)) 
      (define temp (gensym))
      (Let temp e1 (Prim '< (list e2 (Var temp))))]
    [(Prim '>= (list e1 e2)) (Prim 'not (list (Prim '< (list e1 e2))))]
    [(Prim '<= (list e1 e2)) (shrink-exp (Prim 'not (list (Prim '> (list e1 e2)))))]
    [(Let var rhs body) (Let var (shrink-exp rhs) (shrink-exp body))]
    [(WhileLoop cnd body) (WhileLoop (shrink-exp cnd) (shrink-exp body))]
    [(Begin es body) (Begin (map shrink-exp es) (shrink-exp body))]
    [(SetBang var rhs) (SetBang var (shrink-exp rhs))]
    ; [(Prim 'eq? (list e1 e2))
    ;   (shrink-exp (Prim 'and (list (Prim '>= (list e1 e2)) (Prim '<= (list e1 e2)))))]
    [else exp]
  )
)

(define (shrink body)
  (match body
    [(ProgramDefsExp info defs ex) 
      (define shrunk-defs
        (for/list ([def defs])
            (match def
              [(Def label params rtype info body)
                (Def label params rtype info (shrink-exp body))]
            )))
      (ProgramDefs info (append shrunk-defs (list (Def 'main '() 'Integer '() (shrink-exp ex)))))]
  )
)

(define (uniquify-exp env)
  (lambda (e)
    (match e
      [(Var x)
       (Var (dict-ref env x))]
      [(Int n) (Int n)]
      [(Let x e body)
       (let* ([x_new (gensym x)]
              [env_new (dict-set env x x_new)])
       (Let x_new ((uniquify-exp env) e) ((uniquify-exp env_new) body)))]
      [(Prim op es)
        (Prim op (for/list ([e es]) ((uniquify-exp env) e)))]
      ; [(Prim op (list exp1 exp2))
      ;   (Prim op (list ((uniquify-exp env) exp1) ((uniquify-exp env) exp2)))]
      ; [(Prim '< (list exp1 exp2))
      ;   (Prim '< (list ((uniquify-exp env) exp1) ((uniquify-exp env) exp2)))]
      ; [(Prim 'eq? (list exp1 exp2))
      ;   (Prim 'eq? (list ((uniquify-exp env) exp1) ((uniquify-exp env) exp2)))]
      ; [(Prim op (list exp1))
      ;   (Prim op (list ((uniquify-exp env) exp1)))]
      [(If cnd then els)
        (If ((uniquify-exp env) cnd) ((uniquify-exp env) then) ((uniquify-exp env) els))]
      [(SetBang x rhs) 
        (SetBang (dict-ref env x) ((uniquify-exp env) rhs))]
      [(Begin es body) (Begin (for/list ([e es]) ((uniquify-exp env) e)) ((uniquify-exp env) body))]
      [(WhileLoop cnd body) (WhileLoop ((uniquify-exp env) cnd) ((uniquify-exp env) body))]
      [(HasType e type) (HasType ((uniquify-exp env) e) type)]
      [(Apply funref args) (Apply ((uniquify-exp env) funref) (map (uniquify-exp env) args))]
      [else e])
  )
)

;; uniquify : R1 -> R1
(define (uniquify p)
  (match p
    [(ProgramDefs info defs) 
      (define func-map
        (for/hash ([def defs])
          (define name (Def-name def))
          (if (eq? name 'main)
            (values 'main 'main)
            (values name (gensym name))
          )
        )
      )
      (ProgramDefs info 
        (for/list ([def defs]) 
          (match def
            [(Def label params rtype info body)
              (define params-map
                (for/fold ([params-map func-map]) ([param (in-dict-keys params)]) (dict-set params-map param (gensym param))))
              (Def (dict-ref func-map label) (for/list ([param params]) (cons (dict-ref params-map (car param)) (cdr param))) rtype info ((uniquify-exp params-map) body))])))]))


; reveal_functions

(define (reveal_functions_body env)
  (lambda (e)
    (match e
      [(Var x) 
        (if (dict-has-key? env x)
          (FunRef x (dict-ref env x))
          e)]
      
      [(Int n) (Int n)]
      [(Let x es body)
       (Let x ((reveal_functions_body env) es) ((reveal_functions_body env) body))]
      [(Prim op es)
        (Prim op (for/list ([e es]) ((reveal_functions_body env) e)))]
      ; [(Prim op (list exp1 exp2))
      ;   (Prim op (list ((uniquify-exp env) exp1) ((uniquify-exp env) exp2)))]
      ; [(Prim '< (list exp1 exp2))
      ;   (Prim '< (list ((uniquify-exp env) exp1) ((uniquify-exp env) exp2)))]
      ; [(Prim 'eq? (list exp1 exp2))
      ;   (Prim 'eq? (list ((uniquify-exp env) exp1) ((uniquify-exp env) exp2)))]
      ; [(Prim op (list exp1))
      ;   (Prim op (list ((uniquify-exp env) exp1)))]
      [(If cnd then els)
        (If ((reveal_functions_body env) cnd) ((reveal_functions_body env) then) ((reveal_functions_body env) els))]
      [(SetBang x rhs) 
        (SetBang x ((reveal_functions_body env) rhs))]
      [(Begin es body) (Begin (for/list ([e es]) ((reveal_functions_body env) e)) ((reveal_functions_body env) body))]
      [(WhileLoop cnd body) (WhileLoop ((reveal_functions_body env) cnd) ((reveal_functions_body env) body))]
      [(HasType e type) (HasType ((reveal_functions_body env) e) type)]
      [(Apply funref args) (Apply ((reveal_functions_body env) funref) (map (reveal_functions_body env) args))]
      [else e]
    )
  )
)

(define (reveal_functions e)
  (match e
    [(ProgramDefs info defs)
      (define env
        (for/hash ([def defs])
          (values (Def-name def) (length (Def-param* def)))
        )
      )
      (ProgramDefs info 
        (for/list ([def defs])
          (match def
            [(Def label params rtype info body)
              (Def label params rtype info ((reveal_functions_body env) body))
            ])))]
  )
)

; limit-functions 
(define (limit-functions-body lim-params tup)
  (lambda (e)
    (match e
      [(Var x) 
        (if (dict-has-key? lim-params x)
          (Prim 'vector-ref (list (Var tup) (Int (dict-ref lim-params x))))
          e)]
      [(SetBang x rhs)
        (if (dict-has-key? lim-params x)
          (Prim 'vector-set! (list (Var tup) (Int (dict-ref lim-params x)) ((limit-functions-body lim-params tup) rhs)))
          e)]
      [(Let x es body)
       (Let x ((limit-functions-body lim-params tup) es) ((limit-functions-body lim-params tup) body))]
      [(Prim op es)
        (Prim op (for/list ([e es]) ((limit-functions-body lim-params tup) e)))]
      [(If cnd then els)
        (If ((limit-functions-body lim-params tup) cnd) ((limit-functions-body lim-params tup) then) ((limit-functions-body lim-params tup) els))]
      [(Begin es body) (Begin (for/list ([e es]) ((limit-functions-body lim-params tup) e)) ((limit-functions-body lim-params tup) body))]
      [(WhileLoop cnd body) (WhileLoop ((limit-functions-body lim-params tup) cnd) ((limit-functions-body lim-params tup) body))]
      [(HasType e type) (HasType ((limit-functions-body lim-params tup) e) type)]
      [(Apply funref args) 
        (if (> (length args) 6)
          (Apply ((limit-functions-body lim-params tup) funref)
            (let ([mapped-args (map (limit-functions-body lim-params tup) args)])
                 (append (take mapped-args 5) (list (Prim 'vector (drop mapped-args 5))))))
          e)]
      [else e]
    )
  )
)

(define (limit-functions-fun e)
  (match e
    [(Def label params rtype info body)
        (define tup-var (gensym 'tup))
        (define reg-params 
          (if (> (length params) 6) 
            (take params 5)
            params))
        
        (define lim-params 
          (if (> (length params) 6) 
            (drop params 5)
            '()))

        (define lim-params-map 
          (for/fold ([types '()]) ([param lim-params] [idx (in-naturals)])
            (append types (list (cons (car param) idx)))
          )
        )
        (define lim-params-type 
          (for/fold ([types '()]) ([param lim-params]) 
            (match param
              [`(,xs : ,ts) (append types (list ts))])))

        (define lim-params-vec 
          (if (> (length lim-params) 0)
            `([,tup-var : (Vector ,@lim-params-type)])
            '()))
        (define new-params (append reg-params lim-params-vec))
        (Def label new-params rtype info ((limit-functions-body lim-params-map tup-var) body))]
  )
)

(define (limit-functions p)
  (match p
    [(ProgramDefs info defs)
      (define new-defs (for/list ([def defs]) (limit-functions-fun def)))
      (ProgramDefs info new-defs)]
  )
)
;;;;;;;;;;;;;;;;
;;expose
;;;;;;;;;;;;;;;;
(define (do-allocate vars vector-name index)
  (if (empty? vars) 
    (Var vector-name)
    (Let (gensym '_) (Prim 'vector-set! (list (Var vector-name) (Int index) (Var (car vars)))) (do-allocate (cdr vars) vector-name (+ 1 index)))
  )
)

(define (do-expose vars exps collect-and-allocate)
  (if (empty? vars) 
    collect-and-allocate
    (Let (car vars) (car exps) (do-expose (cdr vars) (cdr exps) collect-and-allocate)))
)

(define (expose-exp e)
  (match e
    [(Int n) (Int n)]
    [(Var x) (Var x)]
    [(Bool b) (Bool b)]
    [(Void) (Void)]
    [(HasType (Prim 'vector vs) type)
      (define vector-name (gensym 'vec))
      (define vars (for/list ([count (in-range (length vs))]) (gensym 'tmp))) 
      (define exps (for/list ([v vs]) (expose-exp v)))
      (define req-bytes (* 8 (+ 1 (length vs))))
      (define collect-and-allocate
          (Begin (list (If (Prim '< 
            (list (Prim '+ (list (GlobalValue 'free_ptr) (Int req-bytes)))
            (GlobalValue 'fromspace_end)))
              (Void) 
              (Collect req-bytes)))
              (Let vector-name (Allocate (length vars) type) (do-allocate vars vector-name 0)))
      )
      (do-expose vars exps collect-and-allocate)]
    [(Prim op es) (Prim op (for/list ([e es]) (expose-exp e)))]
    [(Let var rhs body) (Let var (expose-exp rhs) (expose-exp body))]
    [(If cnd then els) (If (expose-exp cnd) (expose-exp then) (expose-exp els))]
    [(SetBang var rhs) (SetBang var (expose-exp rhs))]
    [(Begin es body) (Begin (for/list ([e es]) (expose-exp e)) (expose-exp body))]
    [(WhileLoop cnd body) (WhileLoop (expose-exp cnd) (expose-exp body))]
    [(Apply funref args) (Apply (expose-exp funref) (map expose-exp args))]
    [else e]
   )
  )

(define (expose-allocation-fun p)
  (match p
    [(Def label params rtype info body)
      (Def label params rtype info (expose-exp body))]
  )
)

(define (expose-allocation p)
  (match p
    [(ProgramDefs info defs) (ProgramDefs info (map expose-allocation-fun defs))]
  )
)
;; uncover-get!

(define (collect-set! e)
  (match e
    [(Var x) (set)]
    [(Int n) (set)]
    [(Bool b) (set)]
    [(Void) (set)]
    [(Let x rhs body)
      (set-union (collect-set! rhs) (collect-set! body))]
    [(SetBang var rhs)
      (set-union (set var) (collect-set! rhs))]
    [(If cnd exp1 exp2)
      (set-union (collect-set! cnd) (collect-set! exp1) (collect-set! exp2))]
    [(WhileLoop cnd body)
      (set-union (collect-set! cnd) (collect-set! body))]
    [(Begin es body)
      (define collected-sets (map collect-set! es))
      (set-union (foldl set-union (set) collected-sets) (collect-set! body))]
    [(Prim op es)
      (define collected-sets (map collect-set! es))
      (foldl set-union (set) collected-sets)]
    [else (set)]
  )
)

(define ((uncover-get!-exp set!-vars) e)
  (match e
    [(Var x)
      (if (set-member? set!-vars x)
        (GetBang x)
        (Var x))]
    [(Int n) (Int n)]
    [(Bool b) (Bool b)]
    [(Void) (Void)]
    [(Let x rhs body)
      (Let x ((uncover-get!-exp set!-vars) rhs) ((uncover-get!-exp set!-vars) body))]
    [(WhileLoop cnd body)
      (WhileLoop ((uncover-get!-exp set!-vars) cnd) ((uncover-get!-exp set!-vars) body))]
    [(Begin es body)
      (Begin (for/list ([e es]) ((uncover-get!-exp set!-vars) e)) ((uncover-get!-exp set!-vars) body))]
    [(If cnd exp1 exp2)
      (If ((uncover-get!-exp set!-vars) cnd) ((uncover-get!-exp set!-vars) exp1) ((uncover-get!-exp set!-vars) exp2))]
    [(Prim op es)
      (Prim op (for/list ([e es]) ((uncover-get!-exp set!-vars) e)))]
    [(SetBang var rhs) (SetBang var ((uncover-get!-exp set!-vars) rhs))]
    [else e]
  )
)

(define (uncover-get! e)
  (match e
    [(ProgramDefs info defs)
      (ProgramDefs info 
      (for/list ([def defs]) 
        (match def
          [(Def label params rtype info body)
            (define set!-vars (collect-set! body))
            (Def label params rtype info ((uncover-get!-exp set!-vars) body))])))]
  )
)

;; remove-complex-opera* : R1 -> R1

(define (lets exp env)
  (match env
    ['() exp]
    [(cons (list v e) rem)
      (Let v e (lets exp rem))])
)

(define (rco-atom exp)
  (define new-var (gensym))
  (match exp
    [(Int n) (values (Int n) '())]
    [(Var x) (values (Var x) '())]
    [(Bool b) (values (Bool b) '())]

    [(Prim op es) 
      (define-values (new-es env)
        (for/lists (l1 l2) ([e es]) (rco-atom e)))
      (define combined-env (append* env))
      (define new-var (gensym))
      (define new-pair (list new-var (Prim op new-es)))
      (values (Var new-var) (append combined-env (list new-pair)))]
      
    [(Let var rhs body)
      (define-values (atom-exp env) (rco-atom body))
      (define rcoed-rhs (rco-exp rhs))
      (define new-pair (list var rcoed-rhs))
      (values atom-exp (append (list new-pair) env))]

    [(If cond b1 b2)
    ;  (define ccond (rco-exp cond))
    ;  (define bb1 (rco-exp b1))
    ;  (define bb2 (rco-exp b2))
     (define new-pair (list new-var (rco-exp (If cond b1 b2))))
     (values (Var new-var) (list new-pair))]

    [(SetBang var rhs)
      (define new-pair (list new-var (rco-exp (SetBang var rhs))))
      (values (Var new-var) (list new-pair))]

    [(GetBang var) 
      (define new-pair (list new-var (Var var)))
      (values (Var new-var) (list new-pair))]

    [(WhileLoop cnd body)
      (define new-pair (list new-var (rco-exp (WhileLoop cnd body))))
      (values (Var new-var) (list new-pair))]
    
    [(Begin es body)
      (define new-pair (list new-var (rco-exp (Begin es body))))
      (values (Var new-var) (list new-pair))]
    
    [(Collect sz) 
      (define new-pair (list new-var (Collect sz)))
      (values (Var new-var) (list new-pair))]
    
    [(Allocate sz type)
      (define new-pair (list new-var (Allocate sz type)))
      (values (Var new-var) (list new-pair))]
    
    [(GlobalValue name)
      (define new-pair (list new-var (GlobalValue name)))
      (values (Var new-var) (list new-pair))]
    
    [(FunRef label arity)
      (define new-pair (list new-var (FunRef label arity)))
      (values (Var new-var) (list new-pair))]

    [(Apply fun args)
      (define-values (rcoed-fun fun-env) (rco-atom fun))
      (define-values (rcoed-args args-env) 
        (for/lists (l1 l2) ([a args]) (rco-atom a)))
      (define apply-map (list new-var (Apply rcoed-fun rcoed-args)))
      (values (Var new-var) (append fun-env (append* args-env) (list apply-map)))]
  )
)

(define (rco-exp exp)
  (match exp
    [(Int n) (Int n)]
    [(Var x) (Var x)]
    [(Bool b)(Bool b)]
    [(Void) (Void)]
    [(FunRef label arity) (FunRef label arity)]
    [(Prim op es)
      (define-values (new-es env)
        (for/lists (l1 l2) ([e es]) (rco-atom e)))
      (lets (Prim op new-es) (append* env))]
    [(Let var rhs body)
      (Let var (rco-exp rhs) (rco-exp body))]
    [(If cond b1 b2)
     (define ccond (rco-exp cond))
     (define bb1 (rco-exp b1))
     (define bb2 (rco-exp b2))
     (If ccond bb1 bb2)]
    [(SetBang var es)
      (define es1 (rco-exp es))
      (SetBang var es1)]
    [(GetBang var) (Var var)]
    [(WhileLoop cnd es)
      (define ccond (rco-exp cnd))
      (define es1 (rco-exp es))
      (WhileLoop ccond es1)]
    [(Begin es body)
      (Begin (for/list ([e es]) (rco-exp e)) (rco-exp body))]
    [(Apply fun args)
      (define-values (rcoed-fun fun-env) (rco-atom fun))
      (define-values (rcoed-args args-env) 
        (for/lists (l1 l2) ([a args]) (rco-atom a)))
      (lets (Apply rcoed-fun rcoed-args) (append fun-env (append* args-env)))]
    [else exp]
  )
)

(define (remove-complex-opera-fun p)
  (match p
    [(Def label params rtype info body)
      (Def label params rtype info (rco-exp body))]
  )
)

(define (remove-complex-opera* p)
  (match p
    [(ProgramDefs info defs) (ProgramDefs info (map remove-complex-opera-fun defs))])
)

;; explicate-control : R1 -> C0

(define (create_block tail)
  (match tail
    [(Goto label) (Goto label)]
    [else
      (let ([label (gensym 'block)])
      (set! basic-blocks (cons (cons label tail) basic-blocks))
      (Goto label))]
  )
)

(define (explicate-assign e x cont)
  ;;input: exp, tail in cvar, vars
  ;;output: tail in cvar, vaar list = dict  
  (match e
    [(Var n) (values (Seq (Assign x (Var n)) cont) '())]
    [(Int n) (values (Seq (Assign x (Int n)) cont) '())]
    [(Bool b) (values (Seq (Assign x (Bool b)) cont) '())]
    [(Void) (values (Seq (Assign x (Void)) cont) '())]
    [(Let y rhs body)
     (define-values (res-t dicti) (explicate-assign body x cont))
     (define-values (res-a dicti-f) (explicate-assign rhs (Var y) res-t))
     (values res-a (cons y (append dicti dicti-f)))]
    [(Prim op ex) (values (Seq (Assign x (Prim op ex)) cont) '())]
    [(If exp1 exp2 exp3)
      (define-values (exp2-exp exp2-vars) (explicate-assign exp2 x cont))
      (define-values (exp3-exp exp3-vars) (explicate-assign exp3 x cont))
      (define-values (exp1-pred exp1-vars) (explicate-pred exp1 exp2-exp exp3-exp))
      (values exp1-pred (append exp2-vars exp3-vars exp1-vars))]
    [(SetBang var rhs)
      (define-values (cont-exp cont-vars) (explicate-assign (Void) x cont))
      (define-values (rhs-exp rhs-vars) (explicate-assign rhs (Var var) cont-exp))
      (values rhs-exp (append rhs-vars cont-vars))]
    [(Begin es body)
      (define-values (body-exp body-vars) (explicate-assign body x cont))
      (define-values (es-effect es-vars)
        (for/foldr ([cont body-exp] [vars '()]) ([e es])
          (explicate-effect e cont)))
      (values es-effect (append body-vars es-vars))]
    [(WhileLoop cnd body)
      (define-values (cont-exp cont-vars) (explicate-assign (Void) x cont))
      (define label 'loop)
      (define-values (body-effect body-vars) (explicate-effect body (Goto label)))
      (define-values (cnd-pred cnd-vars) (explicate-pred cnd body-effect cont-exp))
      (values (Goto label) (append cont-vars body-vars cnd-vars))]
    [(Apply fun args)
      (values (Seq (Assign x (Call fun args)) cont) '())]
    [else (values (Seq (Assign x e) cont) '())]))

(define (explicate-tail e)
  ;;input:  exp
  ;;output: tail in cvar, var list=dict
  (match e
    [(Var x)(values (Return (Var x)) '())]
    [(Int n)(values (Return (Int n)) '())]
    [(Bool b) (values (Return (Bool b)) '())]
    [(Void) (values (Return (Void)) '())]
    [(Let x rhs body)
     (define-values (res-t dicti) (explicate-tail body))
     (define-values (res-a dicti-f) (explicate-assign rhs (Var x) res-t))
     (values res-a (cons x (append dicti dicti-f)))]
    [(Prim op ex) (values (Return (Prim op ex)) '())]
    [(If exp1 exp2 exp3)
      (define-values (exp2-exp exp2-vars) (explicate-tail exp2))
      (define-values (exp3-exp exp3-vars) (explicate-tail exp3))
      (define-values (exp1-pred exp1-vars) (explicate-pred exp1 exp2-exp exp3-exp))
      (values exp1-pred (append exp2-vars exp3-vars exp1-vars))]
    [(Begin es body)
      (define-values (body-tail body-vars) (explicate-tail body))
      (define-values (es-effect es-vars)
        (for/foldr ([cont body-tail] [vars '()]) ([e es])
          (explicate-effect e cont)))
      (values es-effect (append body-vars (append es-vars)))]
    [(WhileLoop cnd body)
      (define label 'loop)
      (define-values (body-effect body-vars) (explicate-effect body (Goto label)))
      (define-values (cnd-pred cnd-vars) (explicate-pred cnd body-effect (Void)))
      (define tail (Goto label))
      (set! basic-blocks (cons (cons label cnd-pred) basic-blocks))
      (values tail (append body-vars cnd-vars))]
    [(Apply fun args)
      (values (TailCall fun args) '())]
    [else (values (Return e) '())]))

(define (explicate-pred e cont-then cont-else)
    (define cont-then-block (create_block cont-then))
    (define cont-else-block (create_block cont-else))
    (match e
      [(Bool #t) (values cont-then-block '())]
      [(Bool #f) (values cont-else-block '())]
      [(Var v)
        (values (IfStmt (Prim 'eq? (list (Var v) (Bool #t))) cont-then-block cont-else-block) '())]
      [(Prim op (list atm1 atm2)) 
        (values (IfStmt (Prim op (list atm1 atm2)) cont-then-block cont-else-block) '())]
      [(Prim 'not (list atm1))
        (values (IfStmt (Prim 'eq? (list atm1 (Bool #t))) cont-else-block cont-then-block) '())]
      [(If cnd then els)
        (define-values (then-pred then-vars) (explicate-pred then cont-then-block cont-else-block))
        (define-values (els-pred els-vars) (explicate-pred els cont-then-block cont-else-block))
        (define-values (cnd-pred cnd-vars) (explicate-pred cnd then-pred els-pred))
        (values cnd-pred (append then-vars els-vars cnd-vars))]
      [(Let var rhs body)
        (define-values (body-pred body-vars) (explicate-pred body cont-then-block cont-else-block))
        (define-values (rhs-assign rhs-vars) (explicate-assign rhs (Var var) body-pred))
        (values rhs-assign (cons var (append body-vars rhs-vars)))]
      [(Begin es body)
        (define-values (body-tail body-vars) (explicate-tail body))
        (define-values (es-effect es-vars)
        (for/foldr ([cont body-tail]) ([e es])
          (explicate-effect e cont)))
        (values es-effect (append body-vars (append* es-vars)))]
      [(Apply fun args)
        (define temp-var (gensym))
        (explicate-pred (Let temp-var e (Var temp-var)) cont-then cont-else)]
      [else 
        (IfStmt e cont-then-block cont-else-block) '()]
    )
)

(define (explicate-effect e cont)
  (match e
    [(Var x) (values cont '())]
    [(Int n) (values cont '())]
    [(Bool b) (values cont '())]
    [(Void) (values cont '())]
    [(GlobalValue v) (values cont '())]

    [(Prim 'read '()) (values (Seq e cont) '())]
    [(Prim 'vector-set! es) (values (Seq e cont) '())]

    [(Collect sz) (values (Seq e cont) '())]
    [(Allocate sz type) (values (Seq e cont) '())]
    [(Prim op es) (values cont '())]
    [(Let x rhs body)
     (define-values (res-t dicti) (explicate-effect body cont))
     (define-values (res-a dicti-f) (explicate-assign rhs (Var x) res-t))
     (values res-a (cons x (append dicti dicti-f)))]
    [(If cnd then els)
      (define-values (then-effect then-vars) (explicate-effect then cont))
      (define-values (els-effect els-vars) (explicate-effect els cont))
      (define-values (cnd-pred cnd-vars) (explicate-pred cnd then-effect els-effect))
      (values cnd-pred (append then-vars els-vars cnd-vars))]
    [(SetBang var es)
      (explicate-assign es (Var var) cont)]
    [(Begin es body)
      (define-values (body-tail body-vars) (explicate-effect body cont))
      (define-values (es-effect es-vars)
        (for/foldr ([c body-tail] [vars '()]) ([e es])
          (explicate-effect e c)))
      (values es-effect (append body-vars (append es-vars)))]
    [(WhileLoop cnd body)
      (define label (gensym 'loop))
      (define-values (body-effect body-vars) (explicate-effect body (Goto label)))
      (define-values (cnd-pred cnd-vars) (explicate-pred cnd body-effect cont))
      (define tail (Goto label))
      (set! basic-blocks (cons (cons label cnd-pred) basic-blocks))
      (values tail (append body-vars cnd-vars))]
    [(Apply fun args)
      (values (Seq (Call fun args) cont) '())]
  )
)

(define (explicate-control p)
  (match p
    [(ProgramDefs info defs)
      (ProgramDefs info (map explicate-control-def defs))]
  )
)


(define (explicate-control-def p)
  (match p
    [(Def label params rtype info body)
     (set! basic-blocks '())
     (define-values (ctail dicti-tail) (explicate-tail body))
     (Def label params rtype (dict-set #hash() 'locals dicti-tail) (cons (cons (symbol-append label 'start) ctail) basic-blocks))]))


; select-instructions : C0 -> pseudo-x86
(define (calculate-tag types len)
  (define len-tag (arithmetic-shift len 1))
  (define ptr-tag
    (for/fold 
      ([ptr-tag^ 0]) 
      ([t types] [i (in-naturals 7)])
        (match t
          [`(Vector ,T ...) (bitwise-ior ptr-tag^ (arithmetic-shift 1 i))]
          [else (bitwise-ior ptr-tag^ (arithmetic-shift 0 i))]
        )
      )
    )
    (bitwise-ior ptr-tag len-tag 1)
)

(define (select-instructions-atm p)
  (match p 
    [(Var x) (Var x)]
    [(Int n) (Imm n)]
    [(Bool #t) (Imm 1)]
    [(Bool #f) (Imm 0)]
    [(Void) (Imm 0)]
    [(GlobalValue x) (Global x)]
  )
)

(define (select-instructions-stmt p)
  (match p
    [(Prim 'read '())
      (list (Callq 'read_int 0))]

    [(Collect (Int sz))
      (list (Instr 'movq (list (Reg 'r15) (Reg 'rdi)))
            (Instr 'movq (list (Imm sz) (Reg 'rsi)))
            (Callq 'collect 0))]
    
    [(Prim 'vector-set! (list tup (Int index) rhs))
      (list (Instr 'movq (list (select-instructions-atm tup) (Reg 'r11)))
            (Instr 'movq (list (select-instructions-atm rhs) (Deref 'r11 (* 8 (+ 1 index))))))]

    [(Assign (Var x) (Prim '+ (list (Var v) atm))) #:when (equal? v x)
      (list (Instr 'addq (list (select-instructions-atm atm) (Var v))))]
  
    [(Assign (Var x) (Prim '+ (list atm (Var v)))) #:when (equal? v x)
      (list (Instr 'addq (list (select-instructions-atm atm) (Var v))))]

    [(Assign x (Prim '+ (list atm1 atm2)))
      (list (Instr 'movq (list (select-instructions-atm atm1) x))
            (Instr 'addq (list (select-instructions-atm atm2) x)))]

    [(Assign x (Prim '- (list atm1 atm2)))
      (list (Instr 'movq (list (select-instructions-atm atm1) x))
            (Instr 'subq (list (select-instructions-atm atm2) x)))]        

    [(Assign x (Prim '- (list atm)))
      (list (Instr 'movq (list (select-instructions-atm atm) x))
            (Instr 'negq (list x)))]

    [(Assign x (Prim 'not (list (Var v)))) #:when (equal? v x)
      (list (Instr 'xorq (list (Imm 1) (Var v))))]

    [(Assign x (Prim 'not (list atm)))
      (list (Instr 'movq (list (select-instructions-atm atm) x))
            (Instr 'xorq (list (Imm 1) x)))]

    [(Assign x (Prim '< (list atm1 atm2)))
      (list (Instr 'cmpq (list (select-instructions-atm atm2) (select-instructions-atm atm1)))
            (Instr 'set (list 'l (ByteReg 'al)))
            (Instr 'movzbq (list (ByteReg 'al) x)))]

    [(Assign x (Prim 'eq? (list atm1 atm2)))
      (list (Instr 'cmpq (list (select-instructions-atm atm1) (select-instructions-atm atm2)))
            (Instr 'set (list 'e (ByteReg 'al)))
            (Instr 'movzbq (list (ByteReg 'al) x)))]

    [(Assign x (Prim 'read (list)))
      (list (Callq 'read_int 0)
            (Instr 'movq (list (Reg 'rax) x)))]
    
    [(Assign x (Prim 'vector-set! (list tup (Int index) rhs)))
      (list (Instr 'movq (list (select-instructions-atm tup) (Reg 'r11)))
            (Instr 'movq (list (select-instructions-atm rhs) (Deref 'r11 (* 8 (+ 1 index)))))
            (Instr 'movq (list (Imm 0) x)))]

    [(Assign x (Prim 'vector-ref (list tup (Int index))))
      (list (Instr 'movq (list (select-instructions-atm tup) (Reg 'r11)))
            (Instr 'movq (list (Deref 'r11 (* 8 (+ 1 index))) x)))]
    
    [(Assign x (Allocate sz types))
      (define tag (calculate-tag (cdr types) (length (cdr types))))
      (list (Instr 'movq (list (Global 'free_ptr) (Reg 'r11))) 
            (Instr 'addq (list (Imm (* 8 (+ 1 sz))) (Global 'free_ptr))) 
            (Instr 'movq (list (Imm tag) (Deref 'r11 0)))
            (Instr 'movq (list (Reg 'r11) x)))]

    [(Assign x (Prim 'vector-length (list vec)))
     (list (Instr 'movq (list (select-instructions-atm vec) (Reg 'r11))) 
           (Instr 'movq (list (Deref 'r11 0) (Reg 'rax)))
           (Instr 'sarq (list (Imm 1) (Reg 'rax)))
           (Instr 'andq (list (Imm 63) (Reg 'rax)))
           (Instr 'movq (list (Reg 'rax) x)))]

    [(Assign x (FunRef f arity))
      (list (Instr 'leaq (list (Global f) (select-instructions-atm x))))]

    [(Assign x (Call f args))
      (append (for/list ([arg (map select-instructions-atm args)] [reg arg-registers])
                (Instr 'movq (list arg (Reg reg))))
                (list (IndirectCallq f (length args))
                      (Instr 'movq (list (Reg 'rax) x))))]

    [(Call f args)
      (append (for/list ([arg (map select-instructions-atm args)] [reg arg-registers])
                (Instr 'movq (list arg (Reg reg))))
                (list (IndirectCallq f (length args))))]

    [(Collect sz)
       (list (Instr 'movq (list (Reg 'r15) (Reg 'rdi)))
            (Instr 'movq (list (Imm sz) (Reg 'rsi)))
            (Callq 'collect 0))]
    
    [(Assign x y)
      (list (Instr 'movq (list (select-instructions-atm y) x)))]
  )
)

(define (select-instructions-tail name)
  (lambda (p)
  (match p
    [(Seq stmt tail)
      (append (select-instructions-stmt stmt) ((select-instructions-tail name) tail))]
    [(Goto label)
      (list (Jmp label))]
    [(IfStmt (Prim '< (list atm1 atm2)) (Goto label1) (Goto label2))
      (define atm1-new (select-instructions-atm atm1))
      (define atm2-new (select-instructions-atm atm2))
      (list (Instr 'cmpq (list atm2-new atm1-new))
            (JmpIf 'l label1)
            (Jmp label2))]
    [(IfStmt (Prim 'eq? (list atm1 atm2)) (Goto label1) (Goto label2))
      (define atm1-new (select-instructions-atm atm1))
      (define atm2-new (select-instructions-atm atm2))
      (list (Instr 'cmpq (list atm2-new atm1-new))
            (JmpIf 'e label1)
            (Jmp label2))]
    [(IfStmt (Bool #t) (Goto label1) (Goto label2))
      (list (Jmp label1))]
    [(IfStmt (Bool #f) (Goto label1) (Goto label2))
      (list (Jmp label2))]
    [(IfStmt (Prim 'vector-ref (list tup (Int index))) (Goto label1) (Goto label2))
      (list (Instr 'movq (list (select-instructions-atm tup) (Reg 'r11)))
            (Instr 'movq (list (Imm 1) (Reg 'rax)))
            (Instr 'cmpq (list (Deref 'r11 (* 8 (+ 1 index))) (Reg 'rax)))
            (JmpIf 'e label1)
            (Jmp label2))]
    [(TailCall f args)
      (append (for/list ([arg (map select-instructions-atm args)] [reg arg-registers])
        (Instr 'movq (list arg (Reg reg)))) 
        (list (TailJmp f (length args))))]
    [(Return (Prim 'read '()))
      (list (Callq 'read_int 0)
            (Jmp (symbol-append name 'conclusion)))]
    [(Return ex)
      (define return-assign (Assign (Reg 'rax) ex))
      (append (select-instructions-stmt return-assign) (list (Jmp (symbol-append name 'conclusion))))]

    ; [(IfStmt (Prim '< (list atm1 atm2)) (Goto label1) (Goto label2))
    ;   (list (Instr 'cmpq (list (select-instructions-atm atm1) (select-instructions-atm atm2)))
    ;         (JmpIf 'l label1)
    ;         (Jmp label2))]
    ; [(Return (Prim '< (list atm1 atm2)))
    ;   (list (Instr 'cmpq (list (select-instructions-atm atm1) (select-instructions-atm atm2)))
    ;         (Instr 'set (list 'l (Reg 'al)))
    ;         (Instr 'movzbq (list (Reg 'al) (Reg 'rax))))]
    ; [(Return (Prim 'eq? (list atm1 atm2)))
    ;   (list (Instr 'cmpq (list (select-instructions-atm atm1) (select-instructions-atm atm2)))
    ;         (Instr 'set (list 'e (Reg 'al)))
    ;         (Instr 'movzbq (list (Reg 'al) (Reg 'rax))))]
    ; [(Return (Prim 'read '()))
    ;   (list (Callq 'read_int) (Jmp 'conclusion))]
    ; [(Return (Prim '- (list x)))
    ;   (list (Instr 'movq (list (select-instructions-atm x) (Reg 'rax)))
    ;         (Instr 'negq (list (Reg 'rax)))
    ;         (Jmp 'conclusion))]
    ; [(Return (Prim '+ (list atm1 atm2)))
    ;   (list (Instr 'movq (list (select-instructions-atm atm1) (Reg 'rax)))
    ;         (Instr 'addq (list (select-instructions-atm atm2) (Reg 'rax)))
    ;         (Jmp 'conclusion))]
    ; [(Return atm)
    ;   (list (Instr 'movq (list (select-instructions-atm atm) (Reg 'rax)))
    ;         (Jmp 'conclusion))] 
  ))
)

(define (select-instructions-fun p)
  (match p
    [(Def label params rtype info blocks)
      (define pass-params 
        (for/list ([param params] [reg arg-registers]) 
          (Instr 'movq (list (Reg reg) (Var (car param))))))
      (define new-blocks 
        (for/list ([block blocks])
          (cons (car block) (Block '() ((select-instructions-tail label) (cdr block))))))
      (define start-label (symbol-append label 'start))
      (define start-block (dict-ref new-blocks start-label))
      (define new-start-block 
        (match start-block
          [(Block info instrs)
            (Block info (append pass-params instrs))]))
      (define new-local-types
        (for/list ([param params])
          (match param
            [`(,xs : ,ts) (cons xs ts)])))
      (define final-blocks (dict-set new-blocks start-label new-start-block))
      (Def label '() rtype (list (cons 'locals-types (append new-local-types (dict-ref info 'locals-types))) (cons 'num-params (length params))) final-blocks)]
  )
)

(define (select-instructions p)
  (match p 
    [(ProgramDefs info defs)
      (ProgramDefs info (map select-instructions-fun defs))]
      ;; (X86Program info (for/list ([block blocks]) (cons (car block) (Block '() (select-instructions-tail (cdr block))))))]
      ;;(X86Program info (list (cons 'start (Block info (select-instructions-tail instrs)))))])
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;UNCOVER LIVE;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;La(k) = Lb(k+1)
;;La(n)=null
;;Lb(k)=(La(k)-W(k)) U R(k)
; (define (make-cfg start-label g blocks)
;   (define start-block (dict-ref blocks start-label))
;   (match start-block
;     [(Block info instrs)
;       (for ([instr instrs])
;         (match instr
;           [(JmpIf con label) #:when (not (and (eq? label 'conclusion) (has-vertex? ))
;             (add-vertex! g label)
;             (add-directed-edge! g start-label label)
;             (make-cfg label g blocks)]
;           [(Jmp label) #:when (not (eq? label 'conclusion))
;             (add-vertex! g label)
;             (add-directed-edge! g start-label label)
;             (make-cfg label g blocks)]
;           [else 'nothing])
;       )
;     ]
;   )
;   g
; )

; (define (make-cfg-base blocks)
;   (define cfg (directed-graph '()))
;   (add-vertex! cfg 'start)
;   (make-cfg 'start cfg blocks)
; )

(define (make-cfg blocks)
  (define cfg (directed-graph '()))
  (for ([block-label (in-dict-keys blocks)])
    (add-vertex! cfg block-label)
  )
  (for ([block-pair blocks])
    (define block-label (car block-pair))
    (define block (cdr block-pair))
    (define neighbor-blocks (get-neighbor-blocks block))
    (for ([nblock-label neighbor-blocks])
      (add-directed-edge! cfg block-label nblock-label)
    )
  )
  cfg
)

(define (get-neighbor-blocks block)
  (match block
    [(Block info instrs)
      (for/fold ([adj (set)]) ([instr instrs])
        (match instr
          [(Jmp label) #:when (not (string-contains? (~a label) (~a 'conclusion)))
            (set-add adj label)]
          [(JmpIf cnd label) #:when (not (string-contains? (~a label) (~a 'conclusion)))
            (set-add adj label)]
          [else adj]))]))

(define (find-ret b)
  (match b
    [(Var x) (set x)]
    [(Imm i) (set)]
    [(Reg r) (set r)]
    [(ByteReg b) (set (byte-reg->full-reg b))]
    [(Deref reg int) (set reg)]
    [(Global name) (set)]
    [(FunRef f arity) (set)]
    [else (error "Cant find type" b)])
  )

(define (writei inst)
  (match inst
    [(Instr 'movq (list a b)) (find-ret b)]
    [(Instr 'movzbq (list a b)) (find-ret b)]
    [(Callq label i) caller-save]
    [(IndirectCallq arg arity) caller-save]
    [(TailJmp arg arity) caller-save]
    [(Jmp label) (set)]
    [(JmpIf _ _) (set)]
    [(Instr ins arg*) (find-ret (last arg*))]
    [else (error "Cant find instruction type" inst)]
  )
)

(define (readi inst)
  (match inst
    [(Instr 'movq (list a b)) (find-ret a)]
    [(Instr 'movzbq (list a b)) (find-ret a)]
    [(Instr 'negq (list a)) (find-ret a)]
    [(Callq 'collect i) (set 'rsi 'rdi)]
    [(Instr 'set (list _ arg)) (find-ret arg)]
    [(Callq label i) (set)]
    [(Instr 'leaq (list a b)) (find-ret a)]
    [(Jmp label) (set)]
    [(JmpIf _ _) (set)]
    [(IndirectCallq arg arity) (set-union (find-ret arg) (vector->set (vector-take arg-registers arity)))]
    [(TailJmp arg arity) (set-union (set 'rax 'rsp) (find-ret arg) (vector->set (vector-take arg-registers arity)))]
    [(Instr ins arg*) (apply set-union (for/list ([arg arg*]) (find-ret arg)))]
    [else (error "Cant find instruction type" inst)]
  )
)

(define (uncover-live-instr instrs label->live)
  (cond
    [(null? instrs) (list (set))]
    [else 
      (define inst (car instrs))
      (match inst
        [(Jmp label)
          (dict-ref label->live label)]
        [(JmpIf con label)
          (set-union (dict-ref label->live label) (uncover-live-instr (cdr instrs) label->live))]
        [else
          (define rem-live-afters (uncover-live-instr (cdr instrs) label->live))
          (cons (set-union (set-subtract (first rem-live-afters) (writei inst)) (readi inst)) rem-live-afters)]
      )
    ]
  )
)

; (define (uncover-live-block block label->live)
;   (match block
;     [(Block info instrs)
;       (define live-after-list (uncover-live-instr instrs label->live))
;       (values live-after-list (Block (dict-set #hash() 'live live-after-list) instrs))]
;   )
; )

(define (uncover-live-block block label->live)
  (match block
    [(Block info instrs)
      (define live-after-list (uncover-live-instr instrs label->live))
      (values live-after-list (Block (dict-set #hash() 'live live-after-list) instrs))]
  )
)

(define (uncover_live p)
  (match p
    [(ProgramDefs info defs)
      (ProgramDefs info (map uncover-live-fun defs))]
  )
)

(define (uncover-live-fun body)
  (match body
    [(Def label params rtype info blocks)
      (define conclusion (symbol-append label 'conclusion))
      (define G (make-cfg blocks))
      (print-dot G "cfg")
      (define trans-G (transpose G))

      (define new-blocks (make-hash))

      (define label->live (make-hash))
      (dict-set! label->live conclusion (list (set 'rax 'rsp)))

      (for ([block-label (get-vertices trans-G)])
        (dict-set! label->live block-label (list (set))))

      (define worklist (make-queue))
      (for ([v (in-vertices trans-G)])
        (enqueue! worklist v))
      
      (while (not (queue-empty? worklist))
        (define node (dequeue! worklist))

        (define-values (live-afters new-block)
          (uncover-live-block (dict-ref blocks node) label->live))

        (dict-set! new-blocks node new-block)

        (define live-before (first live-afters))        
        (cond [(not (equal? live-before (first (dict-ref label->live node))))
                (dict-set! label->live node (list live-before))
                (for ([v (in-neighbors trans-G node)])
                  (enqueue! worklist v))])
      )
      (Def label params rtype info 
        (for/list ([block-label (get-vertices G)]) 
        (cons block-label (dict-ref new-blocks block-label))))
    ]
  )     
)

; (define (uncover_live body)
;   (match body
;     [(X86Program info blocks)
;       (define g (tsort (transpose (make-cfg-base blocks))))
;       (define label->live (make-hash))
;       (dict-set! label->live 'conclusion (list (set 'rax 'rsp)))
;       (X86Program info (for/list ([block-label g])
;         (define block (dict-ref blocks block-label))
;         (define-values (live-after-list live-after-block) (uncover-live-block block label->live))
;         (dict-set! label->live block-label (list (car live-after-list)))
;         (cons block-label live-after-block)))]
;   )
; )

(define (get-root arg)
  (match arg
    [(Var x) x]
    [(Reg r) r]
    [(Deref r int) r]
    (else arg)
  )
)

(define (is-vector? v locals-types)

  (match (dict-ref locals-types v #f)
    [`(Vector ,T ...) #t]
    [else #f]))

;; interference graph 
(define (build-interference-block block ig local-types)
  (match block
    [(Block info instrs)
      (define live-afters (dict-ref info 'live))

      (for ([la live-afters] [inst instrs])
        (match inst
          [(Instr 'movq (list arg1 arg2))
            (define arg1-root (get-root arg1))
            (define arg2-root (get-root arg2))
            (for ([arg la])
              (cond [(not (or (eq? arg arg1-root) (eq? arg arg2-root))) (add-edge! ig arg arg2-root)]))]
          [(Instr 'movbzq (list (ByteReg b) arg))
            (define arg-root (get-root arg))
            (for ([arg la])
              (cond [(not (eq? (byte-reg->full-reg b) arg-root)) (add-edge! ig arg arg-root)]))]
          [(or (Callq _ _) (IndirectCallq _ _))
              (define write-regs (writei inst))
              (define vector-conflicts (set-union write-regs callee-save))
              (for ([v la])
                (for ([v^ (in-dict-keys local-types)])
                  (cond [(is-vector? v^ local-types) (for ([reg vector-conflicts]) (add-edge! ig v^ reg))]
                        [else (for ([reg write-regs]) (add-edge! ig v^ reg))])))]
          [(JmpIf cnd label) 'nothing]
          [(Jmp label) 'nothing]
          [else 
            (define writes (writei inst))
            (for ([d writes]) (for ([v la])
              (cond [(not (eq? d v)) (add-edge! ig d v)])))]
        ))]
  )
  ig
)

(define (build-interference-blocks blocks info)
  (define ig (undirected-graph '()))
  (define local-types (dict-ref info 'locals-types))
  (define locals (for/list ([l local-types]) (car l)))
  (for ([l locals]) (add-vertex! ig l))
  (for ([block blocks])
    (set! ig (build-interference-block (cdr block) ig local-types))
  )
  ig
)

(define (build_interference p)
  (match p
    [(ProgramDefs info defs)
      (ProgramDefs info (map build_interference_fun defs))])
)

(define (build_interference_fun p)
  (match p
    [(Def label params rtype info blocks)
      (define g (build-interference-blocks blocks info))
      (print-dot g "ig")
      (Def label params rtype (dict-set info 'conflicts g) blocks)]
  )
)

(define (choose-colour node unavail)
  (for/first ([n (in-naturals)] 
    #:when (not (set-member? unavail n)))
    n
  )
)

(define (colour-graph g)
  (define cmap (make-hash))

  (define regs-in-graph (set-intersect (list->set (get-vertices g)) all-registers))
  (for ([reg regs-in-graph]) 
    (dict-set! cmap reg (register->color reg))
  )

  (define saturation (make-hash))
  (define pqmap (make-hash))

  (define (compare node1 node2)
    (>= (set-count (dict-ref saturation node1)) (set-count (dict-ref saturation node2)))
  )
  (define pq (make-pqueue compare))

  (for ([node (get-vertices g)])
    (define ns (get-neighbors g node))
    (define adj-coloured-nodes (filter (lambda (n) (dict-has-key? cmap n)) ns))
    (define adj-colours (list->set (map (lambda (n) (dict-ref cmap n)) adj-coloured-nodes)))
    (dict-set! saturation node adj-colours)
    (cond 
      [(not (dict-has-key? cmap node)) (dict-set! pqmap node (pqueue-push! pq node))]
    )
  )

  (while ( > (pqueue-count pq) 0)
    (define node (pqueue-pop! pq))
    (define colour (choose-colour node (dict-ref saturation node)))
    (dict-set! cmap node colour)
    (for ([neigh (get-neighbors g node)])
      (dict-set! saturation neigh (set-add (dict-ref saturation neigh) colour))
      (pqueue-decrease-key! pq (dict-ref pqmap node))
    )
  )
  cmap
)

(define (allocate_registers_fun p)
  (match p
    [(Def label params rtype info blocks)
      (define local-types (dict-ref info 'locals-types))
      (define cmap (colour-graph (dict-ref info 'conflicts)))
      
      (define reg-vars-pairs (filter (lambda (var) (<= (dict-ref cmap (car var)) (- num-registers 1))) local-types))
      (define spill-vars-pairs (filter (lambda (var) (and (not (is-vector? var local-types)) (> (dict-ref cmap (car var)) (- num-registers 1)))) local-types))
      (define root-spill-vars-pairs (filter (lambda (var) (and (is-vector? var local-types) (> (dict-ref cmap (car var)) (- num-registers 1)))) local-types))

      (define reg-vars (for/list ([pair reg-vars-pairs]) (car pair)))
      (define spill-vars (for/list ([pair spill-vars-pairs]) (car pair)))
      (define root-spill-vars (for/list ([pair root-spill-vars-pairs]) (car pair)))

      (define reg-vars-map (for/list ([i reg-vars]) (cons i (Reg (color->register (dict-ref cmap i))))))
      (define regs-used (list->set (for/list ([i reg-vars]) (color->register (dict-ref cmap i)))))
      (define callee-used (set->list (set-intersect callee-save regs-used)))

      (define spill-vars-map (for/list ([i spill-vars] [j (in-naturals (+ 1 (length callee-used)))]) (cons i (Deref 'rbp (* j -8)))))
      (define root-spill-vars-map (for/list ([i root-spill-vars] [j (in-naturals)]) (cons i (Deref 'r15 (* j  8)))))

      (define var-map (append spill-vars-map reg-vars-map root-spill-vars-map))
      (define spill-count (length spill-vars))
      (define root-spill-count (length root-spill-vars))

      (Def label params rtype (list (cons 'num-params (dict-ref info 'num-params)) (cons 'spill spill-count) (cons 'num-root-spills root-spill-count) (cons 'callee callee-used)) (for/list ([block blocks]) (cons (car block) (assign-homes-block (cdr block) var-map))))
    ]
  )
)

(define (allocate_registers p)
  (match p
    [(ProgramDefs info defs)
      (ProgramDefs info (map allocate_registers_fun defs))]
  )
)

;; assign-homes : pseudo-x86 -> pseudo-x86
(define (assign-home-instrs instr var-map)
  (match instr
    [(Instr op (list (Var x)))
      (Instr op (list (dict-ref var-map x)))]
    [(Instr op (list (Var x) (Var y)))
      (Instr op (list (dict-ref var-map x) (dict-ref var-map y)))]
    [(Instr op (list not-var (Var y)))
      (Instr op (list not-var (dict-ref var-map y)))]
    [(Instr op (list (Var x) not-var))
      (Instr op (list (dict-ref var-map x) not-var))]
    [(TailJmp (Var x) arity)
      (TailJmp (dict-ref var-map x) arity)]
    [(IndirectCallq (Var x) arity)
      (IndirectCallq (dict-ref var-map x) arity)]
    [else instr])
)

(define (assign-homes-block block var-map)
  (match block
    [(Block info instrs)
      (Block '() (for/list ([instr instrs]) (assign-home-instrs instr var-map)))])
)

; (define (assign-homes p)
;   (match p
;     [(X86Program info blocks)
;       (X86Program info (for/list ([block blocks]) (cons (car block) (assign-homes-block (cdr block) var-map))))])
; )

;; patch-instructions : psuedo-x86 -> x86

;;;;;;;;;;;;;;;PATCH;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (patch-instructions-instr instr)
  (match instr
    [(Instr 'leaq (list arg1 (Deref reg int)))
      (list (Instr 'leaq (list arg1 (Reg 'rax)))
            (Instr 'movq (list (Reg 'rax) (Deref reg int))))]
    [(Instr 'leaq (list arg1 (Global val)))
      (list (Instr 'leaq (list arg1 (Reg 'rax)))
            (Instr 'movq (list (Reg 'rax) (Global val))))]
    [(Instr op (list (Deref reg1 int1) (Deref reg2 int2)))
      (list (Instr 'movq (list (Deref reg1 int1) (Reg 'rax)))
            (Instr op (list (Reg 'rax) (Deref reg2 int2))))]
    [(Instr op (list (Global val) (Deref reg int)))
      (list (Instr 'movq (list (Deref reg int) (Reg 'rax)))
            (Instr  op (list (Reg 'rax) (Global val))))]
    ; [(Instr op (list (Deref reg int) (Global val)))
    ;   (list (Instr 'movq (list (Global val) (Reg 'rax)))
    ;         (Instr  op (list (Reg 'rax) (Deref reg int))))]
    [(Instr 'cmpq (list arg1 (Imm n)))
     (list (Instr 'movq (list (Imm n) (Reg 'rax)))
           (Instr 'cmpq (list arg1 (Reg 'rax))))]
    [(Instr 'movzbq (list arg1 (Imm n)))
         (list (Instr 'movq (list (Imm n) (Reg 'rax)))
               (Instr 'mvzbq (list arg1 (Reg 'rax))))]
    [(Instr 'movq (list (Reg arg1) (Reg arg2))) #:when (eq? arg1 arg2) (list)]
    [(TailJmp arg arity)
      #:when (not (eq? (get-root arg) 'rax))
      (list (Instr 'movq (list arg (Reg 'rax)))
            (TailJmp (Reg 'rax) arity))]
    [else (list instr)])
)

(define (patch-instructions-block blk)
  (match blk
    [(Block info instrs)
      (Block info (foldr (lambda (instr combined) (append (patch-instructions-instr instr) combined)) '() instrs))])
)

(define (patch-instructions-fun p)
  (match p
    [(Def label params rtype info blocks)
      (Def label params rtype info (for/list ([block blocks]) (cons (car block) (patch-instructions-block (cdr block)))))])
)

(define (patch-instructions p)
  (match p
    [(ProgramDefs info defs) (ProgramDefs info (map patch-instructions-fun defs))]
  )
)


; ;; prelude-and-conclusion : x86 -> x86
(define (get-nearest-16 n)
  (cond
    [(equal? (modulo n 16) 0) n]
    [else (get-nearest-16 (+ 1 n))]
  )
)

(define (get-prec info label)
  (define start-label (symbol-append label 'start))
  (define num-spill (dict-ref info 'spill))
  (define callee-used (dict-ref info 'callee))
  (define root-spill-count (dict-ref info 'num-root-spills))
  
  (define offset-val (- (get-nearest-16 (* 8 (+ num-spill (length callee-used)))) (* 8 (length callee-used))))  
  ;; (define offset-val (get-nearest-16 (* 8 (+ num-spill (length callee-used)))))  
  (define vec-stuff (append (list (Instr 'movq (list (Imm 16384) (Reg 'rdi)))
                                  (Instr 'movq (list (Imm 16384) (Reg 'rsi)))
                                  (Callq 'initialize 0)
                                  (Instr 'movq (list (Global 'rootstack_begin) (Reg 'r15))))
                                  (for/list ([i (in-range root-spill-count)]) (Instr 'movq (list (Imm 0) (Deref 'r15 (* 8 i)))))
                                  (list (Instr 'addq (list (Imm (* 8 root-spill-count)) (Reg 'r15))))))
  (define callee-pushes 
    (if (eq? label 'main)
      (append (for/list ([reg callee-used]) (Instr 'pushq (list (Reg reg)))) vec-stuff)
      (for/list ([reg callee-used]) (Instr 'pushq (list (Reg reg))))))

  (define start (append (list (Instr 'pushq (list (Reg 'rbp))) (Instr 'movq (list (Reg 'rsp) (Reg 'rbp))) (Instr 'subq (list (Imm offset-val) (Reg 'rsp)))) callee-pushes))

  (values label (Block '() (append start
                            (list 
                            (Jmp start-label)))))
)

(define (get-conc-instrs info)
  (define num-spill (dict-ref info 'spill))
  (define rev-callee-used (reverse (dict-ref info 'callee)))
  (define root-spill-count (dict-ref info 'num-root-spills))

  (define offset-val (- (get-nearest-16 (* 8 (+ num-spill (length rev-callee-used)))) (* 8 (length rev-callee-used)))) 
  ;; (define offset-val (get-nearest-16 (* 8 (+ num-spill (length rev-callee-used)))))  
  (define callee-pops (for/list ([reg rev-callee-used]) (Instr 'popq (list (Reg reg)))))

  (define start (append (list (Instr 'addq (list (Imm offset-val) (Reg 'rsp)))) callee-pops))
  (define vec-stuff (append (list (Instr 'subq (list (Imm (* 8 root-spill-count)) (Reg 'r15)))) start))

  (append vec-stuff (list (Instr 'popq (list (Reg 'rbp)))))
)

(define (get-conc info label)
  (define conclusion-label (symbol-append label 'conclusion))
  (values conclusion-label (Block '() (append (get-conc-instrs info) (list (Retq)))))
)

(define (get-start block)
  (match block
    ([Block info instrs] instrs)
    (else "error: This should not happen")
  )
)

(define (prelude-and-conclusion-fun p)
  (match p
    [(Def label params rtype info blocks)
      (define-values (prel-label prel-instrs) (get-prec info label))
      (define-values (conc-label conc-instrs) (get-conc info label))
      (define new-blocks
        (for/list ([block blocks])
          (match (cdr block)
            [(Block info_ instrs)
              (cons (car block) (Block info_
                (append* 
                  (for/list ([inst instrs])
                    (match inst
                      [(TailJmp arg arity)
                        (append (get-conc-instrs info) (list (IndirectJmp arg)))]
                      [else (list inst)])))))])))
      (define prelude_block (cons (cons prel-label prel-instrs) new-blocks))
      (define conc_block (cons (cons conc-label conc-instrs) prelude_block))
      (Def label params rtype info conc_block)]
    [else "error: prelude_conclusion incorrect format."]
  )
)

(define (prelude-and-conclusion p)
  (match p
    [(ProgramDefs info defs)
      (define new-defs (map prelude-and-conclusion-fun defs))
      (X86Program info (append-map Def-body new-defs))]
  )
)


;; Define the compiler passes to be used by interp-tests and the grader
;; Note that your compiler file (the file that defines the passes)
;; must be named "compiler.rkt"
(define compiler-passes
  `( ("shrink", shrink, interp-Lfun, type-check-Lfun)
     ;; ("partial eval", pe_Lvar, interp-Lvar)
     ("uniquify", uniquify, interp-Lfun, type-check-Lfun)
     ("reveal functions", reveal_functions, interp-Lfun-prime, type-check-Lfun)
     ("limit functions" ,limit-functions ,interp-Lfun-prime ,type-check-Lfun)
     ("expose allocation", expose-allocation, interp-Lfun-prime, type-check-Lfun)
     ("uncover-get!", uncover-get!, interp-Lfun-prime, type-check-Lfun)
    ; ;  ;; Uncomment the following passes as you finish them.
     ("remove complex opera*", remove-complex-opera*, interp-Lfun-prime, type-check-Lfun)
     ("explicate control", explicate-control, interp-Cfun ,type-check-Cfun)
     ("instruction selection" ,select-instructions , interp-pseudo-x86-3)
     ("uncover live", uncover_live, interp-pseudo-x86-3)
     ("build interference", build_interference, interp-pseudo-x86-3)
     ("allocate register", allocate_registers, interp-x86-3)
    ;  ;; ("assign homes" ,assign-homes ,interp-x86-0)
     ("patch instructions" ,patch-instructions ,interp-x86-3)
     ("prelude-and-conclusion" ,prelude-and-conclusion , #f)
     ))

