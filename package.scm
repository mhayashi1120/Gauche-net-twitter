;;
;; Package Gauche-net-twitter
;;

(define-gauche-package "Gauche-net-twitter"
  ;;
  :version "1.8.0"

  ;; Description of the package.  The first line is used as a short
  ;; summary.
  :description "This module provides an interface to Twitter API\n\
               "

  ;; List of dependencies.
  ;; Example:
  ;;     :require (("Gauche" (>= "0.9.5"))  ; requires Gauche 0.9.5 or later
  ;;               ("Gauche-gl" "0.6"))     ; and Gauche-gl 0.6
  :require (
            ("Gauche-net-oauth" (>= "0.6.5"))
            ("Gauche" (>= "0.9.12"))
            )

  ;; List of providing modules
  ;; NB: This will be recognized >= Gauche 0.9.7.
  ;; Example:
  ;;      :providing-modules (util.algorithm1 util.algorithm1.option)
  :providing-modules ()

  ;; List name and contact info of authors.
  ;; e.g. ("Eva Lu Ator <eval@example.com>"
  ;;       "Alyssa P. Hacker <lisper@example.com>")
  :authors ("Saito Atsushi"
            "tana-laevatein"
            "sirocco634"
            "Shiro Kawai")

  ;; List name and contact info of package maintainers, if they differ
  ;; from authors.
  ;; e.g. ("Cy D. Fect <c@example.com>")
  :maintainers ("Masahiro Hayashi <mhayashi1120@gmail.com>")

  ;; List licenses
  ;; e.g. ("BSD")
  :licenses ("BSD")

  ;; Homepage URL, if any.
  :homepage "https://github.com/mhayashi1120/Gauche-net-twitter/"

  ;; Repository URL, e.g. github
  :repository "git@github.com:mhayashi1120/Gauche-net-twitter.git"
  )
