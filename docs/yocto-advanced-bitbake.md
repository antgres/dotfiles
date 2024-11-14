# More advanced bitbake topics

A lot of this stuff is part of 
- overrides
- variable flags and dependencies [1][3]


## FAQ


## Interesting flags

```

BB_GENERATE_MIRROR_TARBALLS = "1"
```

## Debugging recipes and task dependencies

per dot file
`bitbake -g RECIPE`

visually
`bitbake -g -u taskexp RECIPE`

it is HIGLY recommended to check out the output of
`bitbake -e RECIPE | less -`

as well as
`bitbake-getvar -r RECIPE|IMAGE VARIABLE`
which is a subpart of `bitbake -e`

Also there are some flags which produce more verbose ouput like


```
# Uf set, shell scripts echo commands and shell script output appears on
# standard out (stdout).
BB_VERBOSE_LOGS = "1"
```

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

## Key Tasks which are inherited by every recipe

Defined in `poky/meta/classes/base.bbclass`. This are

1. do_fetch
2. do_unpack
3. do_patch
4. do_configure
5. do_compile
6. do_install
7. do_package
8. do_package_write_* (e.g., do_package_write_ipk, do_package_write_deb, etc.)
9. do_rootfs
10. do_build (but has the definition do_build(){:})

There are other additional support tasks which are inherited like:

- do_checkuri
- do_clean
- do_cleanall
- do_cleansstate
- do_create_spdx
- do_devshell
- do_populate_lic
- do_pydevshell

There are special key tasks like `do_deploy`, `do_image` which needs to inherit
a bbclass to include them but provide additional functionality.

See [7] for their documentation and look at the source code of
`poky/meta/classes/base.bbclass` as well as `poky/meta/classes/*.bbclass` for
the other task definitions.

# My own image definition

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
beginning of the task. Also in these types of functions, the datastore (“d”) is
a global variable and is always automatically available.

Bitbake Python functions differ from regular python functions. See [5] for mroe
information.

## Mixing python and shell tasks

### Shell tasks as origin

Die bitbake engine concatinated alle "snippets" in eine einzelne funktion (der
output dieser kann mit `bitbake -e RECIPE | less -` nachgeschaut werden).

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
#    do_pre_install
#    do_install
#    do_post_install
#
do_install[prefuncs] += "do_pre_install"
do_install[postfuncs] += "do_post_install"

do_install() {
  echo "Hi"
}

python do_post_install() {
  bb.note("Ho")
}

python do_pre_install() {
  bb.note("Hu")
}
```

The recipe/version/temp/log.do_install shows this execution:

```
DEBUG: Executing python function do_pre_install
NOTE: Hu
DEBUG: Python function do_pre_install finished
DEBUG: Executing shell function do_install
Hi
DEBUG: Shell function do_install finished
DEBUG: Executing python function do_post_install
NOTE: Ho
DEBUG: Python function do_post_install finished
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
