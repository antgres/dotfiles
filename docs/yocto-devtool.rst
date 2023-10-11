devtool
-------

Devtool is a command-line utility in the Yocto Project that simplifies the
development and debugging process of custom software recipes and layers for
embedded Linux systems. It provides various features such as recipe creation,
modification, and debugging tools, making it easier for developers to work
with Yocto-based projects.

For the complete documentation see [3].

Cheatsheet
----------

Create a workspace to work on a project, add the application *bar* to a target
and save it to layer *meta-foo*.

::
   cd poky
   . oe-init-build-env
   bitbake-layers add-layer ../meta-foo

   devtool create-workspace workspace
   # Easier to work with if target is created according to [2]
   devtool build-image core-image-full-cmdline
   
   devtool add bar
   devtool build bar

   devtool deploy-target bar root@localhost
   devtool undeploy-target bar root@localhost
   
   devtool edit-recipe bar

   devtool finish bar ../meta-foo

   # delete downloaded source files
   rm -rf workspace/sources/bar

   cat ../meta-foo/recipes-bar/bar/bar_*.append # check out created append file
   
Modify application code.

::

   # if already cached devtool will find application
   devtool modify bar
   # modification and save to git


   devtool finish bar ../meta-foo
   rm -rf workspace/sources/bar


Misc commands.

::

   # Updates the Bitbake cache after making changes to your recipes.
   devtool update-recipes

References
----------

[1] Mastering Embedded Linux Programming - Third Edition
by Frank Vasquez & Chris Simmonds

[2] Using Devtool to Streamline Your Yocto Project Workflow - Tim Orling, Intel
https://www.youtube.com/watch?v=CiD7rB35CRE

[3] devtool Quick Reference
https://docs.yoctoproject.org/dev/ref-manual/devtool-reference.html
