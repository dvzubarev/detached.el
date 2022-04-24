<a href="http://elpa.gnu.org/packages/dtache.html"><img alt="GNU ELPA" src="https://elpa.gnu.org/packages/dtache.svg"/></a>

<a href="http://elpa.gnu.org/devel/dtache.html"><img alt="GNU-devel ELPA" src="https://elpa.gnu.org/devel/dtache.svg"/></a>

<a href="https://melpa.org/#/dtache"><img alt="MELPA" src="https://melpa.org/packages/dtache-badge.svg"/></a>

<a href="https://stable.melpa.org/#/dtache"><img alt="MELPA Stable" src="https://stable.melpa.org/packages/dtache-badge.svg"/></a>

<a href="https://builds.sr.ht/~niklaseklund/dtache/commits/main/.build.yml"><img alt="Build" src="https://builds.sr.ht/~niklaseklund/dtache/commits/main/.build.yml.svg"/></a>


# Introduction

Dtache is a package to run, and interact with, shell commands that are completely detached from Emacs itself. The package achieves this functionality by launching the commands with the program [dtach](https://github.com/crigler/dtach). Even though the commands are run decoupled, the package makes sure the integration to Emacs is seamless. The advantage is that the processes are insensitive to Emacs being killed, and this holds true for remote hosts as well, essentially making `dtache` a lightweight alternative to [Tmux](https://github.com/tmux/tmux) or [GNU Screen](https://www.gnu.org/software/screen/).

Another advantage of `dtache` is that in order to implement the detached feature it actually represents the processes as text inside of Emacs. This enables features such as history of all session outputs, possibility to diff session outputs etc.

The following videos about `dtache`. They are currently a bit outdated but the core concept is still true.

-   [Dtache - An Emacs package that provides detachable shell commands](https://www.youtube.com/watch?v=if1W58SrClk)
-   [Dtache - Version 0.2](https://www.youtube.com/watch?v=De5oXdnY5hY)


## Features

The way `dtache` is designed with its `dtache-session` objects opens up the possibilities for the following features.


### Output

The user always have access to the session's output. The user never needs to fear that the output history of the terminal is not enough to capture all of its output. Also its pretty handy to be able to go back in time and see the output from a session you ran earlier today. Having access to the output as well as the other information from the session makes it possible to compile a session using Emacs built in functionality. This enables navigation between errors in the output as well as proper syntax highlighting. This is something `dtache` will do automatically if it detects that you are opening the output of a session with status `failure`.


### Notifications

Start a session and then focus on something else. `Dtache` will notify you when the session has become inactive.


### Metadata

The session always contain metadata, such as when the session was started, for how long it has been running (if it is active), how long it ran (if it is inactive).


### Annotations

Arbitrary metadata can be captured when a session is started. An example further down is how to leverage this feature to capture the git branch for a session.


### Remote

Proper support for running session on a remote host. See the `Remote suppport` section of the README for further details on how to configure `dtache` to work for a remote host.


### Actions

The package provides commands that can act on a session. There is the functionality to `kill` an active session, to `rerun` a session, or `diff` two sessions.


### Persistent

The sessions are made persistent by writing the `dtache-session` objects to file. This makes it possible for Emacs to resume the knowledge of prior sessions when Emacs is restarted.


# Installation

The package is available on [GNU ELPA](https://elpa.gnu.org) and [MELPA](https://melpa.org/), and for users of the [GNU Guix package manager](https://guix.gnu.org/) there is a guix package.


# Configuration

The prerequisite for `dtache` is that the user has the program `dtach` installed.


## Use-package example

A minimal configuration for `dtache`.

    (use-package dtache
      :hook (after-init . dtache-setup)
      :bind (([remap async-shell-command] . dtache-shell-command)))


# Commands


## Creating a session

There are tree different ways to create a dtache session.

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Function</th>
<th scope="col" class="org-left">Description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left"><code>dtache-shell-command</code></td>
<td class="org-left">Called from M-x</td>
</tr>


<tr>
<td class="org-left"><code>dtache-shell-send-input</code></td>
<td class="org-left">Called from inside M-x shell</td>
</tr>


<tr>
<td class="org-left"><code>dtache-eshell-send-input</code></td>
<td class="org-left">Called from inside eshell</td>
</tr>


<tr>
<td class="org-left"><code>dtache-compile</code></td>
<td class="org-left">Called from M-x</td>
</tr>


<tr>
<td class="org-left"><code>dtache-org</code></td>
<td class="org-left">Used in org-babel src blocks</td>
</tr>


<tr>
<td class="org-left"><code>dtache-start-session</code></td>
<td class="org-left">Called from within a function</td>
</tr>
</tbody>
</table>

The `dtache-shell-command` is for the Emacs users that are accustomed to running shell commands from `M-x shell-command` or `M-x async-shell-command`. The `dtache-shell-send-input` is for those that want to run a command through `dtache` when inside a `shell` buffer. The `dtache-eshell-send-input` is the equivalent for `eshell`. The `dtache-compile` is supposed to be used as a replacement for `compile`. The `dtache-org` provides integration with `org-babel` in order to execute shell source code blocks with `dtache`. Last there is the `dtache-start-session` function, which users can utilize in their own custom commands.

To detach from a `dtache` session you should use the universal `dtache-detach-session` command. The keybinding for this command is defined by the `dtache-detach-key` variable, which by default has the value `C-c C-d`.


## Interacting with a session

To interact with a session `dtache` provides the command `dtache-open-session`. This provides a convenient completion interface, enriched with annotations to provide useful information about the sessions. The `dtache-open-session` command is implemented as a do what I mean command. This results in `dtache` performing different actions depending on the state of a session. The actions can be configured based on the `origin` of the session. The user can have one set of configurations for sessions started in `shell` which is different from those started in `compile`.

The actions are controlled by the customizable variables named `dtache-.*-session-action`. They come preconfigured but if you don't like the behavior of `dtache-open-session` these variables allows for tweaking the experience.

-   If the session is `active`, call the sessions `attach` function
-   If the session is `inactive` call the sessions `view` function, which by default performs a post-compile on the session if its status is `failure` otherwise the sessions raw output is opened.
    
    The package also provides additional commands to interact with a session.

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Command (Keybinding)</th>
<th scope="col" class="org-left">Description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">dtache-view-session (v)</td>
<td class="org-left">View a session's output</td>
</tr>


<tr>
<td class="org-left">dtache-attach-session (a)</td>
<td class="org-left">Attach to a session</td>
</tr>


<tr>
<td class="org-left">dtache-tail-session  (t)</td>
<td class="org-left">Tail the output of an active session</td>
</tr>


<tr>
<td class="org-left">dtache-diff-session (=)</td>
<td class="org-left">Diff a session with another session</td>
</tr>


<tr>
<td class="org-left">dtache-compile-session (c)</td>
<td class="org-left">Open the session output in compilation mode</td>
</tr>


<tr>
<td class="org-left">dtache-rerun-session (r)</td>
<td class="org-left">Rerun a session</td>
</tr>


<tr>
<td class="org-left">dtache-insert-session-command (i)</td>
<td class="org-left">Insert the session's command at point</td>
</tr>


<tr>
<td class="org-left">dtache-copy-session-command (w)</td>
<td class="org-left">Copy the session's shell command</td>
</tr>


<tr>
<td class="org-left">dtache-copy-session (W)</td>
<td class="org-left">Copy the session's output</td>
</tr>


<tr>
<td class="org-left">dtache-kill-session (k)</td>
<td class="org-left">Kill an active session</td>
</tr>


<tr>
<td class="org-left">dtache-delete-session (d)</td>
<td class="org-left">Delete an inactive session</td>
</tr>
</tbody>
</table>

These commands are available through the `dtache-action-map`. The user can bind the action map to a keybinding of choice. For example

    (global-set-key (kbd "C-c d") dtache-action-map)

Then upon invocation the user can choose an action, keybindings listed in the table above, and then choose a session to perform the action upon. See further down in the document how to integrate these bindings with `embark`.


# Extensions


## Shell

A `use-package` configuration of the `dtache-shell` extension, which provides the integration with `M-x shell`.

    (use-package dtache-shell
      :after dtache
      :config
      (dtache-shell-setup)
      (setq dtache-shell-history-file "~/.bash_history"))

A minor mode named `dtache-shell-mode` is provided, and will be enabled in `shell`. The commands that are implemented are:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Command</th>
<th scope="col" class="org-left">Description</th>
<th scope="col" class="org-left">Keybinding</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">dtache-shell-send-input</td>
<td class="org-left">Run command with dtache</td>
<td class="org-left">&lt;S-return&gt;</td>
</tr>


<tr>
<td class="org-left">dtache-shell-attach-session</td>
<td class="org-left">Attach to a dtache session</td>
<td class="org-left">&lt;C-return&gt;</td>
</tr>


<tr>
<td class="org-left">dtache-detach-session</td>
<td class="org-left">Detach from a dtache session</td>
<td class="org-left">dtache-detach-key</td>
</tr>
</tbody>
</table>


## Eshell

A `use-package` configuration of the `dtache-eshell` extension, which provides the integration with `eshell`.

    (use-package dtache-eshell
      :after (eshell dtache)
      :config
      (dtache-eshell-setup))

A minor mode named `dtache-eshell-mode` is provided, and will be enabled in `eshell`. The commands that are implemented are:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Command</th>
<th scope="col" class="org-left">Description</th>
<th scope="col" class="org-left">Keybinding</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">dtache-eshell-send-input</td>
<td class="org-left">Run command with dtache</td>
<td class="org-left">&lt;S-return&gt;</td>
</tr>


<tr>
<td class="org-left">dtache-eshell-attach-session</td>
<td class="org-left">Attach to a dtache session</td>
<td class="org-left">&lt;C-return&gt;</td>
</tr>


<tr>
<td class="org-left">dtache-detach-session</td>
<td class="org-left">Detach from a dtache session</td>
<td class="org-left">dtache-detach-key</td>
</tr>
</tbody>
</table>

In this [blog post](https://niklaseklund.gitlab.io/blog/posts/dtache_eshell/) there are examples and more information about the extension.


## Compile

A `use-package` configuration of the `dtache-compile` extension, which provides the integration with `compile`.

    (use-package dtache-compile
      :hook (after-init . dtache-compile-setup)
      :bind (([remap compile] . dtache-compile)
             ([remap recompile] . dtache-compile-recompile)))

The package implements the commands `dtache-compile` and `dtache-compile-recompile`, which are thin wrappers around the original `compile` and `recompile` commands. The users should be able to use the former as replacements for the latter without noticing any difference except from the possibility to `detach`.


## Org

A `use-package` configuration of the `dtache-org` extension, which provides the integration with `org-babel`.

    (use-package dtache-org
      :after (dtache org)
      :config
      (dtache-org-setup))

The package implements an additional header argument for `ob-shell`. The header argument is `:dtache t`. When provided it will enable the code inside a src block to be run with `dtache`. Since org is not providing any live updates on the output the session is created with `dtache-sesion-mode` set to `create`. This means that if you want to access the output of the session you do that the same way you would for any other type of session. The `dtache-org` works both with and without the `:session` header argument.

    #+begin_src sh :dtache t
      cd ~/code
      ls -la
    #+end_src
    
    #+RESULTS:
    : [detached]


## Consult

A `use-package` configuration of the `dtache-consult` extension, which provides the integration with the [consult](https://github.com/minad/consult) package.

    (use-package dtache-consult
      :after dtache
      :bind ([remap dtache-open-session] . dtache-consult-session))

The command `dtache-consult-session` is a replacement for `dtache-open-session`. The difference is that the consult command provides multiple session sources, which is defined in the `dtache-consult-sources` variable. Users can customize which sources to use, as well as use individual sources in other `consult` commands, such as `consult-buffer`. The users can also narrow the list of sessions by entering a key. The list of supported keys are:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Type</th>
<th scope="col" class="org-left">Key</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">Active sessions</td>
<td class="org-left">a</td>
</tr>


<tr>
<td class="org-left">Inactive sessions</td>
<td class="org-left">i</td>
</tr>


<tr>
<td class="org-left">Successful sessions</td>
<td class="org-left">s</td>
</tr>


<tr>
<td class="org-left">Failed sessions</td>
<td class="org-left">f</td>
</tr>


<tr>
<td class="org-left">Local host sessions</td>
<td class="org-left">l</td>
</tr>


<tr>
<td class="org-left">Remote host sessions</td>
<td class="org-left">r</td>
</tr>


<tr>
<td class="org-left">Current host sessions</td>
<td class="org-left">c</td>
</tr>
</tbody>
</table>

Examples of the different sources are featured in this [blog post](https://niklaseklund.gitlab.io/blog/posts/dtache_consult/).


# Customization


## Customizable variables

The package provides the following customizable variables.

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Name</th>
<th scope="col" class="org-left">Description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">dtache-session-directory</td>
<td class="org-left">A host specific directory to store sessions in</td>
</tr>


<tr>
<td class="org-left">dtache-db-directory</td>
<td class="org-left">A localhost specific directory to store the database</td>
</tr>


<tr>
<td class="org-left">dtache-dtach-program</td>
<td class="org-left">Name or path to the <code>dtach</code> program</td>
</tr>


<tr>
<td class="org-left">dtache-shell-program</td>
<td class="org-left">Name or path to the <code>shell</code> that <code>dtache</code> should use</td>
</tr>


<tr>
<td class="org-left">dtache-timer-configuration</td>
<td class="org-left">Configuration of the timer that runs on remote hosts</td>
</tr>


<tr>
<td class="org-left">dtache-env</td>
<td class="org-left">Name or path to the <code>dtache-env</code> script</td>
</tr>


<tr>
<td class="org-left">dtache-annotation-format</td>
<td class="org-left">A list of annotations that should be present in completion</td>
</tr>


<tr>
<td class="org-left">dtache-max-command-length</td>
<td class="org-left">How many characters should be used when displaying a command</td>
</tr>


<tr>
<td class="org-left">dtache-tail-interval</td>
<td class="org-left">How often <code>dtache</code> should refresh the output when tailing</td>
</tr>


<tr>
<td class="org-left">dtache-nonattachable-commands</td>
<td class="org-left">A list of commands that should be considered nonattachable</td>
</tr>


<tr>
<td class="org-left">dtache-notification-function</td>
<td class="org-left">Specifies which function to issue notifications with</td>
</tr>


<tr>
<td class="org-left">dtache-detach-key</td>
<td class="org-left">Specifies which keybinding to use to detach from a session</td>
</tr>


<tr>
<td class="org-left">dtache-shell-command-initial-input</td>
<td class="org-left">Enables latest value in history to be used as initial input</td>
</tr>


<tr>
<td class="org-left">dtache-filter-ansi-sequences</td>
<td class="org-left">Specifies if dtache will use ansi-color to filter out escape sequences</td>
</tr>
</tbody>
</table>

Apart from those variables there is also the different `action` variables, which can be configured differently depending on the origin of the session.

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Name</th>
<th scope="col" class="org-left">Description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">dtache-shell-command-session-action</td>
<td class="org-left">Actions for sessions launched with <code>dtache-shell-command</code></td>
</tr>


<tr>
<td class="org-left">dtache-eshell-session-action</td>
<td class="org-left">Actions for sessions launched with <code>dtache-eshell-send-input</code></td>
</tr>


<tr>
<td class="org-left">dtache-shell-session-action</td>
<td class="org-left">Actions for sessions launched with <code>dtache-shell-send-input</code></td>
</tr>


<tr>
<td class="org-left">dtache-compile-session-action</td>
<td class="org-left">Actions for sessions launched with <code>dtache-compile</code></td>
</tr>


<tr>
<td class="org-left">dtache-org-session-action</td>
<td class="org-left">Actions for sessions launched with <code>dtache-org</code></td>
</tr>
</tbody>
</table>


## Remote support

The `dtache` package supports [Connection Local Variables](https://www.gnu.org/software/emacs/manual/html_node/elisp/Connection-Local-Variables.html) which allows the user to customize the variables used by `dtache` when running on a remote host. This example shows how the following variables are customized for all remote hosts.

    (connection-local-set-profile-variables
     'remote-dtache
     '((dtache-env . "~/bin/dtache-env")
       (dtache-shell-program . "/bin/bash")
       (dtache-shell-history-file . "~/.bash_history")
       (dtache-session-directory . "~/tmp")
       (dtache-dtach-program . "/home/user/.local/bin/dtach")))
    
    (connection-local-set-profiles
     '(:application tramp :protocol "ssh") 'remote-dtache)


## Completion annotations

Users can customize the appearance of annotations in `dtache-open-session` by modifying the `dtache-annotation-format`. The default annotation format is the following.

    (defvar dtache-annotation-format
      `((:width 3 :function dtache--state-str :face dtache-state-face)
        (:width 3 :function dtache--status-str :face dtache-failure-face)
        (:width 10 :function dtache--host-str :face dtache-host-face)
        (:width 40 :function dtache--working-dir-str :face dtache-working-dir-face)
        (:width 30 :function dtache--metadata-str :face dtache-metadata-face)
        (:width 10 :function dtache--duration-str :face dtache-duration-face)
        (:width 8 :function dtache--size-str :face dtache-size-face)
        (:width 12 :function dtache--creation-str :face dtache-creation-face))
      "The format of the annotations.")


## Status deduction

Users are encouraged to define the `dtache-env` variable. It should point to the `dtache-env` script, which is provided in the repository. This script allows sessions to communicate the status of a session when it transitions to inactive. When configured properly `dtache` will be able to set the status of a session to either `success` or `failure`.

    (setq dtache-env "/path/to/repo/dtache-env")


## Metadata annotators

The user can configure any number of annotators to run upon creation of a session. Here is an example of an annotator which captures the git branch name, if the session is started in a git repository.

    (defun my/dtache--session-git-branch ()
      "Return current git branch."
      (let ((git-directory (locate-dominating-file "." ".git")))
        (when git-directory
          (let ((args '("name-rev" "--name-only" "HEAD")))
            (with-temp-buffer
              (apply #'process-file `("git" nil t nil ,@args))
              (string-trim (buffer-string)))))))

Next add the annotation function to the `dtache-metadata-annotators-alist` together with a symbol describing the property.

    (setq dtache-metadata-annotators-alist '((branch . my/dtache--session-git-branch))


## Nonattachable commands

To be able to both attach to a dtach session as well as logging its output `dtache` relies on the usage of `tee`. However it is possible that the user tries to run a command which involves a program that doesn't integrate well with tee. In those situations the output could be delayed until the session ends, which is not preferable.

For these situations `dtache` provides the `dtache-nonattachable-commands` variable. This is a list of regular expressions. Any command that matches any of the strings will be getting the property `attachable` set to false.

    (setq dtache-nonattachable-commands '("^ls"))

Here a command beginning with `ls` would from now on be considered nonattachable.


# Tips & Tricks


## 3rd party extensions


### Embark

The user have the possibility to integrate `dtache` with the package [embark](https://github.com/oantolin/embark/). The `dtache-action-map` can be reused for this purpose, so the user doesn't need to bind it to any key. Instead the user simply adds the following to their `dtache` configuration in order to get embark actions for `dtache-open-session`.

    (defvar embark-dtache-map (make-composed-keymap dtache-action-map embark-general-map))
    (add-to-list 'embark-keymap-alist '(dtache . embark-dtache-map))


### Alert

By default `dtache` uses the built in `notifications` library to issue a notification. This solution uses `dbus` but if that doesn't work for the user there is the possibility to set the `dtache-notification-function` to `dtache-state-transitionion-echo-message` to use the echo area instead. If that doesn't suffice there is the possibility to use the [alert](https://github.com/jwiegley/alert) package to get a system notification instead.

    (defun my/dtache-state-transition-alert-notification (session)
      "Send an `alert' notification when SESSION becomes inactive."
      (let ((status (car (dtache--session-status session)))
            (host (car (dtache--session-host session))))
        (alert (dtache--session-command session)
         :title (pcase status
                  ('success (format "Dtache finished [%s]" host))
                  ('failure (format "Dtache failed [%s]" host)))
         :severity (pcase status
                    ('success 'moderate)
                    ('failure 'high)))))
    
    (setq dtache-notification-function #'my/dtache-state-transition-alert-notification)


### Projectile

The package can be integrated with [projectile](https://github.com/bbatsov/projectile), by overriding its compilation command in the following fashion.

    (defun my/dtache-projectile-run-compilation (cmd &optional use-comint-mode)
      "If CMD is a string execute it with `dtache-compile', optionally USE-COMINT-MODE."
      (if (functionp cmd)
          (funcall cmd)
        (let ((dtache-session-origin 'projectile))
          (dtache-compile cmd use-comint-mode))))
    
    (advice-add 'projectile-run-compilation :override #'my/dtache-projectile-run-compilation)


### Vterm

The package can be integrated with the [vterm](https://github.com/akermu/emacs-libvterm) package. This is for users that want `dtache` to run in a terminal emulator.

    (use-package vterm
      :defer t
      :bind (:map vterm-mode-map
                  ("<S-return>" . #'dtache-vterm-send-input)
                  ("<C-return>" . #'dtache-vterm-attach)
                  ("C-c C-d" . #'dtache-vterm-detach))
      :config
    
      (defun dtache-vterm-send-input (&optional detach)
        "Create a `dtache' session."
        (interactive)
        (vterm-send-C-a)
        (let* ((input (buffer-substring-no-properties (point) (vterm-end-of-line)))
               (dtache-session-origin 'vterm)
               (dtache-session-action
                '(:attach dtache-shell-command-attach-session
                          :view dtache-view-dwim
                          :run dtache-shell-command))
               (dtache-session-mode
                (if detach 'create 'create-and-attach)))
          (vterm-send-C-k)
          (process-send-string vterm--process (dtache-dtach-command input t))
          (vterm-send-C-e)
          (vterm-send-return)))
    
      (defun dtache-vterm-attach (session)
        "Attach to an active `dtache' session."
        (interactive
         (list
          (let* ((host-name (car (dtache--host)))
                 (sessions
                  (thread-last (dtache-get-sessions)
                               (seq-filter (lambda (it)
                                             (string= (car (dtache--session-host it)) host-name)))
                               (seq-filter (lambda (it) (eq 'active (dtache--determine-session-state it)))))))
            (dtache-completing-read sessions))))
        (let ((dtache-session-mode 'attach))
          (process-send-string vterm--process (dtache-dtach-command session t))
          (vterm-send-return)))
    
      (defun dtache-vterm-detach ()
        "Detach from a `dtache' session."
        (interactive)
        (process-send-string vterm--process dtache--dtach-detach-character)))


### Dired-rsync

The [dired-rsync](https://github.com/stsquad/dired-rsync) is a package to run [rsync](https://linux.die.net/man/1/rsync) commands from within `dired`. Its a perfect package to integrate with `dtache` since it typically requires some time to run and you don't want to have your Emacs limited by that process.

    (defun my/dtache-dired-rsync (command _details)
      "Run COMMAND with `dtache'."
      (let ((dtache-local-session t)
            (dtache-session-origin 'rsync))
        (dtache-start-session command t)))
    
    (advice-add #'dired-rsync--do-run :override #'my/dtache-dired-rsync)

The above code block shows how to make `dired-rsync` use `dtache`.


# Versions

Information about larger changes that has been made between versions can be found in the `CHANGELOG.org`


# Support

The `dtache` package should work on `Linux` and `macOS`. It is regularly tested on `Ubuntu` and `GNU Guix System`.


# Contributions

The package is part of [ELPA](https://elpa.gnu.org/) which means that if you want to contribute you must have a [copyright assignment](https://www.gnu.org/software/emacs/manual/html_node/emacs/Copyright-Assignment.html).


# Acknowledgments

This package wouldn't have been were it is today without these contributors.


## Code contributors

-   [rosetail](https://gitlab.com/rosetail)


## Idea contributors

-   [Troy de Freitas](https://gitlab.com/ntdef) for solving the problem of getting `dtache` to work with `filenotify` on macOS.

-   [Daniel Mendler](https://gitlab.com/minad) for helping out in improving `dtache`, among other things integration with other packages such as `embark` and `consult`.

-   [Ambrevar](https://gitlab.com/ambrevar) who indirectly contributed by inspiring me with his `[[https://www.reddit.com/r/emacs/comments/6y3q4k/yes_eshell_is_my_main_shell/][yes eshell is my main shell]]. It was through that I discovered his [[https://github.com/Ambrevar/dotfiles/blob/master/.emacs.d/lisp/package-eshell-detach.el][package-eshell-detach]] which got me into the idea of using =dtach` as a base for detached shell commands.

