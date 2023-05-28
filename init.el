;;; init.el --- init
;;; Commentary:
;; -*- lexical-binding: t; -*-
;;; Code:

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
(load bootstrap-file nil 'nomessage))
(setq-default straight-use-package-by-default t)
(load-theme 'modus-vivendi nil)

;; global minor modes
(use-package corfu
  :demand t
  :requires (cape)
  :after (tempel)
  :hook (prog-mode shell-mode eshell-mode vterm-mode lisp-mode)
  :config (setq completion-cycle-threshold 3 tab-always-indent 'complete corfu-auto t corfu-auto-delay 0.2 corfu-cycle t corfu-quit-no-match t)
  :bind (:map corfu-map
	      ("TAB" . corfu-next)
	      ("S-TAB" . corfu-previous)))
(use-package orderless
  :demand t
  :custom (completion-styles '(basic partial-completion emacs22 orderless initials substring)))
(use-package cape
  :demand t
  :config
  (add-to-list 'completion-at-point-functions 'cape-keyword)
  (add-to-list 'completion-at-point-functions 'cape-dict)
  (add-to-list 'completion-at-point-functions 'cape-file)
  (add-to-list 'completion-at-point-functions 'cape-line))
(use-package which-key
  :demand t
  :config
  (which-key-setup-side-window-right)(which-key-mode))
(use-package undo-tree ;; note: this is a handy tree history browser, but it will pollute your directories with `.file.~undo-tree~` files
  :demand t
  :config (global-undo-tree-mode))
(use-package flymake
  :demand t
  :bind (:map flymake-mode-map)
  ("C-c ! n" . flymake-goto-next-error)
  ("C-c ! n" . flymake-goto-prev-error)
  :config
  (remove-hook 'flymake-diagnostic-functions 'flymake-proc-legacy-flymake)
  :hook c-mode)
(use-package vertico
  :demand t
  :config (vertico-mode))
(global-auto-revert-mode)
(use-package diff-hl
  :hook (prog-mode text-mode)
  :config (diff-hl-margin-mode))
(when (display-graphic-p)
  (use-package all-the-icons
    :demand t))
;; (use-package dashboard ;; you might want to uncomment this later, it creates a more useful dashboard but hides some beginner info
;;   :config
;;   (dashboard-setup-startup-hook))
(use-package marginalia
  :demand t
  :config (marginalia-mode)
  :bind
  (:map minibuffer-local-map
	("M-A" . marginalia-cycle)))
(use-package tempel
  ;; Require trigger prefix before template name when completing.
  :custom (tempel-trigger-prefix "<")
  :bind (("M-+" . tempel-complete)
         ("M-*" . tempel-insert))
  :init
  ;; Setup completion at point
  (defun tempel-setup-capf ()
    ;; Add the Tempel Capf to `completion-at-point-functions'.
    ;; `tempel-expand' only triggers on exact matches. Alternatively use
    ;; `tempel-complete' if you want to see all matches, but then you
    ;; should also configure `tempel-trigger-prefix', such that Tempel
    ;; does not trigger too often when you don't expect it. NOTE: We add
    ;; `tempel-expand' *before* the main programming mode Capf, such
    ;; that it will be tried first.
    (setq-local completion-at-point-functions
                (cons #'tempel-expand
                      completion-at-point-functions)))

  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf))
(use-package tempel-collection
	:requires (tempel)
	:demand t)
(use-package hideshow
  :straight nil
  :demand t
  :hook (prog-mode . hs-minor-mode))
;; (use-package embark ;; one of my favourite packages, but needs some experience
;;   :demand t
;;   :bind
;; 	("C-M-SPC" . embark-act)
;; 	("C-." . embark-dwim)
;; 	("M-/" . embark-export))
(use-package helpful
  :demand t
  :bind
  (("C-h f" . helpful-callable)
   ("C-h v" . helpful-variable)
   ("C-h k" . helpful-key)
   ("C-h F" . helpful-function)
   ("C-h C" . helpful-command)
   ("C-c C-d" . helpful-at-point)))

(use-package treesit-auto
  :config (global-treesit-auto-mode))
;; (use-package bufler ;; makes `switch-buffer` nicer, but more verbose
;; 	:demand t
;; 	:config (bufler-mode)
;; 	:bind
;; 	("C-x b" . bufler-switch-buffer)
;; 	("C-x C-b" . bufler-list))

;; global functions

(defun indent-buffer ()
  "Indents the entire buffer."
  (interactive)
  (indent-region 0 (buffer-size)))

(require 'eglot)
(require 'cape)
(require 'tempel)
(defun eglot-cape-tempel-capf ()
  (setq-local completion-at-point-functions
	      (list (cape-super-capf #'eglot-completion-at-point #'tempel-expand #'cape-file))))

;; global settings
(electric-pair-mode)
(save-place-mode)
(global-display-line-numbers-mode)
;; (menu-bar--display-line-numbers-mode-relative) ;; uncomment for relative line numbers
(setq-default shell-file-name "bash") ;; set "bash" to the shell you use the most
;; (scroll-bar-mode -1) ;; you might want to uncomment this
;; (tool-bar-mode -1) ;; you might want to uncomment this
;; (menu-bar-mode -1) ;; you might want to uncomment this
(setq-default tab-width 2 indent-tabs-mode t)
(setq debug-on-error t)
(setq load-prefer-newer t)
(setq sentence-end-double-space t)
;; (setq-default compile-command "make -j16")
(setq make-backup-files nil select-enable-clipboard t)
;; (defalias 'yes-or-no-p 'y-or-n-p)
(setq inital-frame-alist '((vertical-scroll-bars) (fullscreen . maximized)))
(setq next-line-add-newlines t)

;; removes keybindings to overwrite-mode (similiar to the R key in Vim)
(unbind-key (kbd "<insert>"))
(unbind-key (kbd "<insertchar>"))

;; LSP
(use-package eglot
  :straight nil
  :requires (orderless cape)
  :defer t
  :custom (completion-category-overrides '((eglot (styles orderless))))
  :config (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster)
  :hook (eglot-managed-mode . eglot-cape-tempel-capf))

;; Git
(use-package magit
  :demand t
  :bind
  ("C-c C-g c" . magit-commit)
	("C-c C-g p" . magit-push)
  ("C-c C-g s" . magit-status)
  ("C-c C-g b s" . magit-branch-checkout)
  ("C-c C-g p s" . magit-patch-save))

;; Debug
(defun debug-gud ()
  "GUD setup for Rust and core files."
  (interactive)
  (cond ((and (or (equal major-mode 'c-mode) (equal major-mode 'c++-mode)) (file-exists-p "./core"))
	 ((setq gud-gdb-command-name "gdb -i=mi ./core") (gud-gdb)))
	((equal major-mode 'rust-mode) (rust-gdb))))

;; Lisp
(use-package paredit
  :defer t
  :hook
  (lisp-mode eval-expression-minibuffer-setup lisp-interaction-mode slime-repl-mode emacs-lisp-mode scheme-mode)
  :bind
  (:map paredit-mode-map
	("M-<right>" . paredit-forward-slurp-sexp)
	("M-<left>" . paredit-forward-barf-sexp)
	("C-<left>" . paredit-backward-slurp-sexp)
	("C-<right>" . paredit-backward-barf-sexp)
	("M-r" . move-to-window-line-top-bottom)
	("C-k" . paredit-kill))) ; todo bind paredit-forward and paredit-backward and paredit-kill

(use-package highlight-function-calls
  :hook (lisp-mode emacs-lisp-mode scheme-mode))

(use-package lisp-extra-font-lock
  :config (lisp-extra-font-lock-global-mode))

(use-package rainbow-delimiters
  :defer t
  :hook (lisp-mode emacs-lisp-mode scheme-mode))

;; Org
(use-package org
  :straight nil
  :defer t
  :config (add-to-list 'org-file-apps '(directory . emacs)))
;; (use-package org-modern ;; prettier look for org-mode, may impede learning it
;;   :requires org
;;   :demand t
;;   :hook ((org-mode) (org-agenda-finalize . org-modern-agenda)))
(use-package org-babel
  :straight nil
  :requires org
  :defer t
  :config
  ((org-babel-do-load-languages
    'org-babel-load-languages
    '((shell . t)
      (emacs-lisp . t)
      (arduino . t)
      (lisp . t)
      (makefile . t)
      (org . t)
      (calc . t)
      (C . t)
      (cpp . t)
      (eshell . t)
      (scheme . t)))
   (setq org-src-preserve-indentation t org-src-fontify-natively t org-confirm-babel-evaluate nil)))

;;; init.el ends here
