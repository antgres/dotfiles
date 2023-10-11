Intel Performance Monitoring Unit (PMU) Events
==============================================

The Intel PMU is a hardware component in Intel processors that can be
used to measure various performance metrics, such as cache misses,
branch mispredictions, CPU usage, etc. These metrics are referred to as
"events" and can be used to analyse the performance of a program or
system.

Which and how many events are available depends on the processor model.
[2] [3] [4]

Each event is identified by a unique event code, which is encoded in the
format "eventsel:umask". The ``eventsel`` field specifies the event
type, and the ``umask`` field specifies additional information about the
event.

.. note::

   "Modern CPUs have hundreds of countable performance events. It’s very
   hard to remember all of them and their meanings. Understanding when
   to use a particular PMC is even harder. That is why generally, we
   don’t recommend manually collecting specific PMCs unless you really
   know what you are doing." [11:5.3.2 Manual performance counters
   collection]

.. note::

   The PMU abstraction events use under the hood specific PMU events
   which has a specific event code.

   For example the PMU abstraction event ``branches`` uses under the
   hood the PMU event ``BR_INST_RETIRED.ALL_BRANCHES`` which has the
   event code ``C4:00``.

   ``ocperf`` [16] is a wrapper around ``perf`` which can do this
   mapping. [11:5.3.2 Manual performance counters collection]

Perf: Performance Analysis Tool
===============================

Perf is a performance analysis tool that is used to measure and analyse
the performance of Linux systems.

Perf uses PMU events to measure various performance metrics by
configuring the PMU events, starting the counters, and then reading the
counters after a period of time. This allows to get a detailed
performance report of the system without knowing the underlying
infrastructure and event codes.

However, if desired, more specific PMU events and their event code can
be used.

The ``perf list`` command lists all the PMU events that are available on
the system [5]

::

   $ perf list
   # Print a longer and more detail description
   $ perf list -v 
   # Print how named events are resolved internally into perf events,
   # and also any extra expressions computed by perf stat.
   $ perf list --details 

.. note::

   More detailed descriptions and their event counter can be found in
   the official intel documentation [3] [4]

To measure a specific PMU event, one can use the ``perf stat`` command
followed by the event name [6]. For example, to measure CPU cycles, one
would use the command:

::

   # Events can optionally have a modifier by appending a colon and
   # one or more modifiers. Modifiers allow the user to restrict the
   # events to be counted [5]
   $ perf stat -e cycles:k -- sleep 5
   # -a --all-cpus: system wide collection from all CPUs
   $ perf stat -e cycles:u -a -- sleep 5

ocperf
======

One can use ``ocperf`` from the ``pmu-tools`` repo [16] to easily check if
an event is supported on a processor. The *ocperf* downloads the latest
PMU event for a given Intel Core generation from the official Intel repo
[3].

::

   # check if PMU loaded and which events (here: Skylake events)
   $ sudo dmesg | grep PMU
   [    0.157217] Performance Events: PEBS fmt3+, Skylake events,
   32-deep LBR, full-width counters, Intel PMU driver.

   # load the tools repo
   git clone https://github.com/andikleen/pmu-tools
   cd pmu-tools
   # optional: sudo ln -sf $PWD/ocperf /usr/bin/ocperf

   # use ocperf
   $ ocperf stat -e ITLB_MISSES.MISS_CAUSES_A_WALK -a -- sleep 2
   Downloading https://raw.githubusercontent.com/intel/perfmon/main/mapfile.csv to mapfile.csv
   Downloading https://raw.githubusercontent.com/intel/perfmon/main/SKL/events/skylake_core.json to GenuineIntel-6-4E-core.json

   ...

   perf stat -e cpu/event=0x85,umask=0x1,name=itlb_misses_miss_causes_a_walk/ -a -- sleep 2

   Performance counter stats for 'system wide':

          84,855      itlb_misses_miss_causes_a_walk

          2.002689352 seconds time elapsed

Perf Callgraph Generation
=========================

Perf provides the ability to generate callgraphs, which are visual
representations of the call stack of a process at a given point in time.

