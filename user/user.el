(setq initial-buffer-choice "~/ORG/map.org")
(if (version< emacs-version "25.0")
    (progn
      (require 'saveplace)
      (setq-default save-place t))
  (save-place-mode 1))
(setq vc-follow-symlinks nil)
(require 'init-haskell)
(require 'init-latex)
(require 'init-locales)
(require 'init-notes)
(require 'init-email)
(require 'init-yas)
(require 'init-utils)
(require 'init-bookmarks)
(require 'init-blog)
(require 'init-c)
