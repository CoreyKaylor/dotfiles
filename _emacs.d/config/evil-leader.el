(use-package evil-leader
  :commands (evil-leader-mode)
  :ensure evil-leader
  :demand evil-leader
  :init
  (global-evil-leader-mode)
  :config
  (progn
    (evil-leader/set-leader ",")
    (evil-leader/set-key
      "e" 'find-file
      "b" 'switch-to-buffer
      "k" 'kill-buffer
      "w" 'save-buffer
      "gs" 'magit-status
      "gc" 'magit-commit
      "gl" 'magit-log
      "gn" 'git-gutter+-next-hunk
      "gp" 'git-gutter+-previous-hunk)
    )
  )
