;;; cb-js-refactor-commands.el --- Commands for refactoring Javascript  -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Chris Barrett

;; Author: Chris Barrett <chris@walrus.cool>

;;; Commentary:

;;; Code:

(require 'dash)
(require 'dash-functional)
(require 's)
(require 'seq)
(require 'smartparens)
(require 'subr-x)
(require 'web-mode)

(defun cb-js-refactor-commands--binding-keyword-at-pt ()
  (seq-contains '(const var let) (symbol-at-point)))

(defun cb-js-refactor-commands--back-to-binding-keyword ()
  (or (cb-js-refactor-commands--binding-keyword-at-pt)
      (when (search-backward-regexp (rx symbol-start (group (or "const" "let" "var")) symbol-end))
        (match-string-no-properties 1))))

(defun cb-js-refactor-commands--forward-to-end-of-binder ()
  (when (cb-js-refactor-commands--binding-keyword-at-pt)
    (search-forward "="))

  (search-forward-regexp (rx (or ";" (and symbol-start (or "let" "const" "var" "function") symbol-end))))
  (goto-char (match-beginning 0)))

(defun cb-js-refactor-commands--rewrite-comma-sep-binding-line (binder-keyword target-indent-column)
  ;; Deindent
  (back-to-indentation)
  (delete-horizontal-space)
  (indent-to target-indent-column)


  ;; Insert binding keyword and collapse whitespace.
  (if (cb-js-refactor-commands--binding-keyword-at-pt)
      (forward-symbol 1)
    (insert binder-keyword))
  (just-one-space)
  (forward-symbol 1)
  (just-one-space)

  ;; Replace comma or semicolon at end of line.
  (when (search-forward-regexp (rx (+? nonl) (group (any ",;")) (* space) eol) nil t)
    (replace-match ";" t nil nil 1)))

(defun cb-js-refactor-commands-expand-comma-bindings (start-pos &optional interactive)
  "Rewrite bindings at point from comma-separated to independent bindings.

E.g.:

  var util          = require('util'),
      _             = require('lodash'),
      restify       = require('restify');

Is rewritten to:

  const util = require('util');
  const _ = require('lodash');
  const restify = require('restify');

START-POS is the point in the buffer at which to begin the
rewrite. When called interactively, it is the beginning of the
current line.

If INTERACTIVE is set, raise an error if not at a binding site."
  (interactive (list (line-beginning-position) t))
  (goto-char start-pos)
  (cond ((cb-js-refactor-commands--binding-keyword-at-pt)
         ;; Create a marker pointing to the end of the binding group.
         (cb-js-refactor-commands--forward-to-end-of-binder)
         (let ((marker (make-marker)))
           (set-marker marker (point))

           (cb-js-refactor-commands--back-to-binding-keyword)
           (let ((target-column (current-column)))
             (while (< (point) (marker-position marker))
               (cb-js-refactor-commands--rewrite-comma-sep-binding-line "const" target-column)
               (forward-line)))))
        (interactive
         (user-error "Not an expandable binding site"))))

(defun cb-js-refactor-commands--import-start-position ()
  (save-excursion
    (goto-char (point-min))
    (search-forward-regexp (rx bol (* space) (or "import" "const" "var" "let")))
    (back-to-indentation)
    (point)))

(defun cb-js-refactor-commands--import-line-p (line)
  (string-match-p (rx bol (* space)
                      (or "import"
                          (and (or "const" "let" "var") (+ space) (+? nonl) "=" (* space) "require" (* space) "(")))
                  line))

(defun cb-js-refactor-commands--forward-to-end-of-imports ()
  (cl-labels
      ((current-line () (buffer-substring-no-properties (line-beginning-position) (line-end-position))))

    (let ((continue t))
      (while (and continue (not (eobp)))
        (if (or (string-blank-p (current-line))
                (cb-js-refactor-commands--import-line-p (current-line)))
            (forward-line)
          (setq continue nil)))
      (point))))

(defvar cb-js-refactor-commands-root-import-prefixes
  '("actions"
    "components"
    "constants"
    "dispatcher"
    "models"
    "routes"
    "selectors"
    "services"
    "stores"
    "types"
    "utils")
  "The names of root directories in the script tree available without qualification.")

(defconst cb-js-refactor-commands--match-relative-import
  (rx-to-string
   `(or "./"
        ;; ... require('foo')
        (and "require" (* space) "(" (any "\"'") (or ,@cb-js-refactor-commands-root-import-prefixes) "/")
        ;; import ... = 'foo'
        (and bol "import" (+? nonl) "=" (* space) (any "\"'") (or ,@cb-js-refactor-commands-root-import-prefixes) "/"))))

(defun cb-js-refactor-commands--import-kind (line)
  (cond
   ((string-match-p (rx bol (* space) "import" (* space) "type" (* space)) line)
    'flow-type)
   ((string-match-p cb-js-refactor-commands--match-relative-import line)
    'relative)
   (t
    'absolute)))

(defun cb-js-refactor-commands--tidy-import-whitespace (line)
  (with-temp-buffer
    (insert line)
    (goto-char (point-min))
    (when (search-forward-regexp (rx bol (+? nonl) (group (* space)) "=" (group (* space)))
                                 nil t)
      (replace-match " " nil nil nil 1)
      (replace-match " " nil nil nil 2))
    (buffer-string)))

(defun cb-js-refactor-commands--rewrite-require-to-destructure (line)
  (-if-let ((_ kw module member)
            (s-match (rx
                      bol (* space)
                      (group (or "const" "let" "var"))
                      (+ space)
                      (and (not (any "{")) (*? nonl))
                      "=" (* space) "require" (* space) "(" (group (+? nonl)) ")"
                      (* space) "."
                      (group (+? (not (any "(" "."))))
                      ";")
                     line))
      (format "%s { %s } = require(%s);" kw member module)
    line))

(defun cb-js-refactor-commands--format-imports (import-lines)
  (-let* ((format-import (-compose #'cb-js-refactor-commands--rewrite-require-to-destructure #'cb-js-refactor-commands--tidy-import-whitespace))
          ((&alist 'absolute absolutes 'relative relatives 'flow-type types)
           (-group-by #'cb-js-refactor-commands--import-kind (-map format-import import-lines))))
    (cl-labels ((format-group
                 (lines)
                 (when-let ((sorted-imports (-sort #'string< lines)))
                   (concat (string-join sorted-imports "\n") "\n\n"))))
      (concat
       (format-group absolutes)
       (format-group types)
       (format-group relatives)))))

(defun cb-js-refactor-commands-group-and-sort-imports (start-pos)
  "Rewrite bindings at point from comma-separated to independent bindings.

E.g.:

  const restify = require('restify');
  const bar = require('../../bar');
  const util = require('util');
  const foo = require('./foo');

Is rewritten to:

  const restify = require('restify');
  const util = require('util');

  const bar = require('../../bar');
  const foo = require('./foo');

START-POS is the point in the buffer at which to begin the
rewrite. When called interactively, it is the beginning of the
current line."
  (interactive (list (cb-js-refactor-commands--import-start-position)))
  (goto-char start-pos)

  (-let* ((end-pos (cb-js-refactor-commands--forward-to-end-of-imports))
          (region (buffer-substring-no-properties start-pos end-pos))
          (import-lines (split-string region (rx (any "\r\n")) t (rx space)))
          (formatted-imports (cb-js-refactor-commands--format-imports import-lines)))

    (goto-char start-pos)
    (delete-region start-pos end-pos)
    (insert formatted-imports)))

(defun cb-js-refactor-commands-organize-imports (start-pos)
  "Clean up and reorder import declarations at the start of the buffer.

START-POS is the start of the import lines. When called
interactively, it is set to the start of the first import group."
  (interactive (list (cb-js-refactor-commands--import-start-position)))
  (cb-js-refactor-commands-expand-comma-bindings start-pos)
  (cb-js-refactor-commands-group-and-sort-imports start-pos))

(defun cb-js-refactor-commands--enclosing-curlies ()
  (-when-let ((plist &as &plist :op op) (sp-get-enclosing-sexp))
    (if (equal op "{")
        plist
      (sp-backward-up-sexp)
      (cb-js-refactor-commands--enclosing-curlies))))

(defun cb-js-refactor-commands--curlies-contain-object-body-p (beg end)
  (string-match-p (rx bos "{" (* (any "\r\n" space))
                      ;; Interpolated keys
                      (or "[" (* space) (+ (syntax symbol)) (* space) "]")
                      ;; Symbol, number, string, etc.
                      (+ (not (any space)))
                      (or ":" ","))
                  (buffer-substring beg end)))

(defun cb-js-refactor-commands--object-literal-bounds ()
  (-if-let* (((&plist :beg beg :end end) (cb-js-refactor-commands--enclosing-curlies))
             (valid (cb-js-refactor-commands--curlies-contain-object-body-p beg end)))
      (list beg end)
    (user-error "Not inside an object literal")))

(defun cb-js-refactor-commands-align-object-literal-values (beg end)
  "Line up the values in an object literal.

E.g.:

  const foo = {
    a: 1,
    b:2,
    c:        3,
    dd: 4,
  }

Is rewritten to:

  const foo = {
    a:  1,
    b:  2,
    c:  3,
    dd: 4,
  }

BEG and END are the bounds of the object in the buffer."
  (interactive (cb-js-refactor-commands--object-literal-bounds))
  (align-regexp beg end ":\\(\\s-*\\)" 1))

(provide 'cb-js-refactor-commands)

;;; cb-js-refactor-commands.el ends here
