; Copyright (c) 1993-2004 by Richard Kelsey and Jonathan Rees. See file COPYING.

; Tests for many of the primitives, both inlined and close-compiled.

; This prints `Hello' three times and then the first command argument, if any,
; and finally reads a line from standard input and prints it to standard output.

(define (start arg in out error-out)
  (call-with-values
    (lambda ()
      (values "H" "e" "ll" "o" " "))
    (lambda (h e ll o sp)
      (write-string h out)
      (write-string e out)
      (write-string ll out)
      (write-string o out)
      (write-string sp out)))
  (call-with-values
    (lambda ()
      (apply values "H" "e" '("ll" "o" " ")))
    (lambda (h e ll o sp)
      (write-string h out)
      (write-string e out)
      (write-string ll out)
      (write-string o out)
      (write-string sp out)))
  (call-with-values
    (lambda ()
      (values "H" "e" "ll" "o" " "))
    (lambda (h e . more)
      (write-string h out)
      (write-string e out)
      (letrec ((loop (lambda (more)
		       (if (eq? '() more)
			   0
			   (begin
			     (write-string (car more) out)
			     (loop (cdr more)))))))
	(loop more))))
  (if (vector? arg)
      (if (< 0 (vector-length arg))
	  (write-string (vector-ref arg 0) out)))
  (newline out)

  (bool-test (= 1 1) "(= 1 1)" #t out)
  (bool-test (= 1 2) "(= 1 2)" #f out)
  (bool-test (= 1 1 1) "(= 1 1 1)" #t out)
  (bool-test (= 1 2 3) "(= 1 2 3)" #f out)
  (bool-test (= 1 1 1 3) "(= 1 1 1 3)" #f out)
  (bool-test (= 1 1 1 1) "(= 1 1 1 1)" #t out)
  (bool-test (= 1 1 2 3) "(= 1 1 2 3)" #f out)
  (bool-test (= 1 1 1 3) "(= 1 1 1 3)" #f out)
  ((lambda (=)
     (bool-test (= 1 1) "(= 1 1)" #t out)
     (bool-test (= 1 2) "(= 1 2)" #f out)
     (bool-test (= 1 1 1) "(= 1 1 1)" #t out)
     (bool-test (= 1 2 3) "(= 1 2 3)" #f out)
     (bool-test (= 1 1 3) "(= 1 1 3)" #f out)
     (bool-test (= 1 1 1 3) "(= 1 1 1 3)" #f out)
     (bool-test (= 1 1 1 1) "(= 1 1 1 1)" #t out)
     (bool-test (= 1 1 2 3) "(= 1 1 2 3)" #f out)
     (bool-test (= 1 1 1 3) "(= 1 1 1 3)" #f out))
   =)
  (bool-test (< 1 1) "(< 1 1)" #f out)
  (bool-test (< 1 2) "(< 1 2)" #t out)
  (bool-test (< 1 1 1) "(< 1 1 1)" #f out)
  (bool-test (< 1 2 3) "(< 1 2 3)" #t out)
  (bool-test (< 1 2 2) "(< 1 2 2)" #f out)
  ((lambda (<)
     (bool-test (< 1 1) "(< 1 1)" #f out)
     (bool-test (< 1 2) "(< 1 2)" #t out)
     (bool-test (< 1 1 1) "(< 1 1 1)" #f out)
     (bool-test (< 1 2 3) "(< 1 2 3)" #t out)
     (bool-test (< 1 2 2) "(< 1 2 2)" #f out))
   <)
  (bool-test (<= 1 1) "(<= 1 1)" #t out)
  (bool-test (<= 1 2) "(<= 1 2)" #t out)
  (bool-test (<= 2 1) "(<= 2 1)" #f out)
  (bool-test (<= 1 1 1) "(<= 1 1 1)" #t out)
  (bool-test (<= 1 2 3) "(<= 1 2 3)" #t out)
  (bool-test (<= 1 2 2) "(<= 1 2 2)" #t out)
  (bool-test (<= 1 2 1) "(<= 1 2 1)" #f out)
  ((lambda (<=)
     (bool-test (<= 1 1) "(<= 1 1)" #t out)
     (bool-test (<= 1 2) "(<= 1 2)" #t out)
     (bool-test (<= 2 1) "(<= 2 1)" #f out)
     (bool-test (<= 1 1 1) "(<= 1 1 1)" #t out)
     (bool-test (<= 1 2 3) "(<= 1 2 3)" #t out)
     (bool-test (<= 1 2 2) "(<= 1 2 2)" #t out)
     (bool-test (<= 1 2 1) "(<= 1 2 1)" #f out))
   <=)
  (bool-test (> 1 1) "(> 1 1)" #f out)
  (bool-test (> 2 1) "(> 2 1)" #t out)
  (bool-test (> 1 1 1) "(> 1 1 1)" #f out)
  (bool-test (> 3 2 1) "(> 3 2 1)" #t out)
  (bool-test (> 2 1 1) "(> 2 1 1)" #f out)
  ((lambda (>)
     (bool-test (> 1 1) "(> 1 1)" #f out)
     (bool-test (> 2 1) "(> 2 1)" #t out)
     (bool-test (> 1 1 1) "(> 1 1 1)" #f out)
     (bool-test (> 3 2 1) "(> 3 2 1)" #t out)
     (bool-test (> 2 1 1) "(> 2 1 1)" #f out))
   >)
  (bool-test (>= 1 1) "(>= 1 1)" #t out)
  (bool-test (>= 2 1) "(>= 2 1)" #t out)
  (bool-test (>= 1 2) "(>= 1 2)" #f out)
  (bool-test (>= 1 1 1) "(>= 1 1 1)" #t out)
  (bool-test (>= 3 2 1) "(>= 3 2 1)" #t out)
  (bool-test (>= 2 1 1) "(>= 2 1 1)" #t out)
  (bool-test (>= 2 1 2) "(>= 2 1 2)" #f out)
  ((lambda (>=)
     (bool-test (>= 1 1) "(>= 1 1)" #t out)
     (bool-test (>= 2 1) "(>= 2 1)" #t out)
     (bool-test (>= 1 2) "(>= 1 2)" #f out)
     (bool-test (>= 1 1 1) "(>= 1 1 1)" #t out)
     (bool-test (>= 3 2 1) "(>= 3 2 1)" #t out)
     (bool-test (>= 2 1 1) "(>= 2 1 1)" #t out)
     (bool-test (>= 2 1 2) "(>= 2 1 2)" #f out))
   >=)
  (arith-test (vector-length (make-vector 3)) "make-vector0" 3 out)
  (arith-test (vector-length (make-vector 3 4)) "make-vector1" 3 out)
  (arith-test (vector-ref (make-vector 3 4) 2) "make-vector2" 4 out)
  ((lambda (make-vector)
     (arith-test (vector-length (make-vector 3)) "make-vector3" 3 out)
     (arith-test (vector-length (make-vector 3 4)) "make-vector4" 3 out)
     (arith-test (vector-ref (make-vector 3 4) 2) "make-vector5" 4 out))
   make-vector)
  (arith-test (string-length (make-string 3)) "make-string0" 3 out)
  (arith-test (string-length (make-string 3 #\a)) "make-string1" 3 out)
  (arith-test (- (char->ascii (string-ref (make-string 3) 2))
		 (char->ascii #\?))
	      "make-string2" 0 out)
  (arith-test (- (char->ascii (string-ref (make-string 3 #\a) 2))
		 (char->ascii #\a))
	      "make-string3" 0 out)
  ((lambda (make-string)
     (arith-test (string-length (make-string 3)) "make-string4" 3 out)
     (arith-test (string-length (make-string 3 #\a)) "make-string5" 3 out)
     (arith-test (- (char->ascii (string-ref (make-string 3) 2))
		    (char->ascii #\?))
		 "make-string6" 0 out)
     (arith-test (- (char->ascii (string-ref (make-string 3 #\a) 2))
		    (char->ascii #\a))
		 "make-string7" 0 out))
   make-string)
  (arith-test (apply + '()) "(apply + '())" 0 out)
  (arith-test (apply + '(1)) "(apply + '(1))" 1 out)
  (arith-test (apply + 1 '()) "(apply + 1 '())" 1 out)
  (arith-test (apply + '(1 2)) "(apply + '(1 2))" 3 out)
  (arith-test (apply + 1 '(2)) "(apply + 1 '(2))" 3 out)
  (arith-test (apply + 1 2 '()) "(apply + 1 2 '())" 3 out)
  (arith-test (apply + '(1 2 3)) "(apply + '(1 2 3))" 6 out)
  (arith-test (apply + 1 2 '(3)) "(apply + 1 2 '(3))" 6 out)
  (bool-test (apply < '(1 2)) "(apply < '(1 2))" #t out)
  (bool-test (apply < 1 '(2)) "(apply < 1 '(2))" #t out)
  (bool-test (apply < 1 2 '()) "(apply < 1 2 '())" #t out)
  (bool-test (apply < '(1 2 3)) "(apply < '(1 2 3))" #t out)
  (bool-test (apply < 1 2 '(3)) "(apply < 1 2 '(3))" #t out)
  (arith-test (apply apply (list + '(1 2 3)))
	      "(apply apply (list + '(1 2 3)))" 6 out)
  (arith-test (apply apply (list + 1 2 '(3)))
	      "(apply apply (list + 1 2 '(3)))" 6 out)
  (arith-test (apply apply (list + 1 2 3 '()))
	      "(apply apply (list + 1 2 3 '()))" 6 out)
  (arith-test (apply apply + 1 '(2 3 ())) "(apply apply + 1 '(2 3 ())" 6 out)
  (arith-test (apply apply + 1 '(2 (3))) "(apply apply + 1 '(2 3 ())" 6 out)
  (arith-test (apply apply + 1 2 3 '(())) "(apply + 1 2 3 '(()))" 6 out)
  ((lambda (apply)
     (arith-test (apply + '(1 2 3)) "(apply + '(1 2 3))" 6 out)
     (arith-test (apply + 1 2 '(3)) "(apply + 1 2 '(3))" 6 out)
     (arith-test (apply apply (list + '(1 2 3)))
		 "(apply apply (list + '(1 2 3)))" 6 out)
     (arith-test (apply apply (list + 1 2 '(3)))
		 "(apply apply (list + 1 2 '(3)))" 6 out)
     (arith-test (apply apply (list + 1 2 3 '()))
		 "(apply apply (list + 1 2 3 '()))" 6 out)
     (arith-test (apply apply + 1 '(2 3 ())) "(apply apply + 1 '(2 3 ())" 6 out)
     (arith-test (apply apply + 1 '(2 (3))) "(apply apply + 1 '(2 3 ())" 6 out)
     (arith-test (apply apply + 1 2 3 '(())) "(apply + 1 2 3 '(()))" 6 out))
   apply)
  (arith-test (+) "(+)" 0 out)
  (arith-test (+ 3) "(+ 3)" 3 out)
  (arith-test (+ 3 4) "(+ 3 4)" 7 out)
  (arith-test (+ 3 4 5) "(+ 3 4 5)" 12 out)
  (arith-test (+ 1 2 3 4 5 6 7 8 9 10 -50) "(+ 1 2 3 ... 10 -50) = 5" 5 out)
  ((lambda (+)
     (arith-test (+) "(+) closed" 0 out)
     (arith-test (+ 3) "(+ 3) closed" 3 out)
     (arith-test (+ 3 4) "(+ 3 4) closed" 7 out)
     (arith-test (+ 3 4 5) "(+ 3 4 5) closed" 12 out)
     (arith-test (+ 3 4 5 6) "(+ 3 4 5 6) closed" 18 out)
     (arith-test (+ 3 4 5 6 7) "(+ 3 4 5 6 7) closed" 25 out)
     (arith-test (+ 1 2 3 4 5 6 7 8 9 10 -50) "(+ 1 2 3 ... 10 -50) = 5 closed" 5 out))
   +)
  (arith-test (*) "(*)" 1 out)
  (arith-test (* 3) "(* 3)" 3 out)
  (arith-test (* 3 4) "(* 3 4)" 12 out)
  (arith-test (* 3 4 2) "(* 3 4 2)" 24 out)
  ((lambda (*)
     (arith-test (*) "(*)" 1 out)
     (arith-test (* 3) "(* 3)" 3 out)
     (arith-test (* 3 4) "(* 3 4)" 12 out)
     (arith-test (* 3 4 2) "(* 3 4 2)" 24 out))
   *)
  (arith-test (- -3) "(- -3)" 3 out)
  (arith-test (- 3 -4) "(- 3 -4)" 7 out)
  ((lambda (-)
     (arith-test (- -3) "(- -3)" 3 out)
     (arith-test (- 3 -4) "(- 3 -4)" 7 out))
   -)
  (arith-test (/ 1) "(/ 1)" 1 out)
  (arith-test (/ 12 4) "(/ 12 4)" 3 out)
  ((lambda (/)
     (arith-test (/ 1) "(/ 1)" 1 out)
     (arith-test (/ 12 4) "(/ 12 4)" 3 out))
   /)
  (arith-test (bitwise-ior) "(bitwise-ior)" 0 out)
  (arith-test (bitwise-ior 5) "(bitwise-ior 5)" 5 out)
  (arith-test (bitwise-ior 5 3) "(bitwise-ior 5 3)" 7 out)
  (arith-test (bitwise-ior 5 3 16) "(bitwise-ior 5 3 16)" 23 out)
  (arith-test (bitwise-xor) "(bitwise-xor)" 0 out)
  (arith-test (bitwise-xor 5) "(bitwise-xor 5)" 5 out)
  (arith-test (bitwise-xor 5 3) "(bitwise-xor 5 3)" 6 out)
  (arith-test (bitwise-xor 5 3 16) "(bitwise-xor 5 3 16)" 22 out)
  (arith-test (- (bitwise-and)) "(- (bitwise-and))" 1 out)
  (arith-test (bitwise-and 5) "(bitwise-and 5)" 5 out)
  (arith-test (bitwise-and 7 3) "(bitwise-and 7 3)" 3 out)
  (arith-test (bitwise-and 7 3 17) "(bitwise-and 7 3 17)" 1 out)
  (apply write-string (read-string in) (cons out '()))
  (newline out)
  0)

(define (length l n)
  (if (eq? l '()) n (length (cdr l) (+ n 1))))

(define (list . x) x)

(define numbers
  '#("0" "1" "2" "3" "4" "5" "6" "7" "8" "9"
     "10" "11" "12" "13" "14" "15" "16" "17" "18" "19"
     "20" "21" "22" "23" "24" "25" "26" "27" "28" "29"))

(define (number->string n)
  (vector-ref numbers n))
	 
(define (arith-test n s a out)
  (if (= n a)
      #t
      (begin
	(write-string "Failure: " out)
	(write-string s out)
	(write-string " = " out)
	(write-string (number->string n) out)
	(write-string " and not " out)
	(write-string (number->string a) out)
	(newline out))))

(define (bool-test n s a out)
  (if (eq? n a)
      #t
      (begin
	(write-string "Failure: " out)
	(write-string s out)
	(write-string " => " out)
	(write-string (if n "#t" "#f") out)
	(newline out))))

(define (write-string string . channel-option)  ; test n-ary procedures
  (channel-maybe-write (car channel-option)
		       string
		       0
		       (string-length string)))

(define (newline channel)
  (write-string "
" channel))

(define (read-string in)
  ((lambda (buffer)
     (letrec ((loop (lambda (have)
		      ((lambda (got)
			 (if (eq? got (eof-object))
			     "eof"
			     ((lambda (len)
				(if len
				    ((lambda (string)
				       (copy-string! buffer string len)
				       string)
				     (make-string len #\space))
				    (loop (+ have got))))
			      (has-newline buffer have got))))
		       (channel-maybe-read in buffer have (- 80 have) #f)))))
       (loop 0)))
   (make-string 80 #\space)))

(define (has-newline string start count)
  (letrec ((loop (lambda (i)
		   (if (= i count)
		       #f
		       (if (char=? #\newline
				   (string-ref string (+ start i)))
			   (+ start i)
			   (loop (+ i 1)))))))
    (loop 0)))

(define (copy-string! from to count)
  (letrec ((loop (lambda (i)
		   (if (< i count)
		       (begin
			 (string-set! to i (string-ref from i))
			 (loop (+ i 1)))))))
    (loop 0)))
