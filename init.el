;;; init.el --- user-init-file                    -*- lexical-binding: t -*-
;;; Early birds
(progn ;     startup
  (defvar before-user-init-time (current-time)
    "Value of `current-time' when Emacs begins loading `user-init-file'.")
  (message "Loading Emacs...done (%.3fs)"
           (float-time (time-subtract before-user-init-time
                                      before-init-time)))
  (setq user-init-file (or load-file-name buffer-file-name))
  (setq user-emacs-directory (file-name-directory user-init-file))
  (message "Loading %s..." user-init-file)
  (setq package-enable-at-startup nil)
  ;; (package-initialize)
  (setq inhibit-startup-buffer-menu t)
  (setq inhibit-startup-screen t)
  (setq inhibit-startup-echo-area-message "locutus")
  (setq initial-buffer-choice t)
  (setq initial-scratch-message "")
  (scroll-bar-mode 0)
  (tool-bar-mode 0)
  (menu-bar-mode 1)
  (setq load-prefer-newer t))

(progn ;    `borg'
  (add-to-list 'load-path (expand-file-name "lib/borg" user-emacs-directory))
  (require  'borg)
  (borg-initialize))

(progn ;    `use-package'
  (require  'use-package)
  (setq use-package-verbose t))

(use-package auto-compile
  :demand t
  :config
  (auto-compile-on-load-mode)
  (auto-compile-on-save-mode)
  (setq auto-compile-display-buffer               nil)
  (setq auto-compile-mode-line-counter            t)
  (setq auto-compile-source-recreate-deletes-dest t)
  (setq auto-compile-toggle-deletes-nonlib-dest   t)
  (setq auto-compile-update-autoloads             t))

(use-package epkg
  :defer t
  :init (setq epkg-repository
              (expand-file-name "var/epkgs/" user-emacs-directory)))

(use-package custom
  :no-require t
  :config
  (setq custom-file (expand-file-name "custom.el" user-emacs-directory))
  (when (file-exists-p custom-file)
    (load custom-file)))

(progn ;     startup
  (message "Loading early birds...done (%.3fs)"
           (float-time (time-subtract (current-time)
                                      before-user-init-time))))

;;; Long tail

(use-package dash
  :config (dash-enable-font-lock))

(use-package diff-hl
  :config (setq diff-hl-draw-borders nil)
  :hook ((after-init . global-diff-hl-mode)
         (magit-post-refresh-hook . diff-hl-magit-post-refresh)))

(use-package dired
  :defer t
  :config (setq dired-listing-switches "-alh"))

(use-package eldoc
  :when (version< "25" emacs-version)
  :hook (after-init . global-eldoc-mode))

(use-package help
  :defer t
  :hook (after-init . temp-buffer-resize-mode))

(progn ;    `isearch'
  (setq isearch-allow-scroll t))

(use-package lisp-mode
  :config
  (add-hook 'emacs-lisp-mode-hook 'outline-minor-mode)
  (add-hook 'emacs-lisp-mode-hook 'reveal-mode)
  (defun indent-spaces-mode ()
    (setq indent-tabs-mode nil))
  (add-hook 'lisp-interaction-mode-hook #'indent-spaces-mode))

(use-package magit
  :defer t
  :config
  (magit-add-section-hook 'magit-status-sections-hook
                          'magit-insert-modules
                          'magit-insert-stashes
                          'append))

(use-package man
  :defer t
  :config (setq Man-width 80))

(use-package paren
  :config (show-paren-mode))

(defun indicate-buffer-boundaries-left ()
  (setq indicate-buffer-boundaries 'left))

(use-package prog-mode
  :hook (prog-mode . indicate-buffer-boundaries-left))

(use-package recentf
  :hook (after-init . recentf-mode)
  :config (setq recentf-max-saved-items 200))

(use-package exec-path-from-shell
  :config (setq exec-path-from-shell-variables '("PATH" "MANPATH" "PYTHONPATH" "GOPATH"))
  :hook (after-init . exec-path-from-shell-initialize))

(use-package savehist
  :config (setq enable-recursive-minibuffers t ; Allow commands in minibuffers
                history-length 1000
                savehist-additional-variables '(mark-ring
                                                global-mark-ring
                                                search-ring
                                                regexp-search-ring
                                                extended-command-history)
                savehist-autosave-interval 300)
  :hook (after-init . savehist-mode))

(use-package saveplace
  :when (version< "25" emacs-version)
  :hook (after-init . save-place-mode))

(use-package simple
  :hook (after-init . column-number-mode))

(use-package text-mode
  :hook (text-mode . indicate-buffer-boundaries-left))

(use-package tramp
  :defer t
  :config
  (add-to-list 'tramp-default-proxies-alist '(nil "\\`root\\'" "/ssh:%h:"))
  (add-to-list 'tramp-default-proxies-alist '("localhost" nil nil))
  (add-to-list 'tramp-default-proxies-alist
               (list (regexp-quote (system-name)) nil nil)))

(letrec ((print-loading-message (lambda (file-loaded start-time end-time &optional extra-message)
                                  (message "Loading %s...done (%.3fs)%s" file-loaded
                                           (float-time (time-subtract end-time start-time))
                                           (if extra-message (concat " " extra-message) "")))))
  ; startup
  (funcall print-loading-message user-init-file before-user-init-time (current-time))
  (add-hook 'after-init-hook (lambda () (funcall print-loading-message user-init-file before-user-init-time (current-time))))

  ; personalize
  (let ((org-file (expand-file-name (concat (user-real-login-name) ".org")
                                    user-emacs-directory)))
    (setq before-personal-init-time (current-time))

    (when (file-exists-p org-file)
      (org-babel-load-file org-file))

    (funcall print-loading-message org-file before-personal-init-time (current-time))))

;; Local Variables:
;; indent-tabs-mode: nil
;; End:
;;; init.el ends here
