
(use gauche.process)

(define (main args)
  (define (invoke-child file)
    (run-process `(gosh ,file) :wait #t))

  (invoke-child "./test/module.scm")
  (invoke-child "./test/api.scm")
  0)
