MMU
===

The Memory Management Unit (MMU) is a hardware component in a computer
system that is responsible for managing the mapping between virtual
memory addresses and physical memory addresses.

Virtual Memory
--------------

Virtual memory is a memory management technique that allows a system to
use more memory than is physically available in the main memory (RAM).
This is done by using a technique called paging, where the system's
memory is divided into fixed-size blocks called pages, and each process
is given a virtual address space that is divided into pages. The MMU is
responsible for mapping the virtual pages to physical pages in main
memory.

Page Tables
-----------

The MMU uses a data structure called a page table to store the mapping
between virtual pages and physical pages for every process. This data
structure lives in memory and exists for every process.

The page table is in its simplest form a list of page table entries
(PTE), a so-called linear page table. Every PTE contains the memory
address of its corresponding page address in the physical memory. In
addition to this, each PTE stores additional meta-information about the
page, such as e.g. access permission, valid bit, dirty bit, etc.

In a more complex system, the page table is organized as a hierarchical
tree, with the top level (called the page directory) containing pointers
to the second level page table, which contains pointers to the third
level page table, and so on. This is called multi-level page tables.

This has the advantage that the overall size of the page directory and
page table is reduced in size because each level contains a smaller
number of entries. This advantage is getting traded against a more
complex (to search through) data structure.

.. note::

   Add chapter about?

   **Address Space**

Example
-------

Let's consider a system with a 16 byte page size and an 8-bit virtual
address space with a linear page table. The virtual address 0x34 is to
be translated to a physical address.

::

   Virtual Address (0x34):
   ---------------------------------
   | 0 | 0 | 1 | 1 | 0 | 1 | 0 | 0 | 
   ---------------------------------
   Page Number      Page Offset
   ------------+++++++++++++++++++++
     0x1 |       0x14 Byte from 16 |
         |                         |
         -------    ----------------
   Page Table: |    |
   ----------------------------------
   |  PTE0  |  PTE1  | ... |  PTE3  |
   ----------------------------------

   PTE1:
     - Physical Address: 0x2000
     - Access: Can only be accessed by process with id 1
     - Is allowed to be swapped to disk.

1. The virtual address is divided into two parts:

   -  The highest 3 bits (0x34 => 0x1) represent the page number of a
      page entry in the page table.
   -  The lowest 5 bits (0x34 => 0x14) represent the page offset in a
      page entry.

2. The page number is used as an index into the page table to find the
   corresponding PTE.
3. The physical address is obtained by adding the page offset to the
   physical page address stored in the PTE.

   -  For example, if the PTE for page number 0x1 contains the physical
      page address 0x2000, the physical address of the virtual address
      0x34 would be 0x2000 + 0x14 = 0x2014.

4. The MMU then uses this physical address to access the memory location
   in physical memory.

Why do we virtual addresses (in with that a MMU)?
=================================================

Shared Memory
-------------

Virtual memory allows multiple processes to share the same physical
memory by giving each process its own virtual address space. This
reduces the size of to be loaded data and code, which is commonly used
by many processes, such as libraries.

Without the MMU, each process would have to access physical memory
directly and have their own copy of common instruction and data, which
would make it difficult to share memory between processes and would also
make it difficult for the operating system to manage memory efficiently.

Security
--------

The MMU prevents processes from accessing memory that they are not
authorized to access via the permissions bits set in a page table entry.
It checks these permissions before allowing a memory access to occur.

This feature helps to prevent other processes from accessing the memory
via the e.g. exploitation of vulnerabilities in a process.

An example of this would be the exploitation of a buffer overflow in a
weakly protected program to access the memory area of the e.g. kernel.
Through a permission bit, the page is safe from unauthorized access at
the lowest level.

This allows an isolation between processes, ensuring that one process's
memory cannot be accessed or modified by another process, which helps in
maintaining the integrity of the system.

TLB
===

