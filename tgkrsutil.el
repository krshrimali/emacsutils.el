;;; tgkrsutil.el --- Tree-sitter utilities for Python -*- lexical-binding: t; -*-
(require 'tree-sitter)
(require 'tree-sitter-langs)

;; Helpers

(defun tgkrsutil--python-node-text (node)
  (buffer-substring-no-properties (tsc-node-start-position node)
                                  (tsc-node-end-position node)))

(defun tgkrsutil--python-current-node ()
  "Return the smallest named node at point."
  (when tree-sitter-tree
    (let* ((tree (tsc-root-node tree-sitter-tree))
           (point-pos (point)))
      (tsc-get-named-descendant-for-position-range tree point-pos point-pos))))

(defun tgkrsutil--python-find-parent (node predicate)
  "Find nearest parent matching predicate."
  (while (and node (not (funcall predicate node)))
    (setq node (tsc-get-parent node)))
  node)

(defun tgkrsutil--python-function-node-p (node)
  (string= (tsc-node-type node) "function_definition"))

(defun tgkrsutil--python-class-node-p (node)
  (string= (tsc-node-type node) "class_definition"))

(defun tgkrsutil--python-function-name (node)
  "Extract name from a Python function_definition node."
  (let ((name-node (tsc-get-child-by-field node :name)))
    (when name-node
      (tgkrsutil--python-node-text name-node))))

(defun tgkrsutil--popup-show (title content)
  "Show CONTENT with TITLE in a temporary popup buffer."
  (let* ((bufname "*tgkrsutil-popup*")
         (buf (get-buffer-create bufname)))
    (with-current-buffer buf
      (read-only-mode -1)
      (erase-buffer)
      (insert (propertize (format "%s\n\n" title)
                          'face '(:height 1.3 :weight bold)))
      (insert content)
      (goto-char (point-min))
      (read-only-mode 1))
    (display-buffer buf '((display-buffer-pop-up-window)))
    ;; Optional: allow easy close with `q`
    (with-current-buffer buf
      (local-set-key (kbd "q") #'quit-window))))

;; Function utilities

(defun tgkrsutil-python-copy-parent-function ()
  "Copy Python parent function to clipboard."
  (interactive)
  (let* ((node (tgkrsutil--python-current-node))
         (fn-node (tgkrsutil--python-find-parent node #'tgkrsutil--python-function-node-p)))
    (if fn-node
        (progn
          (kill-new (tgkrsutil--python-node-text fn-node))
          (message "Copied parent function."))
      (message "No parent function found."))))

(defun tgkrsutil-python-show-function-signature ()
  "Show parent function's name and parameters."
  (interactive)
  (let* ((node (tgkrsutil--python-current-node))
         (func-node (tgkrsutil--python-find-parent node #'tgkrsutil--python-function-node-p)))
    (if (not func-node)
        (message "No parent function found.")
      (let* ((name (or (tgkrsutil--python-function-name func-node) "<anonymous>"))
             (params-node (tsc-get-child-by-field func-node :parameters))
             (params (if params-node (tgkrsutil--python-node-text params-node) "()")))
        (message "- Function: %s%s" name params)))))

(defun tgkrsutil-python-popup-function-signature ()
  "Popup parent function's name and parameters."
  (interactive)
  (let* ((node (tgkrsutil--python-current-node))
         (func-node (tgkrsutil--python-find-parent node #'tgkrsutil--python-function-node-p)))
    (if (not func-node)
        (message "No parent function found.")
      (let* ((name (or (tgkrsutil--python-function-name func-node) "<anonymous>"))
             (params-node (tsc-get-child-by-field func-node :parameters))
             (params (if params-node (tgkrsutil--python-node-text params-node) "()"))
             (file (or (buffer-file-name) "")))
        (tgkrsutil--popup-show
         "Function Signature"
         (format "- Name: %s\n- Parameters: %s\n- File: %s" name params file))))))

;; Class utilities

(defun tgkrsutil-python-copy-parent-class ()
  "Copy Python parent class to clipboard."
  (interactive)
  (let* ((node (tgkrsutil--python-current-node))
         (class-node (tgkrsutil--python-find-parent node #'tgkrsutil--python-class-node-p)))
    (if class-node
        (progn
          (kill-new (tgkrsutil--python-node-text class-node))
          (message "Copied parent class."))
      (message "No parent class found."))))

(defun tgkrsutil-python-show-class-signature ()
  "Show class definition line."
  (interactive)
  (let* ((node (tgkrsutil--python-current-node))
         (class-node (tgkrsutil--python-find-parent node #'tgkrsutil--python-class-node-p)))
    (if (not class-node)
        (message "No parent class found.")
      (let* ((line (car (split-string (tgkrsutil--python-node-text class-node) "\n"))))
        (message "- Class: %s" (string-trim line))))))

(defun tgkrsutil-python-popup-class-signature ()
  "Popup class name and declaration line."
  (interactive)
  (let* ((node (tgkrsutil--python-current-node))
         (class-node (tgkrsutil--python-find-parent node #'tgkrsutil--python-class-node-p)))
    (if (not class-node)
        (message "No parent class found.")
      (let* ((name-node (tsc-get-child-by-field class-node :name))
             (name (if name-node (tgkrsutil--python-node-text name-node) "<anonymous>"))
             (decl-line (car (split-string (tgkrsutil--python-node-text class-node) "\n")))
             (file (or (buffer-file-name) "")))
        (tgkrsutil--popup-show
         "Class Signature"
         (format "- Name: %s\n- Declaration: %s\n- File: %s"
                 name (string-trim decl-line) file))))))

;; Test command

(defun tgkrsutil-python-generate-test-command ()
  "Generate a pytest command for the current function."
  (interactive)
  (let* ((node (tgkrsutil--python-current-node))
         (fn-node (tgkrsutil--python-find-parent node #'tgkrsutil--python-function-node-p)))
    (if fn-node
        (let* ((fn-name (tgkrsutil--python-function-name fn-node))
               (file-name (buffer-file-name))
               (cmd (format "pytest \"%s\" -k \"%s\"" file-name fn-name)))
          (kill-new cmd)
          (message "Copied test command: %s" cmd))
      (message "No parent function found."))))

;; Keybindings (Doom Evil leader)

(map! :leader
      (:prefix ("r" . "Python utils")
       :desc "Copy parent function" "if" #'tgkrsutil-python-copy-parent-function
       :desc "Copy parent class" "ic" #'tgkrsutil-python-copy-parent-class
       :desc "Show function signature (echo)" "sf" #'tgkrsutil-python-show-function-signature
       :desc "Show class signature (echo)" "sc" #'tgkrsutil-python-show-class-signature
       :desc "Popup function signature" "pf" #'tgkrsutil-python-popup-function-signature
       :desc "Popup class signature" "pc" #'tgkrsutil-python-popup-class-signature
       :desc "Generate pytest command" "tc" #'tgkrsutil-python-generate-test-command))

(provide 'tgkrsutil)
;;; tgkrsutil.el ends here