Setting up
==========

Install needed packages

::

   sudo apt install gnupg
   sudo yum install gnupg2
   # windows: look up in [1]

Create a new key

::

   $ gpg --full-generate-key # or --gen-key depending on version

   - Please select what kind of key you want: (1) RSA and RSA (default)
   - What keysize do you want? 4096
   - Key is valid for? 2y (expires after 1 year) 
   - Is this correct? y
   - Real name: your real name here
   - Email address: your_email@address.com
   - Comment: Optional comment that will be visible in your signature
   - Change (N)ame, comment, (E)mail or (O)kay/(Q)uit? O
   - Enter passphrase: Enter a secure passphrase here (upper & lower case, digits, symbols)

Modify key
==========

Defined values with ``--full-generate-key`` can be modified. Use GUI or

::

   gpg --edit-key keyID

   gpg> help # show help menu
   gpg> adduid # add additional EMAIL
   gpg> save # save modified values

Show keys
=========

To look at all the public keys in the keyring use

::

   gpg --list-keys [EMAIL_ADDRESS]
   # The fingerprint/keyID is a hash of the entire key packet
   # and only the key packet.
   gpg --fingerprint [EMAIL_ADDRESS]

*The keyID is the same as the last eight characters (4 bytes) of the key fingerprint*

Export key to key server
========================

To make a key available to other users over the Net use

::

   gpg --send-key [keyID]

Export public key to a file
===========================

Use the following command to export your public key so you and other can
import it

::

   # either the key ID or any part of the user ID may be used to
   # identify the key to export.
   gpg --output email-address.gpg --export EMAIL_ADDRESS
   # export key in an ASCII format
   gpg --armor --export EMAIL_ADRESS

Add a public key
================

To import a public key from other people use

::

   gpg --import other-user.gpg

The last (optional) step is to verify the key is to sign/validate it

.. note::

   After checking the fingerprint, you may sign the key to validate it.
   Since key verification is a weak point in public-key cryptography,
   you should be extremely careful and always check a key's fingerprint
   with the owner before signing the key.
::

   gpg --edit-key EMAIL_ADRESS

   gpg> fpr # show fingerprint
   gpg> sign # sign key
   gpg> check # check the key
Create a Revocation Certificate
===============================

You need to have a way of invalidating your key pair in case there is a
security breach or in case you lose your secret key.

::

   # It will prompt you to give a reason for revocation, we recommend to
   # use 1 = key has been compromised.
   $ gpg --output ~/revocation.crt --gen-revoke EMAI_ADRESS

Encrypt/Decrypt documents manually
==================================

To encrypt and decrypt a file use

::

   gpg --encrypt --recipient OTHER.GUY@mail.com FILE
   gpg [--output FILE.gpg] -d FILE.gpg
   
.. note::

   The ``--recipient`` option is used once for each recipient and takes
   an extra argument specifying the public key to which the document
   should be encrypted. The encrypted document can only be decrypted
   by someone with a private key that complements one of the recipients'
   public keys. In particular, *you cannot decrypt a document encrypted
   by you unless you included your own public key in the recipient list.*

To just secure it with a passphrase use

::

   gpg --symmetric FILE
   gpg -d FILE.gpg
   
References
==========

[1] https://www.gnupg.org/gph/en/manual/book1.html

[2] https://emailselfdefense.fsf.org/en/index.html

[3] https://davesteele.github.io/gpg/2014/09/20/anatomy-of-a-gpg-key/

[4] http://irtfweb.ifa.hawaii.edu/~lockhart/gpg/
