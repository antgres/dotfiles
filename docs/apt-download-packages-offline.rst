# Download source tarball from package

To download the source package itself via a package manager like apt the
following command can be used

::

   apt-get download htop

If the package has package dependencies the following command can be used to
see the dependencies and fetch them accordingly:


::

   apt rdepends "$PACKAGE"  | sed -n '/^  Depends:/ s#  Depends: ##p'

For different architectures
---------------------------

If the target system has a different architecture the source package can be
fetch as follow:

::

   sudo dpkg --add-architecture arm64
   sudo apt update
   apt-get download htop:arm64

