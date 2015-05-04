(require 'use-package)
(use-package evil-leader
  :ensure t
  :defer 5
  :config
    (global-evil-leader-mode)
    (evil-leader/set-leader ",")
    (evil-leader/set-key
      "e" 'find-file
      "b" 'switch-to-buffer
      "k" 'kill-buffer
      "w" 'save-buffer
      "ff" 'helm-projectile-find-file
      "gf" 'helm-projectile-find-file-dwim
      "gs" 'magit-status
      "gc" 'magit-commit
      "gl" 'magit-log
      "gg" 'git-gutter-mode
      "gn" 'git-gutter:next-hunk
      "gp" 'git-gutter:previous-hunk
      "gh" 'git-gutter:stage-hunk
      "gr" 'git-gutter:revert-hunk))
