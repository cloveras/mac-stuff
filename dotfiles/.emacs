;; Package management
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(dolist (pkg '(bash-completion doom-themes yaml-mode markdown-mode json-mode
               web-mode js2-mode php-mode dockerfile-mode))
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

;; Syntax highlighting
(global-font-lock-mode 1)
(setq font-lock-maximum-decoration t)

;; Colors
(set-face-foreground 'default "white")
(set-face-background 'default "black")

;; Mode line
(custom-set-faces
 '(mode-line ((t (:background "white" :foreground "black" :box nil))))
 '(mode-line-inactive ((t (:background "gray90" :foreground "black" :box nil)))))

;; File modes
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
         ("\\.json$" . json-mode)
         ("\\Makefile$" . makefile-mode)
         ("\\makefile$" . makefile-mode)
         ("\\.md$" . markdown-mode)
         ("\\.pdf\\'" . doc-view-mode)
         ("\\.php\\'" . php-mode)
         ("\\.pl\\'" . perl-mode)
         ("\\.pp\\'" . ruby-mode)
         ("\\.properties\\'" . conf-mode)
         ("\\.py\\'" . python-mode)
         ("\\.sed\\'" . sh-mode)
         ("\\.sh\\'" . sh-mode)
         ("\\.sql\\'" . sql-mode)
         ("\\.txt\\'" . text-mode)
         ("\\.yaml\\'" . yaml-mode)
         ("\\.yml\\'" . yaml-mode)
         ("\\config\\'" . conf-mode)
         ("control" . conf-mode)
         ("github.*\\.txt$" . markdown-mode)
)))

;; Restore the "desktop" (do this as late as possible)
(setq desktop-save t)
(desktop-read)
(desktop-save-mode 1)

(custom-set-variables
 '(package-selected-packages
   '(bash-completion doom-themes yaml-mode markdown-mode json-mode
     web-mode js2-mode php-mode dockerfile-mode)))
