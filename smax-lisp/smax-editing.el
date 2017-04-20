;; smax-editing -- Summary: navigation
;;; Commentary:
;;; Code:
;; * Editing
;; ** Packages
;; *** Delimiters

;; **** Paredit
(use-package paredit
  :ensure t
  :init
  :config

  (define-key paredit-mode-map (kbd "C-w") 'paredit-kill-region-or-backward-word)
  (define-key paredit-mode-map (kbd "M-C-<backspace>") 'backward-kill-sexp)

  ;; don't hijack \ please
  (define-key paredit-mode-map (kbd "\\") nil)

  ;; Enable `paredit-mode' in the minibuffer, during `eval-expression'.
  (defun conditionally-enable-paredit-mode ()
    (if (eq this-command 'eval-expression)
	(paredit-mode 1)))

  (add-hook 'minibuffer-setup-hook 'conditionally-enable-paredit-mode)

  ;; making paredit work with delete-selection-mode
  (put 'paredit-forward-delete 'delete-selection 'supersede)
  (put 'paredit-backward-delete 'delete-selection 'supersede)
  (put 'paredit-newline 'delete-selection t))
;; **** Smartparens
(use-package smartparens-config
  :ensure smartparens
  :diminish smartparens-mode
  :config
  (show-smartparens-global-mode t)
  (smartparens-global-mode 1)
  (require 'smartparens-latex)
  (add-hook 'prog-mode-hook 'turn-on-smartparens-strict-mode) 
  (τ smartparens smartparens "<C-backspace>" #'sp-backward-kill-sexp)
  (τ smartparens smartparens "M-b"           #'sp-backward-sexp)
  (τ smartparens smartparens "M-f"           #'sp-forward-sexp)
  (τ smartparens smartparens "M-h"           #'sp-select-next-thing)
  (τ smartparens smartparens "M-k"           #'sp-kill-hybrid-sexp)
  (τ smartparens smartparens "M-u"           #'sp-backward-unwrap-sexp)
  (τ smartparens smartparens "M-t"           #'sp-add-to-previous-sexp))

;; **** Expand-region
(use-package expand-region
  :ensure t
  :init
  :bind (
	 ("C-@" . er/expand-region)))
;; *** Multiple-cursors

(use-package multiple-cursors
  :ensure t
  :init
  :config
  (π "C-c m p" #'mc/mark-previous-like-this)
  (π "C-c m n" #'mc/mark-next-like-this)
  (π "C-c m t" #'mc/mark-all-like-this)
  (π "C-c m r" #'set-rectangular-region-anchor)
  (π "C-c m c" #'mc/edit-lines)
  (π "C-c m e" #'mc/edit-ends-of-lines)
  (π "C-c m a" #'mc/edit-beginnings-of-lines))


;; *** ZZZ-to-char
(use-package zzz-to-char
  :init
  :config
  (π "M-z"        #'zzz-up-to-char))
;; *** Hungry-Delete
(use-package hungry-delete
  :ensure t
  :init
  :config
  (global-hungry-delete-mode))
;; *** Aggressive Indent
(use-package aggressive-indent
  :init
  :diminish aggressive-indent
  :config
  (aggressive-indent-global-mode 1)
  (add-to-list 'aggressive-indent-excluded-modes 'haskell-mode))
;; *** Operating on a Whole Line or a Region
(use-package whole-line-or-region
  :init
  :config
  (whole-line-or-region-mode 1))
;; *** Completion
;; *** Wrapping
(use-package wrap-region
  :init
  :config
  (wrap-region-global-mode +1)
  (wrap-region-add-wrapper "$" "$")
  )
;; **** Hippie-Expand

(use-package hippie-expand
  :ensure nil
  :init
  (setq hippie-expand-try-functions-list
	'(yas-hippie-try-expand
	  try-complete-file-name-partially
	  try-complete-file-name
	  try-expand-dabbrev
	  try-expand-dabbrev-all-buffers
	  try-expand-dabbrev-from-kill))
  :bind
  ("M-SPC" . hippie-expand))

;; **** Ivy-Historian
;; Persistent storage of completions
(use-package ivy-historian
  :init
  :config
  (add-hook 'after-init-hook
	    (lambda ()
	      (ivy-historian-mode)
	      (diminish 'historian-mode)
	      (diminish 'ivy-historian-mode)))
  )
;; *** Spelling
(use-package flyspell-lazy
  :ensure t
  :diminish flyspell-mode
  :init
  :config
  (setq-default  flyspell-lazy-disallow-buffers    nil ; do spell checking everywhere
		 flyspell-lazy-idle-seconds        1   ; a bit faster)
		 ispell-dictionary                 "en"	; default dictionary
		 )
  (flyspell-lazy-mode 1)
  (flyspell-prog-mode)
  (defun flyspell-correct-previous (&optional words)
    "Correct word before point, reach distant words.

     WORDS words at maximum are traversed backward until misspelled
     word is found.  If it's not found, give up.  If argument WORDS is
     not specified, traverse 12 words by default.
     
     Return T if misspelled word is found and NIL otherwise.  Never
     move point."
    (interactive "P")
    (let* ((Δ (- (point-max) (point)))
	   (counter (string-to-number (or words "12")))
	   (result
	    (catch 'result
	      (while (>= counter 0)
		(when (cl-some #'flyspell-overlay-p
			       (overlays-at (point)))
		  (flyspell-correct-word-before-point)
		  (throw 'result t))
		(backward-word 1)
		(setq counter (1- counter))
		nil))))
      (goto-char (- (point-max) Δ))
      result))
  (τ flyspell flyspell "C-;" #'flyspell-correct-previous)
  )
;; ** Modes
;; *** Parentheses
(show-paren-mode 1)         ;; highlight parentheses
(setq show-paren-style 'mixed)
;; *** Paragraph
(electric-indent-mode 0)
;; ** Functions and Bindings
;; *** Functions

;; #############################################################################
;;; Thank you, Mark. https://github.com/mrkkrp
(defun mk-saturated-occurence (&optional after-space)
  "Return position of first non-white space character after point.
  If AFTER-SPACE is not NIL, require at least one space character
  before target non-white space character."
  (save-excursion
    (let ((this-end (line-end-position)))
      (if (re-search-forward
           (concat (when after-space "[[:blank:]]")
                   "[^[:blank:]]")
           this-end			; don't go after this position
           t)				; don't error
          (1- (point))
        this-end))))  

(defun mk-column-at (point)
  "Return column number at POINT."
  (save-excursion
    (goto-char point)
    (current-column)))

(defun mk-smart-indent (&optional arg)
  "Align first non-white space char after point with content of previous line.

   With prefix argument ARG, align to next line instead."
  
  (interactive "P")
  (let* ((this-edge (mk-column-at (mk-saturated-occurence)))
         (that-edge
          (save-excursion
            (forward-line (if arg 1 -1))
            (move-to-column this-edge)
            (mk-column-at (mk-saturated-occurence t)))))
    (when (> that-edge this-edge)
      (insert-char 32 (- that-edge this-edge))
      (move-to-column that-edge))))
(π "C-S-r" #'mk-smart-indent)

(defun mk-transpose-line-down (&optional arg)
  "Move current line and cursor down.

Argument ARG, if supplied, specifies how many times the operation
should be performed."
  (interactive "p")
  (dotimes (_ (or arg 1))
    (let ((col (current-column)))
      (forward-line    1)
      (transpose-lines 1)
      (forward-line   -1)
      (move-to-column col))))

(defun mk-transpose-line-up (&optional arg)
  "Move current line and cursor up.

   Argument ARG, if supplied, specifies how many times the operation
   should be performed."
  (interactive "p")
  (dotimes (_ (or arg 1))
    (let ((col (current-column)))
      (transpose-lines 1)
      (forward-line   -2)
      (move-to-column col))))
(defun mk-show-date (&optional stamp)
  "Show current date in the minibuffer.

If STAMP is not NIL, insert date at point."
  (interactive)
  (funcall (if stamp #'insert #'message)
           (format-time-string "%A, %e %B, %Y")))
(defun mk-grab-input (prompt &optional initial-input add-space)
  "Grab input from user.

If there is an active region, use its contents, otherwise read
text from the minibuffer.  PROMPT is a prompt to show,
INITIAL-INPUT is the initial input.  If INITIAL-INPUT and
ADD-SPACE are not NIL, add one space after the initial input."
  (if mark-active
      (buffer-substring (region-beginning)
                        (region-end))
    (read-string prompt
                 (concat initial-input
                         (when (and initial-input add-space) " ")))))

(defun mk-show-default-dir ()
  "Show default directory in the minibuffer."
  (interactive)
  (message (f-full default-directory)))

(defun mk-file-name-to-kill-ring (arg)
  "Put name of file into kill ring.

   If user's visiting a buffer that's associated with a file, use
   name of the file.  If major mode is ‘dired-mode’, use name of
   file at point, but if point is not placed at any file, put name
   of actual directory into kill ring.  Argument ARG, if given,
   makes result string be quoted as for yanking into shell."
  (interactive "P")
  (let ((φ (if (cl-find major-mode
                        '(dired-mode wdired-mode))
               (or (dired-get-filename nil t)
                   default-directory)
	     (buffer-file-name))))
    (when φ
      (message "%s → kill ring"
               (kill-new
                (expand-file-name
                 (if arg
                     (shell-quote-argument φ)
                   φ)))))))

(defvar mk-search-prefix nil
  "This is an alist that contains some prefixes for online search query.

  Prefixes are picked up according to currect major mode.")

(defun mk-search (what)
  "Search Internet for WHAT thing, with DuckDuckGo.

   When called interactively, it uses prefix corresponding to
   current major mode, as specified in ‘mk-search-prefix’."
  (interactive
   (list (mk-grab-input "DuckDuckGo: "
                        (cdr (assoc major-mode
                                    mk-search-prefix))
                        t)))
  (browse-url
   (concat "https://duckduckgo.com/html/?k1=-1&q="
           (url-hexify-string what))))
(π "C-c s"      #'mk-search)
;; #############################################################################

(defun swap-text (str1 str2 beg end)
  "Changes all STR1 to STR2 and all STR2 to STR1 in beg/end region."
  (interactive "sString A: \nsString B: \nr")
  (if mark-active
      (setq deactivate-mark t)
    (setq beg (point-min) end (point-max))) 
  (goto-char beg)
  (while (re-search-forward
          (concat "\\(?:\\b\\(" (regexp-quote str1) "\\)\\|\\("
                  (regexp-quote str2) "\\)\\b\\)") end t)
    (if (match-string 1)
	(replace-match str2 t t)
      (replace-match str1 t t))))
(defun rename-this-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (unless filename
      (error "Buffer '%s' is not visiting a file!" name))
    (progn
      (when (file-exists-p filename)
        (rename-file filename new-name 1))
      (set-visited-file-name new-name)
      (rename-buffer new-name))))
(defun prettify-paragraph ()
  (interactive)
  (align-current)
  (fill-paragraph))

;; *** Bindings
(π "S-RET"	#'prettify-paragraph)
(π "RET"	#'newline-and-indent)
(π "C-\."	#'align-regexp)



(provide 'smax-editing)