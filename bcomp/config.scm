; Copyright (c) 1993, 1994 Richard Kelsey and Jonathan Rees.  See file COPYING.



; For DEFINE-STRUCTURE macro

(define (make-a-package opens-thunk accesses-thunk for-syntax-thunk
			dir clauses names)
  (make-package opens-thunk accesses-thunk
		;; Pretty much of a kludge
		*evaluator*
		(if for-syntax-thunk
		    (delay (for-syntax-thunk))
		    (*make-package-for-syntax-promise*))
		dir
		clauses
		(if (pair? names)
		    (car names)
		    names)))

(define (init-defpackage! evaluator foo)
  (set! *evaluator* evaluator)
  (set! *make-package-for-syntax-promise* foo))

(define (loser . rest)
  (error "init-defpackage! neglected"))

(define *evaluator* loser)
(define *make-package-for-syntax-promise* loser)

(define interface-of structure-interface)

(define *verify-later!* (lambda (thunk) #f))

(define (verify-later! thunk)
  (*verify-later!* thunk))

(define (set-verify-later! proc)
  (set! *verify-later!* proc))


;(define evaluator-for-syntax-interface
;  (make-simple-interface 'evaluator-for-syntax-interface
;                         (list (list funny-name/evaluator-for-syntax
;                                     syntax-type))))
