; Copyright (c) 1993-2000 by Richard Kelsey and Jonathan Rees. See file COPYING.


; More and more packages.  Some of these get loaded into the initial
; image to create scheme48.image; those that aren't can be loaded later
; using ,load-package.

; Things to load into initial.image to make scheme48.image.

(define-structure usual-features (export )  ;No exports
  (open analysis		;auto-integration
	disclosers
        command-processor
        debuginfo
        ;; Choose any combination of bignums, ratnums, recnums
	bignums ratnums recnums
	;; Choose either innums, floatnums, or neither
	innums			;Silly inexact numbers
        ;; floatnums		;Still don't print correctly
	;; pp
	;; The following is listed because this structure is used to
	;; generate a dependency list used by the Makefile...
	usual-commands))

; Large integers and rational and complex numbers.

(define-structure extended-numbers extended-numbers-interface
  (open scheme-level-2
        methods meta-methods
        define-record-types
        exceptions              ; make-opcode-generic!
        primitives
        architecture
        signals
	util
        number-i/o)
  (files (rts xnum)))

(define-structure bignums bignums-interface
  (open scheme-level-2
        extended-numbers
        methods signals)
  (files (rts bignum))
  (optimize auto-integrate))

(define-structure innums (export )    ;inexact numbers
  (open scheme-level-2
        extended-numbers
        methods signals
        number-i/o)             ;string->integer
  (files (rts innum)))

(define-structure ratnums (export )    ;No exports
  (open scheme-level-2
        extended-numbers
        methods signals
        number-i/o)             ;string->integer
  (files (rts ratnum)))

(define-structure recnums (export )    ;No exports
  (open scheme-level-2
        extended-numbers
        methods signals
        number-i/o)             ;really-number->string
  (files (rts recnum)))

(define-structure floatnums
		  (export floatnum? exp log sin cos tan asin acos atan sqrt)
  (open scheme-level-2
        extended-numbers
        code-vectors
        methods signals
	enumerated
	loopholes
	more-types		;:double
        primitives)             ;vm-extension double?
  (files (rts floatnum))
  (optimize auto-integrate))

(define-structure time time-interface
  (open scheme-level-1 primitives architecture enumerated)
  (files (rts time)))

(define-structure placeholders placeholder-interface
  (open scheme-level-1 define-record-types
	threads threads-internal
	interrupts
	signals)
  (files (big placeholder))
  (optimize auto-integrate))

;----------------
; Big Scheme

(define-structure random (export make-random)
  (open scheme-level-2 bitwise
	signals)		;call-error
  (files (big random)))

(define-structure sort (export sort-list sort-list!)
  (open scheme-level-2)
  (files (big sort)))

(define-structure pp (export p pretty-print define-indentation)
  (open scheme-level-2
        tables
        methods)               ;disclose
  (files (big pp)))

; Bitwise logical operators on bignums.

(define-structure bigbit (export )  ;No exports
  (open scheme-level-2
	bignums
	methods
        extended-numbers
        ;; exceptions
	;; architecture
        bitwise
	signals)
  (files (big bigbit)))

(define-structure formats (export format)
  (open scheme-level-2 ascii signals
	extended-ports)
  (files (big format)))

(define-structure extended-ports extended-ports-interface
  (open scheme-level-2 define-record-types ascii byte-vectors
	ports
	i/o i/o-internal
	;records
	proposals
	structure-refs
	util			; unspecific
	signals)
  (access primitives)     ; copy-bytes!
  (files (big more-port)))

(define-structure destructuring (export (destructure :syntax))
  (open scheme-level-2)
  (files (big destructure)))

(define-structure mvlet (export ((mvlet mvlet*) :syntax))
  (open scheme-level-2)
  (files (big mvlet)))

(define-structure reduce (export ((reduce iterate)
				  :syntax)
				 ((list* list%
				   vector* vector%
				   string* string%
				   count* count%
				   bits* bits%
				   input* input%
				   stream* stream%)
				  :syntax))
  (open scheme-level-2
	bitwise
	signals)
  (files (big iterate)))

(define-structure arrays arrays-interface
  (open scheme-level-2 define-record-types signals)
  (files (big array)))

(define-structure receiving (export (receive :syntax))
  (open scheme-level-2)
  (files (big receive)))

(define-structure defrecord defrecord-interface
  (open scheme-level-1 records loopholes
	primitives)			; unspecific, low-level record ops
  (files (big defrecord)))

(define-structures ((masks masks-interface)
		    (mask-types mask-types-interface))
  (open scheme-level-1 define-record-types
	bitwise
	util			; every
	number-i/o		; number->string
	signals)		; call-error
  (files (big mask)))

(define general-tables tables)    ; backward compatibility

