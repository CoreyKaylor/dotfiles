(defun my-csharp-mode ()
  (add-to-list 'company-backends 'company-omnisharp)
  (omnisharp-mode)
  (company-mode)
  (turn-on-eldoc-mode))
  ;;(flycheck-mode))

(use-package omnisharp
  :ensure t
  :mode ("\\.cs\\'" . csharp-mode)
  :init (add-hook 'csharp-mode-hook 'my-csharp-mode)
  :config 
    (setq omnisharp-company-do-template-completion t)

    (evil-define-key 'normal omnisharp-mode-map (kbd "g d") 'omnisharp-go-to-definition)
    (evil-leader/set-key
      "rt" (lambda() (interactive) (omnisharp-unit-test "single"))
      "rf" (lambda() (interactive) (omnisharp-unit-test "fixture"))
      "ra" (lambda() (interactive) (omnisharp-unit-test "all"))
      "fu" 'omnisharp-helm-find-usages
      "cf" 'omnisharp-code-format
      "b"  'omnisharp-build-in-emacs
      "fi" 'omnisharp-find-implementations
      "fx" 'omnisharp-fix-usings
    ))
 
