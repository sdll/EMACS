(use-package haskell-mode
  :ensure t
  :init
  :config

  (add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
  (eval-after-load 'haskell-mode
    '(define-key haskell-mode-map [f2] 'haskell-navigate-imports))
  ;; necessary for hasktags
  (let ((my-cabal-path (expand-file-name "~/.cabal/bin")))
    (setenv "PATH" (concat my-cabal-path path-separator (getenv "PATH")))
    (add-to-list 'exec-path my-cabal-path))
  (custom-set-variables '(haskell-tags-on-save t))
  ;; stylish-haskell formatting on save
  (custom-set-variables '(haskell-stylish-on-save t))
  )
(use-package hindent
  :init
  :config
  (add-hook 'haskell-mode-hook 'hindent-mode))
(use-package rainbow-delimiters
  :init
  :config
  (add-hook 'haskell-mode-hook #'rainbow-delimiters-mode)
  )

(provide 'init-haskell)