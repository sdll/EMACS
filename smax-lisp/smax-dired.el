;;; smax-dired.el --- Summary

;;; Commentary:
;;
;;; Code:
;; * Dired 
;; ** Initialisation
(eval-when-compile
  (require 'dired)
  (require 'dired-x)
  (require 'image-dired)
  (require 'wdired))

(setq
 delete-by-moving-to-trash          t ; in dired mode
 dired-auto-revert-buffer           t ; automatically revert buffer
 dired-clean-up-buffers-too         t ; kill buffers for deleted files
 dired-dwim-target                  t ; guess target directory
 dired-keep-marker-copy             nil	; don't mark copied files
 dired-listing-switches             "-GAlh --group-directories-first"
 dired-recursive-copies             'always ; don't ask me, just do it
 dired-recursive-deletes            'always ; ^
 image-dired-show-all-from-dir-max-files 127 ; a bit more
 wdired-allow-to-change-permissions t  ; change permissions with Dired
 )
(put 'dired-do-copy   'ido nil) ; use ido there
(put 'dired-do-rename 'ido nil) ; ^


;; ** Packages
(use-package ztree
  :init
  :config
  (setq ztree-dir-filter-list              nil ; don't hide anything
	ztree-draw-unicode-lines           t)

  )
;; ** MIME
(use-package openwith
  :ensure t
  :init
  :config
  (when (require 'openwith nil 'noerror)
    (setq large-file-warning-threshold nil)
    (setq openwith-associations
	  (list
	   (list (openwith-make-extension-regexp
		  '("mpg" "mpeg" "mp3" "mp4"
		    "avi" "wmv" "wav" "mov" "flv"
		    "ogm" "ogg" "mkv"))
		 "vlc"
		 '(file))

	   (list (openwith-make-extension-regexp
		  '("doc" "xls" "ppt" "odt" "ods" "odg" "odp"))
		 "libreoffice"
		 '(file))
	   '("\\.lyx" "lyx" (file))
	   '("\\.chm" "kchmviewer" (file))
	   (list (openwith-make-extension-regexp
		  '("pdf" "ps" "ps.gz" "dvi" "djvu"))
		 "zathura"
		 '(file))
	   )))

  (openwith-mode 1)
  (add-to-list  'mm-inhibit-file-name-handlers 'openwith-file-handler))
;; ** Functions and Bindings
;; *** Navigation
(defun mk-dired-first-file ()
  "Jump to the first file in current directory."
  (interactive)
  (goto-char (point-min))
  (dired-next-line 2))

(defun mk-dired-last-file ()
  "Jump to the last file in current directory."
  (interactive)
  (goto-char (point-max))
  (dired-previous-line 1))

(defun mk-dired-open-external (file)
  "Open specified FILE with application determined by the OS."
  (interactive (list (dired-get-filename)))
  (call-process "xdg-open" nil 0 nil file))

(defun mk-image-dired-show-current ()
  "Make preview and show all images in current directory."
  (interactive)
  (image-dired-show-all-from-dir dired-directory))

(define-key dired-mode-map (kbd  "<down>") 'mk-dired-last-file)
(define-key dired-mode-map (kbd  "<up>")   'mk-dired-first-file)
(define-key dired-mode-map (kbd  "b")      'dired-up-directory)
(define-key dired-mode-map (kbd  "e")      'mk-dired-open-external)
(define-key dired-mode-map (kbd  "i")      'mk-image-dired-show-current)
(define-key dired-mode-map (kbd  "w")      'wdired-change-to-wdired-mode)
(define-key dired-mode-map (kbd "z")       '(lambda () (interactive)
                                              (ztree-dir default-directory)))
(define-key wdired-mode-map (kbd  "<down>")   'mk-dired-last-file)
(define-key wdired-mode-map (kbd  "<up>")     'mk-dired-first-file)

(add-hook 'dired-mode-hook 'toggle-truncate-lines)
;; *** Utilities
(defun xah-dired-rename-space-to-underscore ()
  "In dired, rename current or marked files by replacing space to underscore _.
If not in `dired', do nothing.
URL `http://ergoemacs.org/emacs/elisp_dired_rename_space_to_underscore.html'
Version 2016-12-22"
  (interactive)
  (require 'dired-aux)
  (if (equal major-mode 'dired-mode)
      (progn
        (mapc (lambda (x)
                (when (string-match " " x )
                  (dired-rename-file x (replace-regexp-in-string " " "_" x) nil)
                  ))
              (dired-get-marked-files ))
        (revert-buffer)
        (forward-line ))
    (user-error "Not in dired")))


(defun xah-dired-rename-space-to-hyphen ()
  "In dired, rename current or marked files by replacing space to hyphen -.
If not in `dired', do nothing.
URL `http://ergoemacs.org/emacs/elisp_dired_rename_space_to_underscore.html'
Version 2016-12-22"
  (interactive)
  (require 'dired-aux)
  (if (equal major-mode 'dired-mode)
      (progn
        (mapc (lambda (x)
                (when (string-match " " x )
                  (dired-rename-file x (replace-regexp-in-string " " "_" x) nil)))
              (dired-get-marked-files ))
        (revert-buffer))
    (user-error "Not in dired")))

(define-key dired-mode-map (kbd "_") 'xah-dired-rename-space-to-underscore)
(define-key dired-mode-map (kbd "-") 'xah-dired-rename-space-to-hyphen)

;; -*- lexical-binding: t -*-
(defun ora-ediff-files ()
  (interactive)
  (let ((files (dired-get-marked-files))
        (wnd (current-window-configuration)))
    (if (<= (length files) 2)
        (let ((file1 (car files))
              (file2 (if (cdr files)
                         (cadr files)
                       (read-file-name
                        "file: "
                        (dired-dwim-target-directory)))))
          (if (file-newer-than-file-p file1 file2)
              (ediff-files file2 file1)
            (ediff-files file1 file2))
          (add-hook 'ediff-after-quit-hook-internal
                    (lambda ()
                      (setq ediff-after-quit-hook-internal nil)
                      (set-window-configuration wnd))))
      (error "no more than 2 files should be marked"))))

(define-key dired-mode-map "e" 'ora-ediff-files)

;; * End
(provide 'smax-dired)

;;; smax-dired.el ends here
