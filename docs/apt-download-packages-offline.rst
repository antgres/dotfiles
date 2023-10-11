

::

   apt-get download htop

::

   apt rdepends "$PACKAGE"  | sed -n '/^  Depends:/ s#  Depends: ##p'

For different architectures
---------------------------

::

   sudo dpkg --add-architecture arm64
   sudo apt update
   apt-get download htop:arm64

