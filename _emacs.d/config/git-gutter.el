(require 'use-package)
(use-package git-gutter
  :ensure t
  :defer
  :config (git-gutter:linum-setup))
