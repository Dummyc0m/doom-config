;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; theme
(setq doom-theme 'doom-vibrant)

;; tabnine support
(def-package! company-tabnine
  :when (featurep! :completion company)
  :config
  (setq company-idle-delay 0)
  (setq company-show-numbers t)
  (company-prescient-mode -1)
  )

(setq-hook! 'lsp-mode-hook +lsp-company-backend '(company-tabnine :with company-lsp :separate))
(setq-hook! 'lsp-mode-hook
  company-transformers (remq 'company-prescient-transformer company-transformers)
  company-completion-finished-hook (remq 'company-prescient-completion-finished company-completion-finished-hook))

;; rust-analyzer
;; (after! rustic
;;   (setq rustic-lsp-server 'rust-analyzer))

;; inlay hints, doesn't work yet
(defun rust-analyzer--initialized? ()
  (when-let ((workspace (lsp-find-workspace 'rust-analyzer (buffer-file-name))))
    (eq 'initialized (lsp--workspace-status workspace))))

(defun rust-analyzer--update-inlay-hints (buffer)
  (if (and (rust-analyzer--initialized?) (eq buffer (current-buffer)))
      (lsp-send-request-async
       (lsp-make-request "rust-analyzer/inlayHints"
                         (list :textDocument (lsp--text-document-identifier)))
       (lambda (res)
         (remove-overlays (point-min) (point-max) 'rust-analyzer--inlay-hint t)
         (dolist (hint res)
           (-let* (((&hash "range" "label" "kind") hint)
                   ((beg . end) (lsp--range-to-region range))
                   (overlay (make-overlay beg end)))
             (overlay-put overlay 'rust-analyzer--inlay-hint t)
             (overlay-put overlay 'evaporate t)
             (overlay-put overlay 'after-string (propertize (concat ": " label)
                                                            'font-lock-face 'font-lock-comment-face)))))
       'tick))
  nil)

(defvar-local rust-analyzer--inlay-hints-timer nil)

(defun rust-analyzer--inlay-hints-change-handler (&rest rest)
  (when rust-analyzer--inlay-hints-timer
    (cancel-timer rust-analyzer--inlay-hints-timer))
  (setq rust-analyzer--inlay-hints-timer
        (run-with-idle-timer 0.1 nil #'rust-analyzer--update-inlay-hints (current-buffer))))

(define-minor-mode rust-analyzer-inlay-hints-mode
  "Mode for showing inlay hints."
  nil nil nil
  (cond
   (rust-analyzer-inlay-hints-mode
    (rust-analyzer--update-inlay-hints (current-buffer))
    (add-hook 'lsp-after-initialize-hook #'rust-analyzer--inlay-hints-change-handler nil t)
    (add-hook 'after-change-functions #'rust-analyzer--inlay-hints-change-handler nil t))
   (t
    (remove-overlays (point-min) (point-max) 'rust-analyzer--inlay-hint t)
    (remove-hook 'lsp-after-initialize-hook #'rust-analyzer--inlay-hints-change-handler t)
    (remove-hook 'after-change-functions #'rust-analyzer--inlay-hints-change-handler t))))

(add-hook! 'rustic-mode-hook #'rust-analyzer-inlay-hints-mode)

(load! "tutch/tutch-mode.el")
(add-to-list 'auto-mode-alist '("\\.tut\\'" . tutch-mode ))
