(define-module net.twitter.cursor
  (export
   retrieve-stream
   stream-generator$))
(select-module net.twitter.cursor)

;; # Basic concept
;; - Some of cursor like extension routine by generator (and `lseq`)
;; - Using sub modules (in net.twitter.cursor.*) for each API group

;; ## Generic version twitter timeline (like `stream`)
;; - SLICER : <json> -> <rfc822-headers> -> [CURSOR-ARGS:<list> (<json> ...)]
;;       CURSOR-ARGS are appended to `ARGS`
;; - F : @{ARGS} -> [<json> <rfc822-headers>]
;;    Procedure get result from Twitter API with ARGS and CURSOR-ARGS.
;; - ARGS : <list> basic arguments pass to `F`
;; -> <generator>
(define (stream-generator$ slicer f . args)
  (define cursor #f)
  (define buffer #f)

  (^[]
    (when (or (not buffer)
              (and cursor
                   (null? buffer)))
      (let1 args* (cond-list
                   [#t @ args]
                   ;; seems overwrite ARGS option by this trailing value
                   [cursor @ cursor])
        (receive (json headers) (apply f args*)
          (set!-values (cursor buffer) (slicer json headers))

          (assume-type buffer <list>))))

    (cond
     [(pair? buffer)
      (pop! buffer)]
     [else
      (eof-object)])))

;; ## Twitter cursor which sing `next_cursor`
;; See [=stream-generator$]() about other arguments.
;; - F : @{ARGS} -> [<json> <rfc822-headers>]
;;     Unlike [=stream-generator$]() must accept `:cursor` keyword argument.
;; - MAPPER : <json> -> <list> JSON from `F` results then return list
;;     of streaming item.
;; -> <generator>
(define (cursor-generator$ mapper f . args)
  (define (slice j _)
    (values
     (list :cursor (assoc-ref j "next_cursor"))
     (mapper j)))

  (apply stream-generator$ slice f args))

;; ## See [=cursor-generator$]() arguments
;; -> <lseq>
(define (retrieve-stream mapper f . args)
  ($ generator->lseq
     $ apply cursor-generator$ mapper f args))