;;;
;;; Favotter access module
;;;

(define-module net.favotter
  (use file.util)
  (use rfc.http)
  (use text.tr)
  (use util.list)
  (use srfi-13)
  (export <favotter-favorite> <favotter-error>
		  favotter-user favotter-public
		  favotter-user-stream favotter-public-stream
		  )
  )
(select-module net.favotter)

(define-class <favotter-favorite> ()
  ((status-id :init-keyword :status-id)
   (screen-name :init-keyword :screen-name)
   (favotters :init-keyword :favotters)
   (text :init-keyword :text)))

(define-condition-type <favotter-error> <error> #f
  (status #f)
  (headers #f)
  (body #f))

;;
;; A convenience macro to construct query parameters, skipping
;; if #f is given to the variable.
;;

(define-macro (make-query-params . vars)
  `(cond-list
    ,@(map
	   (lambda (v)
		 `(,v `(,',(string-tr (x->string v) "-" "_") ,(x->string ,v))))
	   vars)))

;;
;; Public web api (no credentials)
;;

;; mode is `new' or 'best' or `hot'
(define (favotter-user user :key (mode #f) (threshold #f) (page #f))
  (call/web #"/user/~|user|"
			(make-query-params mode threshold page)))

;; mode is `new' or 'best' or `hot'
(define (favotter-public :key (mode #f) (threshold #f) (page #f))
  (call/web #"/home.php"
			(make-query-params mode threshold page)))

;; delayed access. See `Delayed evaluation' section in info.
;; mode is `new' or 'best' or `hot'
(define (favotter-user-stream user :key (mode #f) (threshold #f))
  (retrieve-stream
   (lambda (page)
	 (favotter-user user :mode mode :threshold threshold :page page))))

;; delayed access. See `Delayed evaluation' section in info.
;; mode is `new' or 'best' or `hot'
(define (favotter-public-stream :key (mode #f) (threshold #f))
  (retrieve-stream
   (lambda (page)
	 (favotter-public :mode mode :threshold threshold :page page))))

;;
;; private methods
;;

;;BUG almost case ok but radical increasing favorites will have miss page.
(define (retrieve-stream proc)
  (define (stream page prev)
	(delay
	 (let ((favs (proc page)))
	   (receive (merged new) (merge-favorites prev favs)
		 (if (pair? new)
		   (append new (stream (+ page 1) merged))
		   '())))))
  (stream 1 '()))

(define (merge-favorites old-favs new-favs)
  (let ((merging (reverse old-favs))
		(new '()))
	(map
	 (lambda (fav)
	   (if (find
			(lambda (x)
			  (string=? (ref x 'status-id) (ref fav 'status-id)))
			old-favs)
		 (set! merging (cons fav merging))
		 (set! new (cons fav new))))
	 new-favs)
	(values (reverse merging) (reverse new))))

(define (compose-query params)
  (%-fix (http-compose-query #f params 'utf-8)))

(define (%-fix str)
  (regexp-replace-all* str #/%[\da-fA-F][\da-fA-F]/
                       (lambda (m) (string-upcase (m 0)))))

(define (call/web path params)

  (define (call)
	(apply http-get "favotter.net"
		   #"~|path|?~(compose-query params)"
		   '()))

  (define (retrieve status headers body)
	(check-errors status headers body)
	(values (call-with-input-string body (cut parse-web-page <>))
			headers body))

  (call-with-values call retrieve))

(define (check-errors status headers body)
  (unless (equal? status "200")
	(error <favotter-error>
		   :status status :headers headers :body body)))

(define (parse-web-page port)
  (let1 obj (read-from-port port)
	(map
	 (lambda (item)
	   (make <favotter-favorite>
		 :status-id
		 (if-let1 m (#/<div[ \t]+id=\"status_([0-9]+)\"/ item)
				  (m 1)
		   #f)
		 :screen-name
		 (if-let1 m (#/<strong>[ \n\t]*<a[ \t]+title=\"([^\"]+)\"/ item)
				  (m 1))
		 :text
		 ;;TODO when text have newline
		 (if-let1 m (#/<span class=\"[ \t]*status_text[ \t]+description[ \t]*\">([^\n]*)(?:<\/span>)?/ item)
				  (html-to-text (m 1))
		   #f)
		 :favotters
		 (multiple-matches item #/<img class=\"[ \t]*fav_icon[ \t]*\"[^>]*title=\"([^\"]+)\">/)))
	 obj)))

(define (html-unescape string)
  (define (unescape string from to)
	(let loop ((str string)
			   (ret ""))
	  (receive (before after) (string-scan str from 'both)
		(if (and before after)
		  (loop after (string-append ret before to))
		  (string-append ret str)))))

  ;;TODO favotter probably have bug.
  ;;     favotter simply replace string.
  ;;     "<" is output as "&amp;lt;"
  ;;     favotter.scm respect this conduct.
  (define table
	'(("&amp;" . "&")
	  ("&gt;" . ">")
	  ("&lt;" . "<")
	  ("&quot;" . "\"")))

  (let loop ((str string)
			 (rules table))
	(if (pair? (cdr rules))
	  (loop (unescape str (car (car rules)) (cdr (car rules))) (cdr rules))
	  str)))

(define (html-to-text string)
  (define (remove-tags string)
	(let loop ((str string)
			   (ret ""))
	  (if-let1 m (#/<[^>]*>/ str)
			   (loop (m 'after) (string-append ret (m 'before)))
		(string-append ret str))))
  (html-unescape (remove-tags string)))

(define (multiple-matches string reg)
  (let loop ((val string)
			 (ms '()))
	(if-let1 m (reg val)
			 (loop (m 'after) (cons (m 1) ms))
	  ms)))

(define (read-from-port port)
  (define (end-of-read favs)
	(map
	 (lambda (s) (string-join s "\n"))
	 (reverse favs)))

  (with-input-from-port port
	(lambda ()
	  (let loop ((l (read-line))
				 (start? #f)
				 (fav '())
				 (favs '()))
		(cond
		 ((eof-object? l)
		  ;; probablly never through here
		  (end-of-read favs))
		 ((#/<div[ \t]id=\"status_[0-9]+\"[^>]*>.*/ l) =>
		  (lambda (m)
			(loop (read-line) #t
				  (list (m 0))
				  (if (pair? fav)
					(cons (reverse (cons (m 'before) fav)) favs)
					;; first item
					favs))))
		 ((#/<div class=\"pager\">/ l) =>
		  (lambda (m)
			(cond
			 (start?
			  ;; end of favorite item section
			  ;; TODO remove newline (cannot parse correctly)
			  (end-of-read (cons (reverse (cons (m 'before) fav)) favs)))
			 (else
			  (loop (read-line) start? '() favs)))))
		 (else
		  (loop (read-line) start? (if start? (cons l fav) '()) favs)))))))

