; -*- Mode: Scheme; Syntax: Scheme; Package: Scheme; -*-
; Copyright (c) 1993-2004 by Richard Kelsey and Jonathan Rees. See file COPYING.

; Continuations

(define (make-ref index)
  (lambda (c)
    (continuation-ref c index)))

(define continuation-cont          (make-ref continuation-cont-index))
(define real-continuation-code     (make-ref continuation-code-index))
(define real-continuation-pc       (make-ref continuation-pc-index))
(define exception-cont-pc          (make-ref exception-cont-pc-index))
(define exception-cont-code        (make-ref exception-cont-code-index))

; This one is exported
(define exception-continuation-exception
  (make-ref exception-cont-exception-index))

; Exception continuations contain the state of the VM when an exception occured.

(define (exception-continuation? thing)
  (and (continuation? thing)
       (= 11 (real-continuation-pc thing))
       (let ((code (real-continuation-code thing)))
	 (and (= 1				; one return value
		 (code-vector-ref code 12))
	      (= (enum op return-from-exception)
		 (code-vector-ref code 13))))))

(define (call-with-values-continuation? thing)
  (and (continuation? thing)
       (= 11 (real-continuation-pc thing))
       (= call-with-values-protocol
	  (code-vector-ref (real-continuation-code thing)
			   12))))

(define (continuation-pc c)
  (if (exception-continuation? c)
      (exception-cont-pc c)
      (real-continuation-pc c)))

(define (continuation-code c)
  (if (exception-continuation? c)
      (exception-cont-code c)
      (real-continuation-code c)))

; This finds the template if it is in the continuation.  Not all continuations
; have templates.

(define (continuation-template c)
  (if (and (call-with-values-continuation? c)
           (closure? (continuation-arg c 0)))
      (closure-template (continuation-arg c 0))
      (let loop ((i 0))
	(if (= i (continuation-length c))
	    #f
	    (let ((value (continuation-ref c i)))
	      (if (and (template? value)
		       (eq? (template-code value)
			    (continuation-code c)))
		  value
		  (loop (+ i 1))))))))

; Accessing the saved operand stack.

(define (continuation-arg c i)
  (continuation-ref c (+ continuation-cells
			 (if (exception-continuation? c)
			     exception-continuation-cells
			     0)
			 i)))

(define (continuation-arg-count c)
  (- (continuation-length c)
     (+ continuation-cells
	(if (exception-continuation? c)
	    exception-continuation-cells
	    0))))

(define-simple-type :continuation (:value) continuation?)

(define-method &disclose ((obj :continuation))
  (list (if (exception-continuation? obj)
	    'exception-continuation
	    'continuation)
	`(pc ,(continuation-pc obj))
	(let ((template (continuation-template obj)))
	  (if template
	      (template-info template)
	      #f))))
