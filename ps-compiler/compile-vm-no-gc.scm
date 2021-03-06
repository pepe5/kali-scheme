(config '(load "../scheme/vm/macro-package-defs.scm"))
(load-package 'vm-architecture)
(in 'forms '(run (set! *duplicate-lambda-size* 30)))
(in 'simplify-let '(run (set! *duplicate-lambda-size* 15)))
(in 'prescheme-compiler
    '(run (prescheme-compiler
	   'interpreter
	   '("../scheme/vm/interfaces.scm"
	     "../scheme/vm/ps-package-defs.scm"
	     "../scheme/vm/package-defs.scm"
	     "../scheme/vm/no-gc-package-defs.scm")
	   'scheme48-init
	   "../scheme/vm/scheme48vm.c"
	   '(header "#include \"scheme48vm.h\"")
	   '(copy (fixnum-arithmetic quotient-carefully)
		  (interpreter push-continuation-on-stack))
	   '(no-copy (interpreter interpret
				  restart
				  application-exception
				  handle-interrupt
				  uuo
				  collect-saving-temp)))))
;	   '(shadow ((interpreter restart)
;		     (interpreter *val* *code-pointer*)
;		     (stack *stack* *env*))))))
