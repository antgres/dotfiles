=================================
KeepassXC - SSH Agent integration
=================================


Check what keys are loaded withCheck what keys are loaded with

::

   ssh-add -l

Sources of error
================

-  *ssh-agent: "sign_and_send_pubkey: signing failed: agent refused
   operation"*

   Check if ssh-agent is running; check if package like
   *x11-ssh-askpass* or *ssh-askpass* is installed

Documentation
=============

-  KeepassXC SSH Integration
   https://keepassxc.org/docs/#faq-ssh-agent-how
