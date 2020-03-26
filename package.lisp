(defpackage :sigil
  (:use :cl)
  (:import-from :sb-introspect :function-lambda-list)
  (:import-from :alexandria :with-gensyms)
  (:export :defdoc
           :generate-manual))
