==================
Git Config Options
==================


Check set settings in directory

::

   git config -l

CLassic Identity stuff

::

   git config --global user.name "NAME"
   git config --global user.email EMAIL

Editor

::

   git config --global core.editor nano

For more information and settings see [1].

Generate Key

::

   ssh-keygen -t ed25519 -C "EMAIL"

Available documentation suggests ED25519 is more secure than RSA. [2]
For more settings option see [2] too.

Test connection

::

    ssh -T git@github.com

Docs
====

[1] Git First Time Setup
  https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup
[2] Use SSH keys to communicate with GitLab
  https://docs.gitlab.com/ee/user/ssh.html