The Translation Lookaside Buffer (TLB) is a cache located in the MMU and
that is used by the MMU to speed up virtual memory lookups. [5] The TLB
stores a small number of recently used page table entries, so that the
MMU can find the physical address of a virtual page without having to
walk the entire page table (or page table directory) in a process. The
TLB is typically small and has a limited number of entries, so it is not
uncommon for a page table entry to not be in the TLB (a so called TLB
miss). If a page table entry is in the TLB, it is a so called TLB hit.

There are different strategies to efficiently save the TLB entries
between context switches. The simplest one is to clear the complete TLB
at each context switch. Other strategies are described in [4].

The linux kernel has two ways to unmap or modify page entrys in the TLB
which are described in [3]

-  flush the entire TLB fast but at the cost of refilling neccesary
   pages later on.
-  invalidate a single page one at a time.

Which method is used depends on some conditions described in [3].
However, because of the uncertainty of the given conditions, flushing
the whole TLB is used for more cases. [3]

ITLB and DTLB
-------------

In modern systems, the TLB is split in Instruction Translation Lookaside
Buffer (ITLB) and Data Translation Lookaside Buffer (DTLB). The ITLB is
used to store the most recently accessed instruction address and the
DTLB for the most recently accessed data. If the CPU access an
instruction or data, it first checks the corresponding TLB. [6]

.. note::

   This means that with each instruction the ITLB is checked.

ITLB and DTLB are separated because instructions and data have different
access patterns. Instructions are typically read sequentially, with the
next instruction being located at a memory address that is close to the
current instruction. On the other hand, data access patterns can be more
random, with data being accessed from various locations and random size
in memory. [6]

Additionally, instructions are more important to performance than data
references because ”data references can generally be overlapped by
independent streams of instructions because of out-of-order
capabilities, instruction references are often on the critical path of
pipeline execution. Therefore, [ITLB] misses can have a particularly
pernicious impact on performance.” [6]

TLB optimization
----------------

One way to speed up a process can be to improve the TLB
hit-rate/performance. TLB performance can benefit from adhering to the
``principle of locality`` which is a heuristic which includes the idea
of spatial locality (if all elements are near each other than only one
page needs to be loaded, resulting in multiple TLB hits after an initial
TLB miss) and temporal locality (if a recently called instruction will
be re-called soon in the future). [6]

Other ways to improve the TLB performance could be through the use of
huge pages [1] or application algorithm layout improvements [2].

Documentation
=============

-  Remzi H. Arpaci-Dusseau and Andrea C. Arpaci-Dusseau. Operating
   Systems: Three Easy Pieces. Arpaci-Dusseau Books. 2018.
-  Tanenbaum, Andrew S. Modern Operating Systems, 4th Edition. Pearson
   Prentice Hall. 2015

References
==========

[1] Runtime Performance Optimization Blueprint: Intel Architecture
Optimization with large code pages
https://www.intel.com/content/dam/develop/external/us/en/documents/runtimeperformanceoptimizationblueprint-largecodepages-q1update.pdf

[2] Bakhvalov, Denis. Performance analysis and tuning modern CPUs.
Source Code Tuning For CPU.
https://faculty.cs.niu.edu/~winans/notes/patmc.pdf#BackrefHyperFootnoteCounter.152

[3] Linux Kernel. TLB. https://docs.kernel.org/x86/tlb.html

[4] Intel 64 and IA-32 Architectures Software Developers Manual Volume
3A: System Programming Guide, Part 1. Chapter 4.10.4 Invalidation of
TLBs and Paging-Structure Caches.

[5] Bakhvalov, Denis. Performance analysis and tuning modern CPUs. Cache
miss. https://faculty.cs.niu.edu/~winans/notes/patmc.pdf#subsection.4.7

[6] Bhattacharjee, Abhishek. Computer Architecture: A quantitative
approach. Appendix L: Ad-vanced Concepts on Address Translation. Morgan
Kaufmann Publishers, 2018. URL: https:
//www.cs.yale.edu/homes/abhishek/abhishek-appendix-l.pdf.
