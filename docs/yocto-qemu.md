# QEMU - Cross-compile a single recipe for another target architecture on the
# fly

TL;DR: See https://animeshz.github.io/site/blogs/binfmt.html for more
information.

1. Install binfmt-support

See `https://wiki.debian.org/QemuUserEmulation` for that.

Via `update-binfmts --display` one can see the (enabled) entries and used
interpreter per architecture.

2. Build the app with new target architecture

For this example the follwoing target and app were choosen:

- Example architecture: ppc64
- Example application: imx-cst

**Note:** All generic QEMU architectures can be seen here
`https://downloads.yoctoproject.org/releases/yocto/yocto-5.0.3/machines/qemu/`.
At the time of writting they are as follows:

- qemuarm
- qemuarm64
- qemumips
- qemumips64
- qemuppc
- qemuppc64
- qemux86
- qemux86-64

The recipe can then be build:

```
# conf/local.conf - Set MACHINE to weak assignemnt
$ sed -n -i '/MACHINE/ s#=#?=#' conf/local.conf
$ MACHINE="qemuppc64" bitbake imx-cst
```

The needed tools, toolchains and packages will be downloaded and compiled
automagically.

3. Run the target

Depending on how the recipe was built there are two ways to run it.

3.1. Static libraries

If it is a static app, one can just run it as usual (binfmt does all the magic
behind the curtain).

```
$ tmp/work/ppc64p9le-ifmlinux-linux/imx-cst/3.4.0-r0/git/code/obj.linux64/cst --help
```

3.2. Shared libraries

For application specific shared libraries we need to tell QEMU where to find
them. It's easier to work here with the QEMU specific machine binary as with
automagically conversion of binfmt.

Via `file` we check out again what kind of bin we produced.

```
$ file tmp/work/ppc64p9le-ifmlinux-linux/imx-cst/3.4.0-r0/git/code/obj.linux64/cst
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

The last thing we need is to point QEMU to the targets architecture shared
glibc libraries as described in
`https://wiki.debian.org/QemuUserEmulation#Point_QEMU_to_the_target_linux_loader`.
Yocto is very nice and already build them for us.

**Note:** If Yocto did not build them there are also via `dpkg-cross`, in this
example via the package `libc6-ppc64-powerpc-cross`.

```
sudo touch /etc/qemu-binfmt.conf
echo "EXTRA_OPTS=\"-L $PWD/build/tmp/work/ppc64p9le-ifmlinux-linux/glibc/2.35-r0/image\"" >> /etc/qemu-binfmt.conf
```

Finally, we can try to execute the binary. Use `-L` to point to the shared
libraries the executable needs additionally.

**Note:** If you need additional Parameters to be included, use `-E var=value`
(QEMU_SET_ENV) flag.

**Note:** One can also append the path of the shared glibc libraries directly
with `qemu-ppc64le-static -L path/glibc -L path/imx-cst cst`.

```
qemu-ppc64le-static \
  -L tmp/work/ppc64p9le-ifmlinux-linux/imx-cst/3.4.0-r0/recipe-sysroot \
  tmp/work/ppc64p9le-ifmlinux-linux/imx-cst/3.4.0-r0/git/code/obj.linux64/cst --help
```
