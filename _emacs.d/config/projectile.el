(require 'use-package)
(use-package projectile
  :ensure t
  :defer
  :bind-keymap ("C-c p" . projectile-command-map)
  :config
  (projectile-global-mode))
