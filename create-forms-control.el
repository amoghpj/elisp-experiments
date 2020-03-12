;;; create-forms-control.el --- Use file headers to create a control file for forms-mode.el

;;; Commentary:
;; Automatically create a control file by looking a the
;; header of a file.  Prompts user for field separator, currently
;; limited to TAB or COMMA.

;;; Code:
(defun create-forms-mode-control-file ()
  "Prompt user for filename FNAME and separator SEPARATOR."
  (interactive)
  (setq fname (read-file-name "Enter file name: "))
  (setq sep-choice (completing-read "Specify separator: " '("TAB" "COMMA")))
  (cond ((string= sep-choice "TAB") (setq separator "\t"))
        ((string= sep-choice "COMMA") (setq separator ",")))
  (make-ctrl-file-body fname separator)
  )

(defun make-ctrl-file-body (fname separator)
  "Make the control file.
Takes arguments FNAME and SEPARATOR"
  (setq colnames (get-header fname separator))
  (setq numcols  (length colnames))
  (setq contents (format (concat
                                "(setq forms-file \"%s\")\n"
                                "(setq forms-number-of-fields %s)\n"
                                "(setq forms-read-only t)\n"
                                (concat "(setq forms-field-sep \"" separator "\")\n")
                                "(setq forms-format-list\n    (list"
                                "\n   \"========%s========\\n\\n\"")
                               fname numcols fname))
  (setq i 0)
  (while (< i numcols)
    (message "%s" i)
    (setq contents
          (concat
           contents
           "\n   \"" (nth i colnames) ": \"     "
           (number-to-string (1+ i))
           "\n   \"\\n\"")
          )
    (setq i (1+ i)))
  (setq contents (concat contents "))"))
  (write-region contents nil (concat fname ".ctrl"))
  )


(defun get-header (fname separator)
  "Return the headers in the file.
This takes the function name FNAME and
the seperator SEPARATOR as arguments"
  (with-temp-buffer
    (insert-file-contents fname)
    (split-string (buffer-substring
                   (point-at-bol)
                   (point-at-eol))
                  separator)))

;;; create-forms-control.el ends here

