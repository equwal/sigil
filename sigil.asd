;;;; sigil.asd

(asdf:defsystem #:texi-macro
  :description "Sigils for Common Lisp documentation."
  :author "Spenser Truex <web@spensertruex.com>"
  :license  "GNU GPL v3"
  :version "0.0.1"
  :serial t
  :depends-on (#:sb-introspect)
  :components ((:file "package")
               (:file "manual")))
