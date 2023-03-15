# Advanced computer architectures

## Pipelining

See ACSO notes on the same topics.

## Exception handling

We use the term _exception_ to **cover not only exceptions but also interrupts
and faults**. We will considers these types of events:

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
2. It **saves the PC into** a special register called **Exception program
   counter** (EPC). (Note: we do not use the stack as seen in the previous ACSO
   course);
3. It **disables interrupts and transfers control** to a designated handler
   running in kernel mode
4. It reads the status register
5. Uses a **special indirect jump (RFE) to restore the PC and**:
   - **Re-enables interrupts**
   - Restore the processor to **user mode**
   - Restores **hardware status and control state**

This is the **precise interrupt model**.

In case of a **synchronous** interrupt, since it is caused by a particular
instruction state, the **instruction restarted after the exception has been
handled**.

### Exception handling in the pipeline

An **asynchronous** interrupt can happen in any stage of the pipeline.
**Synchronous interrupts happen in different points of the instruction. Due to
pipelining, exceptions can be overlapping or out of order**.

A solution can be to **hold the exception flags and pass it through the
pipeline, but do not handle the exception until it reaches the commit point (and
of MEM)**. We also need to **hold the PC and pass it through the pipeline**.
This way **all exceptions are postponed to be managed in order at the last
stage**. **Writes** in data memory and the writebacks in the register file **are
disabled to guarantee the precise interrupt model**. For a given instruction,
**exceptions in earlier pipeline stages override exceptions raised in later
stages**.

Recapping:

- Hold the exception flag and pass it through the pipeline – Hold the PC and
  pass it through the pipeline (to be saved and restored after the Exception
  Handler Routine) – Wait until the end of MEM stage to raise the exception
- When instruction reaches Commit Point before entering WB stage: – Save PC into
  the EPC and store the Interrupt Handler intro the PC – Turn all next
  instructions in earlier stages into NOPs – Handle interrupts through “faulting
  nop” in IF stage
- After the end of the Exception Handler Routine, the instruction will be
  re-executed

**Injection of asynchronous interrupts** can be also done into the **commit
stage**.

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

1. **Temporal locality**: When there is a reference to one memory element the
   trend is to refer to the same memory element soon
2. **Spatial locality**: when there is a reference to one memory element, the
   trend is to refer soon at other memory elements whose addresses are nearby

### Basics

See same topics of the **ACSO** notes.

## Performance evaluation

We can divide metrics in two types:

1. Execution time, often called latency/response time
2. Number of jobs per unit of time (Performance), called throughput/bandwidth

Often latency and throughput are in direct opposition.

In this course we will focus mainly on the execution time for a single job. This
means that instruction throughput will be our most important metric.

Definitions:

1. $X$ is $n\%$ faster than $Y$:
   $\frac{\mathrm{execution time}_y}{\mathrm{execution time}_y}$ or
   $1 + \frac{n}{100}$.

   An analogous definition exists if we use other metrics.

2. $\mathrm{performance}_x = \frac{1}{\mathrm{execution time}_x}$.

A performance improvement means an increment, while latency improvement means a
decrement.

The execution time of program, also called CPU time, is:

$$
\begin{aligned}
  \mathit{CPU time} &= \#_{cycles}\cdot T_{clk} = \frac{\#_{cycles}}{f_{clk}}
    &= \mathit{IC}\cdot\mathit{CPI}\cdot T_{clk}
\end{aligned}
$$

Where CPI is the clock per instruction. Its inverse, IPC, is instruction per
clock. We can write the number of cycles as $\sum_n (\mathit{CPI}_i I_i)$ where
$I_i$ is the number of instructions of type $i$. This means that the CPU time
can be rewritten as:

$$\mathit{CPU time} = \sum_n (\mathit{CPI}_i I_i) T_{clk}$$

Rewriting the above equations we can extract the instruction frequency
$F_i = \frac{I_i}{IC}$. We can calculate the total $CPI$ as the sum of all the
$CPI_i$ weighted by the instruction frequencies.

MIPS is just IPC where we put the instruction count to $10^6$.

### Amdahl's law

We can express the speedup due to an enhancement as the fraction between the
execution time/performance without and with the enhancement.

Suppose that an enhancement $E$ accelerates a fraction $F$ of the task by a
factor $S$ and the remainder of the task is unaffected then:

$$
\begin{aligned}
  \mathit{Execution time}_E = (\frac(1-F) + \frac{F}{S})\mathit{Execution time}_\bar{E}
  \mathit{Speedup}_E = \frac{1}{(1-F) + \frac{F}{S}}
\end{aligned}
$$

The basic idea is to make the common case fast. The law imposes that the
improvement to be gained from using some faster execution modes is limited by
the fraction of the time the faster mode can be used.

During the development of our design, we can define different levels of
evaluation:

1. Actual target workload
   - Pros: representative
   - Cons: very specific, non-portable, difficult to run and to use to identify
     bottlenecks
2. Full application benchmarks
   - Pros: portable, widely used and contain improvements useful in reality
   - Cons: less representative
3. Small "kernel" benchmarks
   - Pros: easy to run early in the design process
   - Cons: easy to fool
4. Micro-benchmarks
   - Pros: identifies peak capability and potential bottlenecks
   - Cons: not representative of real application performance

Like with levels of evaluation, each layer also has different metrics that are
useful.

### Performance evaluation in pipelined processors

Pipelining improves a processors throughput, but does not reduce latency. On the
contrary, it slightly increases latency of each instruction due to the imbalance
among pipeline stages and the overhead in the pipeline control:

- Imbalance among stages means that latency of each instruction is no less than
  that of the slowest instruction
- Pipeline overhead arises from register delay and clock skew
- All instructions must use all stages

The number of cycles can be computes as such:

$$ \#_{cycles} = IC + \#_{stall} + 4 $$

Let us consider $n$ iterations of a loop composed of $m$ instructions per
iterations requiring $k$ stalls. We can compute the asymptotic CPI as:

$$
\lim_{n\to\infty} \frac{mn + kn +4}{mn} = \frac{m+k}{m}
$$

The ideal CPI in a pipelined processor would be 1, but stalls cause the
pipeline's performance to degrade.

If we make the following assumptions:

1. Ignore the cycle time overhead due to the pipeline
2. Assume perfectly balanced stages
3. Assume that all instructions take the same number of cycles (equal to the
   number of stages)
4. There are no pipeline stalls

We can equate the pipeline's speedup to the depth of the pipeline

### Performance evaluation of the memory hierarchy

Recalling all previous definitions about caches (hit/miss time and rate), we can
define the average memory access time as

$$ \mathit{AMAT} = H*\mathrm{time} + M*\mathrm{rate} \* M\_\mathrm{penalty} $$

If we have separate cache for instructions and data (Harvard architecture), we
need to weigh the $\mathit{AMAT}$ of the two caches. Each level of cache also
has different access times.

Let us specify the two different miss rates:

- Local: misses in this cache divided by the total number of memory accesses to
  this cache
- Global: misses in this cache divided by the total number of memory accesses
  generated by the CPU

We will be more interested in the second one as it indicates how many accesses
reach main memory.

The CPU time is impacted by accesses:

$$
\mathit{CPU}_\mathrm{time} = \mathit{IC}\cdot
  (\mathit{CPI} + \mathit{MAPI}\cdot M_\mathrm{rate}\cdot M_\mathrm{penalty})\cdot
  T_\mathrm{clk}
$$

If we also consider stalls, we need to add to the above time the number of
stalls per instruction.

