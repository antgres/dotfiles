# QEMU for yocto

## Execute a single binary for another target architecture on the fly via binfmt

TL;DR: See

- https://animeshz.github.io/site/blogs/binfmt.html or
- https://cefboud.com/posts/qemu-virtualzation-docker-multi-build/#qemu-and-binfmt-misc-to-the-rescue

for more information.

### 1. Install binfmt-support

See https://wiki.debian.org/QemuUserEmulation for that.

Via `update-binfmts --display` one can see the (enabled) entries and used
interpreter per architecture.

### 2. Build the app with the new target architecture

For this example the following target and app were chosen:

- Example architecture: ppc64
- Example application: imx-cst

**Note:** All generic QEMU architectures can be seen here:
https://downloads.yoctoproject.org/releases/yocto/yocto-5.0.3/machines/qemu/
At the time of writing the following architectures are available:

- qemuarm
- qemuarm64
- qemumips
- qemumips64
- qemuppc
- qemuppc64
- qemux86
- qemux86-64

The recipe can then be built via:

```
# conf/local.conf - Set MACHINE to weak assignment
$ sed -i -E 's/^(MACHINE[[:space:]]*)=/\1?=/' conf/local.conf
$ MACHINE="qemuppc64" bitbake imx-cst
```

**Note:** Passing `MACHINE` via the environment only works because it is part
of BitBake's default `BB_ENV_PASSTHROUGH_ADDITIONS`; arbitrary environment
variables are not passed through to BitBake.

The needed tools, toolchains and packages will be downloaded and compiled
automagically.

### 3. Run the target

All paths below are relative to the build directory.

Depending on how the recipe was built there are two ways to run it.

#### 3.1. Static libraries

If it is a static app, one can just run it as usual (binfmt does all the magic
behind the curtain).

```
$ tmp/work/ppc64p9le-linux/imx-cst/3.4.0-r0/git/code/obj.linux64/cst --help
```

#### 3.2. Shared libraries

For application specific shared libraries we need to tell QEMU where to find
them. There are two alternative approaches: configure the binfmt wrapper so
that transparent execution keeps working (A), or invoke the QEMU user binary
directly (B).

Via `file` we check out again what kind of bin we produced.

```
$ file tmp/work/ppc64p9le-linux/imx-cst/3.4.0-r0/git/code/obj.linux64/cst
ELF 64-bit LSB executable, 64-bit PowerPC or cisco 7500, OpenPOWER ELF V2 ABI,
version 1 (SYSV), dynamically linked, interpreter /lib64/ld64.so.2,
BuildID[sha1]=a48ed980e6d8e42370168d8e7b106bfeaecde0b8, for GNU/Linux 3.10.0,
with debug_info, not stripped
```

Then we look via `update-binfmts --display` for the correct entry for this
binary:

```
qemu-ppc64le (enabled):
     package = qemu-user-static
        type = magic
      offset = 0
       magic = \x7f\x45\x4c\x46\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x15\x00
        mask = \xff\xff\xff\xff\xff\xff\xff\xfc\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\x00
 interpreter = /usr/libexec/qemu-binfmt/ppc64le-binfmt-P
```

From the interpreter path we can deduce the used QEMU machine.

```
$ readlink -f /usr/libexec/qemu-binfmt/ppc64le-binfmt-P
/usr/bin/qemu-ppc64le-static
```

The last thing we need is to point QEMU to the target's shared libraries.
Yocto is very nice and already built them for us: the `recipe-sysroot` of the
recipe contains glibc as well as the app's library dependencies.

**Note:** If Yocto did not build them we can build them via `dpkg-cross`, in
this example via the package `libc6-ppc64-powerpc-cross`.

**Approach A: Configure the binfmt wrapper.** The Debian wrapper
(`/usr/libexec/qemu-binfmt/*-binfmt-P`) reads `/etc/qemu-binfmt.conf`, as
described in
https://wiki.debian.org/QemuUserEmulation#Point_QEMU_to_the_target_linux_loader.

```
echo "EXTRA_OPTS=\"-L $PWD/tmp/work/ppc64p9le-linux/imx-cst/3.4.0-r0/recipe-sysroot\"" \
  | sudo tee -a /etc/qemu-binfmt.conf
```

**Note:** `$PWD` is expanded when the line is written — run this from the
build directory (or use an absolute path). The config only affects executions
going through the binfmt wrapper, not direct QEMU invocations.

Afterwards the binary can be executed transparently again, as in the static
case.

**Approach B: Invoke QEMU directly.** Use `-L` to point QEMU to the shared
libraries the executable needs. `/etc/qemu-binfmt.conf` is not needed in this
case.

**Note:** If you need additional parameters to be included, use `-E var=value`
(QEMU_SET_ENV) flag, e.g. `-E LD_LIBRARY_PATH=/path/to/extra/libs` for further
library paths.

**Note:** `-L` can only be given once (the last one wins) and must point to
where the dynamic linker (`ld.so`) lives — hence the `recipe-sysroot`. For
additional library paths use `-E LD_LIBRARY_PATH=path1:path2` instead.

```
qemu-ppc64le-static \
  -L tmp/work/ppc64p9le-linux/imx-cst/3.4.0-r0/recipe-sysroot \
  tmp/work/ppc64p9le-linux/imx-cst/3.4.0-r0/git/code/obj.linux64/cst --help
```

## Chroot into a rootfs of another target architecture

A small script to demonstrate and automate it could be:

```sh
#!/bin/sh
# https://wiki.debian.org/Arm64Qemu#Use_Qemu_user_mode
# https://wiki.debian.org/RaspberryPi/qemu-user-static

# Requires:
#   sudo apt install qemu-user-static

ROOTFS_PATH="/path/to/core-image-minimal/1.0-r0/rootfs"

# Pick the QEMU user binary matching the *target* rootfs architecture
# (NOT the host architecture), e.g. by inspecting a binary inside it:
#   file "${ROOTFS_PATH}/bin/busybox"
# qemu-arm-static for 32-bit ARM, qemu-aarch64-static for arm64, ...
QEMU_BIN="qemu-aarch64-static"

cp "$(which "${QEMU_BIN}")" "${ROOTFS_PATH}/usr/bin/"

# core-image-minimal ships BusyBox, so use /bin/sh (bash is not available)
sudo chroot "${ROOTFS_PATH}" /bin/sh
```
