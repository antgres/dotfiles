Bitbake
=======

Bitbake is a generic engine for execution of **only** python and bash
commands. The goal is to coordinate and thread tasks efficiently.

Bitbake has three standard types of files/elements:

-  classes (.bbclass)
-  conf (.conf)
-  recipes (.bb)

On top of that: Layers define a collection of these standart types of
files and thus represent a package/module.

Install from scratch
--------------------

Install bitbake, checkout the newest version (see releases) and check if
it works.

::

   git clone git://git.openembedded.org/bitbake
   # see https://wiki.yoctoproject.org/wiki/Releases
   git checkout -b bitbake-2.0

   # add bitbake exec to path
   export PATH=$PATH:~/Documents/bitb/bitbake/bin

   # check if works
   bitbake --version

Next set the all important env variable *BBPATH*. In this case the it is
the path to the example project folder.

::

   export BBPATH=~/bitbake-hello

.. note::

   *BBPATH* needs to be set or bitbake errors out. *BBPATH* points to
   the project folder which is to be used.

For bitbake to work two more files are needed. These are so important
that the path to them is hardcoded in the source code:

-  conf/bitbake.conf
-  classes/base.bbclass

Additional but optional file:

-  bblayers.conf

Bitbake script language
-----------------------

The bitbake syntax has **no** relation to the shell syntax. For more
information check the bitbake manual.

.. note::

   The following example is described in the bitbake manual.

1) Inline python expansion

bitbake executes python syntax if the command start with the character
*@*.

::

   FOO = "${@foo()}"

2) Function name convention

A common syntax for task names defined in the recipes is *do_TASK*.
Bitbake does not care about the pre-name *do\_*. It recognices and
executes the *TASK* name. The *TASK* name needs to be unique.

3) Main function

The first standard function call (like main) is *do_build*. If a recipe
is called via bitbake *do_build* gets called automaticly. In this
example the recipe *simplehello* is called which starts *do_build*

::

   bitbake simplehello
   # -> runs do_build

Individual tasks in a recipe can be called via the *-c* flag.

::

   bitbake -c build simplehello
   bitbake -c do_example_bash_task simplehello

.. note::

   Tasks needs to be registered with the keyword *addtask* or bitbake
   ignores them. This can be defined in the recipe.

   Build targets like *bitbake build* needs also to be defined. They are
   commonly defined in the class file. Everything else bitbake sees as
   functions.

In the *addtask* command the task order can be defined. Tasks without
order are run parallel to other tasks.

4. Glossary and ENV

Bitbake defines a lot of env variables which can be used in the conf and
class files. Example are the env variables *TMPDIR* and *CACHE* (which
define the temporary folder to which stuff gets loaded and cache
folder).

.. note::

   Therefore if the cached and tmpdir needs to be deleted one needs to
   check where bitbake loads it top

      ::
         # defined as TMPDIR/CACHE in bitbake.conf # TMPDIR = ~/tmp #
         CACHE = ~/cache

         rm -rf ~/{tmp,cache}; bitbake simplehello

5. Cached folder, work folder structure and files

The build tasks can be seen in the defined cached folder *CACHE*. At its
core bitbake translates every bitbake recipe and the contained tasks
into its corresponding *run.*\ \* file which is a valid shell or python
script. Additionally bitbake creates a *log.*\ \* file for every task
for debug purpose.

The translated tasks in the recipe can be inspected.

::

   ls $TMPDIR/$RECIPE/work
   cat run.do_build; cat log_do_build

If you look at the contents of the files you will notice that the
functions described in the recipe are here instead of being written to
stdout.

This is by design: bitbake takes control of stdout and writes all
information to the log files by default. Accordingly, bitbake must be
specifically informed that certain messages should be written to stdout.

For this there is the library *import bb; bb.plain("text")* implemented
in bitbake for python and *inherit logging; bbplain("text")* for the
shell.

For shell commands the class *logging* of *oe-core* must be included.

7. Debug recipes

Another option besides looking through the log files per task is to ask
bitbake itself if it can generate a whole debugging log for all
environment variables and tasks.

