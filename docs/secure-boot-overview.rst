===========
Secure boot
===========

.. note::

   Every source that refers to a talk at a conference also has slides
   available for this talk. They are just not linked in.

Secure Boot is a security feature that aims to establish trust and
integrity throughout the boot process, preventing unauthorized or
malicious code from compromising, or in general running, on the system.
[G1] [G2, 1:34]

Secure boot works using cryptographic checksums and signatures. Each
program that is loaded by the firmware includes a signature and a
checksum, and before allowing execution, the firmware will verify that
the program is trusted by validating the checksum and the signature.
This creates a chain of trust. When secure boot is enabled on a system,
any attempt to execute an untrusted program will not be allowed. [G1]

Boot stages
===========

To create a chain of trust each stage in the boot order needs to be
authenticated (and, if implemented, decrypted) by the stage beforehand
and also needs to do the same for the next stage in the boot order.

TF-A implements the Trusted Board Boot via asynchronous keys and
certificates. The single stages are signed and embedded with a public
key during build time. The authentication process can be described by
the following figure. [G7]

::

                                  PubKey
            Actual    Expected      |
   Hash---> Digest-----Digest <---Decrypt
    |               |               |
   Data             |           Certificate
                 Compare

Stage N calculates the hash of each stage N+1 image. It compares it with
the hash obtained from the corresponding content certificate. The image
authentication succeeds if the hashes match. [G7] [G8]

The stages can be different depending on the e.g. SoC, but in general
the following stages can be named:

1. BootROM
2. Bootloader(s)
3. Kernel
4. Userspace (rootfs)
5. Userspace application

A more detailed example of a complete boot order can be seen in [G3].

