# Secure boot

Secure Boot is a security feature that aims to establish trust and integrity
throughout the boot process by allowing only approved software to execute on
the platform, and by preventing unauthorized or malicious code from
compromising, or in general running, on the system. [SB1] [SB2]

Secure boot is achieved by establishing a **chain of trust**, starting from the
hardware. The chain of trust is implemented using a series of cryptographic
signatures and hashes, attached to software components.

Each boot stage that is loaded during the boot process includes a signature and
a signed hash. Before allowing the execution of the next boot stage, it is to
be authenticated by the current boot stage by comparing the calculated hash of
the next boot stage with the appended signed hash. Any attempt to execute an
unauthenticated boot stage results in the failure of the boot process. [SB1]

## Table of Contents
1. [Fundamentals](#fundamentals)  
  1.1. [The CIA Triad](#the-cia-triad)  
  1.2. [Encryption](#encryption)  
  1.3. [Asymmetric Keys](#asymmetric-keys)  
  1.4. [Signatures](#signatures)  
  1.5. [Certificates](#certificates)  
2. [Boot stages](#boot-stages)  
3. [Disadvantages](#disadvantages)  
4. [Security holes](#security-holes)  
5. [Terminology](#terminology)  
  5.1. [Trusted Execution Environment (TEE) Specification](#trusted-execution-environment-tee-specification)  
  5.2. [ARM Security Models](#arm-security-models)  
  5.3. [ARM Trusted Firmware (ATF)](#arm-trusted-firmware-atf)  
  5.4. [(ARM) Trusted Firmware (TF) Design](#arm-tusted-firmware-design)  
  5.5. [High Assurance Boot (HAB)](#high-assurance-boot-hab)  
6. [Software](#software)  
  6.1. [Trusted Firmware (TF)](#trusted-firmware-tf)  
  6.2. [OP-Tee](#op-tee)  
  6.3. [Hardware TEE vs TPM vs Secure Enclave vs Secure Element](#hardware-tee-vs-tpm-vs-secure-enclave-vs-secure-element)  
7. [References](#references)  

## Fundamentals

### The CIA Triad

The three letters in CIA triad stand for *Confidentiality*, *Integrity*, and
*Availability*. The CIA triad is a common model that forms the basis for the
development of security systems. They are used for finding vulnerabilities and
methods for creating solutions. [F1]

There are other IT protection goals, including authenticity, privacy,
reliability and (non)-repudiation. However, the CIA triad is of particular
importance in information security, as they are often referred to as the
*pillars of data security*. [F2]

The three most important IT protection goals mean in detail: [F2]

- Confidentiality  
    Data should be treated confidentially and only authorized users should be
    able to view it. This applies both to their state during storage and to
    any data transmission. Under all circumstances, confidential data must not
    be disclosed to unauthorized third parties.

- Integrity  
    Data integrity requires that both the data and the functioning of the
    processing system are correct. This includes data integrity and system
    integrity. Additionally, any changes made to the data during business
    processes should be easily traceable.

- Availability  
    This means that both the IT systems and the data stored in them must be
    available at all times. In most cases, this cannot be guaranteed 100
    percent.

### Encryption

Encryption is the process of encoding information in a format that cannot be
read or understood by an unauthorized observer. [F3]

The process of encrypting and decrypting messages involves keys. There are two
main types of encryption keys in cryptographic systems: symmetric-keys and
asymmetric-keys. [F3]

### Asymmetric Keys

In an asymmetric key (also called public-key) encryption scheme, a pair of keys
(usually called public and private keys) is used. Data encrypted with the
public key can only be decrypted with the private key, and vice-versa. [F3]

This relationship is shown in the following diagram: [F4]

                Public                 Private
                  Key                    Key
                   |                      |
    +-------+      |       +-------+      |       +-------+
    | Plain |  Encryption  | *?*?* |  Decryption  | Plain |
    | Text  |------------->| *?*?  |------------->| Text  |
    +-------+              +-------+              +-------+
                          Cipher Text

The advantage of this scheme is that the user can freely share the public key
with other parties while not sharing the private key. If other parties want to
send an encrypted message to the private key owner, they can encrypt it with
the public key which can only be decrypted by the private key.

### Signatures

Encryption is a mean to achieve confidentiality. It is used to protect the
information from disclosure to unauthorized parties. However, it is not a mean
to validate the origin of information, meaning an encrypted message does not
necessarily originate from a well trusted source with the intended content. For
this purpose, cryptographic signatures are used to confirm the legitimacy of
the sender of the message(s), document(s) or data. [F4]

Cryptographic signatures leverage cryptographic hash functions like SHA to
ensure the integrity and authenticity of digital documents. Before signing, a
unique hash value is generated from the content of the document using a one-way
hash function. This hash, representing the documents integrity, is then
encrypted using the signers private key, forming the digital signature. [F4]

Recipients can verify the signature by independently calculating the hash of
the received document/data, decrypting the attached signature using the signing
party public key, and confirming a match. [F4]

**Note:** Hash functions are not free of collisions, i.e., instances where
multiple inputs yield identical hash values.

This relationship is shown in the following diagram: [F4]

    Data signing
                                                       Signed Data Layout
    Signer--> Data--------------------> +-> Signed     +----------------+
               |                        |    Data      |      Data      |
               +--> Hash--> Encryption--+              +----------------+
                                |                      | Encrypted hash |
                            PrivateKey                 +----------------+

    Data Validation

    Signed--> Data--> Calculate---------+
     Data               Hash            v       | If hashes equal:
      |                              Compare--> |   Signature valid
      |            (Precalculated)      ^       | else:
      +--> Hash -->  Decrypted----------+       |   Signature not valid
        Decryption     Hash
            |
        PublicKey

If both authenticity and integrity are present the legitimacy of the data (both
origin and content) cannot be denied. This is usually called non-repudiation.

However, a potential trap can occur during transmission: both the public key
and the digitally signed data may be tampered with. In this scenario, an
attacker could intercept the data, encrypt a newly generated hash with its own
private key from the (signed) data, sign the data, and send the new public key
along with the tampered signed data to the receiver. [F4]

This case occurs when both the public key and the signed data are transmitted,
but cannot be authenticated by the recipient. If the public key is embedded
into the device, the task of replacing the signed data with a malicious version
is not easily possible. However, the attacker could alter the data itself
during transmission, i.e. the calculated hash, resulting in an invalid
signature check because the calculated hash differs from the hash calculated by
the signer. This would result, in the worst case, in a not bootable device.

Therefore, all data from a recipient should be authenticated at multiple
occasions, no matter whether fetching or execution.

The uncertainty of the origin of the public key can be solved by certificates
and a public-key infrastructure (PKI). [F4]

### Certificates

Certificates are data packages which identify the entity that is associated
with a public key. The certificate itself is signed by a single, or multiple,
trusted Certificate Authority (CA), validating the authenticity of the
certificate. This is called a certificate chain. [F5] [F6]


       Bundes-             D-TRUST             ifm               VHIP4
     netzagentur            GmbH               GmbH            Evalboard
    +----------+ signs +------------+ signs +-------+ signs +-------------+
    |   Root   |---+   |Intermidiate|---+   |Issuing|---+   |   Device    |
    |    CA    |   +-->|     CA     |   +-->|  CA   |   +-->| Certificate |
    +----------+       +------------+       +-------+       +-------------+

The certificate includes the public key and information about it, information
about the identity of its owner and the digital signature of an entity that has
verified the certificate contents. [F5]

            ifm Certificate   | Example Categories
         +  +--------------+  +------------------------
         |  |      DE      |  | Country
    Meta |  |  Martin Buck |  | Common Name
    data |  |      ifm     |  | Organization
         |  | D-Trust GmbH |  | Verified by
         |  |  2030-07-04  |  | Not valid after
         +  +--------------+  |
    Key  |  |  Public Key  |  | Public Key Information
         +  +--------------+  |

When an individual/organization/party uses their private key to create, for
example, a digital signature, recipients can verify that signature using the
public key within the associated certificate. [F5]

For more detailed information and diagrams see [F6].

[F1] CIA Triad  
https://www.fortinet.com/de/resources/cyberglossary/cia-triad

[F2] CIA-Traide -- Definition  
https://it-service.network/it-lexikon/cia-triade

[F3] Introduction to encryption for embedded Linux developers  
https://sergioprado.blog/introduction-to-encryption-for-embedded-linux-developers

[F4] Asymmetric-Key Encryption and Digital Signatures in Practice  
https://sergioprado.blog/asymmetric-key-encryption-and-digital-signatures-in-practice/

[F5] Public key certificate  
https://en.wikipedia.org/wiki/Public_key_certificate

[F6] Everything you should know about certificates and PKI but are too afraid
to ask  
https://smallstep.com/blog/everything-pki/#certificates-drivers-licenses-for-computers-and-code

## Boot stages

To establish a chain of trust, each stage in the boot order needs to be
authenticated (and, if implemented, decrypted) by the previous stage.
Traditionally this is done via asynchronous keys and certificates. Each stage
contains a public key necessary to authenticate the next stage. Each stage is
also signed with a matching private key which is kept secret. [SB6] [SB7]

This concept can be described by the following figures. In the figures Data N
is already authenticated, Data N+1 is to be authenticated.

    Build Phase

                                 boot media
                              +-------------+
    Data-+------------------> |    Data N   |
         |                    +-------------+
         |                    |PublicKey N+1|
         v                    +-------------+
     calculated--> Encrypt--> | Signature N |
        hash          ^       +-------------+
                      |
                PrivateKey N

    Boot Phase

                boot media
             +-------------+
        +----|   Data N+1  |
        |    +-------------+
        |    |PublicKey N+2|
        |    +-------------+
        |    |Signature N+1|------+
        |    +-------------+      |
        |    |             |      |
        |    |     ...     |      |
        |    |             |      |
        |    +-------------+      |
        |    |    Data N   |      |
        |    +-------------+      |
        |    |PublicKey N+1|---+  |
        |    +-------------+   |  |
        |    | Signature N |   |  |
        |    +-------------+   |  |
        |                      |  |
        v           pre-       |  |
    calculated   calculated    v  v
      Hash----+-----Hash <---Decrypt
              |
           Compare

The calculated hash of the next stage N+1 is compared with the pre-calculated
hash (of the next stage N+1), which is stored in the signature of stage N. Each
image is authenticated by a public key, which is part of the already
authenticated current stage. BootROM stage uses public key stored (and obtained
from) e.g. the one-time programmable storage on the SoC. The authentication
succeeds if the hashes match. [SB5] [SB6] [SB8]

The stages are different, depending on SoC or even system setup. However, the
following common stages are generally present:

1.  BootROM
2.  Bootloader(s)
3.  Kernel
4.  Userspace (rootfs)
5.  Userspace application

A more detailed example of a complete boot order can be seen in [SB3].

The **BootROM** contains a hardwired initial setup code which cannot be changed
or updated. BootROM uses keys embedded in hardware (also known as Root of
Trust) and implements software services to authenticate the next stage using
those keys. [SB2] [SB4] i.MX SoCs implement the [High Assurance
Boot](#high-assurance-boot-hab) (HAB) functionality in this stage.

The **Bootloader** usually consists of several sub-stages itself which can be:

-  U-Boot secondary program loader (SPL)
-  U-Boot

All sub-stages check the signature of the next sub-stage to establish the chain
of trust. Other functionality can be initialized and used here for the next
stages, such as [ARM Trusted Firmware](#arm-trusted-firmware-atf) (ATF) or
[Trusted Execution Environment](#trusted-execution-environment-tee) (TEE), as
well as for example memory protection and isolation configurations.

It is recommended that the bootloader should be sufficiently locked-down. A
collection of links for some pitfalls and attacks on secure boot via the
bootloader are described in chapter [Security holes](#security-holes). The use
of a FIT image is recommended. [SB2] Anything else is either legacy, deprecated
or dangerous (or a combination of all three).

The **Kernel**, **Userspace** and **Userspace applications** can extend this
chain of trust via the embedded device public key(s) or via external keys
embedded in a, for example, initramfs.

Additional measures, that can be applied here but are outside the chain of
trust are the use of **dm-verity**, **dm-crypt** and read-only filesystem like
squashfs. [SB2] [SB7]

## Disadvantages

As described in [SB2], secure boot requires more effort:

- whole architecture to create/build/use/distribute keys
- if the platform is locked down, the developer needs to re-sign the binary
  and validate the chain of trust every time
- increase in boot time

Therefore it is recommended to do all development with an unlocked device to
postpone the described disadvantages.

## Security holes

Since no security mechanism offers one hundred percent security (also due, for
example, to security gaps in the whole architecture), some example resources
are collected here that deal with the circumvention of secure boot.

[S1] Vacuum robot security and privacy prevent your robot from sucking
your data - Dennis Giese  
https://media.defcon.org/DEF%20CON%2031/DEF%20CON%2031%20presentations/Dennis%20Giese%20-%20Vacuum%20robot%20security%20and%20privacy%20-%20prevent%20your%20robot%20from%20sucking%20your%20data.pdf  
https://media.ccc.de/v/camp2023-57158-vacuum_robot_security_and_privacy

[S2] 20 ways past secure boot - Job de Haas  
https://archive.conference.hitb.org/hitbsecconf2013kul/materials/D2T3%20-%20Job%20de%20Haas%20-%2020%20Ways%20Past%20Secure%20Boot.pdf  
https://www.youtube.com/watch?v=74SzIe9qiM8

## Terminology

### Trusted Execution Environment (TEE) Specification

The *Trusted Execution Environment* (TEE) is a specification to define a way to
ensure the integrity and confidentiality of data running in the entity
implementing this specification. It specifies the use of both hardware and
software to protect data and code via a secure area inside the device. It runs
alongside a standard OS or *Rich Execution Environment* (REE) system. [TEE1]
[TEE2]

Trusted applications running in a TEE have access to the full power of a
devices main processor and memory, whereas hardware isolation protects these
components from user installed applications running in the main operating
system. Software and hardware isolations inside the TEE protect the different
trusted applications from each other. [TEE1]

The TEE specification defines multiple architecture implements to accomplish
this goal, see [TEE2, Figure 2-2] and [TEE2, Figure 2-3], as well as an overall
software architecture, see [TEE2, Figure 2-1].

TEE also defines device life cycle, security problem definitions, objectives
and requirements and attackers profiles (security levels) 1 to 4. [TEE2]

An example of available hardware technologies which implement TEE can be seen
in [TEE3].

An example of available software which implement TEE can be seen in chapter
[Software](#software).

Some TEE implementations vulnerabilities can be found at [TEE4].

[TEE1] Introduction to Trusted Execution Environment: ARMs TrustZone  
https://blog.quarkslab.com/introduction-to-trusted-execution-environment-arms-trustzone.html

[TEE2] TEE Protection Profile Version 1.2  
https://www.commoncriteriaportal.org/files/ppfiles/anssi-profil_PP-2014_01.pdf

[TEE3] Trusted execution environment: Hardware support  
https://en.wikipedia.org/wiki/Trusted_execution_environment#Hardware_support

[TEE4] Introduction to Trusted Execution Environment and ARMs
TrustZone  
https://sergioprado.blog/introduction-to-trusted-execution-environment-tee-arm-trustzone/#nothing-is-100-secure

### ARM Security Models

The ARM Cortex-A architecture features a security extension called **TrustZone
hardware architecture**. "ARM Processor uses ARM TrustZone technology to
implement the TEE environment". [EL4]

ARM TrustZone achieves system security by dividing all of the devices hardware
and software resources, so that they exist in either the secure world for the
security subsystem, or the normal world for everything else. System hardware
ensures that no secure world resources can be accessed from the normal world.
[EL1] [EL5]

To transition between the secure world and the normal world the *secure monitor
(mode)* is used. [EL1] [EL5]

The ARMv8-A architecture introduced 64 bit instruction set and a new exception
model.

In ARMv8-A, execution occurs at one of four exception levels:

- EL0: Normal user applications (lowest level).
- EL1: Operating system kernel typically described as privileged.
- EL2: Hypervisor.
- EL3: Low-level firmware, including the Secure Monitor (highest level).

**Note:** The U-Boot SPL and TFA on e.g. VHIP4 run in EL3 until U-Boot is
started in EL2 (and therefore cannot access whatever is protected by the secure
MMU tables in EL3 only). The same is true for Linux, which also runs in EL2.
Linux in virtualization would run in EL1.

The following diagram illustrates how the exception levels and secure/nonsecure
mode in the ARMv8-A fit together: [EL2]

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

[EL2] ARM Cortex-A Series Programmer's Guide for ARMv8-A:
Fundamentals of ARMv8  
https://developer.arm.com/documentation/den0024/a/Fundamentals-of-ARMv8

[EL3] Ngabonziza, Bernard et. al. TrustZone Explained: Architectural
Features and Use Cases. 10.1109/CIC.2016.065.  
https://dl.acm.org/doi/abs/10.1007/978-3-030-68851-6_14

[EL4] Demystifying ARM TrustZone TEE Client API using OP-TEE  
https://dl.acm.org/doi/10.1145/3426020.3426113

[EL5] Trusted Execution Environments and Arm TrustZone  
https://azeria-labs.com/trusted-execution-environments-tee-and-trustzone/

### ARM Trusted Firmware (ATF)

"Originally known as Arm Trusted Firmware (ATF), an ARM open source project
since October 2013, [...], TF-A has been migrated to an open governance model
and it's now fully part of the Trusted Firmware [project]." [ATF1]

[ATF1] Trusted Firmware-A  
https://developer.arm.com/Tools%20and%20Software/Trusted%20Firmware-A

### (ARM) Trusted Firmware Design

"Trusted Firmware-A (TF-A) implements a subset of the Trusted Board Boot
Requirements (TBBR) Platform Design Document (PDD) for Arm reference platforms.
The TBB sequence starts when the platform is powered on and runs up to the
stage where it hands-off control to firmware running in the normal world in
DRAM. This is the **cold boot path**." [ATD1]

For AArch64, it is divided into five steps (in order of execution) [ATD1]
[ATD3]

                 Stage           | Level |            Desciption
    ---------------------------------------------------------------------
    Boot Loader stage 1   (BL1)  | EL3   | Trusted ROM (BootROM)
    Boot Loader stage 2   (BL2)  | EL1S  | Trusted Boot Firmware
    Boot Loader stage 3-1 (BL31) | EL3   | EL3 Runtime Firmware
    Boot Loader stage 3-2 (BL32) | EL1S  | Secure-EL1 Payload (optional)
    Boot Loader stage 3-3 (BL33) | EL2   | Non-trusted Firmware

The cold boot begins execution from the platform's reset vector at EL3.
Afterwards, the BootROM (BL1) runs from on-chip ROM with data in trusted
SRAM. After performing platform setup, BL1 proceeds with the boot process.
[ATD1]

BL1 loads and passes control to BL2 at EL1-Secure. BL2 initializes platform
using architecture specific code. After that, BL2 loads the BL31 image (the EL3
Runtime Software image), and the optional BL32 image, into trusted SRAM and the
BL33 image into non-secure memory as defined by the platform. Finally, BL2
drops it's exception level (i.e. switches to a less priviliged exception level)
to EL2, calls the BL31 entrypoint and, once secure state initialization is
complete, the BL33 entry point. [ATD1]

BL31 initializes more architecture, platform and runtime specific code and
services. If a BL32 image is detected a Secure-EL1 Payload Dispatcher (SPD)
service is needed to initialize the image. [ATD1]

This can be showcased in the following diagram [ATD4]

         Normal (Non-Secure) World |                      Secure World
    ----------------------------------------------------------------------------------------------
                                   |
    EL0     Rich Applications      |                                 Trusted Applications     EL0S
                    |              |                                          |
                    |              |                                          |
                    |4             |                                       optional:
    EL1   Non trusted EL1-Payload  | Trusted Boot Firmware         Secure EL1-Payload (BL32)  EL1S
             e.g. Linux kernel     |   2|     (BL2)                  e.g. OP-TEE Trusted OS
                    |              |    |       |                             |
                    |              |    |       |                             |
                    |3             |    |       |                             |
    EL2    Non-trusted Firmware    |    |       ---------------------         |
         (BL33) e.g. U-boot, UEFI--|----+---------------------------|----------
    -------------------------------|    |                           |
                                        |                           |1
    EL3                   EL3 Runtime Software (BL31)        Trusted ROM (BL1)
                          Secure Monitor, SMCs, PSCI

This can also be illustrated within a time sequence. [ATD5] The shown time
sequence should be considered as an example.

    EL3 |  |BL1| |BL2| | BL31
    ----|-----------------------------------
    EL2 |              | BL33 | | Hypervisor
    ----|-----------------------------------
    EL1 |                          | Linux
    ----|-----------------------------------
    EL0 |                             | App
        |             ->time
        | Reset Vector

**Note:** On IMX8M (and a lot of other systems), bare metal Linux runs in EL2.

BL1, BL2 and BL31 are part of the TF-A project. BL32 can be either taken from
the TF-A project or it can be an external project (for example OP-TEE OS). BL33
is the first non-secure code loaded by TF-A and may be a traditional bootloader
like U-Boot. [ATD2] [ATD4]

For a more in detail explanation of the ARM bootflow see [ATD5].

[ATD1] Firmware Design  
https://trustedfirmware-a.readthedocs.io/en/v2.8/design/firmware-design.html

[ATD2] TF-A overview  
https://wiki.st.com/stm32mpu/wiki/TF-A_overview

[ATD3] ARM Trusted Firmware (ATF)  
https://ohwr.org/project/soc-course/wikis/ARM-Trusted-Firmware-(ATF)

[ATD4] Trusted Execution Environments: A Technical Overview of Intel
SGX, Arm TrustZone, and RISC-V PMP - Stephano Cetola, The Linux
Foundation  
https://ossalsjp20.sched.com/event/fy4E/trusted-execution-environments-a-technical-overview-of-intel-sgx-arm-trustzone-and-risc-v-pmp-stephano-cetola-the-linux-foundation  
https://www.youtube.com/watch?v=MREwcSo0uz4

[ATD5] How ARM Systems are Booted: An Introduction to the ARM Boot
Flow - Rouven Czerwinski, Pengutronix  
https://osseu2022.sched.com/event/15z7R/how-arm-systems-are-booted-an-introduction-to-the-arm-boot-flow-rouven-czerwinski-pengutronix-ek  
https://www.youtube.com/watch?v=GXFw8SV-51g

[ATD6] Firmware Design - Cold boot  
https://trustedfirmware-a.readthedocs.io/en/v2.8/design/firmware-design.html#cold-boot

### High Assurance Boot (HAB)

*High Assurance Boot* (HAB) is a feature of the i.MX SoC family which provides
hardware assisted authentication, decryption and key management. HAB also
supports keys stored in secure one-time programmable (OTP) hardware storage.

HAB uses public key cryptography to authenticate the next stage payload, for
example a Devicetree file, image, data, etc., at boot time. Image data is
signed offline by the image provider using private keys and the i.MX processor
verifies the signature using the corresponding public keys stored in the secure
OTP hardware storage. [HAB2]

These public key(s), which are stored in the one-time programmable (OTP)
hardware storage and form the root of trust, are called *Super Root Keys*
(SRKs). [HAB1] [HAB2] More information can be found at [HAB3].

Another related technology from NXP is called *Advanced High Assurance Boot*
(AHAB).

[HAB1] i.MX High Assurance Boot (HAB) / Secure Boot  
https://variwiki.com/index.php?title=High_Assurance_Boot

[HAB2] High Assurance Boot (HAB)  
https://blog.quarkslab.com/vulnerabilities-in-high-assurance-boot-of-nxp-imx-microprocessors.html#high-assurance-boot-hab

[HAB3] i.MX 6 Linux High Assurance Boot (HAB) User's Guide  
https://community.nxp.com/pwmxy87654/attachments/pwmxy87654/imx-processors/60046/1/i.MX_6_Linux_High_Assurance_Boot_(HAB)_User's_Guide.pdf

## Software

### Trusted Firmware (TF)

Trusted Firmware project provides a reference implementation of secure software
for processors implementing both the A-Profile for ARM {Cortex-A,Neoverse}
architecture (TF-A) and M-Profile for ARM Cortex-M architecture (TF-M). [TF1]

The Trusted Firmware project provides SoC developers and OEMs with a reference
trusted code base complying with the relevant ARM specifications, allowing
quick and easy porting to modern chips and platforms. [TF1]

TF-A includes an Exception Level 3 (EL3) Secure Monitor and is implementing the
following ARM interface standards: [TF4]

- Power State Coordination Interface (PSCI)
- Trusted Board Boot Requirements CLIENT (TBBR-CLIENT)
- Secure Monitor Call (SMC) Calling Convention
- System Control and Management Interface (SCMI)
- Software Delegated Exception Interface (SDEI)

It interfaces with the two worlds as follows [TF3]

    Linux Application      Seure Application
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

TF-A is loaded after the BootROM and stays resident after the control has
passed to the OS. [TF3]

[TF1] Trusted Firmware - About  
https://www.trustedfirmware.org/about/

[TF2] Trusted Firmware: Building Secure Firmware Collaboratively -
Shebu Varghese Kuriakose & Matteo Carlini, ARM  
https://osseu2020.sched.com/event/eCJE  
https://www.youtube.com/watch?v=LxLYq8xyexY

[TF3] Bootlin Embedded Linux training - Slides - Trusted Firmware  
https://bootlin.com/doc/training/embedded-linux/embedded-linux-slides.pdf

[TF4] ARM-software/arm-trusted-firmware  
https://github.com/ARM-software/arm-trusted-firmware

### OP-TEE

OP-TEE is an open source TEE that is designed to use the ARM TrustZone
technology in collaboration to a non-secure Linux kernel. It is implemented
according to TEE Internal Core API v1.3.1. [OP1] [OP4]

OP-TEE consists of three components, OP-TEE Client, OP-TEE Linux driver [OP2],
and OP-TEE Trusted OS. It also ensures platform integrity with TrustZone secure
boot.

The TEE exposes its features through a tandem operation between a Client
Application and a Trusted Application. The client application runs in the Rich
OS and always initiates the communication with the Trusted Application that
runs in the Trusted OS. The Client application interacts with the TEE through
the TEE client API interface. The Secure Application interacts with the TEE
Core through the TEE Internal API. [OP4]

The OP-TEE project is part of the Trusted Firmware project. [OP3]

[OP1] About OP-TEE  
https://optee.readthedocs.io/en/latest/general/about.html

[OP2] TEE subsystem  
https://docs.kernel.org/staging/tee.html

[OP3] OP-TEE moving into Trusted Firmware  
https://www.trustedfirmware.org/blog/op-tee-moving-into-trusted-firmware/

[OP4] Open Portable Trusted Execution Environment (OP-TEE)  
http://trac.gateworks.com/wiki/venice/secure_boot#OpenPortableTrustedExecutionEnvironmentOP-TEE

### Hardware TEE vs TPM vs Secure Enclave vs Secure Element

A hardware trusted execution environment (TEE) is a secure area of a main
processor which guarantees confidentiality (no one has access to the data) and
integrity (no one can change the code and its behaviour) of code and data
loaded inside. A TEE as an **isolated** execution environment. It provides
security features such as isolated execution, integrity of applications
executing with the TEE, along with confidentiality of their assets. [TTS1]
[TTS4]

Trusted Platform Module (TPM) is an international standard for a secure
cryptoprocessor - a special microcontroller designed to secure hardware by
containing, for example, a true random number generator, secure memory for
storing secrets, cryptographic operations and tamper resistance. It is often
used in combination with measured boot. This microcontroller interfaces with a
standard hardware/software platform to be secured to serve the interests of the
system designer alone. TPM can also refer to a chip conforming to the standard.
[TTS1] [TTS2] [TTS6]

A secure enclave is potentially a hardware assisted TEE. Meaning it differs
from a TEE in that a TEE can be implemented either in both software and
hardware. [TTS3] [TTS5]

A secure element is a tamper-resistant hardware platform, capable of securely
hosting applications and storing confidential and cryptographic data. It
provides a highly-secure environment that protects user credentials. Secure
elements are unique in terms of interface. Examples of a secure elements are
smart-cards, SIM-cards or Hardware Security Module (HSM). [TTS1] [TTS2] [TTS4]

[TTS1] What Is the Difference Between HSM, TPM, Secure Enclave, and
Secure Element or Hardware Root of Trust  
https://www.wolfssl.com/difference-hsm-tpm-secure-enclave-secure-element-hardware-root-trust/

[TTS2] Introduction to TPM (Trusted Platform Module)  
https://sergioprado.blog/introduction-to-tpm-trusted-platform-module/

[TTS3] Secure enclaves  
https://www.thoughtworks.com/en-de/radar/techniques/secure-enclaves

[TTS4] Introduction to Embedded Linux Security - Sergio Prado,
Embedded Labworks  
https://ossna2020.sched.com/event/c3XR/introduction-to-embedded-linux-security-sergio-prado-embedded-labworks  
https://www.youtube.com/watch?v=McuP1_mvE_g

[TTS5] Security enclaves, TEE and other creatures  
https://deeprnd.medium.com/security-enclaves-tee-and-other-creatures-c9a7a6d85fb8

[TTS6] Hardware Solutions To Highly-Adversarial Environments Part 2:
HSM vs TPM vs Secure Enclave  
https://www.cryptologie.net/article/500/hardware-solutions-to-highly-adversarial-environments-part-2-hsm-vs-tpm-vs-secure-enclave/

## References

[SB1] SecureBoot  
https://wiki.debian.org/SecureBoot

[SB2] Secure Boot from A to Z - Quentin Schulz & Mylène Josserand,
Bootlin  
https://bootlin.com/pub/conferences/2018/elc/josserand-schulz-secure-boot/josserand-schulz-secure-boot.pdf  
https://www.youtube.com/watch?app=desktop&v=jtLQ8SzfrDU

[SB3] From Reset Vector to Kernel - Navigating the ARM Matryoshka -
Ahmad Fatoum, Pengutronix  
https://archive.fosdem.org/2021/schedule/event/from_reset_vector_to_kernel/attachments/slides/4632/export/events/attachments/from_reset_vector_to_kernel/slides/4632/from_reset_vector_to_kernel.pdf  
https://www.youtube.com/watch?v=-Ak9MWGxd7M

[SB4] IFM Ecomatic Workshop - Marek Vašut

[SB5] Trusted Board Boot Requirements CLIENT (TBBR-CLIENT) Armv8-A  
https://developer.arm.com/documentation/den0006/d/

[SB6] Secure boot in embedded Linux systems - Thomas Perrot  
https://bootlin.com/pub/conferences/2021/lee/perrot-secure-boot/perrot-secure-boot.pdf  
https://www.youtube.com/watch?v=fBDNqvNLxMk

[SB7] An Introduction to Dm-verity in Embedded Device Security  
https://www.starlab.io/blog/dm-verity-in-embedded-device-security

[SB8] Trusted Board Boot - Chain of Trust  
https://trustedfirmware-a.readthedocs.io/en/latest/design/trusted-board-boot.html#chain-of-trust
