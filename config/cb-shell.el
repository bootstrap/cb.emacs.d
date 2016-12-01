;;; cb-shell.el --- Shell config.  -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Chris Barrett

;; Author: Chris Barrett <chris+emacs@walrus.cool>

;;; Commentary:

;;; Code:

(eval-when-compile
  (require 'use-package))

(require 'spacemacs-keys)

(setenv "INSIDE_EMACS" "true")

(use-package term
  :commands (ansi-term)
  :preface
  (progn
    (defun cb-shell-ansi-term ()
      (interactive)
      (ansi-term (getenv "SHELL")))

    (defun cb-shell--hl-line-off ()
      (when (bound-and-true-p hl-line-mode)
        (hl-line-mode -1))))

  :init
  (spacemacs-keys-set-leader-keys "at" #'cb-shell-ansi-term)
  :config
  (add-hook 'term-mode-hook #'cb-shell--hl-line-off))


(provide 'cb-shell)

;;; cb-shell.el ends here