; Copyright (c) 1993-2004 by Richard Kelsey and Jonathan Rees. See file COPYING.



; ,open architecture primitives assembler packages enumerated 
; ,open features sort locations display-conditions

(define length-procedures
  (do ((i (- stob-count 1) (- i 1))
       (l '() (cons (eval `(lap *length ()
                                (check-nargs= 1)
                                (pop)
                                (stored-object-length
                                  ,(enumerand->name i stob))
				(push)
				(literal '2)
				(arithmetic-shift)
                                (return))
                          (interaction-environment))
                    l)))
      ((< i 0) l)))

(define (space)
  (collect)
  (display "                     pure          impure        total") (newline)
  (display "                  count  bytes  count  bytes  count  bytes")
  (newline)
  (let loop ((i 0)
             (p-count-total 0)
             (p-bytes-total 0)
             (i-count-total 0)
             (i-bytes-total 0))
    (if (< i stob-count)
        (begin
          (collect)
          (let ((xs (find-all i))
                (length (list-ref length-procedures i)))
            (let loop2 ((j (- (vector-length xs) 1))
                        (p-count 0)
                        (i-count 0)
                        (p-bytes 0)
                        (i-bytes 0))
              (if (< j 0)
                  (begin (report1 (enumerand->name i stob)
                                  p-count p-bytes
                                  i-count i-bytes)
                         (loop (+ i 1)
                               (+ p-count-total p-count)
                               (+ p-bytes-total p-bytes)
                               (+ i-count-total i-count)
                               (+ i-bytes-total i-bytes)))
                  (if (immutable? (vector-ref xs j))
                      (loop2 (- j 1)
                             (+ p-count 1)
                             i-count
                             (+ p-bytes (+ 4 (length (vector-ref xs j))))
                             i-bytes)
                      (loop2 (- j 1)
                             p-count
                             (+ i-count 1)
                             p-bytes
                             (+ i-bytes (+ 4 (length (vector-ref xs j))))))))))
        (report1 'total
                 p-count-total p-bytes-total
                 i-count-total i-bytes-total))))

(define (report1 name p-count p-bytes i-count i-bytes)
  (write-padded name 16)
  (write-padded p-count 7)
  (write-padded p-bytes 7)
  (write-padded i-count 7)
  (write-padded i-bytes 7)
  (write-padded (+ p-count i-count) 7)
  (write-padded (+ p-bytes i-bytes) 8)
  (newline))

(define least-byte-type (enum stob string))


(define (write-padded x pad)
  (let ((s (if (symbol? x)
               (symbol->string x)
               (number->string x))))
    (display (make-string (- pad (string-length s)) #\space))
    (display s)))


(define (record-space . pred-option)
  (collect)
  (let ((pred (if (null? pred-option) (lambda (x) #t) (car pred-option)))
	(rs (find-all (enum stob record)))
        (a '()))
    (do ((i (- (vector-length rs) 1) (- i 1)))
        ((< i 0)
         (for-each (lambda (z)
                     (write-padded (cadr z) 7)
                     (write-padded (* (caddr z) 4) 7)
                     (display "  ")
                     (write (car z))
                     (newline))
                   (sort-list a (lambda (z1 z2)
                                  (> (caddr z1) (caddr z2))))))
      (let* ((r (vector-ref rs i))
             (probe (assq (record-ref r 0) a)))
        (if (pred r)
	    (if probe
		(begin (set-car! (cdr probe) (+ (cadr probe) 1))
		       (set-car! (cddr probe) (+ (caddr probe)
						 (+ 1 (record-length r)))))
		(set! a (cons (list (record-ref r 0) 1 (+ 1 (record-length r)))
			      a))))))))
                       

(define (vector-space . pred-option)
  (collect)
  (let ((pred (if (null? pred-option) (lambda (x) #t) (car pred-option)))
	(vs (find-all (enum stob vector))))
    (let ((e-count 0)
          (e-bytes 0)
          (t-count 0)
          (t-bytes 0)
          (b-count 0)
          (b-bytes 0)
          (v-count 0)
          (v-bytes 0)
          (l-count 0)
          (l-bytes 0)
          (o-count 0)
          (o-bytes 0))
      (let loop ((i (- (vector-length vs) 1)))
        (if (< i 0)
            (let ((fz (lambda (k b what)
                        (write-padded k 7)
                        (write-padded b 7)
                        (display what)
                        (newline))))
              (fz t-count t-bytes "  table buckets")
              (fz e-count e-bytes "  table entries")
              (fz b-count b-bytes "  bindings")
              (fz v-count v-bytes "  environment info")
              (fz l-count l-bytes "  lexical environments")
              (fz o-count o-bytes "  other"))
            (let* ((v (vector-ref vs i))
                   (len (vector-length v))
                   (bytes (* (+ len 1) 4)))
              (cond ((not (pred v)))
                    ((and (= len 3)
                          (bucket? (vector-ref v 2)))
                     (set! e-count (+ e-count 1))
                     (set! e-bytes (+ e-bytes bytes)))
                    ((and (= len 3)
                          (location? (vector-ref v 1)))
                     (set! b-count (+ b-count 1))
                     (set! b-bytes (+ b-bytes bytes)))
                    ((vector-every bucket? v)
                     (set! t-count (+ t-count 1))
                     (set! t-bytes (+ t-bytes bytes)))
                    ((or (and (= len 4)
                              (integer? (vector-ref v 0))
                              (list? (vector-ref v 3)))
                         (vector-every symbol? v))
                     (set! v-count (+ v-count 1))
                     (set! v-bytes (+ v-bytes bytes)))
                    ((and (> len 1)
                          (or (vector? (vector-ref v 0))
                              (integer? (vector-ref v 0))))
                     (set! l-count (+ l-count 1))
                     (set! l-bytes (+ l-bytes bytes)))
                    (else
                     ;;(if (= (remainder i 197) 0)
                     ;;    (begin (write v) (newline)))
                     (set! o-count (+ o-count 1))
                     (set! o-bytes (+ o-bytes bytes))))
              (loop (- i 1))))))))


(define (bucket? x)
  (or (eq? x #f)
      (vector? x)))

(define (vector-every pred v)
  (let loop ((i (- (vector-length v) 1)))
    (if (< i 0)
        #t
        (if (pred (vector-ref v i))
            (loop (- i 1))
            #f))))

(define (mutable? x) (not (immutable? x)))


; Print a random sampling of mutable pairs.

(define (pair-space)
  (collect)
  (let ((vs (find-all (enum stob pair))))
    (let loop ((i (- (vector-length vs) 1))
	       (j 0))
      (if (>= i 0)
	  (let ((x (vector-ref vs i)))
	  (if (mutable? x)
	      (begin (if (= (remainder j 293) 0)
			 (begin (limited-write x (current-output-port) 4 4)
				(newline)))
		     (loop (- i 1) (+ j 1)))
	      (loop (- i 1) j)))))))
