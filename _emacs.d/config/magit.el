(use-package magit
  :ensure magit
  :config
  (progn
    (evil-set-initial-state 'magit-mode 'normal)
    (evil-set-initial-state 'magit-status-mode 'normal)
    (evil-set-initial-state 'magit-diff-mode 'normal)
    (evil-set-initial-state 'magit-log-mode 'normal)
    (evil-define-key 'normal magit-mode-map
        "j" 'magit-goto-next-section
        "k" 'magit-goto-previous-section)
    (evil-define-key 'normal magit-log-mode-map
        "j" 'magit-goto-next-section
        "k" 'magit-goto-previous-section)
    (evil-define-key 'normal magit-diff-mode-map
        "j" 'magit-goto-next-section
        "k" 'magit-goto-previous-section)))