Perf provides the ``perf record`` command to record data into the
default output file ``perf.data``, which can be used to generate
callgraphs. [8] The ``-g`` option (``--call-graph``) is used to enable
callgraph generation for both user and kernel space.

The ``-g`` option can be further modified. [9] [14:13.9.3 Stack Walking]

::

   $ perf record -e cycles:k -a --call-graph dwarf -- sleep 5 
   # Collect callchains only from kernel space.
   $ perf record -e cycles --kernel-callchain -g dwarf -- sleep 5
   # sample at 99 Hertz (samples per second). I'll sometimes
   # sample faster than this (up to 999 Hertz), but that also costs
   # overhead. 99 Hertz should be negligible. Also, the value '99'
   # and not '100' is to avoid lockstep sampling, which can produce
   # skewed results. [14]
   $ perf record -F 99 -a -g -- sleep 5

.. note::

   "Historically, frame pointer (RBP) was used for debugging since it
   allows us to get the call stack without popping all the arguments
   from the stack (stack unwinding). The frame pointer can tell the
   return address immediately. However, it consumes one register just
   for this purpose, so it was expensive. It is also used for profiling
   since it enables cheap stack unwinding." [11:5.4.3 Collecting Call
   Stacks]

.. note::

   Some intel processors have a hardware-based unwinding method called
   Last Branch Record (LBR) instead of a more generic software-based
   approach like DWARF. LBR unwinds the call stack more accurate and
   efficient. [8] [11]

   One can check if LBR is available with:

   ::

      $ sudo dmesg | grep -i lbr
      [ 0.228886] Performance Events: PEBS fmt3+, Skylake events,
      32-deep LBR, full-width counters, Intel PMU driver.

   "LBR stacks can also be collected using
   ``perf record --call-graph lbr`` command, but the amount of
   information collected is less than using ``perf record -b``. For
   example, branch misprediction and cycles data is not collected when
   running ``perf record --call-graph lbr``." [12]

   "Because each collected sample captures the entire LBR stack (32 last
   branch records), the size of collected data (perf.data) is
   significantly bigger than sampling without LBRs." [12]

From this information one can generate a visual represantion of the
callgraph along with the ``gprof2dot`` project [10] and the ``graphviz``
package.

::

   perf record -a --kernel-callchains -g dwarf -- sleep 5 && \
   perf report --header --stdio  && \
   perf script | ./gprof2dot.py -n0 -e0 --format=perf > temp && \
   dot -Tsvg temp -o callgraph.svg

ITLB PMU events
===============

.. note::

   Some kinda generic text

::

   - ITLB_MISSES.MISS_CAUSES_A_WALK

   Counts page walks of any page size (4K/2M/4M/1G) caused by a code fetch.
   This implies it missed in the ITLB and further levels of TLB (STLB), but
   the walk need not have completed.

   .. note::

     "Additionally, there is a unified Second-level (L2) Unified
     TLB (STLB) which is shared across both Data and Instructions." [1] [13]

     "When the CPU does not find an entry in the ITLB, it has to do a
     page walk and populate the entry. A miss in the L1 (first level)
     ITLBs results in a very small penalty that can usually be hidden by
     the Out of Order (OOO) execution. A miss in the STLB results in the
     page walker being invoked." [13]

   - ITLB_MISSES.WALK_COMPLETED

   Counts completed page walks (all page sizes) caused by a code fetch.
   This implies it missed in the ITLB (Instruction TLB) and further levels
   of TLB. The page walk can end with or without a fault.

   - ITLB_MISSES.WALK_ACTIVE

   Cycles when at least one PMH (Page Miss Handler) is busy with a page
   walk for code (instruction fetch) request.

.. note::

   Not all of the here presented PMU events are available on all
   processors. Check the docs which PMU events are available. [3]

