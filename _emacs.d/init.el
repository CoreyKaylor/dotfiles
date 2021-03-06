(require 'package)
(setq package-archives
      '(("gnu"       . "http://elpa.gnu.org/packages/")
        ("original"  . "http://tromey.com/elpa")
        ("org"       . "http://orgmode.org/elpa/")
        ("marmalade" . "http://marmalade-repo.org/packages/")
        ("melpa"     . "http://melpa.milkbox.net/packages/")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(defvar required-packages
  (list 'use-package))

(dolist (package required-packages)
  (unless (package-installed-p package)
    (package-install package)))

(setq inhibit-splash-screen t
      inhibit-startup-echo-area-message t
      inhibit-startup-message t)
(setq shell-file-name "/bin/zsh")

(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

(require 'use-package)

(defun load-directory (dir)
  "`load' all elisp libraries in directory DIR which are not already loaded."
  (interactive "D")
  (let ((libraries-loaded (mapcar #'file-name-sans-extension
                                  (delq nil (mapcar #'car load-history)))))
    (dolist (file (directory-files dir t ".+\\.elc?$"))
      (let ((library (file-name-sans-extension file)))
        (unless (member library libraries-loaded)
          (load library nil t)
          (push library libraries-loaded))))))

(load-directory "~/.emacs.d/config/")

(set-face-attribute 'default nil :height 140 :font "Consolas")

(fset 'yes-or-no-p 'y-or-n-p)
(setq-default indent-tabs-mode nil)
(define-key global-map (kbd "RET") 'newline-and-indent)
(tool-bar-mode 0)
(global-linum-mode 1)
(setq whitespace-style (quote (spaces tabs space-mark tab-mark)))

(toggle-frame-maximized)

(global-set-key (kbd "C-c w h") 'windmove-left)
(global-set-key (kbd "C-c w l") 'windmove-right)
(global-set-key (kbd "C-c w j") 'windmove-down)
(global-set-key (kbd "C-c w k") 'windmove-up)