The **BootROM** (aka Root of Trust) contains a hardwired inital setup
code which cannot be changed or updated [1]_. It contains the public
key(s) and the microcode to check the signature of the next stage, the
bootloader. [G2, 9:49] [G4] i.MX SoCs implement the [High Assurance
Boot](#high-assurance-boot-hab) (HAB) functionality in this stage.

The **Bootloader** usually consists of several sub-stages itself which
can be:

1. U-Boot SPL(s)
2. optional: [ATF](#arm-trusted-firmware-atf) BL31,
   [TEE](#trusted-execution-environment-tee)
3. U-Boot

All sub-stagess check the signature of the next sub-stage to create the
chain of trust. Other security functionality can be initialised and used
here for the next stages, such as [ARM Trusted
Firmware](#arm-trusted-firmware-atf (ATF) or [Trusted Execution
Environment]](#trusted-execution-environment-tee) (TEE).

The bootloader **has** to be sufficiently locked-down, otherwise there
is no point authenticating it. [G2, 14:50] A link collection for some
pitfalls and attacks on secure boot via the bootloader are described in
chapter [Security holes](#security-holes). The use of a FIT image is
recommended. [G2, 20:13]

The **kernel**, or in general the **rootfs**, can be additionally
encrypted (via dm-crypt or dm-crypt) and set to a read-only filesystem
(eg. squashfs). [G2, 25:02-37:55] [G6]

Disadvantages
=============

As described in [G2, 7:36], secure boot requires more effort:

-  whole architecture to create/build/use/distribute keys
-  if the platform is locked down, the developer needs to re-sign the
   binary and validate the chain of trust every time
-  increase in boot time

If a single opening exists or a private key is broken or leaked:
failure.

Security holes
==============

*Work in progress*

[S1] Vacuum robot security and privacy prevent your robot from sucking
your data - Dennis Giese
https://media.ccc.de/v/camp2023-57158-vacuum_robot_security_and_privacy

[S2] 20 ways past secure boot - Job de Haas
https://archive.conference.hitb.org/hitbsecconf2013kul/materials/D2T3%20-%20Job%20de%20Haas%20-%2020%20Ways%20Past%20Secure%20Boot.pdf

[S3] U-Booting securely - Dmitry Janushkevich
https://labs.withsecure.com/publications/u-booting-securely

[S4] I hack, U-Boot - Théo Gordyjan
https://www.synacktiv.com/en/publications/i-hack-u-boot

Terminology
===========

Trusted Execution Environment (TEE)
-----------------------------------

The *Trusted Execution Environment* (TEE) is a specification to define a
way to ensure the integrity and confidentiality of data running in the
entity implementing this specification. It specifies the use of both
hardware and software to protect data and code via a secure area inside
the main processor. This alongside-system is intended to be more secure
than the classic *Rich Execution Environment* (REE) system. [TEE1]

"Trusted applications running in a TEE have access to the full power of
a device's main processor and memory, whereas hardware isolation
protects these components from user installed applications running in
the main operating system. Software and cryptographic isolations inside
the TEE protect the different contained trusted applications from each
other." [TEE1]

TEE also defines in general hardware and software architecture, device
life cycle, security problem definitions, objectives and requirements
and attackers profiles (security levels) 1 to 4. [TEE2]

An example of available hardware technologies which implement TEE can be
seen in [TEE3].

An example of available software which implement TEE can be seen in
chapter [Software](#software).

Some TEE implementations vulnerabilities can be found at [TEE4].

[TEE1] Introduction to Trusted Execution Environment: ARM's TrustZone
https://blog.quarkslab.com/introduction-to-trusted-execution-environment-arms-trustzone.html

[TEE2] TEE Protection Profile Version 1.2
https://www.commoncriteriaportal.org/files/ppfiles/anssi-profil_PP-2014_01.pdf

[TEE3] Trusted execution environment: Hardware support
https://en.wikipedia.org/wiki/Trusted_execution_environment#Hardware_support

[TEE4] Introduction to Trusted Execution Environment and ARM's TrustZone
https://sergioprado.blog/introduction-to-trusted-execution-environment-tee-arm-trustzone/#nothing-is-100-secure

ARM Security Models
-------------------

The ARM Cortex-A architecture features a security extension called
**TrustZone hardware architecture**. "ARM Processor uses ARM TrustZone
technology to implement the TEE environment". [EL4]

ARM TrustZone achieves system security by dividing all of the device's
hardware and software resources, so that they exist in either the secure
world for the security subsystem, or the normal world for everything
else. System hardware ensures that no secure world resources can be
accessed from the normal world. [EL1] [EL5]

To transition between the secure world and the normal world the *secure
monitor (mode)* is used. [EL1] [EL5]

In the ARMv8 architecture they reworked a bunch of stuff: It introduces
AARCH64 and it reworked the exception handling model.

In ARMv8, execution occurs at one of four exception levels:

-  EL0: Normal user applications.
-  EL1: Operating system kernel typically described as privileged.
-  EL2: Hypervisor.
-  EL3: Low-level firmware, including the Secure Monitor.

How the exception levels are linked together with the Trustzone in
ARMv8-A can be seen in the figure below. [EL2]

::

                                Normal World                            ||    Secure World
       --------------- --------------- --------------- ---------------  || -------------------
   EL0 | Application | | Application | | Application | | Application |  || | Secure Firmware | EL0S
       --------------- --------------- --------------- ---------------  || -------------------
       ------------------------------- -------------------------------  || -------------------
   EL1 |          Guest OS           | |           Guest OS          |  || |   Trusted OS    | EL1S
       ------------------------------- -------------------------------  || -------------------
       ---------------------------------------------------------------  ||
   EL2 |                          Hypervisor                         |  ||    No Hypervisor
       ---------------------------------------------------------------  ||
       - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
       ---------------------------------------------------------------------------------------
   EL3 |                           Secure Monitor (Secure World)                             |
       ---------------------------------------------------------------------------------------

A more detailed comparison can be found in [EL3].

[EL1] ARM Cortex-A Series Programmer's Guide for ARMv7-A: TrustZone
hardware architecture
https://developer.arm.com/documentation/den0013/d/Security/TrustZone-hardware-architecture

[EL2] ARM Cortex-A Series Programmer's Guide for ARMv8-A: Fundamentals
of ARMv8
https://developer.arm.com/documentation/den0024/a/Fundamentals-of-ARMv8

[EL3] Ngabonziza, Bernard et. al. TrustZone Explained: Architectural
Features and Use Cases. 10.1109/CIC.2016.065.
https://dl.acm.org/doi/abs/10.1007/978-3-030-68851-6_14

[EL4] Demystifying ARM TrustZone TEE Client API using OP-TEE
https://dl.acm.org/doi/10.1145/3426020.3426113

[EL5] Trusted Execution Environments and Arm TrustZone
https://azeria-labs.com/trusted-execution-environments-tee-and-trustzone/

ARM Trusted Firmware (ATF)
--------------------------

"Originally known as Arm Trusted Firmware (ATF), an ARM open source
project since October 2013, with the recent launch of Trusted Firmware
(TF) community project, TF-A has been migrated to an open governance
model and it's now fully part of the Trusted Firmware community." [ATF1]

Therefore, ATF implements the [Trusted Firmware-A](#trusted-firmware-tf)
(TF-A). [ATF2]

[ATF1] Trusted Firmware-A
https://developer.arm.com/Tools%20and%20Software/Trusted%20Firmware-A

[ATF2] ARM Trusted Firmware (ATF)
https://ohwr.org/project/soc-course/wikis/ARM-Trusted-Firmware-(ATF)

(ARM) Trusted Firmware Design
-----------------------------

"Trusted Firmware-A (TF-A) implements a subset of the Trusted Board Boot
Requirements (TBBR) Platform Design Document (PDD) for Arm reference
platforms. The TBB sequence starts when the platform is powered on and
runs up to the stage where it hands-off control to firmware running in
the normal world in DRAM. This is the **cold boot path**." [ATD1]

For AArch64, it is divided into five steps (in order of execution)
[ATD1] [ATD3]

::

                Stage           |Level |            Desciption
   ---------------------------------------------------------------------
   Boot Loader stage 1   (BL1)  | EL3  | AP Trusted ROM
   Boot Loader stage 2   (BL2)  | EL1S | Trusted Boot Firmware
   Boot Loader stage 3-1 (BL31) | EL3  | EL3 Runtime Firmware
   Boot Loader stage 3-2 (BL32) | EL1S | Secure-EL1 Payload (optional)
   Boot Loader stage 3-3 (BL33) | EL2  | Non-trusted Firmware

The cold boot begins execution from the platform’s reset vector at EL3.
The BL1 data section is copied to trusted SRAM at runtime. After
performing platform setup, BL1 determines if a Firmware Update (FWU) is
required or to proceed with the normal boot process. [ATD1]

BL1 loads and passes control to BL2 at EL1-Secure. BL2 initalizes
architecture and plattform specific code. After that BL2 loads the BL31
image (the EL3 Runtime Software image), and the optional BL32 image,
into trusted SRAM and the BL33 image into non-secure memory as defined
by the platform. Finally, BL2 passes control back to BL1 to call the
BL31 entrypoint and, once secure state initialization is complete, the
BL33 entry point. [ATD1]

BL31 initalizes more architecture, plattform and runtime specific code
and services. If a BL32 image is detected a Secure-EL1 Payload
Dispatcher (SPD) service is needed to initialize the image. [ATD1]

This can be showcased in the following diagram [ATD4]

::

        Normal (Non-Secure) World |                      Secure World
   ----------------------------------------------------------------------------------------------
                                  |
   EL0     Rich Applications      |                                 Trusted Applications     EL0S
                   |              |                                          |
                   |              |                                          |
                   |4             |                                       optional:
   EL1   Non trusted EL1-Payload  | Trusted Boot Firmware         Secure EL1-Payload (BL32)  EL1S
            eg. Linux kernel      |   2|     (BL2)                  eg. OP-TEE Trusted OS
                   |              |    |       |                             |
                   |              |    |       |                             |
                   |3             |    |       |                             |
   EL2    Non-trusted Firmware    |    |       ---------------------         |
         (BL33) eg. uboot, UEFI---|----+---------------------------|----------
   -------------------------------|    |                           |
                                       |                           |1
   EL3                   EL3 Runtime Software (BL31)        Trusted ROM (BL1)
                         Secure Monitor, SMCs, PSCI

This can also be illustrated with a time sequence [ATD5]

::

   EL3 |  |BL1| |BL2| |                BL31
   ----|-----------------------------------
   EL2 |              | BL33 | | Hypervisor
   ----|-----------------------------------
   EL1 |                          |   Linux
   ----|-----------------------------------
   EL0 |                             |  App
       |             ->time
       | Reset Vector

BL1, BL2 and BL31 are part of the TF-A project. BL32 can be either taken
from the TF-A project or it can be an external project (for example
OP-TEE). BL33 is the first non-secure code loaded by TF-A and may be a
traditional bootloader like uboot. [ATD2] [ATD4]

For a more in detail explaination for the ARM bootflow see [ATD5].

[ATD1] Firmware Design
https://trustedfirmware-a.readthedocs.io/en/v2.8/design/firmware-design.html

[ATD2] TF-A overview https://wiki.st.com/stm32mpu/wiki/TF-A_overview

[ATD3] ARM Trusted Firmware (ATF)
https://ohwr.org/project/soc-course/wikis/ARM-Trusted-Firmware-(ATF)

[ATD4] Trusted Execution Environments: A Technical Overview of Intel SGX,
Arm TrustZone, and RISC-V PMP - Stephano Cetola, The Linux Foundation
https://www.youtube.com/watch?v=MREwcSo0uz4

[ATD5] How ARM Systems are Booted: An Introduction to the ARM Boot Flow
- Rouven Czerwinski, Pengutronix
https://www.youtube.com/watch?v=GXFw8SV-51g

[ATD6] Firmware Design - Cold boot
https://trustedfirmware-a.readthedocs.io/en/v2.8/design/firmware-design.html#cold-boot

Software
========

Trusted Firmware (TF)
---------------------

Trusted Firmware project provides a reference implementation of secure
software for processors implementing both the A-Profile for ARM
{Cortex-A,Neoverse) architecture (TF-A) and M-Profile for ARM Cortex-M
architecture (TF-M). [TF1]

The Trusted Firmware project provides SoC developers and OEMs with a
reference trusted code base complying with the relevant ARM
specifications, allowing quick and easy porting to modern chips and
platforms. [TF1]

TF-A includes an Exception Level 3 (EL3) Secure Monitor and is
implementing the follwoing ARM interface standards: [TF4]

-  Power State Coordination Interface (PSCI)
-  Trusted Board Boot Requirements CLIENT (TBBR-CLIENT)
-  Secure Monitor Call (SMC) Calling Convention
-  System Control and Management Interface (SCMI)
-  Software Delegated Exception Interface (SDEI)

It interfaces with the two worlds as follows [TF3]

::

   Linux Application      Secure Application
         (EL0)                 (EL0S)
           |                      |
           |   System             |
           |    call              |
           |                      |
     Linux Kernel             Trusted OS
         (EL1)                  (EL1S)
           |                      |
           |   PSCI, SCMI,        |
           |   etc                |
           -----Secure firmware/---
                  monitor (EL3)

TF-A is loaded after the BootROM and stays resident after the control
has passed to the OS. [TF3]

[TF1] About https://www.trustedfirmware.org/about/

[TF2] Trusted Firmware: Building Secure Firmware Collaboratively - Shebu
Varghese Kuriakose & Matteo Carlini, ARM
https://www.youtube.com/watch?v=LxLYq8xyexY

[TF3] Bootlin Embedded Linux training - Slides - Trusted Firmware
https://bootlin.com/doc/training/embedded-linux/embedded-linux-slides.pdf

[TF4] ARM-software/arm-trusted-firmware
https://github.com/ARM-software/arm-trusted-firmware

OP-TEE
------

OP-TEE is an open source TEE that implements TrustZone technology. It is
designed to use ARM TrustZone technology and is implemented according to
TEE Internal Core API v1.3.1. [OP1]

OP-TEE consists of three components, OP-TEE Client, OP-TEE Linux driver
[OP2], and OP-TEE Trusted OS. It also ensures platform integrity with
TrustZone secure boot.

The OP-TEE project is part of the Trusted Firmware project. [OP4]

[OP1] About OP-TEE
https://optee.readthedocs.io/en/latest/general/about.html

[OP2] TEE subsystem https://docs.kernel.org/staging/tee.html

[OP3] Demystifying ARM TrustZone TEE Client API using OP-TEE
https://dl.acm.org/doi/10.1145/3426020.3426113

[OP4] OP-TEE moving into Trusted Firmware
https://www.trustedfirmware.org/blog/op-tee-moving-into-trusted-firmware/

High Assurance Boot (HAB)
-------------------------

*High Assurance Boot* (HAB) is an optional NXP feature in the i.MX SOC
family, which allows to make sure only a signed first stage bootloader
can be executed by the SoC. It incorporates BootROM level security which
cannot be altered after programming the appropriate one-time
electrically programmable fuses (eFuses). [HAB1] [HAB2]

HAB uses public key cryptography, specifically RSA keys, to authenticate
the image executed at boot time. Image data is signed offline by the
image provider using private keys and the i.MX processor verifies the
signature using the corresponding public keys, which are loaded from a
section of the binary to be verified. [HAB2]

The root of the trust chain is anchored on a set of RSA key pair(s)
called *Super Root Keys* (SRKs). The public key(s) are stored on the
i.MX masked ROM. [HAB1] [HAB2] More information can be seen in [HAB3].

The successor of HAB is called *Advanced High Assurance Boot* (AHAB).

[HAB1] i.MX High Assurance Boot (HAB) / Secure Boot
https://variwiki.com/index.php?title=High_Assurance_Boot

[HAB2] High Assurance Boot (HAB)
https://blog.quarkslab.com/vulnerabilities-in-high-assurance-boot-of-nxp-imx-microprocessors.html#high-assurance-boot-hab

[HAB3] i.MX 6 Linux High Assurance Boot (HAB) User's Guide
https://community.nxp.com/pwmxy87654/attachments/pwmxy87654/imx-processors/60046/1/i.MX_6_Linux_High_Assurance_Boot_(HAB)_User's_Guide.pdf

[HAB4] Secure boot in embedded Linux systems - Thomas Perrot
https://bootlin.com/pub/conferences/2021/lee/perrot-secure-boot/perrot-secure-boot.pdf

Hardware TEE vs TPM vs Secure Enclave
-------------------------------------

A hardware trusted execution environment (TEE) is a secure area of a main
processor which guarantees confidentiality and integrity of code and data
loaded inside. A TEE as an isolated execution environment provides security
features such as isolated execution, integrity of applications executing with
the TEE, along with confidentiality of their assets. [TTS1]

Trusted Platform Module (TPM) is an international standard for a secure
cryptoprocessor – a special microcontroller designed to secure hardware
through integrated a true random number generator, secure memory for storing
secrets, cryptographic operations and tamper resistance. This microcontroller
interfaces with a standard hardware/software platform to be secured to serve
the interests of the system designer alone. TPM can also refer to a chip
conforming to the standard. [TTS1] [TTS2]

A secure enclave is similar to a hardware TEE but they differ in that a
secure enclave is often a specific component, like a separate co-processor,
within a device's hardware. The data and processes within the enclave are
protected from unauthorized access, even if the main system is compromised.

Secure enclaves identifies as a TEE. [TTS3]

A secure element is a tamper-resistant hardware platform, capable of securely
hosting applications and storing confidential and cryptographic data. It
provides a highly-secure environment that protects user credentials.
It refers to secure solutions like STSAFE, ATECC608, and hardware roots of
trust without the standard TPM interface. Secure elements are unique in terms
of interface. [TTS1]

[TTS1] What Is the Difference Between HSM, TPM, Secure Enclave, and Secure
Element or Hardware Root of Trust
https://www.wolfssl.com/difference-hsm-tpm-secure-enclave-secure-element-hardware-root-trust/

[TTS2] Hardware Solutions To Highly-Adversarial Environments Part 2: HSM vs
TPM vs Secure Enclave
https://www.cryptologie.net/article/500/hardware-solutions-to-highly-adversarial-environments-part-2-hsm-vs-tpm-vs-secure-enclave/

[TTS3] Secure enclaves
https://www.thoughtworks.com/en-de/radar/techniques/secure-enclaves

UEFI uBoot vs uBoot
-------------------

The *Unified Extensible Firmware Interface* (UEFI) serves as a
contemporary replacement for traditional bootloaders like uBoot. It is
described in the *Embedded Base Boot Requirements* (EBBR) specification.
[UEFI2]

The idea of EBBR is "to define a set of boot standards that reduce the
amount of custom engineering required, make it possible for OS
distributions to support embedded platforms, while still preserving the
firmware stack that product vendors are comfortable with. Or in simpler
terms, EBBR is designed to solve the embedded boot mess by adding a
defined standard (UEFI) to the existing firmware projects (U-Boot)."
[UEFI1]

UEFI introduces several advantages to the booting process. It provides a
standardized interface, ensuring consistency across platforms.
Compatibility with various operating systems and support for secure boot
are notable features. Moreover, UEFI offers networking capabilities and
advanced scripting, enhancing adaptability in diverse environments.

However, the adoption of UEFI brings its own set of challenges. The
increased complexity of UEFI may pose difficulties in configuration and
maintenance. Its larger resource footprint, potentially longer boot
times, and reduced community support compared to uBoot are factors to
consider, especially in resource-constrained environments. The learning
curve associated with UEFI may also impact those accustomed to the
simplicity of uBoot.

Deciding to transition requires a careful evaluation of project needs,
balancing the desired features of UEFI against the potential drawbacks.

[UEFI1] EBBR Specification https://arm-software.github.io/ebbr/

[UEFI2] UEFI on U-Boot
https://u-boot.readthedocs.io/en/latest/develop/uefi/uefi.html

References
==========

[G1] SecureBoot https://wiki.debian.org/SecureBoot

[G2] Secure Boot from A to Z - Quentin Schulz & Mylène Josserand,
Bootlin https://www.youtube.com/watch?v=jtLQ8SzfrDU

[G3] From Reset Vector to Kernel - Navigating the ARM Matryoshka - Ahmad
Fatoum, Pengutronix https://www.youtube.com/watch?v=-Ak9MWGxd7M

[G4] IFM Ecomatic Workshop - Marek Vašut

[G5] Secure Boot: What Is It, and Do I Need It? - Fabio Tranchitella,
Northern.tech https://www.youtube.com/watch?v=Fwp_DMIeK5M

[G6] An Introduction to Dm-verity in Embedded Device Security
https://www.starlab.io/blog/dm-verity-in-embedded-device-security

[G7] Secure boot in embedded Linux systems - Thomas Perrot
https://bootlin.com/pub/conferences/2021/lee/perrot-secure-boot/perrot-secure-boot.pdf

[G8] Trusted Board Boot - Chain of Trust
https://trustedfirmware-a.readthedocs.io/en/latest/design/trusted-board-boot.html#chain-of-trust

Footnotes
=========

.. [1]
   The ability to update the microcode depends on the processor in use.
   https://wiki.archlinux.org/title/microcode#Which_CPUs_accept_microcode_updates
