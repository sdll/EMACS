;;; smax-ivy.el --- ivy functions for smax

;;; Commentary:
;; 
(require 'counsel)

;; * Generic ivy actions
(ivy-set-actions
 t
 '(("i" (lambda (x) (with-ivy-window
		      (insert x))) "insert candidate")
   ("t" (lambda (x) (find-file )) "resume")
   ("?" (lambda (x)
	  (interactive)
	  (describe-keymap ivy-minibuffer-map)) "Describe keys")))

;; ** Find file actions
(ivy-add-actions
 'counsel-find-file
 '(("a" (lambda (x)
	  (unless (memq major-mode '(mu4e-compose-mode message-mode))
	    (compose-mail)) 
	  (mml-attach-file x)) "Attach to email")
   ("c" (lambda (x) (kill-new (f-relative x))) "Copy relative path")
   ("4" (lambda (x) (find-file-other-window x)) "Open in new window")
   ("5" (lambda (x) (find-file-other-frame x)) "Open in new frame")
   ("C" (lambda (x) (kill-new x)) "Copy absolute path")
   ("d" (lambda (x) (dired x)) "Open in dired")
   ("D" (lambda (x) (delete-file x)) "Delete file")
   ("e" (lambda (x) (shell-command (format "open %s" x)))
    "Open in external program")
   ("f" (lambda (x)
	  "Open X in another frame."
	  (find-file-other-frame x))
    "Open in new frame")
   ("p" (lambda (path)
	  (with-ivy-window
	    (insert (f-relative path))))
    "Insert relative path")
   ("P" (lambda (path)
	  (with-ivy-window
	    (insert path)))
    "Insert absolute path")
   ("l" (lambda (path)
	  "Insert org-link with relative path"
	  (with-ivy-window
	    (insert (format "[[./%s]]" (f-relative path)))))
    "Insert org-link (rel. path)")
   ("L" (lambda (path)
	  "Insert org-link with absolute path"
	  (with-ivy-window
	    (insert (format "[[%s]]" path))))
    "Insert org-link (abs. path)")
   ("r" (lambda (path)
	  (rename-file path (read-string "New name: ")))
    "Rename")))


;; * ivy colors
(defun ivy-colors ()
  "List colors in ivy."
  (interactive)
  (ivy-read "Color: "
	    (progn
	      (save-selected-window
		(list-colors-display))
	      (prog1
		  (with-current-buffer (get-buffer "*Colors*")
		    (mapcar (lambda (line)
			      (append (list line) (s-split " " line t)))
			    (s-split "\n" (buffer-string))))
		(kill-buffer "*Colors*")))
	    :action
	    '(1
	      ("i" (lambda (line) 
		     (insert (elt line 1)))
	       "Insert name")
	      ("c" (lambda (line)
		     (kill-new (car line)))
	       "Copy name")
	      ("h" (lambda (line) 
		     (insert (car (last line))))
	       "Insert hex")
	      ("r" (lambda (line) 
		     (insert (format "%s" (color-name-to-rgb (elt line 1))))) 
	       "Insert RGB")
	      
	      ("m" (lambda (line) (message "%s" (cdr line)))))))

;; * ivy-top

(defcustom ivy-top-command
  "top -stats pid,command,user,cpu,mem,pstate,time -l 1"
  "Top command for `ivy-top'."
  :group 'smax-ivy)

(defun ivy-top ()
  (interactive)
  (let* ((output (shell-command-to-string ivy-top-command))
	 (lines (progn
		  (string-match "TIME" output)
		  (split-string (substring output (+ 1 (match-end 0))) "\n")))
	 (candidates (mapcar (lambda (line)
			       (list line (split-string line " " t)))
			     lines)))
    (ivy-read "process: " candidates)))


;; * ivy-ps


;; a data structure for a process
(defstruct ivy-ps user pid)


(defun ivy-ps ()
  "WIP: ivy selector for ps.
TODO: sorting, actions."
  (interactive)
  (let* ((output (shell-command-to-string "ps aux | sort -k 3 -r"))
	 (lines (split-string output "\n"))
	 (candidates (mapcar
		      (lambda (line)
			(cons line
			      (let ((f (split-string line " " t)))
				(make-ivy-ps :user (elt f 0) :pid (elt f 1)))))
		      lines)))
    (ivy-read "process: " candidates
	      :action
	      '(1
		("k" (lambda (cand) (message "%s" (ivy-ps-pid cand))))))))

(provide 'smax-ivy)

;;; smax-ivy.el ends here
;; * Helpers
(defun mk-anti-ivy-advice (func &rest args)
  "Temporarily disable Ivy and call function FUNC with arguments ARGS."
  (interactive)
  (let ((completing-read-function #'completing-read-default))
    (if (called-interactively-p 'any)
        (call-interactively func)
      (apply func args))))

(defun mk-disable-ivy (command)
  "Disable IDO when command COMMAND is called."
  (advice-add command :around #'mk-anti-ivy-advice))
