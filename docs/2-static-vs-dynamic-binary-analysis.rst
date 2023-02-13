Static binary analysis
======================

Static analysis of binary code (machine code) is the process of
analysing a program without executing it. Additionally, this is usually
done without the source code that is written in a programming language.

This can be done by examining the machine code of the program, as well
as the data and metadata associated with it.

The advantage is that no hardware is needed because machine code is
independent of a specific processor or of other hardware units.
Additionally, the results of a static analyser are consistent: in
comparison to an execution of the program on real hardware no external
conditions such as temperature of the measuring room, noise
interference, etc. can influence the analysed result.

The downside is that it is, depending on the program, a complex and
time-consuming task, especially for large and complex programs.
Furthermore, disassemblers can produce different assembly instructions
for the same binary code, depending on the settings and options used.

One application of static binary analysis can be in the field of Link
Time Optimization (LTO) which "is a form of interprocedural optimization
that is performed at the time of linking application code." [6] [7]

Because reading machine code is very cumbersome, the machine code is
converted to assembly instructions in the first step.

Disassembly
-----------

Disassembly is the process of converting the machine code of a program
into its equivalent assembly instructions, performed by a tool called a
disassembler.

Disassembly can be performed in two main ways:

-  Linear Disassembly

   Linear disassembly is the process of disassembling a program in a
   linear, sequential fashion. The disassembler starts at the entry
   point of the program and proceeds to disassemble each instruction in
   sequence until the end of the program is reached.

   This method is simple and easy to implement, but it can miss code
   that is not reachable from the entry point, such as code in a library
   or code that is executed only in certain conditions.

   One such linear disassembler is ``objdump``.

-  Recursive Disassembly

   Recursive disassembly is a more complex method that is used to
   disassemble a program more thoroughly. The disassembler starts at the
   entry point of the program, and then recursively follows all branches
   and jumps in the program to disassemble all reachable code.

   This method is more thorough than linear disassembly, as it can
   disassemble code that is not reachable from the entry point, such as
   code in a library or code that is executed only in certain
   conditions. It is more time-consuming though.

It should be noted that, unlike the source code, disassembling a binary
program is not a straightforward task. A problem in theoretical
informatics which describes why it is so difficult are known as the
``Halting Problem`` and ``Rice's Theorem.``

Halting Problem and Rice's Theorem
----------------------------------

The problem of determining whether a given program will halt when
executed is known as the ``Halting Problem`` and it is proven to be
unsolvable by Alan Turing in 1936.

This means that it can not be predicted beforehand if a program, for all
possible inputs and outputs, finishes its execution.

Another important concept is ``Rice's Theorem``. It states that for any
non-trivial property of a program, it is undecidable whether a given
program has the property or not.

This means that for any non-trivial property, that can't be decided by
examining the program's input and output, there will always be an
program for which it is impossible to determine whether that property
applies or not.

An example could be the property of a program being able to determine
whether a given randomly selected program will output a prime number or
not. Given an arbitrary program, it is not possible to determine whether
the program will output a prime number or not.

The halting problem and Rice's theorem point to the fact that
disassembly (which is a program) is an undecidable problem and that any
non-trivial property of a program is undecidable.

This means that it is impossible to determine with certainty whether a
program will halt when executed or whether a given program has a
specific property using an algorithm.

As a result, the output of a disassembler is not necessarily a
deterministic result, but subject to statistical laws.

This is because disassemblers uses heuristics and approximation to infer
the behaviour of a program from its machine code. These heuristics may
not always work as intended, especially for more complex and optimized
programs.

It follows that the disassembler may produce false positives and false
negatives, meaning that the disassembler may identify certain features
or properties of a program that do not actually exist or misinterpret
certain machine code as wrong assembly instructions, depending on the
settings and options used.

Furthermore, some programs may use obfuscation or code packing
techniques that make disassembly more difficult. In these cases,
disassembly may need to be performed manually.

