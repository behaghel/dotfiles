(in-package :next-user)

(defvar *hub-normal-keymap* (make-keymap)
  "Hubert's Bépo command keymap")

(define-key :keymap *hub-normal-keymap* 
            "g b" #'switch-buffer
            "g g" #'scroll-to-top
            "G" #'scroll-to-bottom
            "K" #'delete-current-buffer
            "m u" #'bookmark-url
            "m k" #'bookmark-delete
            "U" #'load-init-file
            )


(define-mode hub-mode ()
  "Dummy mode for the custom key bindings in `*my-keymap*'."
  ((keymap-schemes :initform (list :emacs *hub-normal-keymap*
                                   :vi-normal *hub-normal-keymap*))))

(defclass hub-buffer (buffer)
  ((default-modes :initform
     (cons 'hub-mode (get-default 'buffer 'default-modes)))))

(setf *buffer-class* 'hub-buffer)
