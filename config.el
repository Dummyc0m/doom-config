;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; latex
(setq +latex-viewers '(zathura okular evince pdf-tools))

;; theme
(setq doom-theme 'doom-vibrant)

;; tabnine support
;; (def-package! company-tabnine
;;   :when (featurep! :completion company)
;;   :config
;;   (setq company-idle-delay 0)
;;   (setq company-show-numbers t)
;;   (company-prescient-mode -1)
;;   )

;; (setq-hook! 'lsp-mode-hook +lsp-company-backend '(company-tabnine :with company-lsp :separate))
;; (setq-hook! 'lsp-mode-hook
;;   company-transformers (remq 'company-prescient-transformer company-transformers)
;;   company-completion-finished-hook (remq 'company-prescient-completion-finished company-completion-finished-hook))

;; rust-analyzer
(setq rustic-lsp-server 'rust-analyzer)

(setq company-minimum-prefix-length 2)

(setq lsp-rust-analyzer-server-display-inlay-hints t)
(setq lsp-rust-analyzer-max-inlay-hint-length 16)
(setq lsp-rust-analyzer-cargo-watch-enable t)
(setq lsp-rust-analyzer-cargo-watch-command "watch -x clippy")

(map! :map rustic-mode-map :n "S-j" #'lsp-rust-analyzer-join-lines)
(map! :map lsp-mode-map :n "g d" #'lsp-find-definition)
(map! :map lsp-mode-map :n "g e" #'lsp-find-references)
(map! :map lsp-mode-map :n "K" #'lsp-describe-thing-at-point)
(map! :map rustic-mode-map :leader "r x" #'lsp-rust-analyzer-expand-macro)
(map! :map rustic-mode-map :leader "r i" #'lsp-execute-code-action)

;; tutch
(load! "tutch/tutch-mode.el")
(add-to-list 'auto-mode-alist '("\\.tut\\'" . tutch-mode ))

;; hacky fix for spell module
(setq ispell-dictionary "en_US")
