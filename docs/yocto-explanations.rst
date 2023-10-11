Installing and building yocto
-----------------------------

See [1] for more information.

.. note::
   One can choose a different working directory via

   ::
      source poky/oe-init-build-env different-build-folder

Additional information and explanations can be found at [2], [5], [6], [9]
or [10].

Terms explained
---------------

- Board Support Package

  A Board Support Package (BSP) layer adds support for a particular hardware
  device or family of devices to Yocto. This support usually includes
  the bootloader, device tree blobs, and additional kernel drivers needed to
  boot Linux on that specific hardware.

  A BSP may also include any additional user space software and peripheral
  firmware needed to fully enable and utilize all the features of the hardware.
  By convention, BSP layer names start with the meta- prefix, followed by the
  machine's name.

  Locating the best BSP for your target device is the first step toward
  building a bootable image for it using Yocto.

- Distribution

  The distribution is the policy of which components to download and install,
  so maybe cutting edge package versions or maybe more conservative versions.
  An example can be features, C library implementations, choice of package
  manager, package format (rpm, deb or ipk), init system, and so on.

Folder structure
----------------

The build directory contains the following interesting folders in *./tmp*:

- work/
  This contains the build directory and the staging area for the root
  filesystem.
- deploy/
  This contains the final binaries to be deployed on the target:
- deploy/images/[machine name]/
  Contains the bootloader, the kernel and the root filesystem images ready
  to be run on the target.
- deploy/rpm/
  This contains the RPM packages that make up the images.
- deploy/licenses/
  This contains the licence files that are extracted from each package.

Doing stuff with layers
-----------------------

The metadata for the Yocto Project is structured into layers. By convention,
each layer has a name beginning with **meta-**. The core layers are:

- meta
  This is the OpenEmbedded core and contains some changes for Poky.
- meta-poky
  This is the metadata specific to the Poky distribution.
- meta-yocto-bsp
  This contains the board support packages for the machines that the Yocto
  Project supports

Additional layers can be found at [3], which can be appended via

::
   cd ${POKY}/build
   git clone git://cool-meta-layer ../cool-meta-layer
   bitbake-layers add-layer ../cool-meta-layer

   # or adding it to *BBLAYERS* in build/conf/bblayers.bb

The order in which the layers are added is important, because layers can fail
to parse if a layer, which they depend on, is added after them. An example
could be the layer *meta* which contains many basic recipes. Accordingly,
this layer needs to be placed at the top of the *BBLAYERS* variable.

To show all layers use

::
   bitbake-layers show-layers

.. note::
   The layer's priority is important if the same recipe appears in several
   layers: the one in the layer with the highest priority wins.


File types, bitbake and recipes
-------------------------------

- Recipes
  Files ending in .bb. These contain information about building
  a unit of software, including how to get a copy of the source code, the
  dependencies of other components, and how to build and install it.
- Append
  Files ending in .bbappend. These allow some details of a
  recipe to be overridden or extended. A bbappend file simply appends
  its instructions to the end of a recipe (.bb) file of the same root name.
- Include
  Files ending in .inc. These contain information that is common
  to several recipes, allowing information to be shared among them. The
  files may be included using the include or require keywords. The
  difference is that require produces an error if the file does not exist,
  whereas include does not.
- Classes
  Files ending in .bbclass. These contain common build
  information; for example, how to build a kernel or how to build an
  autotools project. The classes are inherited and extended in recipes and
  other classes using the inherit keyword. The
  classes/base.bbclass class is implicitly inherited in every
  recipe.
- Configuration
  Files ending in .conf. They define various
  configuration variables that govern the project's build process
- Images
  An image recipe (.bb) contains instructions about how to create the image
  files for a target, for example which applications to include, which kernel
  version to use, how to build the root filesystem, etc.


Looking for images and recipes
------------------------------

See all image recipes

:: 
   cd ${POKY}/build
   ls ../meta*/recipes*/images/*.bb

See all available machine configurations

::
   cd ${POKY}/build
   ls ../meta*/conf/machine/*

One can also start a single task in a recipe

One can also list all tasks for a image recipe via
one can start a single task in a recipe

::
  bitbake -c fetch busybox  
  bitbake -c listtasks core-image-minimal

This can be expanded for all recipes via

::
  bitbake core-image-minimal --runall=fetch

Extra Image Features
--------------------

One can add several different flags to  *EXTRA_IMAGE_FEATURES* variable, which
in turn add predefined packages such as development utilities or packages with
debug information to the recipes. For example

- dbg-pkgs
  This installs debug symbol packages for all the packages
  installed in the image.
- debug-tweaks
  This allows root logins without passwords and other changes that make
  development easier.
- package-management
  This installs package management tools and preserves the package manager
  database.
- read-only-rootfs
  This makes the root filesystem read-only.
- x11: This installs the X server.
- x11-base: This installs the X server with a minimal environment.

More can be found at [4] or in *meta/classes/core-image.bbclass*

.. note::
   Even more variables to modify can be found at [7] and [8].

References
----------

[1] Yocto Project Quick Build
https://docs.yoctoproject.org/singleindex.html

[2] Mastering Embedded Linux Programming - Third Edition
by Frank Vasquez & Chris Simmonds

[3] OpenEmbedded Layer Index
http://layers.openembedded.org/layerindex/

[4] Image Features
https://docs.yoctoproject.org/ref-manual/features.html#image-features

[5] Yocto Project Reference Manual
https://docs.yoctoproject.org/ref-manual/index.html

[6] How to write a really good board support package for Yocto Project - Chris Simmonds
https://www.youtube.com/watch?v=s5U4c2_ChrA

[7] Variable Context
https://docs.yoctoproject.org/ref-manual/varlocality.html

[8] Variables Glossary
https://docs.yoctoproject.org/ref-manual/variables.html

[9] Yocto Project Development Tasks Manual
https://docs.yoctoproject.org/dev-manual/index.html

[10] Real-World Yocto: Getting the Most out of Your Build System - Stephano Cetola, Intel
https://www.youtube.com/watch?v=LXMwP5_v_k4