(define-structure big-util big-util-interface
  (open scheme-level-2
	formats
	features		; immutable? make-immutable!
        structure-refs)         ; structure-ref
  (access signals               ; error
          debugging		; breakpoint
	  primitives)		; copy-bytes!
  (files (big big-util)))

(define-structure big-scheme big-scheme-interface
  (open scheme-level-2
	formats
	sort
        extended-ports
	pp
	enumerated
        bitwise
        ascii
        bigbit
	big-util
        tables
	;defrecord
        destructuring
        receiving))

; Things needed for connecting with external code.

(define-structure external-calls (export call-imported-binding
					 lookup-imported-binding
					 define-exported-binding
					 shared-binding-ref
					 ((import-definition
					   import-lambda-definition)
					  :syntax)
					 add-finalizer!
					 define-record-resumer
					 call-external-value)
  (open scheme-level-2 define-record-types
	primitives
        architecture
	exceptions interrupts signals
	placeholders
	shared-bindings
	byte-vectors
	bitwise bigbit		;for {enter|extract}_integer() helpers
	(subset records			(define-record-resumer))
	(subset records-internal	(:record-type)))
  (files (big import-def)
	 (big callback)))

(define-structure dynamic-externals dynamic-externals-interface
  (open scheme-level-2 define-record-types tables
        signals                 ;warn
	primitives		;find-all-records
	i/o			;current-error-port
        code-vectors
	external-calls)
  (files (big external)))

; Externals - this is obsolete; use external-calls and dynamic-externals
; instead.

(define-structure externals (compound-interface
			       dynamic-externals-interface
			       (export external-call
				       null-terminate))
  (open scheme-level-2 structure-refs
	dynamic-externals)
  (access external-calls)
  (begin
   ; We fake the old external-call primitive using the new one and a
   ; a C helper procedure from c/unix/dynamo.c.

    (define (external-call proc . args)
      (let ((args (apply vector args)))
	(old-external-call (external-value proc) args)))
    
    ((structure-ref external-calls import-lambda-definition)
       old-external-call (proc args)
       "s48_old_external_call")

    ; All strings are now null terminated.
    (define (null-terminate string) string)))

; Rudimentary object dump and restore

(define-structure dump/restore dump/restore-interface
  (open scheme-level-1
        number-i/o
        tables
        records
        signals                 ;error
        locations               ;make-undefined-location
        closures
        code-vectors            ;code vectors
        fluids
        ascii
        bitwise
        methods                 ;disclose
        templates)              ;template-info
  (files (big dump)))

; Pipes containing values.

(define-structure value-pipes value-pipes-interface
  (open scheme queues
        proposals
        threads-internal
	signals)		;call-error
  (optimize auto-integrate)
  (files (big value-pipe)))

; Unix Sockets

(define-structures ((sockets (export open-socket
				     close-socket
				     socket-accept
				     socket-port-number
				     socket-client
				     get-host-name

				     ; From the old interface
				     ; I would like to get rid of these.
				     socket-listen
				     socket-listen-channels
				     socket-client-channels))
		    (udp-sockets (export get-host-name
					 close-socket
					 open-udp-socket
					 udp-send
					 udp-receive
					 lookup-udp-address
					 socket-port-number
					 udp-address?
					 udp-address-address
					 udp-address-hostname
					 udp-address-port)))
  (open scheme define-record-types
	external-calls
	channels		; channel? close-channel
	signals			; error call-error
	proposals		; atomically!
	interrupts		; enable-interrupts! disable-interrupts!
	channel-ports		; {in|out}put-channel->port
	channel-i/o		; wait-for-channel
	condvars)		; for wait-for-channel
  (files (big socket)))

; Heap traverser

(define-structure traverse
                  (export traverse-depth-first traverse-breadth-first trail
                          set-leaf-predicate! usual-leaf-predicate)
  (open scheme-level-2
        primitives              ; ?
        queues tables
        bitwise locations closures code-vectors
        disclosers              ; foo
        features                ; string-hash
        low-level)              ; flush-the-symbol-table!, vector-unassigned?
  (files (env traverse)))

; Space analyzer

(define-structure spatial (export space vector-space record-space)
  (open scheme
	architecture primitives assembler packages enumerated 
	features sort locations display-conditions)
  (files (env space)))

; Listing what is in an interface.  Here because it needs sort.

(define-structure list-interfaces (export list-interface)
  (open scheme-level-2 interfaces packages meta-types sort bindings)
  (files (env list-interface)))

; Structure & Interpretation compatibility

(define-structure sicp sicp-interface
  (open scheme-level-2 signals tables)
  (files (misc sicp)))

; red-black balanced binary search trees

(define-structure search-trees search-trees-interface
  (open scheme-level-2 define-record-types)
  (optimize auto-integrate)
  (files (big search-tree)))

; record types with a fixed number of instances

