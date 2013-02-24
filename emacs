(setq mac-command-key-is-meta t)
(setq mac-command-modifier 'meta)
(setq mac-option-key-is-meta nil)
(setq mac-option-modifier nil)

;; minimal GUI
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))


;; install
(require 'package)
(add-to-list 'package-archives 
	     '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/"))
; required to find melpa-installed package after restart at init time
(package-initialize)

; let's make something useful with those french keys
(global-set-key (kbd "C-é") 'undo)

;;; ido
(require 'ido)
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode t)
(setq ido-create-new-buffer 'always)

;;; org-mode
(add-to-list 'load-path (expand-file-name "~/git/org-mode/lisp"))
(add-to-list 'auto-mode-alist '("\\.\\(org|org_archive\\|txt\\)$" . org-mode))
(setq org-agenda-files '("~/Documents/org/test.org"))
(setq org-hide-leading-stars t)
(setq org-return-follows-link t)
(require 'org-install)
(require 'org-habit)

(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)

;;; TRAMP
(setq tramp-default-method "ssh")

;;; git
;; magit
(autoload 'magit-status "magit" nil t)
(global-set-key (kbd "C-c g s") 'magit-status)
;; mo-git-blame
;; (autoload 'mo-git-blame-file "mo-git-blame" nil t)
;; (autoload 'mo-git-blame-current "mo-git-blame" nil t)
;; (global-set-key (kbd "C-c g c") 'mo-git-blame-current)
;; (global-set-key (kbd "C-c g f") 'mo-git-blame-file)

; eshell
(require 'em-smart)
(setq eshell-where-to-jump 'begin)
(setq eshell-review-quick-commands nil)
(setq eshell-smart-space-goes-to-end t)

; coding
; highlight matching brackets under cursor
(show-paren-mode 1)
;languages
; anti useless whitespace
(defun anti-useless-whitespace ()
  "show and clean on save any trailing/useless whitespace"

  (require 'whitespace)

  ;; clean-up whitespace at save
  (make-local-variable 'before-save-hook)
  (add-hook 'before-save-hook 'whitespace-cleanup)

  ;; turn on highlight. To configure what is highlighted, customize
  ;; the *whitespace-style* variable. A sane set of things to
  ;; highlight is: face, tabs, trailing
  (whitespace-mode)
)

;scala
(require 'scala-mode2)
(add-hook 'scala-mode-hook 'anti-useless-whitespace)

; Misc
(require 'jka-compr) ; find-tag to be able to find .el.gz 

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(scala-indent:align-forms t)
 '(scala-indent:align-parameters t)
 '(scala-indent:default-run-on-strategy 0))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

; tweaking to get my proper setup
; OSX
; * iTerm2
; Preferences > Keys (tab) > Remap Left Command to Left Option
; Preferences > Profile > Left Option: Meta + Esc
; * Numpad: remap keypad-dot to Option+Shift+Keypad-dot
