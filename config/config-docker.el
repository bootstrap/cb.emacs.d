;;; config-docker.el --- Configuration for docker-related packages  -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(eval-when-compile
  (require 'use-package)
  (require 'lsp-mode nil t))

;; dockerfile-mode provides a major mode for docker files.

(use-package dockerfile-mode
  :straight t
  :mode ("Dockerfile\\'" . dockerfile-mode))

;; docker provides an Emacs interface for working with docker.

(use-package docker
  :straight t
  :commands (docker)
  :general
  (:states '(motion) :keymaps 'docker-container-mode-map
   "?" 'docker-container-help-popup
   "C" 'docker-container-cp-popup
   "D" 'docker-container-rm-popup
   "I" 'docker-container-inspect-popup
   "K" 'docker-container-kill-popup
   "L" 'docker-container-logs-popup
   "O" 'docker-container-stop-popup
   "P" 'docker-container-pause-popup
   "R" 'docker-container-restart-popup
   "S" 'docker-container-start-popup
   "b" 'docker-container-shell-popup
   "d" 'docker-container-diff-popup
   "f" 'docker-container-find-file-popup
   "l" 'docker-container-ls-popup
   "r" 'docker-container-rename-selection)

  (:states '(motion) :keymaps 'docker-image-mode-map
   "?" 'docker-image-help-popup
   "D" 'docker-image-rm-popup
   "F" 'docker-image-pull-popup
   "I" 'docker-image-inspect-popup
   "P" 'docker-image-push-popup
   "R" 'docker-image-run-popup
   "T" 'docker-image-tag-selection
   "l" 'docker-image-ls-popup)

  (:states '(motion) :keymaps 'docker-machine-mode-map
   "?" 'docker-machine-help-popup
   "C" 'docker-machine-create
   "D" 'docker-machine-rm-popup
   "E" 'docker-machine-env-popup
   "O" 'docker-machine-stop-popup
   "R" 'docker-machine-restart-popup
   "S" 'docker-machine-start-popup
   "l" 'docker-machine-ls-popup)

  (:states '(motion) :keymaps 'docker-network-mode-map
   "?" 'docker-network-help-popup
   "D" 'docker-network-rm-popup
   "l" 'docker-network-ls-popup)

  (:states '(motion) :keymaps 'docker-volume-mode-map
   "?" 'docker-volume-help-popup
   "D" 'docker-volume-rm-popup
   "d" 'docker-volume-dired-selection
   "l" 'docker-volume-ls-popup))

;; configure LSP support for dockerfiles.

(defconst lsp-dockerfile-server "docker-langserver")

(with-eval-after-load 'lsp-mode
  (lsp-define-stdio-client lsp-dockerfile
                           "Docker"
                           (lambda () default-directory)
                           (list lsp-dockerfile-server "--stdio"))
  (add-hook 'dockerfile-mode-hook #'lsp-dockerfile-enable))




(defun eshell/docker (&rest args)
  (let ((args (eshell-flatten-list args)))
    (pcase (car args)
      ("ps" (docker-containers))
      ((or "image" "images") (docker-images))
      ((or "volume" "volumes") (docker-images))
      ((guard (null args))
       (docker))
      (_
       (eshell-external-command "docker" args)))))

(provide 'config-docker)

;;; config-docker.el ends here
