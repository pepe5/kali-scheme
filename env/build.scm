; Copyright (c) 1993 by Richard Kelsey and Jonathan Rees.  See file COPYING.


; Commands for writing images.

; A heap image written using ,dump or ,build can be invoked with
;    s48 -i <filename> [-h <heap size>] [-a <argument>]
; For images made with ,build <exp> <filename>, <argument> is passed as
; a string to the procedure that is the result of <exp>.


; dump <filename>

(define-command-syntax 'dump "<filename>" "write a heap image"
  '(filename &opt form))

(define (dump filename . maybe-info)
  (let ((info (if (null? maybe-info) "(suspended image)" (car maybe-info)))
	(context (user-context))
	(env (environment-for-commands)))
    (build-image (lambda (arg)
		   (start-command-processor arg
					    context
					    env
					    (lambda () (greet-user info))))
		 filename)))

; build <exp> <filename>

(define-command-syntax 'build "<exp> <filename>" "application builder"
  '(expression filename))

(define (build exp filename)
  (build-image (evaluate exp (environment-for-commands)) filename))

; build-image

(define (build-image start filename)
  (let ((filename (translate filename)))
    (write-line (string-append "Writing " filename) (command-output))
    (flush-the-symbol-table!)	;Gets restored at next use of string->symbol
    (write-image filename
		 (stand-alone-resumer start)
		 "")
    #t))

(define (stand-alone-resumer start)
  (usual-resumer  ;sets up exceptions, interrupts, and current input & output
   (lambda (arg)
     (call-with-current-continuation
       (lambda (halt)
	 (with-handler (simple-condition-handler halt (current-output-port))
	   (lambda ()
	     (start arg))))))))

; Simple condition handler for stand-alone programs.

(define (simple-condition-handler halt port)
  (lambda (c punt)
    (cond ((error? c)
	   (display-condition c port)
	   (halt 1))
	  ((warning? c)
	   (display-condition c port))		;Proceed
	  ((interrupt? c)
	   ;; (and ... (= (cadr c) interrupt/keyboard)) ?
	   (halt 2))
	  (else
	   (punt)))))

;(define interrupt/keyboard (enum interrupt keyboard))