Dynamic analysis
================

Dynamic analysis is the process of analysing an application (program)
while it is executing. This type of analysis is typically performed by
executing the application with a set of inputs and monitoring its
behaviour. The goal of dynamic analysis is to identify runtime errors,
performance issues, and other issues that could impact the security and
stability of the application.

These tools typically use a variety of techniques, including logging,
tracing, and instrumentation, to monitor the behaviour of the
application. For mor information see [5].

Dynamic analysis can identify issues that are not easily found by static
analysis, such as runtime errors and performance issues. It also can
test the application in its operational environment, simulating
realistic scenarios, detecting issues that are caused by the
interactions between different functionalities and modules and stress
testing the system.

However, dynamic analysis can be more time-consuming, resource-intensive
and more difficult to automate than static analysis. Additionally, it
can be less accurate because, depending on the test or workload, not all
possible paths of an application are tested.

One aspect that must be taken into account is the danger of measurement
bias. Measurement bias is the tendency for measurements to be inaccurate
due to errors or inaccuracies in the measuring process. Depending on the
experimental setup the results of the experiment can lead to incorrect
conclusions. [8]

Workloads
=========

A workload is a set of inputs and interactions that are used to test the
application during dynamic analysis. The workloads are designed to
stress the application and simulate realistic scenarios. The goal is to
exercise the different functionalities and paths of the application and
identify issues that would not be found by testing only a subset of the
inputs.

When choosing a workload (for a dynamic analysis), it is important to
consider the nature of the workload, the hardware the application is
running on, and the actual workload of the application. The workload
should accurately reflect the actual workload of the application, and it
should be chosen with consideration for the hardware the application is
running on.

That is why choosing the right workload though is not an easy task. Some
factors can be:

- Coverage: The workloads should cover all the functionalities and paths
of the application. This will help to identify issues that would not be
found by testing only a subset of the inputs.

- Realism: The workloads should simulate realistic scenarios that
reflect the usage of the application in production. This will help to
identify issues that would not be found by testing only unrealistic
scenarios.

- Stress: The workloads should stress the application by simulating high
loads, long-running operations and edge cases. This will help to
identify issues that would not be found by testing only normal loads and
scenarios.

Documentation
=============

[1] Bakhvalov, Denis. Performance analysis and tuning modern CPUs.
Static vs. Dynamic Analyzers.
https://faculty.cs.niu.edu/~winans/notes/patmc.pdf#subsubsection.5.6.1

[2] Andriesse, Dennis. Practical Binary Analysis. No Starch Press, Inc.
2019.

[3] Rival, Xavier; Yi, Kwangkeun. Introduction to static analysis: an
abstract interpretation perspective. The MIT Press. 2020.

[4] Feitelson, Dror. Workload Modeling for Computer Systems Performance
Evaluation. Cambridge University Press. 2015.

References
==========

[5] Bakhvalov, Denis. Performance analysis and tuning modern CPUs.
Performance Analysis Approaches.
https://faculty.cs.niu.edu/~winans/notes/patmc.pdf#section.5

[6] ARM Link Time Optimization
https://developer.arm.com/documentation/101458/2100/Optimize/Link-Time-Optimization--LTO-/What-is-Link-Time-Optimization--LTO-

Papers
======

[7] L. Van Put, D. Chanet, B. De Bus, B. De Sutter and K. De Bosschere,
"DIABLO: a reliable, retargetable and extensible link-time rewriting
framework," Proceedings of the Fifth IEEE International Symposium on
Signal Processing and Information Technology, 2005., Athens, Greece,
2005, pp. 7-12, doi: 10.1109/ISSPIT.2005.1577061.

[8] Todd Mytkowicz, Amer Diwan, Matthias Hauswirth, and Peter F.
Sweeney. 2009. Producing wrong data without doing anything obviously
wrong! SIGPLAN Not. 44, 3 (March 2009), 265–276.
https://doi.org/10.1145/1508284.1508275
