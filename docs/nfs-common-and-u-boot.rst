Setting up NFS
==============

NFS (Network File System) shares a directory located on a host device
with other devices on the network. The devices on the network can mount
this directory and access the shared files.

NFS is a native Unix/Linux protocol in comparison to eg. a Samba/SMB
share.

Setting up a NFS server
-----------------------

A NFS server is required on the host device to provide a shared folder
to the network. For this example ``nfs-kernel-server`` will be
installed.

::

   sudo apt install nfs-kernel-server

Add a rule to the configuration file */etc/exports* how and with whom
the directory is shared. In this example the directory */var/target/nfs*
will be shared to the local network ``192.168.1.0/24`` and with a device
with the IP ``192.168.0.100``.

::

   /var/target/nfs 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
   /var/target/nfs 192.168.0.1(rw,sync,no_subtree_check,no_root_squash)

.. note::

   Between IP and the start bracket is **no** whitespace character.

.. note::

   The wildcard characters \* and ? can be used in the export file to
   share the folder with multiple hosts. See *man 5 exports* for more
   information.

In this example, the share is conditioned with the following parameter:

-

   rw
      Allow both read and write requests on the share.

-

   sync
      Reply to requests only after the changes have been committed to
      the storage.

-

   no_subtree_check
      Disable the check if the requested file is in a sub-/directory.
      Can improve the reliability of the connection at the cost of
      reduced security.

-

   no_root_squash
      Disable the permission of the client device to access files on the
      share as root.

.. note::

   See *man 5 exports* for more parameter.

Save the new rule, restart the nfs-kernel-server and check for a
successful startup.

::

   sudo systemctl restart nfs-kernel-server
   systemctl status nfs-kernel-server

Mounting a shared directory
---------------------------

If the functionality to mount a NFS share is not already available in
the kernel, the following package can be installed:

::

   sudo apt install nfs-common

If the package is installed ``showmount`` can be used to check which
directory a NFS Server is sharing.

::

   showmount -e IP_NFS_SERVER

Now a permissioned device on the network can mount the shared directory.
In this example the shared directory */var/target/nfs* from the host
device with IP *IP_NFS_SERVER* is mounted to the local directory
*/var/nfs*.

::

   sudo mount -t nfs IP_NFS_SERVER:/var/target/nfs /var/nfs

Documentation
-------------

More information can be found at:

-  exports options https://man7.org/linux/man-pages/man5/exports.5.html
-  NFS HOWTO http://nfs.sourceforge.net/nfs-howto/


NFS Booting with U-Boot
=======================

A common configuration for rapid kernel/application development and debugging
is to have the target machine connected to a development host inside a network.

This documentation describes the steps needed to a) setup a NFS Server on a
development PC and b) the necessary configurations in U-boot on the development
board to boot from the host PC. This allows the development board to mount a
root file system over Ethernet.

Assumptions
-----------

It is assumed that:

* the host PC is on the same local network as your development board and the firewall is configured accordingly.
* the development board has a known IPv4 address.
* the development board uses an U-Boot Version which supports NFS.
* the Linux kernel boot executable *zImage* and the Device tree file *BOARD.dtb* are located in the folder path */path/to/kernel-files*.
* the following kernel options were compiled into *zImage*:
       *CONFIG_IP_PNP=y*,
       *CONFIG_NFS_FS=y*,
       *CONFIG_ROOT_NFS=y*
* the root file system is based on the latest ELBE version and extracted to the folder */path/to/nfsroot*.

Setting up a NFS server
-----------------------
A NFS server is to be installed on the host PC. For this example ``nfs-kernel-server`` will be installed.

.. code-block:: bash

   sudo apt install nfs-kernel-server

Add a rule to the configuration file */etc/exports* to share the folder
*/path/to/nfsroot* to the development board with IP ``192.168.0.100``. The
folder will be shared **only** with the IP ``192.168.0.100``.

::

  /path/to/nfsroot 192.168.0.100(rw,sync,no_subtree_check,no_root_squash)


Reload the configuration for the NFS server via

::

  sudo exportfs -r

Save the new rule and restart the nfs-kernel-server.

.. code-block:: bash

   sudo systemctl restart nfs-kernel-server

.. note::

   The wildcard characters * and ? can be used in the export file to share the
   folder with multiple hosts. See *man 5 exports* for more information.

Preparing U-Boot
----------------

In this example, the host PC is assigned the IP address ``192.168.0.1`` and the
development board is assigned the IP address ``192.168.0.100``.

Start the development board, stop the bootloader and configure the U-Boot
environment variables. If you wish your settings to be persistent across
reboots save the environment variables with ``saveenv``.

Take care that the settings from the */etc/exports* matches the target IP
settings in the bootloader.

::

   ...

   Press SPACE to abort autoboot in 2 seconds

   U-Boot# setenv ipaddr 192.168.0.100
   U-Boot# setenv serverip 192.168.0.1

   U-Boot# setenv netmask 255.255.255.0
   U-Boot# setenv ip-method static

   U-Boot# setenv boot_mode nfs

   U-Boot# setenv nfsroot /path/to/nfsroot

   U-Boot# saveenv

or shorter

::

  U-Boot# setenv ipaddr 192.168.0.100 && setenv netmask 255.255.255.0 && setenv serverip 192.168.0.1
  U-Boot# setenv boot_mode nfs && setenv ip-method static && setenv nfsroot /path/to/nfsroot

In order for the kernel to mount the root file system over NFS the kernel boot
arguments ``bootargs`` needs to be adjusted. In this case it is assumed that
the NFS share is connected to the interface *eth0*.

::

   U-Boot# setenv bootargs root=/dev/nfs console=ttyO0,115200n8 nfsroot=${serverip}:${nfsroot},nfsvers=3 ip=${ipaddr}:${serverip}:${gatewayip}:${netmask}::eth0:off
   U-Boot# saveenv

.. note::

   If any further debug messages are needed for mounting the NFS share from the
   kernel, the flag ``nfsrootdebug`` can be appended to the kernel boot
   arguments.

Run **boot** to boot the target.

::

   U-Boot# boot

Documentation
-------------
More information can be found at:

- Recommended: Setting up the NFS server https://bootlin.com/doc/training/embedded-linux-qemu/embedded-linux-qemu-labs.pdf#section*.41

- exports options https://man7.org/linux/man-pages/man5/exports.5.html

- Kernel Boot Arguments https://man7.org/linux/man-pages/man7/bootparam.7.html

- U-Boot Environment Variables https://u-boot.readthedocs.io/en/latest/usage/environment.html

- NFS boot example https://www.kernel.org/doc/html/latest/admin-guide/nfs/nfsroot.html

