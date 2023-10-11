GIT Structure
=============

General
-------

A famous quote from Linus Torvalds states that "Bad programmers worry about
the code. Good programmers worry about data structures and their
relationships."

This highlights the importance of describing what to store and why in a
repository. The purpose of the repository is to maintain a timeline order
of patches for traceability.

Structure
---------

The old development structure was as follows:

1. Stable kernel
2. Linux flavor patches (Debian)
3. Vendor-specific patches
4. Custom patches

::

   Debian   NXP    MSC   custom
   5.15.5=+++++++-------~~~~~~~&&&&&&&&=End

   5.15.6=+++++++-------~~~~~~~&&&&&&&&=End


Each step was stored in its own repository. This structure had some
advantages and disadvantages. The patches were grouped by source
and easy to reuse for other projects. They were also sorted by a general
useful order. However, there was no package information and with a new
kernel base, one would have to fiddle around in the steps itself to adjust
it to a new kernel version.


The new structure is as follows:

::

                       merges from
                         5.15.6  fixup
   5.15.5=+++---~~~&&&///////////IIIII=End
                                      /
                               /
   5.15.6=+++---~~~&&&=/


Maintainance
------------

Debian packages are meta-data about how to build and install. It is
important to handle packaging separately from development in its own
repository. This creates its own roles and keeps it separate.

Contents
--------

A README file should be included and contain the following information:

- Target architecture
- Subrepos to generate from
- Additional comments
- It should never end up in the final package

A subdirectory should also be included for the source of packaging, but
without patches (separation of concerns). 
