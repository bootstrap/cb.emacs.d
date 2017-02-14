;;; cb-emacs.el --- Variables relating to core Emacs functionality. -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Chris Barrett

;; Author: Chris Barrett <chris+emacs@walrus.cool>

;;; Commentary:

;;; Code:

(require 'dash)
(require 'f)
(require 's)

(autoload 'magit-anything-modified-p "magit-git")
(autoload 'magit-list-remotes "magit-git")
(autoload 'magit-process-buffer "magit-process")
(autoload 'magit-read-string-ns "magit-utils")
(autoload 'magit-read-url "magit-remote")
(autoload 'magit-run-git "magit-process")

(defvar magit-process-raise-error)

;; Config Paths

(defconst cb-emacs-cache-directory
  (concat user-emacs-directory ".cache"))

(defconst cb-emacs-autosave-directory
  (concat user-emacs-directory "autosave"))

(defconst cb-emacs-lisp-directory
  (concat user-emacs-directory "lisp"))

(defconst cb-emacs-config-directory
  (concat user-emacs-directory "config"))

;; Commands for working with config subtrees

(defun cb-emacs--read-subtree ()
  (completing-read "Select subtree to update: "
                   (-map #'f-filename (f-directories cb-emacs-lisp-directory))
                   t))

(defun cb-emacs--find-subtree-remote (subtree)
  (--find (equal (-last-item (s-split "/" it)) subtree)
          (magit-list-remotes)))

(defmacro cb-emacs--with-signal-handlers (step &rest body)
  (declare (indent 1))
  `(condition-case _
       (let ((magit-process-raise-error t))
         (message "%s" ,step)
         ,@body)
     (magit-git-error
      (error "%sfailed.  See %s" ,step (magit-process-buffer t)))
     (error
      (error "%sfailed" ,step ))))

(defun cb-emacs--read-new-remote ()
  (let ((name (magit-read-string-ns "Remote name"))
        (url (magit-read-url "Remote url")))
    (cb-emacs--with-signal-handlers "Adding remote..."
      (magit-run-git "remote" "add" name url)
      name)))

(defun cb-emacs--assert-tree-not-dirty ()
  (require 'magit)
  (when (magit-anything-modified-p)
    (user-error "`%s' has uncommitted changes.  Aborting" default-directory)))

(defun cb-emacs-update-subtree (subtree &optional remote)
  "Update SUBTREE at REMOTE.

When called interactively, prompt for the subtree, then only
prompt for REMOTE if it cannot be determined."
  (interactive  (let ((default-directory user-emacs-directory))
                  (cb-emacs--assert-tree-not-dirty)
                  (let ((subtree (cb-emacs--read-subtree)))
                    (list subtree
                          (or (cb-emacs--find-subtree-remote subtree)
                              (cb-emacs--read-new-remote))))))
  (let ((default-directory user-emacs-directory))

    (cb-emacs--assert-tree-not-dirty)
    (run-hooks 'magit-credential-hook)

    (cb-emacs--with-signal-handlers "Fetching remote..."
      (magit-run-git "fetch" "-q" remote))

    (let* ((prefix (format "lisp/%s" subtree))
           (fullpath (f-join cb-emacs-lisp-directory subtree))
           (commit-message (format "'Merge %s@master into %s'" remote prefix)))

      (cb-emacs--with-signal-handlers "Importing subtree..."
        (magit-run-git "subtree" "-q" "pull" "--prefix" prefix remote "master" "--squash" "-m" commit-message))

      (cb-emacs--with-signal-handlers "Compiling..."
        (byte-recompile-directory fullpath 0))

      (message "Subtree `%s' updated successfully." prefix))))

(provide 'cb-emacs)

;;; cb-emacs.el ends here
