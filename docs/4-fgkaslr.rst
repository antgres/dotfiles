ASLR and KASLR
==============

``Address Space Layout Randomization`` (ASLR) is a security feature in
Linux that helps protect against memory based attacks by randomizing the
address space of a process.

This makes it more difficult for an attacker to predict where sensitive
information is located and thus makes it significantly more difficult
for an attacker to exploit vulnerabilities in a system.

``Kernel Address Space Layout Randomization`` (KASLR) is an extension of
ASLR that randomizes the location of the kernel code in memory.

This makes it more difficult for an attacker to exploit kernel
vulnerabilities, as they would have to first determine the location of
the kernel code in memory before attempting to exploit it.

::

   main.c
   .. code::

     #include <stdio.h>

     // GCC Function Attributes
     // The '__noinline__' attribute prevents the compiler from
     // substituting the function call with the actual code of
     // the function for the purpose of optimization.
     #define noinline __attribute__((__noinline__))

     static noinline int func_b(void){;}
     static noinline int func_a(void){;}

     int main(){
         printf("func_a is at process virtual");
         printf("address: %p\n", func_a);
         printf("func_b is at process virtual");
         printf("address: %p\n", func_b);
         printf("main   is at process virtual");
         printf("address: %p\n", main);
     }

    $ gcc main.c

    #
    # different results for each run
    #
    # But notice is that the entire text section is mapped to
    # a different "starting" virtual address offset. But
    # functions' offsets within the text section are preserved.

    $ ./a.out
    func_a is at process virtual address: 0x55ca49786150
    func_b is at process virtual address: 0x55ca49786145
    func_c is at process virtual address: 0x55ca49786139
    main   is at process virtual address: 0x55ca4978615b

    #
    # With disabled ASLR, addresses remain the same
    #

    $ setarch $(uname -m) -R  ./a.out
    func_a is at process virtual address: 0x555555555150
    func_b is at process virtual address: 0x555555555145
    func_c is at process virtual address: 0x555555555139
    main   is at process virtual address: 0x55555555515b

Function granular KASLR
=======================

general flow with fgkaslr patches

::

   arch/x86/boot/compressed/head_{32,64}.S
   .. code::
      ...
      call extract_kernel





   arch/x86/boot/compressed/misc.c
   .. code::


      asmlinkage __visible void *extract_kernel(void *rmode, memptr heap,
                 unsigned char *input_data,
                 unsigned long input_len,
                 unsigned char *output,
                 unsigned long output_len)
      {
          ...
      parse_elf(output);
      ...
      }


      void parse_elf(void *output){

      ...

      if (IS_ENABLED(CONFIG_FG_KASLR) && !nokaslr)
          layout_randomized_image(output, &ehdr, phdrs);
      else
      layout_image(output, &ehdr, phdrs);

      ...

      }

References
==========

[1] Edge, Jake. Randomizing the kernel. URL:
https://lwn.net/Articles/546686/