This option is even easier because bitbake explains above the created
variables and scripts in which file, line and command it got it from.

::

   bitbake -e TARGET

   # cleaner view
   bitbake -e TASK  < grep -v '^#'

Before bitbake starts the tasks it builds the dependancy and hierarchy
object *\_task_deps* which can be found in this debug option.

::

   In the work/log.task.order one can see the whole task order.

8. Class and conf files

(Common) Tasks (like logging) can also be defined in the class file. All
recipes inheret *.conf* and *.bbclass* files (they themselves do too,
from the base config up to every layer).

Specific class and conf files can be defined for every layer itself.

This common tasks can be imported with the *inherit* keyword. Here the
file *logging.bbclass* gets imported (could be a specific layer class or
project base class).

::

   inherit logging

9. stamps

Every task has a config bit *stamp*. If the stamp option for a task is
activated the task is getting executed even if it is already cached
(useful for pre- and post-operations)

::

   # activate for the task *do_build* the stamp option
   do_build[nostamp] = "1"

10. Fetchers

Bitbake has builtin fetchers for http/-s, git, etc. See the manual for
more information.

The Fetchers are to be used unlike programms which can be called from
python or the shell (for security reasons like hash comparison).

11. Recipe build order

On a bigger level a recipe is a component in eg. a filesystem. oe-core
(provided from the OpenEmbedded guys) standardized a function trail for
building a component.

::

   Start
     - do_fetch
     - do_unpack
     - do_patch
     - do_configure
     - do_compile
     - do_stage
     - do_install
     - do_package
     - ...
   END

Besides the standardization oe-core provides different pre-written
components, layers, configs and tasks. (eg. *PN* and *PV* for getting
the name of the recipe and the recipe version).

Yocto/poky
==========

bitbake is the base for poky which builds on top bitbake to provide more
complex operations and configurations. Together bitbake and poky are
called *yocto*.

The yocto version *Kirkstone - 4.0* is composed of bitbakev2.0 and
pokyv23.0. See the release activity for mor einformation.

All used Layers need to be adjusted to the current yocto version.

Building yocto/poky
-------------------

Here yocto version kirkstone is installed.

::

   git clone -b 'yocto-4.0.1' https://git.yoctoproject.org/poky/
   cd poky/
   source oe-init-build-env
   # bitbake core-image-minimal
   # runqemu --help
   # runqemu qemux86 core-image-minimal

.. note::

   Yocto pre-defines other tools which can be used like *runqemu* and
   bitbake which is staticly included in poky in the folder
   *poky/bitbake*.

Yocto (so its maintainer OpenEmbedded) predefines the base conf file and
base bbclass in - poky/meta/conf/bitbake.conf
-poky/meta/classes/base.bbclass

Layers are have mostly the pre-text *meta\_*. This shows that the layer
is to b integrated into poky and.

If runqemu is invoked the invokation of bitbake can be seen under *ps
aux \| grep runqemu*

Images
------

Images are not build in a single recipe. An Image liek Debian is an
output of eg. a layer and all packages inside the rootfs can be
themselves be layers or recipes itself. *oe-core* defines the output of
a recipe as a package.

With this one can declare in the layer config which packages (recipe)
gets included inside the image.

The output of layers and recipes can be custom. For exampel packages
output \*.ipk files (similar to .deb files).

Debbuging becomes important to check if a recipe fails or the image
process itself. The image process can eg. fail because of the file name
clashes.

siemens/kas
-----------

All the manual stuff from yocto can be automated with *kas*.

References
----------

-  Yocto release cycles https://wiki.yoctoproject.org/wiki/Releases
-  Bitbake manual
   https://docs.yoctoproject.org/1.6.1/bitbake-user-manual/bitbake-user-manual.html
-  Bitbake example project
   https://bitbucket.org/a4z/bitbakeguide/src/master
-  Debian Image layer
   https://elinux.org/images/a/ae/Elce_2018_kazuhiro_hayashi_Debian-Yocto-State-of-the-Art_r6.pdf
