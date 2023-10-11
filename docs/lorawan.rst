LoraWan
=======

LoRaWAN is a Media Access Control (MAC) layer protocol created by the LoRa
Alliance Group built on top of LoRa modulation intended for Things to operate
in a network. It targets requirements such as secure bi-directional
communication, mobility and localization services. [1] [5]

This standard tries to provide seamless interoperability among smart Things
without the need of complex local installations. [5] A typical LoraWan
network can be seen below or in [2].

::

   +++++++      +++++++++   +++++++++   +++++++++++++  +++++++++++++
   + End +      +       +   +       +   +Application+  +Applikation+
   + Node+=====>+       +   +       +===+   Server  +==+  Frontend +
   +++++++      +       +   +       +   +   -HTTP-  +  +++++++++++++
                +Gateway+===+Network+   +++++++++++++
   +++++++      +   X   +   +Server +   +++++++++++++
   + End +=====>+       +   +       +===+Appl. Serv.+
   + Node+      +       +   +       +   +   -MQTT-  +
   +++++++      +++++++++   +++++++++   +++++++++++++
  
   |<-------------->|<-------------------------------------------->|
     Lora Wireless            IP Network based on WAN/WIFI   


If one wants to use a network the thing can be part of a public or private
LoraWan network. A public LoraWan network is provided by
*The Things Network* (TTN) and a private network can be build with eg. the
open source LoraWan Network Server Stack *Chirpstack*. [7, Appendix B] [10]

The advantages of Lora can be found at [1] and the limitations at [4].

End devices
===========

End devices are sensors or actuators send LoRa modulated wireless messages to
the gateways or receive messages wirelessly back from the gateways. This is
done via a single LoraWan RF transceiver module (transmitter + receiver,
like the SX1262) for bi-directional communication. [2]

The LoRaWAN specification defines three device types: Class A, Class B, and
Class C. All LoRaWAN devices must implement Class A, whereas Class B and
Class C are extensions to the specification of Class A devices. All device
classes support bi-directional communication.

More information about the difference of the classes can be found at
https://www.thethingsnetwork.org/docs/lorawan/classes/.

Gateways
========

A gateway receives LoRa messages from end devices and simply forwards them to
the LoRaWAN network server. They can be categorized into indoor and outdoor
gateways with different advantages. [2] In general, gateways act in a similar
manner to what routers and bridges do: they connect different networks together. 

Gateways implement LoRaWAN concentrator which is a complex device that
includes multiple RF transceiver modules (typically eight or more, like a
SX1302), a more powerful MCU or FPGA (field-programmable gate array), and
additional hardware such as memory, Ethernet connectivity, and power
management.

The multiple RF transceiver modules allow the concentrator to listen for and
receive data from multiple LoRaWAN nodes simultaneously, and the more
powerful MCU or FPGA enables the concentrator to process and aggregate data
from multiple nodes before forwarding it to the central server or gateway.

Technically it is possible to build a gateway out of a LoraWan transceiver
instead of a LoraWan concentrator. However, TTN has declared them in 2019
for obsolete and not supported for the public TTN v3. [6] [8] [9]

Network Server
==============

The Network Server manages gateways, end-devices, applications, and users in
the entire LoRaWAN network. [2]

LoraWan is secure by design and implements an AES 128 encryption on multiple
layer. Therefore, end devices and gateways need to be registered
(establishing a LoraWan session) via dynamic Over the air activation (OTAA)
or hardcoded Activation by personalization (ABP). [3]

Application Server
==================

The Application Server processes application-specific data messages received
from end devices through the network (more specific the network server). It
also generates all the application-layer downlink payloads and sends them to
the connected end devices through the Network Server. A LoRaWAN network
can have more than one Application Server. [2]

References
==========

[1] https://www.thethingsnetwork.org/docs/lorawan/what-is-lorawan/
[2] https://www.thethingsnetwork.org/docs/lorawan/architecture/
[3] https://www.thethingsnetwork.org/docs/lorawan/end-device-activation/
[4] https://www.thethingsnetwork.org/docs/lorawan/limitations/
[5] Soroush Allahparast. Development of an open-source gateway and network
server for "Internet of Things" communications based on LoRaWAN technology.
2017-18. http://vlsi.diet.uniroma1.it/downloads/Thesis_Allahparast.pdf
[6] Brent Rubell. Single Channel LoRaWAN Gateway for Raspberry Pi. 2022.
https://cdn-learn.adafruit.com/downloads/pdf/raspberry-pi-single-channel-lorawan-gateway.pdf
[7] Fredrik Lund. Study of LoRaWAN device and gateway setups with ChirpStack
implementation. ISY, Linköping University. 2022.
https://liu.diva-portal.org/smash/get/diva2:1679773/FULLTEXT01.pdf
[8] Single Channel Packet Forwarders (SCPF) are obsolete and not
supported. 2019.
https://www.thethingsnetwork.org/forum/t/single-channel-packet-forwarders-scpf-are-obsolete-and-not-supported/31117
[9] mikrocontroller.net. TTN V3 das Ende einer guten Idee? 2021.
https://www.mikrocontroller.net/topic/528327
[10] https://www.chirpstack.io/
