(define-module net.twitter.snowflake
  (use srfi-19)
  (use srfi-60)
  (export
   snowflake-id? snowflake-split-id
   snowflake-date snowflake-time
   date->pseudo-snowflake time->pseudo-snowflake)
  )
(select-module net.twitter.snowflake)

;; http://www.slideshare.net/pfi/id-15755280
;; http://qiita.com/items/c3c330a8d9e1dc1bcca8
;; https://github.com/twitter/snowflake

;; https://github.com/twitter/snowflake#solution
;;
;; > time - 41 bits (millisecond precision w/ a custom epoch gives us 69 years)
;; > configured machine id - 10 bits - gives us up to 1024 machines
;; > sequence number - 12 bits - rolls over every 4096 per machine (with protection to avoid rollover in the same ms)
(define (snowflake-split-id id)
  (unless (snowflake-id? id)
    (error "Not a valid snowflake id" id))
  ;;TODO consider worker-id
  (values
   (logand (ash id -22) #x1ffffffffff)
   (logand (ash id -12) #x3ff)
   (logand      id      #xfff)))

(define (snowflake-date id)
  ($ time-utc->date $ snowflake-time id))

(define (snowflake-time id)
  (receive (time . _) (snowflake-split-id id)
    (seconds->time (/ (+ time 1288834974657) 1000))))

(define (snowflake-id? id)
  (and (number? id)
       (let1 n (integer-length id)
         (<= 23 n 63))))

;; Generate the status id to search by time (using max-id or since-id)
(define (time->pseudo-snowflake time)
  (let ([tmsec (- ($ round->exact $ * 1000 $ time->seconds time) 1288834974657)]
        [machine-id 0]
        [seq-num 0])
    (unless (and (positive? tmsec)
                 (<= (integer-length tmsec) 41))
      (error "Arg out of range" time))
    (logior
     (ash tmsec       22)
     (ash machine-id  12)
     (ash seq-num      0))))

(define (date->pseudo-snowflake date)
  ($ time->pseudo-snowflake $ date->time-utc date))
