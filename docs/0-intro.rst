Introduction
============

The world today is a complex one. This is due to the state of our
society. Emerging from the industrial age, we have been living in an
information age since the middle of the 20th century. [1] [2]

Unlike the industrial age, the focus of the information age is not on
machines that extend the human physique, for example through the
invention of the railway or the car, allowing us to travel longer
distances faster, but on the extension of our brains, allowing us to
solve difficult and tedious tasks in a fraction of the time through the
help of computer systems. [1] [2]

In this context, information on how something can be done is of great
importance. [2]

However, "what characterizes the current technological [age] is not the
centrality of knowledge and information, but the application of such
knowledge and information to knowledge generation and information
processing/communication devices, in a cumulative feedback loop between
innovation and the uses of innovation." [3]

In the sense of this feedback loop are also the topics we are dealing
with in this generation: Machine Learning, Artificial Intelligence, Big
Data, Autonomous driving, Industry 4.0, Virtual Reality, Digital Twins,
etc.

In order to implement these technologies, all these topics require a
huge amount of real-time number crunching. In addition, these
applications should not only have to do their job, but should also be
cryptographically accessible via the internet, synchronize with other
systems, etc. Furthermore, the software behind them must also meet these
requirements in the shortest time-to-market possible to remain
competitive. [6] [7]

That's why the Linux kernel has become a necessary building block from
the software's point of view: it publicly provides these desired
functionalities to everyone to satisfy the increasing demands. [6]

From the point of view of the hardware, however, we are reaching a
limit: Over the years, transistor size and clock frequency have evolved
logarithmically, driven by Moore's Law. This has roughly improved the
average performance of a computer every year. [4]

However, In the current state it has reached a limit: the transistor
size has become so small that the chip becomes too hot when the clock
frequency is increased further. As a result, Dennard Scaling, which was
the main driver behind the annual performance boost, loses momentum. [4]
[5]

In order to compensate for this circumstance, this disadvantage must now
be offset by clever ideas that are implemented on the software side in
order to secure the innovations of tomorrow. This thesis attempts to do
its part.

This thesis focuses on the analysis of heuristic code collocation in the
Linux kernel with the aim to reduce ITLB pressure. For this purpose,
several possible methods are discussed and compared with each other.

Objective
=========

The objective of this thesis is to analyze if reducing the Instruction
translation lookaside buffer (ITLB) pressure through code collocation in
the kernel improves the performance of the system as a whole.

To achieve this, this thesis will be reorganizing the code within the
textit{text} section itself, rather than reorganizing the textit{text}
sections relative to each other.

By reordering the code in such a way that hot-paths are located closer
together, and thus increasing the ITLB hit-rate, this methodology can
improve the performance of the system by reducing the number of page
faults.

However, it should be avoid relying on developers to manually mark code
which should be organised together, as this approach is unlikely to
scale and may result in incorrect guesses. Instead, this thesis will be
exploring different ways to automatically reorganize the code in the
textit{text} section to minimize ITLB pressure.

The conceptual sections of this thesis will present different approaches
and their respective advantages and disadvantages before finalizing on
the best solution.

References
==========

[1] M. Haupt. Society 4.0: The evolutionary journey to humanity’s next
transition. URL:
https://medium.com/society4/evolution-of-societies-93a5f0f9b31. (visited
on 20/01/2023).

[2] Dietel, Harvey M., Deitel, Barbara. An Introduction to Information
Processing. Amsterdam, Boston: Academic Press, 2014.

[3] M. Castells. The rise of the network society: Second edition, with a
new preface. Wiley-Blackwell, 2012.

[4] E. Berger. ‘Performance Matters’. Strange Loop Conference. 2019.
URL: https://www.youtube.com/watch?v=r-TLSBdHe1A (visited on 23/01/2023)

[5] Dennard’s law.
https://semiengineering.com/knowledge_centers/standards-laws/laws/dennards-law/

[6] Simmonds, Chris. Mastering embedded linux programming: Unleash the
full potential of em-bedded linux. 2nd ed. Packt, 2017

[7] Reedy, Scott. Improving the time to release products: Speeding Time
to market (TTM). URL:
https://www.arenasolutions.com/resources/articles/time- to- market/
