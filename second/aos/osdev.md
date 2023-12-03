# Operating system programming

We are going to focus more on microcontrollers, since they are enough to get the
point without the complexity of full CPUs.

## Booting an OS

Processes in a general-purpose OS run in a virtual address space, which requires
HW Support (MMU/TLB). Inside an OS we can access both physical memory and
virtual memory. Most microcontroller do not even have an MMU so the code needs
to work only with physical memory addresses (even for applications).

OS/application code is located in the nonvolatile Flash memory which is memory
mapped. Stack, heap and global variables are placed in RAM. An address range is
reserved for HW peripherals, but it is sparsely used and mostly unmapped. Parts
of the address space is unmapped, accessing these areas causes a fault interrupt
to be generated.

### Linker scripts

With virtual memory, we decide the addresses by convention. Thus we can use one
linker for all programs. With physical memory we must adapt to the memory
layout, meaning we need a different linker for each hardware platform we
support. Loadable application (if there are any) must be compiled as PIC.

When compiling an OS, we must tell the linker at which physical address to put
our code/data. For micro controllers we usually have:

1. Code (`.text` section): Flash memory
2. Data (`.text`/`.bss` section): RAM
3. Stack and heap are allocated at runtime

Linker scripts configure the linker (such as GNU's `ld`).

```ld
ENTRY(Reset_Handler) /* the first function called at boot */

/* The MEMORY section specifies the hardware memory layout */
MEMORY
{
  flash(rx) : ORIGIN = 0x08000000, LENGTH = 1M
  ram(wx)   : ORIGIN = 0x20000000, LENGTH = 128K
}

/* _stack_top is a variable that defines the start of address of the stack.
 *
 * Variables will be added to the program's symbol table and can be accessed by
 * them
 */
_stack_top = 0x20000000+128*1024;

/* SECTIONS tells the linker how to map the program sections into memory regions
 * `.` is as special variable called the "location counter"; it is incremented
 * after each section mapping by the section size.
 */
SECTIONS
{
  . = 0;

  /* Map the .isr_vector, .text and .rodata sections to the flash.
   * `*` is a wildcard and means any executable name
   */
  .text :
  {
    KEEP(*(.isr_vector)) /* All executables' `.isr_vector` is placed first,
                          * `KEEP` prevents any garbage collection from omitting
                          *  it
                          */
    *(.text)      /* Then we place the `.text` */
    . = ALIGN(4); /* Align on the byte boundary (ABI and platform dependant) */
    *(.rodata)    /* Last we place the `.rodata` */
  } > flash /* Put this section to flash */

   /* Output section for `.data` */
  .data :
  {
    _data = .; /* Declare a variable holding the start of the `.data` section */
    *(.data)   /* Place the section */
    . = ALIGN(8); /* Align it */
    _edata = .; /* Declare a variable holding the end of the section */
  } > ram AT > flash /* Then load this section in RAM, however, since at boot
                      * the memory might me uninitialized, place a copy of it
                      * into flash so that the OS can initialized it at runtime
                      */
  _etext = LOADADDR(.data); /* Save the end of `.text` in a variable (LOADADDR
                             * indicates the address to which the section is
                             * loaded). In conjunction with the other two
                             * previous variables, we can copy the `.data`
                             * section from flash to memory
                             */

  /* `.bss` is uninitialized data that should be zeroed out at runtime. We,
   * again, save the start/end of it so we can zero-it at runtime
   *
   * The reason why we do it outside the output section is to include an
   * "anonymous" (`.common`) section that also needs zero-ing. Summary: it has
   * been this way since the 70's and fortran, don't ask questions.
   */
  _bss_start = .;
  .bss :
  {
    *(.bss)
    . = ALIGN(8);
  } > ram
  _bss_end = .;

  _end = .; /* End of application code, we can start the heap at this address */
}
```

### Booting the damn thing

The place where the microcontroller/CPU start executing code is architecture
dependant:

- On PC, it starts from the BIOS/UEFI that loads a second level bootloader (such
  as GRUB) into memory
- Microcontrollers have memory-mapped nonvolatile memory (the flash), meaning we
  can directly boot the kernel without needing to load it in RAM.

There are two ways to identify the first instruction to run:

1. Set the Program Counter to a predefined address (e.g., `0x0`) and start from
   there
2. Read a predefined memory location containing the address of the first
   instruction, and use that value to initialize the Program Counter (approach
   used by e.g. ARM Cortex)

Assuming an ARM Cortex-based STM32F407 micro, the address of the first
instruction must be placed at `0x08000004` (flash memory base + `0x4`). Is it
enough to put there the address of the first C function of our kernel there? No,
we also need to ensure some of the guarantees about the execution environment
that high-level languages (such as C) need to function. This part will obviously
need to be written in assembly language.

The assumptions are:

1. For C:

   - The stack pointer register must point to the top of a suitable memory area
     - The compiler implicitly uses the stack to allocate local variables within
       functions
     - Until then, only assembler code can be executed
   - Global and static initialized variables must set to their initial value
     - Since they are placed in RAM, and after the power on the content of RAM
       is random, they must be explicitly initialized
   - Global and static uninitialized variables must be set to 0

   Example startup code (ARM):

   ```asm
     .syntax unified  // since ARM is a family of different instruction sets, we
     .cpu cortex-m4   // need to specify for what CPU we are writing for
     .thumb

     // Section containing a table of pointers:
     // - 0x08000000 = stack pointer init
     // - 0x08000004 = program counter init
     // Additional entries (not shown) are addresses of interrupt handlers
     .section .isr_vector
     .global __Vectors // global variable
   __Vectors:
     .word _stack_top  // defined in liker script
     .word Reset_Handler

     // Define the code of the first function executed by the kernel
     .section .text
     .global Reset_Handler          // Define it as a global function
     .type Reset_Handler, %function //
   Reset_Handler:
     /* Copy .data from FLASH to RAM */
     ldr r0, =_data  // \
     ldr r1, =_edata // | From the linker script
     ldr r2, =_etext // /
     cmp r0, r1
     beq nodata
   dataloop:
     ldr r3, [r2], #4
     str r3, [r0], #4
     cmp r1, r0
     bne dataloop
   nodata:
     // Zero-out the bss
     ldr r0, =_bss_start // | From the linker script
     ldr r1, =_bss_end   // |
     cmp r0, r1
     beq nobss
     movs r3, #0
   bssloop:
     str r3, [r0], #4
     cmp r1, r0
     bne bssloop
   nobss:
     /* Jump to kernel C entry point */
     bl
     kernel_entry_point
     .size
     Reset_Handler, .-Reset_Handler
   ```
