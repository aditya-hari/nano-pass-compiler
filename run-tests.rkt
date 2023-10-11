#! /usr/bin/env racket
#lang racket

(require "utilities.rkt")
(require "interp-Lvar.rkt")
(require "interp-Cvar.rkt")
(require "interp-Lif.rkt")
(require "interp-Lvar.rkt")
(require "interp-Lwhile.rkt")
(require "interp-Lvec.rkt")
(require "interp-Lfun.rkt")
(require "type-check-Lif.rkt")
(require "type-check-Lwhile.rkt")
(require "type-check-Lvec.rkt")
(require "type-check-Lfun.rkt")
(require "interp.rkt")
(require "compiler.rkt")
(debug-level 1)
(AST-output-syntax 'concrete-syntax)

;; all the files in the tests/ directory with extension ".rkt".
(define all-tests
  (map (lambda (p) (car (string-split (path->string p) ".")))
       (filter (lambda (p)
                 (string=? (cadr (string-split (path->string p) ".")) "rkt"))
               (directory-list (build-path (current-directory) "tests")))))

(define (tests-for r)
  (map (lambda (p)
         (caddr (string-split p "_")))
       (filter
        (lambda (p)
          (string=? r (car (string-split p "_"))))
        all-tests)))

;; (interp-tests "var" #f compiler-passes interp-Lvar "var_test" (tests-for "var"))

;; Uncomment the following when all the passes are complete to
;; test the final x86 code.
; (compiler-tests "var" type-check-Lfun compiler-passes "var_test" (tests-for "var"))

;(interp-tests "cond" #f compiler-passes interp-Lif "cond_test" (tests-for "cond"))
; (compiler-tests "cond" type-check-Lfun compiler-passes "cond_test" (tests-for "cond"))

;(interp-tests "while" #f compiler-passes interp-Lwhile "while_test" (tests-for "while"))
; (compiler-tests "while" type-check-Lfun compiler-passes "while_test" (tests-for "while"))

; (interp-tests "vec" #f compiler-passes interp-Lvec "vec_test" (tests-for "vec"))
; (compiler-tests "vec" type-check-Lfun compiler-passes "vec_test" (tests-for "vec"))

; (interp-tests "fun" #f compiler-passes interp-Lfun "fun_test" (tests-for "fun"))
(compiler-tests "tfun" type-check-Lfun compiler-passes "tfun_test" (tests-for "tfun"))
