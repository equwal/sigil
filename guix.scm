;;; guix.scm --- Guix package for sigil.  Build with: guix build -f guix.scm
;;; Install with: guix package -f guix.scm
(use-modules (guix packages) (guix gexp) (guix build-system asdf)
             ((guix licenses) #:prefix license:)
             (gnu packages lisp) (gnu packages lisp-xyz) (gnu packages lisp-check))

(define %source-dir (dirname (current-filename)))

(define-public sbcl-sigil
  (package
    (name "sbcl-sigil")
    (version "0.0.1")
    (source (local-file %source-dir "sigil-checkout"
                        #:recursive? #t
                        #:select? (lambda (file stat)
                                    (not (or (string-suffix? ".fasl" file)
                                             (string-contains file "/.git"))))))
    (build-system asdf-build-system/sbcl)
    (arguments
     (list #:asd-systems ''("sigil")
           #:phases
           #~(modify-phases %standard-phases
               ;; the .asd does not declare everything the sources use; fix the build copy
               (add-after 'unpack 'fix-asd-deps
                 (lambda _
                   (substitute* "sigil.asd"
                     (("\\(#:sb-introspect\\)") "(#:sb-introspect #:alexandria)")))))))
    (inputs (list
                  sbcl-alexandria))
    (synopsis "Sigils for Common Lisp documentation")
    (description "Sigils for Common Lisp documentation.")
    (home-page "https://github.com/equwal/texi-macro")
    (license license:gpl3)))

(define-public cl-sigil
  (sbcl-package->cl-source-package sbcl-sigil))

sbcl-sigil
