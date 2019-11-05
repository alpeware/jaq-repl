;;; jaq-repl --- CLJC HTTP REPL

;;; Commentary:
;; A Clojure(Script) HTTP REPL for use with JAQ

;;; Code:

(require 'clojure-mode)

(setq *jaq-endpoint* "https://PROJECT-ID.appspot.com/repl")
(setq *jaq-device-id* "JAQ-DEVICE-ID")
(setq *jaq-repl-token* "JAQ-REPL-TOKEN")
(setq *jaq-repl-type* ":clj")
(setq *jaq-broadcast* "false")
(setq *jaq-buffer* "*jaq-clojure*")
(setq *jaq-session* "*jaq-repl-session*")


;;; util
(defun jaq-delete-headers (buf)
  (with-current-buffer buf
    (goto-char url-http-end-of-headers)
    (forward-char)
    (delete-region (point-min) (point))
    (buffer-string)))

(defun jaq-buffer-mode (buffer-or-string)
  "Returns the major mode associated with a buffer."
  (with-current-buffer buffer-or-string
    major-mode))

;;;; eval
(defun jaq-eval-repl (endpoint device-id repl-type broadcast form)
  (let ((url endpoint)
        (url-request-method "POST")
        (url-request-extra-headers `(("Content-Type" . "application/x-www-form-urlencoded")))
        (url-request-data (concat "form" "=" (url-hexify-string (format "%s" form))
                                  "&repl-type=" repl-type
                                  "&broadcast=" broadcast
                                  "&device-id=" device-id
                                  "&repl-token=" *jaq-repl-token*)))
    (url-retrieve url
                  (lambda (result)
                    (switch-to-buffer (current-buffer))
                    (goto-char url-http-end-of-headers)
                    (forward-char)
                    (delete-region (point-min) (point))
                    (let ((str (buffer-substring-no-properties (point-min) (point-max))))
                      (kill-buffer (current-buffer))
                      (with-current-buffer (get-buffer-create *jaq-buffer*)
                        (insert str)
                        (goto-char (point-max))
                        (set-window-point
                         (get-buffer-window (current-buffer) 'visible)
                         (point-max))))))))

(defun jaq-eval-region (start end &optional and-go)
  (interactive "r\nP")
  (let ((str (replace-regexp-in-string
              "[\n]+\\'" ""
              (buffer-substring-no-properties start end))))
    (with-current-buffer (get-buffer-create *jaq-session*)
      (insert (concat str "\n")))
    (jaq-eval-repl *jaq-endpoint* *jaq-device-id* *jaq-repl-type*
                   *jaq-broadcast* str))
  (when and-go (pop-to-buffer (get-buffer-create *jaq-buffer*))))

(defun jaq-eval-sexp (&optional and-go)
  (interactive "P")
  (jaq-eval-region (save-excursion (backward-sexp) (point)) (point) and-go))

(global-set-key (kbd "C-x C-j") 'jaq-eval-sexp)

;;; eval buffer
(defun jaq-eval-buffer (&optional and-go)
  (interactive "P")
  (let ((str (format
              "(jaq.repl/load-string %s)"
              (prin1-to-string (buffer-substring-no-properties (point-min) (point-max))))))
    (jaq-eval-repl *jaq-endpoint* *jaq-device-id* *jaq-repl-type*
                   *jaq-broadcast* str)))

(global-set-key (kbd "C-x C-h") 'jaq-eval-buffer)


;;; post buffer
(defun jaq-post-buffer (file-name)
  (interactive "bFile name: ")
  (let ((body (buffer-substring-no-properties (point-min) (point-max)))
        (str (format
              "(jaq.repl/save-file %s %s)"
              (prin1-to-string file-name)
              (prin1-to-string (buffer-substring-no-properties (point-min) (point-max))))))
    (jaq-eval-repl *jaq-endpoint* *jaq-device-id* ":clj"
                   *jaq-broadcast* str)))

(global-set-key (kbd "C-x C-k") 'jaq-post-buffer)

;;;; get buffer
(defun jaq-get-file (endpoint device-id repl-type broadcast file-name)
  (let ((url endpoint)
        (url-request-method "POST")
        (url-request-extra-headers `(("Content-Type" . "application/x-www-form-urlencoded")))
        (url-request-data (concat "form" "=" (url-hexify-string
                                              (format
                                               "(jaq.repl/get-file %s)"
                                               (prin1-to-string file-name)))
                                  "&repl-type=" repl-type
                                  "&broadcast=" broadcast
                                  "&device-id=" device-id
                                  "&repl-token=" *jaq-repl-token*)))
    (setq bname file-name)
    (url-retrieve url
                  (lambda (result)
                    (switch-to-buffer (current-buffer))
                    (goto-char url-http-end-of-headers)
                    (forward-char)
                    (delete-region (point-min) (point))
                    (let ((str (buffer-substring-no-properties (point-min) (point-max))))
                      ;;(append-to-buffer (get-buffer-create bname) (point-min) (point-max))
                      (kill-buffer (current-buffer))
                      (get-buffer-create bname)
                      (switch-to-buffer (get-buffer bname))
                      (insert (read str))
                      (funcall (intern "clojure-mode")))))))

(defun jaq-get-buffer (file-name)
  (interactive "sFile name: ")
  (jaq-get-file *jaq-endpoint* *jaq-device-id* ":clj"
                *jaq-broadcast* file-name))

(global-set-key (kbd "C-x C-l") 'jaq-get-buffer)

(defun jaq-switch-repl-type ()
  (interactive)
  (setq *jaq-repl-type*
        (if (string= *jaq-repl-type* ":clj")
            ":cljs"
          ":clj"))
  (message "Switched REPL type to: %s" *jaq-repl-type*))

(global-set-key (kbd "C-x C-y") 'jaq-switch-repl-type)

(provide 'jaq-eval-repl)
