;;; cb-modeline.el --- Modeline configuration  -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Chris Barrett

;; Author: Chris Barrett <chris+emacs@walrus.cool>

;;; Commentary:

;;; Code:

(eval-when-compile
  (require 'use-package))

(require 'spacemacs-keys)

(use-package all-the-icons
  :defer t
  :init
  (defvar all-the-icons-scale-factor 1.0)
  :config
  (dolist (spec '((nix-mode all-the-icons-faicon "file-o" :height 0.8 :v-adjust 0.0 :face all-the-icons-dsilver)
                  (makefile-mode all-the-icons-fileicon "gnu" :face all-the-icons-dorange)
                  (makefile-bsdmake-mode all-the-icons-fileicon "gnu" :face all-the-icons-dorange)))
    (add-to-list 'all-the-icons-mode-icon-alist spec)))

(use-package cb-header-line-format
  :defines cb-header-line-format
  :config
  (setq-default header-line-format cb-header-line-format))

(use-package hidden-mode-line
  :commands (hidden-mode-line-mode global-hidden-mode-line-mode)
  :init
  (setq-default mode-line-format " "))

(use-package cb-header-line-mode
  :commands (cb-header-line-global-mode cb-header-line-mode cb-header-line-mode-on)
  :init
  (progn
    (spacemacs-keys-set-leader-keys
      "tM" #'cb-header-line-mode
      "tm" #'cb-header-line-global-mode)
    (add-hook 'after-init-hook #'cb-header-line-global-mode))
  :config
  (setq cb-header-line-function (lambda () cb-header-line-format)))

(provide 'cb-modeline)

;;; cb-modeline.el ends here
