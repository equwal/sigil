;;;; Copyright (C) 2007-2008 Shawn Betts
;;;;
;;;; stumpwm is free software; you can redistribute it and/or modify
;;;; it under the terms of the GNU General Public License as published by
;;;; the Free Software Foundation; either version 2, or (at your option)
;;;; any later version.

;;;; stumpwm is distributed in the hope that it will be useful,
;;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;;; GNU General Public License for more details.

;;;; You should have received a copy of the GNU General Public License
;;;; along with this software; see the file COPYING.  If not, see
;;;; <http://www.gnu.org/licenses/>.

;;;; Commentary:
;;;
;;; Generate documentation for sigil lines in the source, according to some
;;; input documentation standard.
;;;
;;;
;;;; Code:

(in-package #:sigil)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defvar *doc-fns* nil "The functions used to generate documents.")
  (defun compile-doc (name body)
    (concatenate 'string
                 "@" name " " body "~&@end " name "~%~%"))

  (defun doc-fmt (stream name body-format &rest args)
    "Fill in a texinfo template."
    (apply #'format stream (compile-doc name body-format)
           name body-format args)))

(defmacro defdoc ((macro name specializer &optional pprint custom-var custom-var-body) body)
  "Define a document generating method."
  (with-gensyms (os line sym var)
    `(push (lambda (,os ,line)
             (ppcre:register-groups-bind (,sym)
                 (,(format nil "~@{~A~}" "^" macro "\\W(.*)") ,line)
               (let* ((,var (find-symbol (string-upcase ,sym) :stumpwm))
                      (,var (cond ((eql ',specializer 'function)
                                   (symbol-function ,var))
                                  ((eql ',specializer 'macro)
                                   (macro-function ,var))
                                  (t ,var)))
                      (,var `(if ,',custom-var
                                ,(let ((custom-var sym))
                                   `(progn ,,@custom-var-body))
                                ,var)))
                 (format *debug-io* "~&Formatting manual for the ~a ~a...~&"
                         ',var ,sym)
                 (let ((*print-pretty* ,pprint))
                   (if (member ',specializer '(function macro))
                       (doc-fmt ,os ,name ,body
                                ,sym
                                (sb-introspect:function-lambda-list ,var)
                                (documentation ,var ',specializer))
                       (doc-fmt ,os ,name ,body
                                ,sym
                                (documentation ,var ',specializer))))
                 t)))
           *doc-fns*)))

(defdoc ("@@@" "defun" function t
               name
               (if (find #\( name :test 'char=)
                   ;; handle (setf <symbol>) functions
                   (with-standard-io-syntax
                     (let ((*package* (find-package :stumpwm)))
                       (fdefinition (read-from-string name))))
                   (symbol-function (find-symbol (string-upcase name) :stumpwm))))
        "{~a} ~{~a~^ ~}~%~a")

(defdoc ("%%%" "defmac" function) "{~a} ~{~a~^ ~}~%~a")
(defdoc ("###" "defvar" variable nil) "~a~%~a")

(defun generate (os line)
  "Generate a texi.in documentation line."
  (dolist (fn *doc-fns*)
    (when (funcall fn os line)
      (return-from generate)))
  ;; Not a macro line.
  (write-line line os))

(defun generate-manual (&key in out (package (find-package :cl)))
  #.(format nil "~@{~a~^~%~}"
                 "Generate the texinfo manual from the template texi.in file."
                 "IN the input file path file.texi.in"
                 "OUT the output file path file.texi"
                 "PACKAGE is the package where names are pulled from")
  (let ((*print-case* :downcase))
    (with-open-file (os out :direction :output :if-exists :supersede)
      (with-open-file (is in :direction :input)
        (loop for line = (read-line is nil is)
              until (eq line is) do (generate os line))))))
