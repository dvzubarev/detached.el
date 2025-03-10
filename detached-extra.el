;;; detached-extra.el --- Detached integration for external packages -*- lexical-binding: t -*-

;; Copyright (C) 2022  Free Software Foundation, Inc.

;; This file is part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides a collection of functionality to integrate `detached' with external packages.

;;; Code:

;;;; Requirements
(require 'detached)

(declare-function detached-compile "detached")
(declare-function detached-start-session "detached")
(declare-function detached-session-command "detached")

(declare-function alert "alert")

(defvar detached-session-origin)
(defvar detached-local-session)
(defvar detached-enabled)

(defcustom detached-extra-ntfysh-topic nil
  "Topic for ntfy.sh for publishing alerts."
  :type 'string :group 'detached)
(defcustom detached-extra-ntfysh-server "https://ntfy.sh"
  "Ntfy.sh server, you can specify your own self-hosted server here."
  :type 'string :group 'detached)


;;;; Functions

;;;###autoload
(defun detached-extra-projectile-run-compilation (cmd &optional use-comint-mode)
  "If CMD is a string execute it with `detached-compile'.

Optionally USE-COMINT-MODE"
  (if (functionp cmd)
	  (funcall cmd)
	(let ((detached-session-origin 'projectile))
	  (detached-compile cmd use-comint-mode))))

;;;###autoload
(defun detached-extra-dired-rsync (command _details)
  "Run COMMAND with `detached'."
  (let* ((detached-local-session t)
		 (detached-session-origin 'rsync)
         (detached-session-mode 'detached)
         (session (detached-create-session command)))
	(detached-start-session session)))

;;;###autoload
(defun detached-extra-alert-notification (session)
  "Send an `alert' notification when SESSION becomes inactive."
  (let ((status (detached-session-status session))
		(host (detached-session-host-name session)))
	(alert (detached-session-command session)
		   :title (pcase status
					('success (format "Detached finished [%s]" host))
					('failure (format "Detached failed [%s]" host)))
		   :severity (pcase status
					   ('success 'moderate)
					   ('failure 'high)))))


;;;###autoload
(defun detached-extra-launch-cmd-w-detached (key-sequence)
  "This function allow to enable detached per command.
KEY-SEQUENCE is the command that should start in detached session. For
example, this command is bound to a <C-;> and compile is bound to <C-c C-c>,
 then after key sequence - <C-; C-c C-c> compilation will start in
detached session."
  (interactive
   (list (read-key-sequence "Press key: ")))
  (when-let* ((sym (key-binding key-sequence))
              ((commandp sym t)))
    (let ((detached-enabled t))
      (call-interactively sym))))


;;;###autoload
(defun detached-extra-dirvish (dirvish-yank--start-proc command details)
  "Run dirvish COMMAND with `detached'."

  (if detached-enabled
      (progn
        (when (listp command)
          (user-error "Unable to create detach session on commands that are in form of a list!"))
        (let* ((detached-local-session t)
               (detached-session-origin 'rsync)
               (detached-session-mode 'detached)
               (session (detached-create-session (string-replace "\"" "\\\"" command))))
          (detached-start-session session)))

    (funcall dirvish-yank--start-proc command details)))


;;;###autoload
(defun detached-extra--ntfysh-publish-message (session)
  "Send message via ntfy.sh when SESSION beocmes inactive."
  (when (null detached-extra-ntfysh-topic)
    (user-error "Set ntfy.sh topic in 'detached-extra-ntfysh-topic'!"))
  (let ((status (detached-session-status session))
        (host (detached-session-host-name session)))
    ;; TODO error handling
    (start-process "detached-nfty-sh" nil "curl"
                   "-H" (format "Title: %s" (pcase status
                                              ('success (format "Detached finished [%s]" host))
                                              ('failure (format "Detached failed [%s]" host))))
                   "-H" (format "Tags: %s" (pcase status
                                             ('success "white_check_mark")
                                             ('failure "x")))
                   "-H" (format "Priority: %s" (pcase status
                                                 ('success "default")
                                                 ('failure "high")))
                   "-d" (detached-session-command session)
                   (format "%s/%s"
                           detached-extra-ntfysh-server
                           detached-extra-ntfysh-topic))))


(provide 'detached-extra)

;;; detached-extra.el ends here
