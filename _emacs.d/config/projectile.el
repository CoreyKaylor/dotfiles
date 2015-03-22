(use-package projectile
  :ensure t
  :commands projectile-global-mode
  :defer
  :bind-keymap ("C-c p" . projectile-command-map)
  :config
    (projectile-global-mode))
