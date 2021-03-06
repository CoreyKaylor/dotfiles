(require 'use-package)
(use-package js2-mode
  :ensure t
  :config
    (electric-pair-mode 1)
    (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
    (js2-mode-hide-warnings-and-errors)
    (setq js2-highlight-level 3)
    (defvar js-indent-level
      (setq js-indent-level 2))
    (custom-set-variables
     '(js2-basic-offset 2)))
