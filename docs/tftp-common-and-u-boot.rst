Setting up TFTP
===============

Trivial File Transfer Protocol (TFTP) is a simple File Transfer Protocol
which allows a device on the network to get a file from a host device or
put a file onto a host device.

It works unencrypted and offers no authentication.

Setting up a TFTP server
------------------------

A TFTP server is required on the host device to provide the shared files
to the network. For this example ``tftpd-hpa`` will be installed.

.. code:: bash

   sudo apt install tftpd-hpa

Setup the corresponding TFTP configuration file
*/etc/default/tftpd-hpa*.

::

   TFTP_USERNAME="tftp"
   TFTP_DIRECTORY="/var/srv"
   TFTP_ADDRESS="0.0.0.0:69"
   TFTP_OPTIONS="--secure"

Save the new configuration, restart tftpd-hpa and check for a successful
startup.

.. code:: bash

   sudo systemctl restart tftpd-hpa
   systemctl status tftpd-hpa

Documentation
-------------

More information can be found at:

-  TFTP man page
   https://manpages.debian.org/testing/tftpd-hpa/tftpd.8.en.html

Downloading Files with U-Boot via TFTP
=======================================

U-Boot can also be used to download files to local flash. This documentation describes the process of using U-Boot to download a Linux kernel boot executable and a Device tree file over a TFTP server and save them to the local flash for use during the boot process.

Setting up a TFTP server
------------------------
A TFTP server is to be installed on the host PC. For this example ``tftpd-hpa`` will be installed.

.. code-block:: bash

   sudo apt install tftpd-hpa

Setup the corresponding tftp configuration file */etc/default/tftpd-hpa*.

::

   TFTP_USERNAME="tftp"
   TFTP_DIRECTORY="/path/to/files-to-load"
   TFTP_ADDRESS="0.0.0.0:69"
   TFTP_OPTIONS="--secure"

With the new options saved restart the tftpd server.

.. code-block:: bash

   sudo systemctl restart tftpd-hpa


Preparing U-Boot
----------------
In this example, the host PC is assigned the IP address ``192.168.0.1`` and the development board is assigned the IP address ``192.168.0.100``.

Start the development board, stop the bootloader and configure the U-Boot environment variables. If you wish your settings to be persistent across reboots save the environment variables with ``saveenv``.

::

   ...

   Press SPACE to abort autoboot in 2 seconds

   U-Boot# setenv ipaddr 192.168.0.100
   U-Boot# setenv serverip 192.168.0.1

   U-Boot# setenv netmask 255.255.255.0
   U-Boot# setenv ip-method static

   U-Boot# saveenv

To enable the development board to download the kernel files automatically on boot-up the boot default variable ``bootcmd`` needs to be adjusted.

In this example the files  ``zImage`` and  ``BOARD.dtb`` are downloaded to the memory addresses ``${loadaddr}`` and ``${fdtaddr}``. These serve as the starting point for the bootloader to boot from.

::

   U-Boot# setenv bootcmd 'tftp ${loadaddr} zImage; tftp ${fdtaddr} BOARD.dtb; bootz ${loadaddr} - ${fdtaddr}'
   U-Boot# saveenv

.. note::

   Further memory addresses and environment variables can be found in the official U-Boot documentation.

Run **boot** to boot the target.

::

   U-Boot# boot

Documentation
-------------
More information can be found at:

- U-Boot Environment Variables https://u-boot.readthedocs.io/en/latest/usage/environment.html


