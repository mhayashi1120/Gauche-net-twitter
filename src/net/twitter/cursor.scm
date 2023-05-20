(define-module net.twitter.cursor
  (export
   retrieve-stream
   timeline-generator$
   stream-generator$))
(select-module net.twitter.cursor)

;; # Basic concept
;; - Some of cursor like extension routine by generator (and `lseq`)
;; - Using sub modules (in net.twitter.cursor.*) for each API group

;; ## Generic version twitter timeline (like `stream`)
;; - SLICER : <json> -> <rfc822-headers> -> [CURSOR-ARGS:{<list> | #f} (<json> ...)]
;;       CURSOR-ARGS are appended to `ARGS` if list.
;; - F : @{ARGS:(<top> ...)} -> [<json> <rfc822-headers>]
;;    Procedure get result from Twitter API with ARGS and CURSOR-ARGS.
;; - ARGS : <list> basic arguments pass to `F`
;; -> <generator>
(define (stream-generator$ slicer f . args)
  (define cursor #f)
  (define buffer #f)

  (assume-type slicer (<^> <top> <top> -> (<?> <list>) <list>))
  (assume-type f <procedure>)

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

;; ## General timeline generator
;; ### Example
;; Show first 50 of home timeline
;; ```
;; (let1 home$ (gtake (timeline-generator$ home-timeline/json cred) 50)
;;    (generator-for-each print-status home$))
;; ```
;;
;; Using <lseq> to get first 50 entry
;;
;; ```
;; (let1 home$ (timeline-generator$ home-timeline/json cred)
;;    (dolist (s (take (generator->lseq home$) 50))
;;       (print-status s)))
;; ```
;; ### Interface
;; - F : @{ARGS:(<top> ...)} -> [TIMELINE:#(<json> ...) <rfc822-headers>]
;; -> <generator>
(define (timeline-generator$ f . args)
  (assume-type f <procedure>)

  (apply stream-generator$
         (^ [j hdrs]
           (assume-type j <vector>)

           (let1 statuses (vector->list j)
             (values
              (and-let* ([(pair? statuses)]
                         [min-entry (last statuses)]
                         [id (assoc-ref min-entry "id")])
                (list :max-id (- id 1)))
              statuses)))
         f args))

;; ## Twitter cursor which using `next_cursor`
;; See [=stream-generator$]() about other arguments.
;; - F : @{ARGS:(<top> ...)} -> [CURSOR:<json> <rfc822-headers>]
;;     Unlike [=stream-generator$]() must accept `:cursor` keyword option.
;;     Must return json-object that contains "next_cursor" field.
;; - MAPPER : <json> -> <list> JSON from `F` results then return list
;;     of streaming item.
;; -> <generator>
(define (cursor-generator$ mapper f . args)
  (define (slice j _)
    (values
     (list :cursor (assoc-ref j "next_cursor"))
     (mapper j)))

  (assume-type f <procedure>)
  (assume-type mapper (<^> <top> -> <list>))

  (apply stream-generator$ slice f args))

;; ## See [=cursor-generator$]() arguments
;; -> <lseq>
(define (retrieve-stream mapper f . args)
  ($ generator->lseq
     $ apply cursor-generator$ mapper f args))