(define-structure finite-types (export ((define-finite-type
					 define-enumerated-type) :syntax))
  (open scheme-level-2 code-quote define-record-types
	enumerated
	features)		; make-immutable
  (files (big finite-type)))

; nondeterminism via call/cc

(define-structure nondeterminism (export with-nondeterminism
					 ((either one-value all-values) :syntax)
					 fail)
  (open scheme-level-2
	fluids
	(subset signals (error)))
  (files (big either)))

;----------------
; SRFI packages

; SRFI-0 - Doesn't work with the module system.

; Olin's list library.

(define-structure srfi-1 srfi-1-interface
  (open scheme-level-2
	receiving)
  (files (srfi srfi-1)))

(define-structure srfi-2 (export (and-let* :syntax))
  (open scheme-level-2
	signals)		; error
  (files (srfi srfi-2)))

; SRFI-3 - withdrawn
; SRFI-4 - needs hacks to the reader

(define-structure srfi-5 (export (let :syntax))
  (open (modify scheme-level-2 (drop let)))
  (files (srfi srfi-5)))

(define-structure srfi-6 (export open-input-string
				 open-output-string
				 get-output-string)
  (open (modify extended-ports
		(rename (make-string-input-port    open-input-string)
			(make-string-output-port   open-output-string)
			(string-output-port-output get-output-string)))))

; Configuration language

(define-structure srfi-7 (export)	; defines a command
  (open scheme

	; for parsing programs
	receiving
	nondeterminism
	(subset signals (error))

	(subset package-commands-internal	(config-package))
	ensures-loaded
	(subset packages			(note-structure-name!))

	; for defining the command
	(subset command-processor		(define-user-command-syntax
						 user-command-environment))
	(subset environments			(environment-define!)))

  (begin
    (define available-srfis
      '(srfi-1 srfi-2 srfi-5 srfi-6 srfi-7))

    ; Some SRFI's redefine Scheme variables.
    (define shadowed
      '((srfi-1 map for-each member assoc)
	(srfi-5 let))))

  (files (srfi srfi-7)))

; Taken directly from the SRFI document (or from `receiving', take your pick).

(define-structure srfi-8 (export (receive :syntax))
  (open scheme-level-2)
  (begin
    (define-syntax receive
      (syntax-rules ()
	((receive formals expression body ...)
	 (call-with-values (lambda () expression)
			   (lambda formals body ...)))))))

; SRFI-9 is a slight modification of DEFINE-RECORD-TYPE.

(define-structure srfi-9 (export define-record-type)
  (open scheme-level-2 
	(with-prefix define-record-types sys:))
  (begin
    (define-syntax define-record-type
      (syntax-rules ()
	((define-record-type type-name . stuff)
	 (sys:define-record-type type-name type-name . stuff))))))

;----------------
; ... end of package definitions.

; Temporary compatibility stuff
(define-syntax define-signature
  (syntax-rules () ((define-signature . ?rest) (define-interface . ?rest))))
(define-syntax define-package
  (syntax-rules () ((define-package . ?rest) (define-structures . ?rest))))
(define table tables)
(define record records)


; Must list all the packages defined in this file that are to be
; visible in the command processor's config package.

(define-interface more-structures-interface
  (export ((more-structures
	    usual-features
	    arrays
	    assembler
	    assembling
	    general-tables
	    bigbit
	    bignums ratnums recnums floatnums
	    build
	    callback
	    command-levels
	    command-processor
	    debugging
	    define-record-types
	    defrecord
	    destructuring
	    disassembler
	    disclosers
	    dump/restore
	    dynamic-externals
	    enum-case
	    extended-numbers
	    extended-ports
	    externals
	    external-calls
	    finite-types
	    formats
	    innums
	    inspector
	    inspector-internal
	    list-interfaces
	    masks
	    mask-types
	    mvlet
	    nondeterminism
	    package-commands-internal
	    package-mutation
	    placeholders
	    pp
	    ;profile
	    queues
	    time
	    random
	    receiving
	    reduce
	    search-trees
	    sicp
	    sockets
	    sort
	    spatial
	    strong
	    traverse
	    udp-sockets
	    value-pipes

	    big-scheme
	    big-util
	    ;; From link-packages.scm:
	    analysis
	    debuginfo
	    expander
	    flatloading
	    linker
	    link-config
	    reification			;?
	    shadowing
	    ;; Compatibility
	    record table

	    ; POSIX packages (see scheme/posix/packages.scm)
	    posix-files
	    posix-time
	    posix-users
	    posix-process-data
	    posix-processes
	    posix-regexps
	    posix-i/o
	    regexps
	    posix

	    ; SRFI packages
	    srfi-1 srfi-2 srfi-5 srfi-6 srfi-7 srfi-8 srfi-9
	    )
	   :structure)
	  ((define-signature define-package) :syntax)))
