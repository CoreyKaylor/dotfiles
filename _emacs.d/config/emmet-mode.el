(use-package emmet-mode
  :ensure emmet-mode
  :config (add-hook 'sgml-mode-hook 'emmet-mode)
					(add-hook 'css-mode-hook 'emmet-mode))
