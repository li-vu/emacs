(add-to-list 'auto-mode-alist '("\\.sal\\'" . sal-mode))

(setq sal-mode-syntax-table (make-syntax-table))
;; Underscores are allowed as "symbol constituent"
(modify-syntax-entry ?_  "w"  sal-mode-syntax-table)
(set-syntax-table sal-mode-syntax-table)

;; Syntax highlighting
(defvar sal-keywords
  '("begin" "end" "module" "initialization" "transition" "type" "local" "input" "output" "theorem" "context" "if" "then" "else" "endif" "definition" "rename" "array" "elsif" "lambda" "claim" "exists" "false" "true" "let" "in" "global" "lemma" "of" "with" "obligation" "to" "forall") )
(defvar sal-operators
  '("or" "and" "not" "x" "g" "f" "xor") )
(defvar sal-types
  '("boolean" "int" "natural" "nznatural" "nzinteger" "integer" "real" "nzreal" "nzint" "nat" "nznat") )
(defvar sal-font-lock-defaults
  `((
     ("^[ \t]*%.*$" . font-lock-comment-face)
     ( ,(regexp-opt sal-keywords 'words) . font-lock-builtin-face)
     ("\\(-->\\|\\[]\\||-\\)" . font-lock-builtin-face)
     ("\\(=>?\\|<=?\\|>=?\\|+\\|*\\|/\\|-\\)" . font-lock-function-name-face)
     ( ,(regexp-opt sal-operators 'words) . font-lock-function-name-face)
                                        ;     ("=[ \t]*\\w+" . font-lock-string-face)
                                        ;     (":[ \t]*\\w+" . font-lock-type-face)
     ("\\b[A-Z]\\w*\\b" . font-lock-type-face)
     ( ,(regexp-opt sal-types 'words) . font-lock-type-face)
     ("\\b[\\w\\[\\]]+'" . font-lock-variable-name-face)
     ("{[^}]+}" . font-lock-string-face)
     ("\\b[0-9]+\\b" . font-lock-string-face)
                                        ;     ("\\b\\w+\\b" . font-lock-constant-face)
     )))

;; Clear memory
(setq sal-keywords nil)
(setq sal-operators nil)

;; Indentation
(defun sal-indent-line ()
  "Indent current line as SAL code."
  (interactive)
  (beginning-of-line)
  (if (bobp)
      (indent-line-to 0)           ; First line is always non-indented
    (let ((not-indented t) cur-indent (is-brackets (looking-at "^[ \t]*\\[\\]")))
      (if (looking-at "^[ \t]*\\(END\\|\\]\\)") ; If the line we are looking at is the end of a block, then decrease the indentation
          (progn
            (save-excursion
              (forward-line -1)
              (setq cur-indent (- (current-indentation) tab-width)))
            (if (< cur-indent 0) ; We can't indent past the left margin
                (setq cur-indent 0)))
        (save-excursion
          (while not-indented ; Iterate backwards until we find an indentation hint
            (forward-line -1)
            (if (looking-at "^[ \t]*\\(END\\|\\]\\)") ; This hint indicates that we need to indent at the level of the end token
                (progn
                  (setq cur-indent (current-indentation))
                  (setq not-indented nil))
              (if (looking-at "^[ \t]*\\(BEGIN\\|TRANSITION\\)") ; This hint indicates that we need to indent an extra level
                  (progn
                    (setq cur-indent (+ (current-indentation)
                                        (if is-brackets
                                            (/ tab-width 2)
                                          tab-width))) ; Do the actual indenting
                    (setq not-indented nil))
                (if (bobp)
                    (setq not-indented nil)))))))
      (if cur-indent
          (indent-line-to cur-indent)
        (indent-line-to 0))))) ; If we didn't see an indentation hint, then allow no indentation

;; Entry point
(define-derived-mode sal-mode fundamental-mode "SAL"
  "Major mode for editing SRI SAL files."
  (setq comment-start "%")
  (setq comment-end "")
  (setq font-lock-defaults sal-font-lock-defaults)
  (setq indent-line-function 'sal-indent-line)
  )

(provide 'sal-mode)
