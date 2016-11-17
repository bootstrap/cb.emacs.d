;;; cb-dired.el --- Configuration for dired.  -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Chris Barrett

;; Author: Chris Barrett <chris+emacs@walrus.cool>

;;; Commentary:

;;; Code:

(eval-when-compile
  (require 'use-package))

(require 'cb-emacs)
(require 'spacemacs-keys)

(autoload 'evil-define-key "evil-core")

(use-package dired
  :defer t
  :commands (dired dired-hide-details-mode)
  :preface
  (progn
    (autoload 'diredp-next-line "dired+")
    (autoload 'diredp-previous-line "dired+")

    ;; HACK: Hide the cursor and use hl-line.
    (defun cb-dired--hacky-show-line-only ()
      (run-with-timer 0.01 nil (lambda ()
                                 (setq cursor-type nil)
                                 (hl-line-mode +1))))

    (defun cb-dired--sort-directories-first (&rest _)
      "Sort dired listings with directories first."
      (save-excursion
        (let (buffer-read-only)
          (forward-line 2) ;; beyond dir. header
          (sort-regexp-fields t "^.*$" "[ ]*." (point) (point-max)))
        (set-buffer-modified-p nil))))

  :init
  (progn
    (spacemacs-keys-declare-prefix-for-mode 'dired-mode "s" "subdir")
    (spacemacs-keys-set-leader-keys "d" #'dired)
    (spacemacs-keys-set-leader-keys-for-major-mode
      'dired-mode
      "d"  'dired-hide-details-mode
      "si" 'dired-insert-subdir
      "sd" 'dired-kill-subdir)

    (add-hook 'dired-mode-hook #'dired-hide-details-mode))

  :config
  (progn
    (add-hook 'dired-mode-hook #'cb-dired--hacky-show-line-only t)

    (put 'dired-find-alternate-file 'disabled nil)

    (setq-default dired-listing-switches "-alhv")
    (setq dired-dwim-target t)
    (advice-add 'dired-readin :after #'cb-dired--sort-directories-first)

    (unless (bound-and-true-p diredp-loaded-p)
      (load-file (concat cb-emacs-lisp-directory "/dired-plus/dired+.el")))

    (evil-define-key 'normal dired-mode-map (kbd "j") #'diredp-next-line)
    (evil-define-key 'normal dired-mode-map (kbd "k") #'diredp-previous-line)))

(use-package dired-x
  :commands (dired-omit-mode)
  :init
  (progn
    (add-hook 'dired-load-hook (lambda () (load "dired-x")))
    (spacemacs-keys-set-leader-keys-for-major-mode
      'dired-mode
      "h" #'dired-omit-mode)

    (add-hook 'dired-mode-hook #'dired-omit-mode))
  :config
  (progn
    (evil-define-key 'normal dired-mode-map (kbd "h") #'dired-omit-mode)
    (setq dired-omit-verbose nil)
    (setq dired-clean-up-buffers-too t)
    (setq dired-omit-files (rx bol (+ ".")))))


(provide 'cb-dired)

;;; cb-dired.el ends here