.. note::

   The definition of the PMU abstraction events ``iTLB-loads`` and
   ``iTLB-load-misses`` can be found in the linux kernel source code
   ``arch/x86/events/intel/core.c``:

   ::

      [ C(ITLB) ] = {
      [ C(OP_READ) ] = {
          # iTLB-loads
          [ C(RESULT_ACCESS) ] = 0x2085,    /* ITLB_MISSES.STLB_HIT */
          # iTLB-load-misses
          [ C(RESULT_MISS)   ] = 0xe85,    /* ITLB_MISSES.WALK_COMPLETED */
      },

.. note::

   "``iTLB-load-misses`` and ``L1-icache-load-misses`` are not related.
   iTLB miss means that a page walk is needed to find the physical
   address matching the virtual one. An icache miss though is about
   whether the actual data is hot in the cache or a memory fetch for it
   is needed." -Darwi

ITLB Metrics
============

A PMU events a ITLB pressure metric can be calculated.

Brendan Gregg defines the following metrics in his ``tlbstat`` [15] [14]
application:

::

   - ITLB_WALKS: Instruction TLB walks
       ``(ITLB_MISSES.MISS_CAUSES_A_WALK)``

   - K_ITLBCYC: Cycles at least one PMH is active with instr. TLB walks x 1000
       ``(ITLB_MISSES.WALK_ACTIVE / 1000)``

   - ITLB%: Instruction TLB active cycles as a ratio of total cycles
       ``((100 * ITLB_MISSES.WALK_ACTIVE) / CYCLES)``

Other Metrics can be found in Intels
``Runtime Performance Optimization \n Blueprint: Intel Architecture Optimization with large code pages``
[13]:

::

   - ITLB Stall Metric: Represents the fraction of cycles the
     CPU was stalled due to instruction TLB misses.   
       ``(100 * (ICACHE_64B.IFTAG_STALL / CPU_CLK_UNHALTED.THREAD))``

   .. note::

     "Measuring ITLB miss stall is critical to determine if your workload on
     a runtime has an ITLB performance issue." [13]

   - ITLB Misses Per Kilo Instructions (MPKI): Normalization of the ITLB misses
     against number of instructions (allows comparison between different
     systems)
       ``(1000 * (ITLB_MISSES.WALK_COMPLETED / INST_RETIRED.ANY))``

References
==========

[1] Intel 64 and IA-32 Architectures Software Developers ManualVolume
3A: System Programming Guide, Part 1. Figure 11.2

[2] Intel Performance Monitoring Units event references
https://perfmon-events.intel.com/ [3]

[3] Intel perfmon events https://github.com/intel/perfmon

[4] Intel® 64 and IA-32 Architectures Developer's Manual: Vol. 3B.
Chapter 19: Performance-Monitoring Events. [3]

[5] Man page: perf-list
https://man7.org/linux/man-pages/man1/perf-list.1.html

[6] Man page: perf-stat
https://man7.org/linux/man-pages/man1/perf-stat.1.html

[7] Perf hardware events
https://perf.wiki.kernel.org/index.php/Tutorial#Hardware_events

[8] Man page: perf-record
https://man7.org/linux/man-pages/man1/perf-record.1.html

[9] https://www.brendangregg.com/perf.html#StackTraces

[10] jrfonseca/gprof2dot https://github.com/jrfonseca/gprof2dot

[11] Bakhvalov, Denis. Performance analysis and tuning modern CPUs. 2020

[12] Performance analysis and tuning modern CPUs. Last Branch Records.
https://faculty.cs.niu.edu/~winans/notes/patmc.pdf#subsection.6.2

[13] Runtime Performance Optimization Blueprint: Intel Architecture
Optimization with large code pages.
https://www.intel.com/content/dam/develop/external/us/en/documents/runtimeperformanceoptimizationblueprint-largecodepages-q1update.pdf

[14] Gregg, Brendon. Systems Performance: Enterprise and the Cloud, 2nd
Edition. Addison-Wesley. 2020.

[15] brendangregg/pmc-cloud-tools. tlbstat.
https://github.com/brendangregg/pmc-cloud-tools/blob/master/tlbstat

[16] ocperf https://github.com/andikleen/pmu-tools/blob/master/ocperf.py
