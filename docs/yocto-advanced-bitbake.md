# More advanced bitbake topics

A lot of this stuff is part of 
- variable flags and dependencies [1][3]


## FAQ


## Interesting flags

```

BB_GENERATE_MIRROR_TARBALLS = "1"
```

## Debugging recipes and task dependencies

Bitbake has some options to display the dependency order and used variables for
a recipe (see [DBG1] for a general overview):

### Viewing Dependencies Between Recipes and Tasks

See [DBG2] for more information.

To generate dependency information for a recipe the command `bitbake -g RECIPE`
can be used. One file it generates is `task-depends.dot` which showcases ALL
dependencies between (multiple) recipes, which can be quite large even for
small recipes.

A (less) helpful variant is to use `bitbake -g -u taskexp RECIPE` which opens a
graphical application to browse the tasks and dependencies.

The simple graph query utility script `poky/scripts/contrib/graph-tool` can be
used to filter out some specific information from that .dot file.

To create a simple dependency graph for e.g. [Graphviz
Online](https://dreampuf.github.io/GraphvizOnline/) the following command can
be used:

```
poky/scripts/contrib/graph-tool filter -n /path/to/build/task-depends.dot RECIPE
# or
poky/scripts/contrib/graph-tool find-paths /path/to/build/task-depends.dot \
     RECIPE.do_install RECIPE.do_fetch
```

which can be pasted into the visualizer.

### Viewing RECIPE and IMAGE variables

See [DBG3] for more information.

Sometimes you need to know the value of a variable as a result of BitBake’s
parsing step because perhaps an attempt to modify a variable e.g. via an
override did not work out as expected.

The command `bitbake -e RECIPE | less -` displays

- all global and private recipe variables values,
- description of how the variable got its value,
- after the value definiton: the final merged form of a task

and pipes it into `less` to browse.

If only a single variable is of interest then this can be done faster via
`bitbake-getvar`:

```
bitbake-getvar -r RECIPE VARIABLE
bitbake-getvar -r IMAGE VARIABLE
# or
bitbake-getvar -r RECIPE VARIABLE --value
# If multiple flags are associated with a variable like SRC_URI[md5sum],
# SRC_URI[sha256sum], etc.
bitbake-getvar -r RECIPE SRC_URI -f md5sum --value
```

### Debugging applications

https://developer.ridgerun.com/wiki/index.php/Preparing_Yocto_Development_Environment_for_Debugging


### Additional variables

Also there are some flags which produce more verbose ouput like

```
# If set, shell scripts echo commands and shell script output appears on
# standard out (stdout).
BB_VERBOSE_LOGS = "1"
```

[DBG1] Debugging Tools and Techniques
https://docs.yoctoproject.org/dev-manual/debugging.html

[DBG2] Viewing Dependencies Between Recipes and Tasks
https://docs.yoctoproject.org/dev-manual/debugging.html#viewing-dependencies-between-recipes-and-tasks

[DBG3] Viewing Variable Values
https://docs.yoctoproject.org/dev-manual/debugging.html#viewing-variable-values

## Debugging recipes and task dependencies via buildstats and pychartboot

which is defined in [8]

```
#
# Additional image features
#
# The following is a list of additional classes to use when building images which
# enable extra features. Some available options which can be included in this variable
# are:
#   - 'buildstats' collect build statistics
#   - 'image-mklibs' to reduce shared library files size for an image
#   - 'image-prelink' in order to prelink the filesystem image
# NOTE: if listing mklibs & prelink both, then make sure mklibs is before prelink
# NOTE: mklibs also needs to be explicitly enabled for a given image, see local.conf.extended
USER_CLASSES ?= "buildstats"
```

The buildstats class records performance statistics about each task executed
during the build (e.g. elapsed time, CPU usage, and I/O usage).

When you use this class, the output goes into the `BUILDSTATS_BASE` directory,
which defaults to `${TMPDIR}/buildstats/` so probably `build/tmp/buildstats`.
You can analyze the elapsed time using
`poky/scripts/pybootchartgui/pybootchartgui.py` like

```
../poky/scripts/pybootchartgui/pybootchartgui.py tmp/buildstats/
```

## Directory naming convenctions

The recipes-*/ directory convention (e.g., recipes-bsp/, recipes-core/, etc.)
is a widely adopted naming convention in the Yocto Project community. This
convention helps in organizing recipes by their functionality or target
component (like Board Support Packages in recipes-bsp/)

See [6] for more information.

Es können jedoch eigene custom directories im layer hinzugefügt werden welche
über die local.conf gesteuert werden (deswegen includes local.conf oft):

```
BBFILES += "${LAYERDIR}/recipes-*/*/*.bb \
            ${LAYERDIR}/recipes-*/*/*.bbappend"
```

## Overrides

Described in
https://docs.yoctoproject.org/bitbake/2.2/bitbake-user-manual/bitbake-user-manual-metadata.html#conditional-syntax-overrides

# The default value of OVERRIDES includes the values of the CLASSOVERRIDE,
# MACHINEOVERRIDES, and DISTROOVERRIDES variables. Another important override
# included by default is pn-${PN}.
https://docs.yoctoproject.org/ref-manual/variables.html#term-OVERRIDES

**Note:** An easy way to see what overrides apply is to search for OVERRIDES in
the output of the `bitbake -e` command

### Complete override

If the have a task like do_compile, we can completly override it. That works
also with functions, which are not tasks.

```
# Definition in .bb or .bbclass
my_function() {
  :
}

do_compile(){
  : # very complex installation, does not include execute my_function
}

# Definition in .bbappend
my_function(){
  echo "Nothing happens"
}

do_compile(){
  : # Overwrite original definiton with my own
}

do_compile:MACHINE(){
  : # Overwrite with this definiton if MACHINE in MACHINEOVERRIDES
}
```

### appends

The most seen form is in combination with `:append`/`:prepend`

```
# Definition in .bb or .bbclass
do_compile(){
  : # Base implementation
}

# Definition in .bbappend
do_compile:append() {
  # Append additional steps every time bbappend is included for example to
  # check if variable is included
  if [ "${GLOBAL_VARIABLE}" -eq "0" ]; then
    bbnote "Wanted function is deactivated."
    return
  fi
}

do_compile:append:MACHINE() {
  : # Append additional steps after do_compile:append but only for MACHINE
}

do_compile:prepend:MACHINE() {
  : # Prepend additional steps before do_compile:append but only for MACHINE
}
```

Same idea for `my_function`.

## The base.bbclass

See https://docs.yoctoproject.org/ref-manual/classes.html#base for more
information.

Every recipe implicitly inherits the class `poky/meta/classes/base.bbclass`
which contains definitions for standard basic tasks such as fetching,
unpacking, configuring (empty by default), compiling (runs any Makefile
present), installing (empty by default) and packaging (empty by default).

The class also contains some commonly used functions such as `oe_runmake`,
which runs `make`.

## Key Tasks which are inherited by every recipe

The `poky/meta/classes/base.bbclass` class defines a set of default tasks. For
example:

0. do_build (has an empty definition)
1. do_fetch
2. do_unpack
3. do_patch
4. do_prepare_recipe_sysroot
5. do_configure
6. do_compile
7. do_install
8. do_populate_sysroot
9. do_package (includes do_package_write_* (so e.g. do_package_write_ipk))

See [7] or the source .bbclass files for more information. For a (simple but
not so simple) example of the task structure see [BASE1].

There are other additional support tasks which are inherited like:

- do_checkuri
- do_clean
- do_cleanall
- do_cleansstate (recommended)
- do_deploy
- do_create_spdx
- do_devshell
- do_populate_lic
- do_pydevshell

There are special tasks like `do_deploy` and `do_devshell` which need to be
 inherited and provide additional functionality. For example the `do_deploy`
task can be inherited via adding the line `inherit deploy` to recipe. The
`do_deploy` is defined in the `poky/meta/classes-recipe/deploy.bbclass` file.

[BASE1] BitBake Tasks Map
https://docs.yoctoproject.org/dev/overview-manual/concepts.html#bitbake-tasks-map

## do_deploy vs do_populate_sysroot

The idea of both tasks is to provide some kind of development artifact to other
"consumer"-recipes like e.g.

```
# Provider               # Consumer
libmysharedlibrary.bb -> my-application.bb
# or
my-dev-keys.bb        -> recipe-which-needs-keys.bb
```

Both recipes `libmysharedlibrary.bb` and `my-dev-keys.bb` provide artifacts to
their corresponding consumer recipe.

However, both tasks do this in different ways (while trying to reuse already
deployed artifacts via sstate cache):

- The do_deploy is an additional task (which is not executed by default) which
handles the deployment of final built artifacts, such as binaries and firmware,
to their designated locations, such as a target device or an image directory.

It does that by copying/installing files to the `DEPLOYDIR` directory, which
automagically at the end of the do_deploy task are copied to the
`DEPLOY_DIR_IMAGE` directory.

See [DEPTASK1] for more information.

The difference between do_install and do_deploy is that the do_install task
installs any content/artifact that needs to be added to the rootfs/image. The
artifacts also end up in a binary package (rpm, deb, or ipk). The do_deploy
task only copies or installs files `DEPLOY_DIR_IMAGE` which does not add
additional tasks.

The provider recipe need to use it like e.g.

```
...
inherit deploy

do_deploy(){
  # Copy or install files to 
  install -D -m 0644 -t ${DEPLOYDIR}/my_stuff/my_stuff.so ${WORKDIR}/mystuff.so
}

addtask deploy after do_compile before do_build
```

and the consumer recipe can use it like

```
# A simple DEPENDS:append += " producer" does not work as intended because the
# do_deploy task/bbclass, caches artifacts not perfectly via sstate. If a
# recipe depends on a blob deployed by another recipe then a dependency via
# `do_compile[depends] += recipe:do_deploy` needs to be added else the files
# can't be found if a build is executed with an empty workdir.
#
# See
#   https://yoctoproject.blogspot.com/2020/09/yocto-bitbake-and-dependencies-eg-one.html
#   https://docs.yoctoproject.org/dev/overview-manual/concepts.html#shared-state
# for more information.
do_compile[depends] += 'producer:do_deploy'

do_compile(){
  echo "My shared lib in $(realpath $[DEPLOY_DIR_IMAGE}/my_stuff/my_stuff.so)"
}
```

- The do_populate_sysroot task prepares a consumer with needed headers,
libraries and artifacts for generating binaries in the e.g. do_compile task.
The provider calls the corresponding do_prepare_recipe_sysroot (which handles
artifacts for native and non-native builds).

See [SYSTASK1] for more information.

The do_populate_sysroot task is executed by default after the do_install task
for a provider. The do_prepare_recipe_sysroot task is executed by default
before the do_configure task for the consumer. The files defined in
do_populate_sysroot task are not staged/deployed/installed into the final
rootfs/image.

The provider recipe need to use it like e.g.

```
...
# See
#   https://docs.yoctoproject.org/ref-manual/variables.html#term-SYSROOT_DIRS
# for more information like the default directories.
# In this case append an additional custom directory `/sysroot-only` to
# provide artifacts which also use the sstate cache mechanism correctly.
SYSROOT_DIRS:append = " /sysroot-only"
do_install() {
  install -D -m 0644 -t ${D}/sysroot-only/my/stuff/my_stuff.so ${WORKDIR}/mystuff.so  
}
```

and the consumer recipe can use it like

```
DEPENDS:append = ' producer'

do_compile(){
  echo "My shared lib in $(realpath ${STAGING_DIR_HOST}/sysroot-only/my_stuff/my_stuff.so)"
}
```

[DEPTASK1] deploy
https://docs.yoctoproject.org/ref-manual/classes.html#deploy

[SYSTASK1] staging
https://docs.yoctoproject.org/ref-manual/classes.html#staging

## My own image definition

`poky/meta/recipes-sato/images/core-image-sato-sdk.bb`

which `require core-image-sato.bb`
which `require poky/meta/classes/core-image.bbclass`
which `require poky/meta/classes/image.bbclass`

## Recipe Ordering

https://docs.yoctoproject.org/contributor-guide/recipe-style-guide.html#recipe-ordering

## Patch Upstream Status

https://docs.yoctoproject.org/contributor-guide/recipe-style-guide.html#patch-upstream-status

## Normal recipe build tasks

https://docs.yoctoproject.org/ref-manual/tasks.html#normal-recipe-build-tasks

Not all tasks are availabgle from the start and it is not recommended to add
new tasks but append to this well defined tasks (because of possible missing
tasks dependencies which can result in race conditions between tasks)

## BitBake-Style Python Functions

These functions are written in Python and executed by BitBake or other Python
functions using `bb.build.exec_func()` [4].

```
python some_python_function () {
    d.setVar("TEXT", "Hello World")
    print d.getVar("TEXT")
}
```

The python modules `import bb; import os` are automaticly imported at the
beginning of the task (see varibale `OE_IMPORTS` defined in bbclass
`poky/meta/classes/base.bbclass`). Also in these types of functions, the
datastore `d` is a global variable and is always automatically available.

Bitbake Python functions differ from regular python functions. See [5] for mroe
information.

## Mixing python and shell tasks

### Shell tasks as origin

Die bitbake engine concatinated alle "snippets" in eine einzelne funktion :

```
# Definition in recipe.bb
do_install() {
  echo "Hi"
}

do_install:append() {
  echo "Ho"
}

do_install:append() {
  echo "Hu"
}

# Summary of all appended snippets in `bitbake -e`
do_install() {
  echo "Hi"
  echo "Ho"
  echo "Hu"
}
```

Dies passiert in .bb files als auch .bbappend files.

```
# Definition of recipe.bb
do_install() {
  echo "Hi"
}

# Definition in recipe.bbappend
do_install:append() {
  echo "Ho"
}

# Summary of all appended snippets
do_install() {
  echo "Hi"
  echo "Ho"
}
```

Aus diesem grund können python function und shell funktionen nicht zusammen
gemischt werden da die base function do_install von der class ShellParser
geparsed wird (bitbake/lib/bb/codeparser.py) und diese nicht python source code
ausführen kann.

```
# Results in error
do_install() {
  echo "Hi"
}

python do_install:append() {
  echo "Ho"
}
```

Um das zu umgehen können die speziellen variablen flags `postfunc` und
`prefuncs` [1] verwendet werden.

```
# Executes snippets in the following order
#    do_pre_compile
#    do_install
#    do_post_compile
#
do_compile[prefuncs] += "do_pre_compile"
do_compile[postfuncs] += "do_post_compile"

do_compile() {
  echo "Hi"
}

python do_post_compile() {
  bb.note("Ho")
}

do_pre_compile() {
  echo "Hu"
}
```

The recipe/version/temp/log.do_install shows this execution:

```
DEBUG: Executing shell function do_pre_compile
Hu
DEBUG: Shell function do_pre_compile finished
DEBUG: Executing shell function do_compile
Hi
DEBUG: Shell function do_compile finished
DEBUG: Executing python function do_post_compile
NOTE: Ho
DEBUG: Python function do_post_compile finished
```

### Python tasks as origin

Wenn die originalle task als python tasks gestartet ist ist das alles einfacher
weil wir auf die bitbake internen funktionen von `bb.build` zugreifen können.

```
python whatever () {
    pass
}

do_something_shell () {
    :
}

python do_something () {
    bb.build.exec_func("whatever", d)
    bb.build.exec_func("something_shell", d)
}
```

The recipe/version/temp/log.do_install shows this execution:

# TODO

## Intertask dependency

BitBake uses the [depends] flag [1] in a more generic form to manage inter-task
dependencies. For example

```
# Definition in recipe.bb
do_fetch[depends] += "{@'virtual/bootloader:do_fetch virtual/bootloader:do_unpack' \
                       if d.getvar('VARIABLE') else ''}"
```

See [2] for more explanations.

# Reference

[1] Bitbake: Variable Flags
https://docs.yoctoproject.org/bitbake/2.2/bitbake-user-manual/bitbake-user-manual-metadata.html#variable-flags

[2] Bitbake: Inter-Task Dependencies
https://docs.yoctoproject.org/bitbake/2.2/bitbake-user-manual/bitbake-user-manual-metadata.html#inter-task-dependencies

[3] Bitbake: Dependencies
https://docs.yoctoproject.org/bitbake/2.2/bitbake-user-manual/bitbake-user-manual-metadata.html#dependencies

[4] Bitbake: BitBake-Style Python Functions
https://docs.yoctoproject.org/bitbake/bitbake-user-manual/bitbake-user-manual-metadata.html#bitbake-style-python-functions

[5] Bitbake: BitBake-Style Python Functions Versus Python Functions
https://docs.yoctoproject.org/bitbake/bitbake-user-manual/bitbake-user-manual-metadata.html#bitbake-style-python-functions-versus-python-functions

[6] Bitbake: Source Directory Structure: The Metadata: meta/recipes-bsp
https://docs.yoctoproject.org/dev/ref-manual/structure.html#meta-recipes-bsp

[7] Bitbake Tasks
https://docs.yoctoproject.org/ref-manual/tasks.html#tasks

[8] Classes: buildstats
https://docs.yoctoproject.org/ref-manual/classes.html#buildstats
