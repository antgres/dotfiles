Build Yocto in a docker container
---------------------------------

0. Install Docker  “Docker CE Stable” or the “Docker Toolbox” [1]
   and check if it is running. For more information see [3].

1. Use a command described in [4]. For Linux use

::

   docker run --rm -it -v $WORKDIR:/workdir crops/poky --workdir=/workdir

2. Download poky and build it

::

   git clone -b kirkstone git://git.yoctoproject.org/poky
   . poky/oe-init-build-env 
   bitbake core-image-minimal
   runqemu qemux86

.. note::

   To spped up the process change the environment variables in
   */build/conf/local.conf* to, for example, [2]

   ::

     BB_NUMBER_THREADS = "8"
     # Also, make can be passed flags so it run parallel threads
     PARALLEL_MAKE = "-j 8"

.. note::

   To install additional applications via eg. *apt* either

   1. build your container fork of *crops/poky*
   2. log into the container via root with

   ::

      docker exec -it --user=root CONTAINERID bash
      apt install nano

   The *CONTAINERID* can be taken from the pokyuser terminal, eg.

   ::

      # USER  @ CONTAINERID
      pokyuser@09844d580f48:/workdir$


References
----------

[1] Setting Up to Use CROss PlatformS (CROPS)
https://docs.yoctoproject.org/4.0.12/dev-manual/start.html?highlight=docker#setting-up-to-use-cross-platforms-crops

[2] The best way to use Yocto and Docker
https://ubs_csse.gitlab.io/secu_os/tutorials/crops_yocto.html

[3] docker-win-mac-docs
https://github.com/crops/docker-win-mac-docs/wiki

[4] Poky Container - README.md
https://github.com/crops/poky-container/blob/master/README.md
