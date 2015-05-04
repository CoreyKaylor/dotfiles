(require 'use-package)
(use-package multi-term
  :ensure t
  :defer
  :config
  (setq multi-term-program "/bin/zsh"))

(add-hook 'term-mode-hook
          (lambda ()
            (define-key term-raw-map (kbd "C-j") 'windmove-down)
            (define-key term-raw-map (kbd "C-l") 'windmove-right)
            (define-key term-raw-map (kbd "C-k") 'windmove-up)
            (define-key term-raw-map (kbd "C-h") 'windmove-left)))
