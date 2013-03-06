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

;;; ERC
(autoload 'erc-select "erc" "IRC client." t)
(setq erc-echo-notices-in-minibuffer-flag t)
(eval-after-load "erc"
  (lambda ()
    (require 'erc-match)
    (setq erc-keywords '("hub" "behaghel" "hubert" "alois"))
    (erc-autojoin-mode t)
    (setq erc-autojoin-channels-alist
          '((".*\\.freenode.net" "#emacs" "#scala")))
    (setq erc-auto-query 'bury)
    (setq erc-track-exclude-types '("JOIN" "NICK" "PART" "QUIT" "MODE"
                                    "324" "329" "332" "333" "353" "477"))
    (setq erc-fill-function 'erc-fill-static)
    (setq erc-timestamp-format "[%H:%M] "
          erc-insert-timestamp-function 'erc-insert-timestamp-left)))

;;; Git
;; magit
(autoload 'magit-status "magit" nil t)
(global-set-key (kbd "C-c g s") 'magit-status)
;; mo-git-blame
;; (autoload 'mo-git-blame-file "mo-git-blame" nil t)
;; (autoload 'mo-git-blame-current "mo-git-blame" nil t)
;; (global-set-key (kbd "C-c g c") 'mo-git-blame-current)
;; (global-set-key (kbd "C-c g f") 'mo-git-blame-file)

;; eshell
(eval-after-load 'esh-opt
  '(progn
     (require 'em-term)
     (add-to-list 'eshell-visual-commands "sbt")
     (require 'em-cmpl)
     (add-to-list 'eshell-command-completions-alist
                  '("gunzip" "gz\\'"))
     (add-to-list 'eshell-command-completions-alist
                  '("tar" "\\(\\.tar|\\.tgz\\|\\.tar\\.gz\\)\\'"))
     (add-to-list 'eshell-output-filter-functions 'eshell-handle-ansi-color)
     (require 'em-smart)
     (setq eshell-where-to-jump 'begin)
     (setq eshell-review-quick-commands nil)
     (setq eshell-smart-space-goes-to-end t)
     ))


; coding
(show-paren-mode 1)                     ; highlight matching brackets
(setq-default indent-tabs-mode nil)     ; no tabs, only spaces
;; (global-linum-mode t) ; always show line numbers
(add-hook 'prog-mode-hook
          (lambda () (linum-mode 1)))   ; all code buffers with linum
(setq linum-format "  %d ")    ; remove graphical glitches with fringe
;languages
; anti useless whitespace
(defun hub-anti-useless-whitespace ()
  "show and clean on save any trailing/useless whitespace"

  (require 'whitespace)

  ;; clean-up whitespace at save
  (make-local-variable 'before-save-hook)
  (add-hook 'before-save-hook 'whitespace-cleanup)

  ;; turn on highlight. To configure what is highlighted, customize
  ;; the *whitespace-style* variable. A sane set of things to
  ;; highlight is: face, tabs, trailing
  (make-local-variable 'whitespace-style)
  (setq whitespace-style '(face tabs lines-tail empty trailing))
  (whitespace-mode)
)
; RET insert newline and indent + comment if required
(defun hub-set-newline-and-indent-comment ()
  "Bind RET locally to comment-indent-new-line"
  (local-set-key (kbd "RET") 'comment-indent-new-line))
; automatically indent yanked text in prog-modes
(dolist (command '(yank yank-pop))
  (eval `(defadvice ,command (after indent-region activate)
           (and (not current-prefix-arg)
                (derived-mode-p 'prog-mode)
                (let ((mark-even-if-inactive transient-mark-mode))
                  (indent-region (region-beginning) (region-end) nil))))))
;scala
(autoload 'scala-mode "scala-mode2")
(add-to-list 'auto-mode-alist '("\\.scala$" . scala-mode))
(defun hub-scala-config ()
  (setq
   scala-indent:align-forms t
   scala-indent:align-parameters t
   scala-indent:default-run-on-strategy 0)
  (hub-anti-useless-whitespace)
  (hub-set-newline-and-indent-comment))
(add-hook 'scala-mode-hook 'hub-scala-config)

; Emacs Lisp
(add-hook 'emacs-lisp-mode-hook 'hub-set-newline-and-indent-comment)
(require 'jka-compr) ; find-tag to be able to find .el.gz 

; tweaking to get my proper setup
; OSX
; * iTerm2
; Preferences > Keys (tab) > Remap Left Command to Left Option
; Preferences > Profile > Left Option: Meta + Esc
; * Numpad: remap keypad-dot to Option+Shift+Keypad-dot
