# Advanced computer architectures

## Pipelining

See ACSO notes on the same topics.

## Exception handling

We use the term _exception_ to **cover not only exceptions but also interrupts and
faults**. We will considers these types of events:

1. IO device request
2. Invoking syscalls
3. Tracing instrument execution
4. Arithmetic overflow/underflow
5. FP arithmetic anomaly
6. Page faults
7. Misaligned memory acess
8. Memory protection violations
9. Hardware/power filures

An _interrupt_ is an event that requests the attention of the processor. We can
have:

- **Asynchrounous**: external events
- **Synchronous**: internal events

When the processor interrupts the user process:

1. It **stops** the current program at instruction $I_i$, **completing all
   instructions up to $I_{i-1}$**.
2. It **saves the PC into** a special register called **Exception program counter**
   (EPC). (Note: we do not use the stack as seen in the previous ACSO course);
3. It **disables interrupts and transfers control** to a designated handler running
   in kernel mode
4. It reads the status register
5. Uses a **special indirect jump (RFE) to restore the PC and**:
   - **Re-enables interrupts**
   - Restore the processor to **user mode**
   - Restores **hardware status and control state**

This is the **precise interrupt model**.

In case of a **synchronous** interrupt, since it is caused by a particular
instruction state, the **instruction restarted after the exception has been handled**.

### Exception handling in the pipeline

An **asynchronous** interrupt can happen in any stage of the pipeline. **Synchronous
interrupts happen in different points of the instruction. Due to pipelining,
exceptions can be overlapping or out of order**.

A solution can be to **hold the exception flags and pass it through the pipeline,
but do not handle the exception until it reaches the commit point (and of MEM)**.
We also need to **hold the PC and pass it through the pipeline**. This way **all
exceptions are postponed to be managed in order at the last stage**. **Writes** in
data memory and the writebacks in the register file **are disabled to guarantee
the precise interrupt model**. For a given instruction, **exceptions in earlier
pipeline stages override exceptions raised in later stages**.

Recapping:

- Hold the exception flag and pass it through the pipeline
– Hold the PC and pass it through the pipeline (to be saved and
  restored after the Exception Handler Routine)
– Wait until the end of MEM stage to raise the exception
- When instruction reaches Commit Point before entering WB stage:
  – Save PC into the EPC and store the Interrupt Handler intro the PC
  – Turn all next instructions in earlier stages into NOPs
  – Handle interrupts through “faulting nop” in IF stage
- After the end of the Exception Handler Routine, the instruction will be
  re-executed

**Injection of asynchronous interrupts** can be also done into the **commit stage**.

## Cache memory

The goal of cache is to increase performance by providing the illusion of a
large and fast memory and providing data to the processor at high frequency.

Architectures with hyperthreading can generate 2 instruction fetcher per core
per clock. This means that for a 3.2Ghz clock 4-core processor we need a peak
bandwidth of 409.6Gbit/s. DRAM bandwidth is only 6% of this. Aggregate peak
bandwidth also increases with the core count of processors. Solving this problem
requires:

1. Multi-port, pipelined caches;
2. Two levels of cache per core;
3. Shared third level cache for one chip.

Caches **exploit two locality principles**:

1. **Temporal locality**: When there is a reference to one memory element the trend
   is to refer to the same memory element soon
2. **Spatial locality**: when there is a reference to one memory element, the trend
   is to refer soon at other memory elements whose addresses are nearby

### Basics

See same topics of the **ACSO** notes.
