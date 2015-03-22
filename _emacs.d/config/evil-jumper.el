(use-package evil-jumper
  :ensure evil-jumper
  :defer 5
  :config 
    (setq evil-jumper-auto-center t)
    (setq evil-jumper-file (concat temporary-file-directory "evil-jumps"))
    (setq evil-jumper-auto-save-interval 3600)
    (require 'evil-jumper)
    (global-evil-jumper-mode t))
