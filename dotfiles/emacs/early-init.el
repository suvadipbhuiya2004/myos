
;; ~/.config/emacs/early-init.el

;; Temporarily maximize Garbage Collection to prevent startup pauses
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Strip away all GUI bloat immediately
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)

(setq menu-bar-mode nil
      tool-bar-mode nil
      scroll-bar-mode nil
      inhibit-startup-screen t
      inhibit-startup-echo-area-message user-login-name)

;; Prevent default package initialization (we handle this later)
(setq package-enable-at-startup nil)
