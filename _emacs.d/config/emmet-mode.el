(require 'use-package)
(use-package emmet-mode
  :ensure t
  :init (autoload 'emmet-mode "emmet-mode" nil t)
  (add-hook 'sgml-mode-hook 'emmet-mode)
  (add-hook 'css-mode-hook 'emmet-mode))
