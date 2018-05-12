;;; config-hydras.el --- Grab-bag for configuring general prefixed keys.  -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(eval-when-compile
  (require 'use-package))

(require 'all-the-icons)
(require 'buffer-cmds)
(require 'hydra)
(require 'jump-cmds)
(require 'spacemacs-keys)
(require 'subr-x)

(autoload 'cb/toggle-window-split "cb-toggle-window-split")
(autoload 'counsel-find-file "config-ivy")
(autoload 'counsel-recentf "config-ivy")
(autoload 'evil-window-next "evil")
(autoload 'evil-window-prev "evil")
(autoload 'evil-window-rotate-downwards "evil")
(autoload 'evil-window-split "evil")
(autoload 'evil-window-vsplit "evil")
(autoload 'ivy-switch-buffer "ivy")
(autoload 'neotree-toggle "neotree")
(autoload 'org-narrow-to-subtree "org")


;; Define hydras as main interface for running commands.

(defun hydra-title-with-faicon (icon title)
  (concat (all-the-icons-faicon icon :face 'all-the-icons-orange :v-adjust 0.05) " " title))

(defun hydra-title-with-aicon (icon title)
  (concat (all-the-icons-alltheicon icon :face 'all-the-icons-orange :v-adjust 0.05) " " title))

(defhydra select-input-method (:color amaranth :hint nil)
  "
%s(hydra-title-with-faicon \"language\" \"Input Method\")

_a_ Arabic  _t_ TeX  _SPC_ clear

"
  ("a" (progn (set-input-method "arabic") (message "Arabic input method activated")))
  ("t" (progn (set-input-method "TeX") (message "TeX input method activated")))
  ("SPC" (progn (deactivate-input-method) (message "Input method cleared")))
  ("q" nil :exit t))

(defhydra font-scale (:color amaranth :hint nil)
  "
%s(hydra-title-with-faicon \"search-plus\" \"Font Scale\")

_+_ zoom in  _-_ zoom out  _0_ reset

"
  ("+" (text-scale-increase 1))
  ("-" (text-scale-decrease 1))
  ("0" (text-scale-set 0))
  ("q" nil :exit t))

(defhydra buffers (:color amaranth :hint nil)
  "
%s(hydra-title-with-faicon \"cogs\" \"Buffer Commands\")

^Switch^^^                 ^^ ^Manage^^^
^------^^^-----------------^^ ^------^^^------------
_n_: forward  _p_/_N_: back   _b_: bury  _d_: kill
_l_: list  _s_: switch     ^^ _w_: save  _v_: reload

"
  ("b" #'bury-buffer)
  ("d" #'kill-this-buffer)
  ("p" #'previous-buffer)
  ("N" #'previous-buffer)
  ("n" #'next-buffer)
  ("s" #'ivy-switch-buffer)
  ("w" #'save-buffer)
  ("l" #'ibuffer :exit t)
  ("v" #'reload-file :exit t)
  ("q" nil :exit t))

(defhydra windows (:color amaranth :hint nil)
  "
%s(hydra-title-with-faicon \"clone\" \"Window Management\")

^^^^^Switch^                   ^Split^          ^Close^
^^^^^------^------------------ ^-----^--------- ^-----^------
^^^^_w_: next                  _/_ vertical     _d_ window
_n_: forward  _p_/_N_: back    _-_ horizontal   _o_ others
^^^^_r_: rotate                _=_ rebalance

"
  ("=" #'balance-windows :exit t)
  ("p" #'evil-window-prev)
  ("N" #'evil-window-prev)
  ("n" #'evil-window-prev)
  ("w" #'evil-window-next :exit t)
  ("r" #'evil-window-rotate-downwards)
  ("o" #'delete-other-windows :exit t)
  ("d" #'delete-window :exit t)
  ("-" #'evil-window-split)
  ("/" #'evil-window-vsplit)
  ("q" nil :exit t))

(defhydra files (:color teal :hint nil)
  "
%s(hydra-title-with-faicon \"files-o\" \"File Commands\")

^Find^               ^Save^              ^Copy^             ^Other^
^----^-------------- ^----^------------- ^----^------------ ^-----^------------
_f_: file            _s_: buffer         _d_: dir           _e_: edit with sudo
_o_: other window    _S_: many buffers   _y_: path          _v_: reload
_p_: at pt           _W_: write copy     _Y_: filename      _t_: file tree
_r_: recent          _R_: rename
^^                   _D_: delete
"
  ("D" #'delete-current-buffer-and-file)
  ("R" #'rename-file-and-buffer)
  ("S" #'save-some-buffers)
  ("W" #'write-file)
  ("Y" #'copy-buffer-name)
  ("d" #'copy-buffer-directory)
  ("e" #'sudo-edit)
  ("f" #'counsel-find-file)
  ("o" #'find-file-other-window)
  ("p" #'find-file-at-point)
  ("r" #'counsel-recentf)
  ("s" #'save-buffer)
  ("t" #'neotree-toggle)
  ("v" #'reload-file)
  ("y" #'copy-buffer-path)
  ("q" nil :exit t))

(defhydra git-and-files (:color teal :hint nil)
  "
%s(hydra-title-with-aicon \"git\" \"Git and Goto\")

^Goto^                 ^Git^                ^Jump to Def
^----^---------------- ^---^--------------- ^-----------------------
_i_: init file         _s_: magit           _g_:   jump
_m_: messages          _b_: blame           _G_:   jump other window
_n_: nix packages      _d_: diff buffer     _SPC_: jump back
_p_: personal config   _f_: find file
_u_: package usage     _h_: navigate hunks
                    ^^ _l_: log buffer
                    ^^ _t_: time machine
"
  ("i" #'jump-to-init-file)
  ("n" #'jump-to-nix-packages)
  ("p" #'jump-to-personal-config)
  ("u" #'jump-to-package-usage)
  ("g" #'dumb-jump-go)
  ("G" #'dumb-jump-go-other-window)
  ("SPC" #'pop-tag-mark)
  ("m" #'jump-to-messages)
  ("s" #'magit-status)
  ("b" #'git-blame-transient-state/body)
  ("d" #'cb-git-diff-buffer-file)
  ("f" #'cb-git-find-file)
  ("h" #'git-hunks-transient-state/body)
  ("l" #'magit-log-buffer-file)
  ("t" #'git-time-machine-transient-state/body)
  ("q" nil :exit t))

(spacemacs-keys-set-leader-keys
  "a i" #'select-input-method/body
  "b" #'buffers/body
  "f" #'files/body
  "g" #'git-and-files/body
  "w" #'windows/body
  "z" #'font-scale/body)


;; Use which-key as a fallback for stuff I haven't ported to hydras yet.

(define-key universal-argument-map (kbd (concat "SPC u")) #'universal-argument-more)

(spacemacs-keys-set-leader-keys
  "u"   #'universal-argument
  "SPC" #'execute-extended-command
  "|"   #'cb/toggle-window-split
  ":"   #'eval-expression
  "TAB" #'alternate-buffer

  "!"   #'shell-command

  "C" #'compile

  "c r" #'comment-or-uncomment-region

  "h d c" #'describe-face
  "h d k" #'describe-key
  "h d m" #'describe-mode
  "h d p" #'describe-text-properties
  "h f c" #'find-face-definition
  "h f f" #'find-function
  "h f l" #'find-library
  "h f v" #'find-variable
  "h i"   #'info

  "k b" #'kill-this-buffer
  "k w" #'delete-window

  "n d" #'narrow-to-defun
  "n f" #'narrow-to-defun
  "n r" #'narrow-to-region
  "n s" #'org-narrow-to-subtree
  "n w" #'widen

  "q" #'delete-window

  "z"   #'font-scale/body)

(use-package which-key
  :straight t
  :preface
  (progn
    (autoload 'which-key-mode "which-key")
    (autoload 'which-key-add-key-based-replacements "which-key")

    (defun cb-leader-keys-set-up-which-key-buffer (&rest _)
      (when-let* ((buf (get-buffer which-key-buffer-name)))
        (when (buffer-live-p buf)
          (with-current-buffer buf
            (setq-local mode-line-format nil)
            (setq-local header-line-format nil)
            (force-mode-line-update))))))

  :config
  (progn
    (setq which-key-special-keys nil)
    (setq which-key-use-C-h-commands t)
    (setq which-key-echo-keystrokes 0.02)
    (setq which-key-max-description-length 32)
    (setq which-key-sort-order 'which-key-key-order-alpha)
    (setq which-key-idle-delay 0.02)
    (setq which-key-allow-evil-operators t)

    (advice-add 'which-key--create-buffer-and-show
                :after #'cb-leader-keys-set-up-which-key-buffer)

    ;; Strip cb prefixes from commands shown in which-key.

    (push `((nil . ,(rx bos "cb" (*? nonl) "/" (group (+? nonl))
                        (? "/body") eos))
            .
            (nil . "\\1"))
          which-key-replacement-alist)

    ;; Strip hydra body suffixes

    ;; Clean up comments entries

    (push `(("SPC c" . ,(rx (? "cb-evil-nerd-commenter/") (? "quick-") "comment-or-uncomment-" (group (+? nonl)))) . (nil . "\\1\\2"))
          which-key-replacement-alist)

    ;; Clean up errors entries

    (push `(("SPC e" . ,(rx (? "cb-") "flycheck-" (group (+? nonl)))) . (nil . "\\1"))
          which-key-replacement-alist)

    ;; Clean up goto and git

    (push `(("SPC g" . ,(rx (? "cb-") "magit-" (group (+? nonl)))) . (nil . "\\1"))
          which-key-replacement-alist)

    (push `(("SPC g" . ,(rx "cb-" (group "goto-" (+? nonl)))) . (nil . "\\1"))
          which-key-replacement-alist)

    (push `(("SPC g" . "time-machine-transient-state/body") . (nil . "git-time-machine"))
          which-key-replacement-alist)

    ;; Clean up help

    (push `(("SPC h d" . ,(rx bos (? "counsel-") "describe-" (group (+ nonl)))) . (nil . "\\1"))
          which-key-replacement-alist)

    (push `(("SPC h f" . ,(rx bos "find-" (group (+ nonl)))) . (nil . "\\1"))
          which-key-replacement-alist)

    ;; Clean up navigation

    (push `(("SPC j" . ,(rx bos (? "evil-") "avy-" (group (+ nonl)))) . (nil . "\\1"))
          which-key-replacement-alist)

    ;; Clean up kill

    (push `(("SPC k" . "kill-this-buffer") . (nil . "buffer"))
          which-key-replacement-alist)

    (push `(("SPC k" . "delete-window") . (nil . "window"))
          which-key-replacement-alist)

    (push `(("SPC k" . "counsel-yank-pop") . (nil . "kill-ring"))
          which-key-replacement-alist)

    ;; Clean up narrowing

    (push `(("SPC n" . ,(rx bos (? "org-") "narrow-to-" (group (+ nonl)))) . (nil . "\\1"))
          which-key-replacement-alist)

    ;; Clean up org

    (push `(("SPC o" . ,(rx bos (? "cb-") (or "org-" "ledger-") (group (+ nonl)))) . (nil . "\\1"))
          which-key-replacement-alist)

    ;; Clean up projectile

    (push `((nil . ,(rx bos (? "cb-") (? "counsel-") "projectile-" (group (+? nonl)) (? "-project") eos)) . (nil . "\\1"))
          which-key-replacement-alist)

    (push `((nil . "projectile-dired") . (nil . "root (dired)"))
          which-key-replacement-alist)

    (push `((nil . "cb-neotree-find-project-root") . (nil . "root (neotree)"))
          which-key-replacement-alist)

    (push `(("SPC p" . ,(rx bos (*? nonl) "shell-command" (* nonl))) . (nil . "shell-command"))
          which-key-replacement-alist)

    (push `(("SPC p" . ,(rx bos (*? nonl) "async-shell-command" (* nonl))) . (nil . "shell-command (async)"))
          which-key-replacement-alist)

    ;; Clean up symbols

    (push `(("SPC s" . "evil-iedit-state/iedit-mode") . (nil . "iedit"))
          which-key-replacement-alist)

    ;; Clean up toggles

    (push `(("SPC t" . ,(rx bos "cb-" (? "faces/") (group (+ nonl)))) . (nil . "\\1"))
          which-key-replacement-alist)

    ;; Clean up windows

    (push `(("SPC w" . ,(rx bos (? "cb-") (? "evil-") "window-" (group (+ nonl)))) . (nil . "\\1"))
          which-key-replacement-alist)

    (push `(("SPC w" . "balance-windows") . (nil . "balance"))
          which-key-replacement-alist)

    (push `(("SPC w" . "delete-window") . (nil . "delete"))
          which-key-replacement-alist)

    (push `(("SPC w" . "delete-other-windows") . (nil . "delete-others"))
          which-key-replacement-alist)

    ;; Clean up links

    (push `(("SPC x" . ,(rx bos "link-hint-" (group (+ nonl)))) . (nil . "\\1"))
          which-key-replacement-alist)

    ;; Clean up yasnippet

    (push `(("SPC y" . ,(rx bos (? "cb-") "yas" (any "-/") (group (+? nonl)) "-snippet" eos)) . (nil . "\\1"))
          which-key-replacement-alist)

    (push `(("SPC y" . "yas-visit-snippet-file") . (nil . "visit-file"))
          which-key-replacement-alist)

    ;; Clean up transient states

    (push `((nil . ,(rx bos (group (+? nonl)) "-transient-state/body" eos)) . (nil . "\\1"))
          which-key-replacement-alist)

    ;; Fallback for any other hydras.

    (push `((nil . ,(rx bos (? "config-") (group (+? nonl)) "/body" eos)) . (nil . "\\1"))
          which-key-replacement-alist)

    ;; Add basic prefixes

    (which-key-add-key-based-replacements
      "SPC ,"   "smartparens"
      "SPC a"   "applications"
      "SPC b"   "buffers"
      "SPC c"   "comments"
      "SPC e"   "errors"
      "SPC f"   "files"
      "SPC g"   "git/goto"
      "SPC h"   "help"
      "SPC h d" "describe"
      "SPC h f" "find"
      "SPC k"   "kill"
      "SPC n"   "narrow"
      "SPC o"   "org"
      "SPC p"   "project"
      "SPC w"   "window"
      "SPC s"   "symbols"
      "SPC t"   "toggles"
      "SPC SPC" "M-x"
      "SPC m"   '("major-mode-cmd" . "Major mode commands"))

    (which-key-mode +1)))

(provide 'config-hydras)

;;; config-hydras.el ends here