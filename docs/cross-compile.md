# Cross-Compile on x86_64 host for aarch64 target using muslc

## Introduction

This file contains a step-by-step guide on how to cross-compile software on
x86_64 (host) for aarch64 (target) using the muslc cross-compiling toolchain.

'musl libc' is a lightweight alternative to glibc and is often used for
compilation for embedded systems. This is due to its comparably small footprint
and its static linking capabilities.

Since it can be run 'portably' on different systems, it is a good choice for
cross-compiling software without having to mess with the host's libraries. The
guide is based on the following sources: [Jensd's I/O
buffer](https://jensd.be/1126/linux/cross-compiling-for-arm-or-aarch64-on-debian-or-ubuntu)

**Note:** Since cross-compilers can easily mess up native programs, it is a
good practice to cross-compile software only within some kind of container.

**Note:** To run, and test, cross-compiled binaries on the host machine one can
either

- spawn a VM with a different architecture with QEMU 
- use binfmt

See [yocto-qemu.md](yocto-qemu.md) for more information

## Prerequisites

Following packages are needed for a basic cross-compilation using the
glibc-based compiler

```sh
apt install file gcc make gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
```

## Optional: Test basic cross-compilation

To test the cross-compilation process using multiple compilers, a simple "Hello
World"-program will do the trick:

```sh
# Create a simple "Hello World!" c-file
cat <<EOF > helloworld.c
#include <stdio.h>

int main() {
    printf("Hello World\n");
    return 0;
}
EOF

# Compile the c-file for x86_64
gcc helloworld.c -o helloworld-x86_64 -static
# Check the file type; it should be a statically linked x86_64 executable
file helloworld-x86_64

# Compile the c-file for aarch64
aarch64-linux-gnu-gcc helloworld.c -o helloworld-aarch64 -static
# Check the file type; it should be a statically linked aarch64 executable
file helloworld-aarch64
```

## Cross-compiling more complex software

More complex software often requires additional libraries such as glibc or
ncurses. To compile successfully, all libraries must be cross-compiled too,
which is a reason to compile additional libraries statically.

[muslc](https://musl.cc/) includes pre-built cross-compilers for aarch64 which
saves us the trouble of building the cross-compiler with glibc integration from
scratch. muslc can be fetched like:


```sh
wget https://musl.cc/aarch64-linux-musl-cross.tgz
tar -xf aarch64-linux-musl-cross.tgz
./aarch64-linux-musl-cross/bin/aarch64-linux-musl-gcc --version
```

After installing the cross-compiler the following common flag names can be used
to specify the cross-compiler and the cross-compiled libraries:

```sh
export CC=../aarch64-linux-musl-cross/bin/aarch64-linux-musl-gcc
export LD=../aarch64-linux-musl-cross/bin/aarch64-linux-musl-ld
export CFLAGS="-I../aarch64-linux-musl-cross/include"                     #Add necessary include directories here
export LDFLAGS="-L../aarch64-linux-musl-cross/lib -static"                #Add necessary library directories here
export STRIP=../aarch64-linux-musl-cross/bin/aarch64-linux-musl-strip     #Optional, depends on the project
```

**Note**: By exporting the variables in a terminal, the set variables are only
available in the current terminal session but will persist until the terminal is
closed. To make the variables available only for one command, the variables can
be set directly in the command line:

```sh
CC=... LD=... CFLAGS=... LDFLAGS=... STRIP=... ./configure
```

## Example: Cross-compile cli-editor nano and its dependencies

Since nano is a popular command-line editor, it is a good example for testing
out cross-compilation with larger dependencies. In order for the following
example to work, you need to set the environment variable `PRJROOT` to the root
directory of your cross-compilation project. This can be done with the following
command:

```sh
export PRJROOT=/home/$USER/crosscompile
mkdir -p $PRJROOT
cd $PRJROOT
```

First we need to install the musl-cross-compiler as described above:

```sh
cd $PRJROOT
wget https://musl.cc/aarch64-linux-musl-cross.tgz
tar -xf aarch64-linux-musl-cross.tgz
./aarch64-linux-musl-cross/bin/aarch64-linux-musl-gcc --version
```

Next we need to cross-compile ncurses setting the environment-variables as
described above:

```sh
wget https://ftp.gnu.org/gnu/ncurses/ncurses-6.4.tar.gz
tar -xf ncurses-6.4.tar.gz
cd ncurses-6.4/
export CC=$PRJROOT/aarch64-linux-musl-cross/bin/aarch64-linux-musl-gcc
export LD=$PRJROOT/aarch64-linux-musl-cross/bin/aarch64-linux-musl-ld
export STRIP=$PRJROOT/aarch64-linux-musl-cross/bin/aarch64-linux-musl-strip
./configure --build x86_64-pc-linux-gnu --host aarch64-linux-gnu --without-shared
make
```

Finally we can cross-compile nano (make sure the environment-variables are set):

```sh
cd $PRJROOT/
wget https://www.nano-editor.org/dist/v7/nano-7.2.tar.gz
tar -xf nano-7.2.tar.gz
cd nano-7.2/
# Set the environment-variables to include ncurses
export CFLAGS="-I$PRJROOT/ncurses-6.4/include -I$PRJROOT/aarch64-linux-musl-cross/include"
export LDFLAGS="-static -L$PRJROOT/ncurses-6.4/lib -L$PRJROOT/aarch64-linux-musl-cross/lib"
./configure --build x86_64-pc-linux-gnu --host aarch64-linux-gnu CPPFLAGS=-I$PRJROOT/ncurses-6.4/include
make
# The cross-compiled nano executable can be found in the src-directory
# Test if the cross-compilation was successful
file ./src/nano         # Should be a statically linked aarch64 executable
```
