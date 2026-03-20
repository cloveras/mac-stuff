;; Package management
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(dolist (pkg '(bash-completion doom-themes yaml-mode markdown-mode json-mode))
  (unless (package-installed-p pkg)
    (package-install pkg)))

;; Completely disable Tree-sitter
(setq treesit-extra-load-path nil)
(setq major-mode-remap-alist nil)
(setq treesit-language-source-alist nil)

;; Force traditional major modes instead of Tree-sitter versions
(fset 'bash-ts-mode 'sh-mode)
(fset 'python-ts-mode 'python-mode)
(fset 'c-ts-mode 'c-mode)
(fset 'js-ts-mode 'js-mode)
(fset 'yaml-ts-mode 'yaml-mode)

;; No welcome
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)

;; Time
(setq display-time-24hr-format t)
(display-time)

;; Indents
(setq c-basic-offset 4)
(setq tab-width 4)
(setq indent-tabs-mode nil)

;; Cursor
(set-cursor-color "red")
(setq-default cursor-type 'box)

;; Parentheses
(show-paren-mode t)
(setq show-paren-style 'expression)
(require 'paren)
(set-face-background 'show-paren-match (face-background 'default))
(set-face-attribute 'show-paren-match nil :weight 'extra-bold)

(autoload 'hippie-exp "hippie-exp" t)

;; Keys
(global-set-key "\C-x\C-f" 'find-file)
(global-set-key "\C-\M-f" 'find-file-at-point)
(global-set-key "\C-cn" 'find-dired)
(global-set-key "\C-cN" 'grep-find)

(require 'grep)

;; No backups or autosaves
(setq make-backup-files nil)
(setq auto-save-default nil)

;; Misc
(transient-mark-mode 1)
(setq mark-even-if-inactive t)

;; Enable full syntax highlighting
(global-font-lock-mode 1)
(setq font-lock-maximum-decoration t)
(setq font-lock-support-mode 'jit-lock-mode)
(setq jit-lock-defer-time 0.1)

;; Force colors in terminal
(setq term-default-bg-color "black")
(setq term-default-fg-color "white")
(set-face-foreground 'default "white")
(set-face-background 'default "black")

;; Font lock mode: Bold
(defun my-make-face (face colour &optional bold)
  "Create a face from a colour and optionally make it bold"
  (make-face face)
  (copy-face 'default face)
  (set-face-foreground face colour)
  (if bold (make-face-bold face))
)

;; Mode line
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(mode-line ((t (:background "white" :foreground "black" :box nil))))
 '(mode-line-inactive ((t (:background "gray90" :foreground "black" :box nil)))))

;; File modes

(require 'yaml-mode)

(setq auto-mode-alist
      (append
       '(("\\.awk\\'" . awk-mode)
         ("ChangeLog" . change-log-mode)
         ("\\.bashrc\\'" . sh-mode)
         ("\\.conf\\'" . conf-mode)
         ("\\.config\\'" . conf-mode)
         ("config" . conf-mode)
         ("\\.css\\'" . css-mode)
         ("Dockerfile" . dockerfile-mode)
         ("\\.diff\\'" . diff-mode)
         ("\\.el\\'"  . emacs-lisp-mode)
         ("\\.emacs\\'" . emacs-lisp-mode)
         ("\\.htm\\'" . html-mode)
         ("\\.html\\'" . web-mode)
         ("\\.json$" . js2-mode)
         ("\\Makefile$" . makefile-mode)
         ("\\makefile$" . makefile-mode)
         ("\\.md$" . markdown-mode)
         ("\\.pdf\\'" . doc-view-mode)
         ("\\.php\\'" . php-mode)
         ("\\.pl\\'" . perl-mode)
         ("\\.pp\\'" . ruby-mode)
         ("\\.properties\\'" . conf-mode)
         ("\\.py$" . python-mode)
         ("\\.py\\'" . python-mode)
         ("\\.sed\\'" . sh-mode)
         ("\\.sh\\'" . sh-mode)
         ("\\.sql\\'" . sql-mode)
         ("\\.text\\'" . text-mode)
         ("\\.txt\\'" . text-mode)
         ("\\.yaml\\'" . yaml-mode)
         ("\\.yml\\'" . yaml-mode)
         ("\\config\\'" . conf-mode)
         ("control" . conf-mode)
         ("github.*\\.txt$" . markdown-mode)
)))

;; Restore the "desktop" (do this as late as possible)
(desktop-read)
(desktop-save-mode 1)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(bash-completion doom-themes yaml-mode markdown-mode json-mode)))
