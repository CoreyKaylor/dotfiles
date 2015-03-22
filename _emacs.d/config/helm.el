(use-package helm
  :ensure t
  :defer 15
  :config
    (require 'helm-config)
    (helm-mode 1)
    (helm-autoresize-mode 1))

(use-package helm-ag
  :ensure t
  :defer 15
  :commands helm-ag)

(use-package helm-projectile
  :ensure t
  :defer 15
  :config
    (setq projectile-completion-system 'helm)
    (setq helm-projectile-fuzzy-match nil)
    (helm-projectile-on))
