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
   $\frac{\mathit{ExecutionTime}_y}{\mathit{ExecutionTime}_y}$ or
   $1 + \frac{n}{100}$.

   An analogous definition exists if we use other metrics.

2. $\mathit{Performance}_x = \frac{1}{\mathit{ExecutionTime}_x}$.

A performance improvement means an increment, while latency improvement means a
decrement.

The execution time of program, also called CPU time, is:

$$
\begin{aligned}
  \mathit{CPU}_{time} &= \#_{cycles}\cdot T_{clk} = \frac{\#_{cycles}}{f_{clk}}
    &= \mathit{IC}\cdot\mathit{CPI}\cdot T_{clk}
\end{aligned}
$$

Where CPI is the clock per instruction. Its inverse, IPC, is instruction per
clock. We can write the number of cycles as $\sum_n (\mathit{CPI}_i I_i)$ where
$I_i$ is the number of instructions of type $i$. This means that the CPU time
can be rewritten as:

$$\mathit{CPU}_{time} = \sum_n (\mathit{CPI}_i I_i) T_{clk}$$

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
  \mathit{ExecutionTime}_E &= ((1-F) + \frac{F}{S})\cdot\mathit{ExecutionTime}_{\bar{E}} \\
  \mathit{Speedup}_E &= \frac{1}{(1-F) + \frac{F}{S}}
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

$$
  \#_{cycles} = IC + \#_{stall} + 4
$$

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

$$
  \mathit{AMAT} = H_\mathrm{time} + M_\mathrm{rate} \cdot M_{\mathrm{penalty}}
$$

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

## Control hazards

In pipelining control hazards are one of the biggest performance penalties. We
can apply some optimizations to make them less probable.

A **branch is taken if the branch condition is satisfied, otherwise the branch
is not taken**. The branch target address is the address where to branch.

The **outcome of the comparison is computed in the EX phase, together with the
computation of the branch target address**. The result is then used in the
memory access phase to update the program counter.

The main problem with conditional instructions is that **we need to wait for the
EX step to fetch the correct instruction based on the conditional outcome**:
this causes a one-cycle stall in our pipeline. To fix this problem we have
several solution:

1. **Stalling until resolutions**
2. **Assume the branch as not taken**

### Branch optimization using stalling

We **would need to insert 3 stalls** until IF of the next instruction comes
after MEM. Then we can use MEM-IF propagation to fetch the correct instruction.

We can **anticipate the resolution of the branch outcome to the EX stage**,
before writing and use propagation to **reduce to only 2 stalls** per branch.

We can do **even better by moving the branch determination into the ID stage**.
Using our conservative method, we can **then insert only 1 stall and use ID-IF
propagation to fetch the correct instruction**.

The number of stall cycles introduced due to branch conflicts is:

$$
  \#_{cycles} = \mathit{Branch}_{freq} \cdot \mathit{Branch}_{Penalty}
$$

This is the slowest option and results to 10%-30% performance loss.

### Branch prediction techniques

There are **two main types of branch prediction**:

1. **Static** branch prediction techniques: done at **compile time**
2. **Dynamic** branch prediction techniques: done at **execution time**

#### Static prediction techniques

Static branch prediction is typically **used when the branch behaviour for the
target application is highly predictable at compile time**. **It can be used in
combination with dynamic predictors**.

We have the following schemes:

1. **Branch always not taken**: the easiest method, **every branch is predicted
   as not taken by the compiler**. In case we **mispredict**, we need to
   **flush** one instruction: we have a **one-cycle penalty**.

   This type of prediction is **best suited to if-then-else** constructs where
   we have information about the probability of each branch.

2. **Branch always taken**: the **dual to the previous case**. Like before, we
   have a **one-cycle penalty** if we mispredict.
3. **Backward taken forward not taken (BTFNT)**: we can make **predictions based
   on the direction of the jump**:
   - **Backward branches are taken** since they are most likely **loops**
   - **Forward branches are not taken** since we assume that the condition
     relative to the **else is less likely** and not taken.
4. **Profile**: we assume **some profiling done on the application**; the
   prediction is based on said profiling. The profile-driven prediction method
   can use **compiler hints** associated to each branch instruction.
5. **Delayed branch**: the **compiler statically schedules an independent
   instruction in the branch delay slot**. The **instruction(s) in the branch
   delay slot is always executed or needs to be flushed in case of
   misprediction, the instruction after the slot will depend on if the branch
   was taken or not**.

   There are four ways of filling the branch delay slot:

   1. **From before**: an independent instruction **from before the branch is
      scheduled in the slot**. Useful for if-then-else constructs.
   2. **From target**: an **independent instruction from the target of the jump
      is scheduled in the slot**. This strategy is preferred when is more
      probable that a branch is taken (e.g. in do-while loops).
   3. **From fall-through**: an **independent instruction from the fall-through
      path of the jump** is scheduled in the slot. This branch is preferred when
      there is a high likelihood of the branch not being taken (e.g an
      if-then-else with less probable else).
   4. **From after**: an independent instruction **from after the condition**.

   In **deeply pipelined processors, the slot might be more than one cycle long,
   so the compiler needs more instructions**. On average, the compiler manages
   to fill 50% of them. For this reasons, **if a processor uses a delay slot it
   is usually one cycle**.

   The **limitations** arise from the **ability of the compiler to predict the
   outcome and on choosing instructions to schedule**. To improve the filling
   ability of the compiler, **most processors using this predictions implemented
   a hint direction in the instruction: if the branch behaves as predicted, the
   instruction in the slot is executed, otherwise it is flushed**.

#### Dynamic branch prediction

We **use the past behaviour to predict the outcome of a branch**. The prediction
will **depend on the runtime behaviour of the branch**. Dynamic branch
prediction is based on **two interacting hardware blocks placed in the IF
stage** used to predict the next instruction to read in the instruction cache:

1. **Branch outcome predictor** (buffer): to predict the **direction** of a
   branch
2. **Branch target predictor** (buffer): to predict the **branch target
   address** in case of taken branch

If the branch is predicted by the BOP as not taken, the PC is incremented and
execution proceeds. If we predict correctly, performance is preserved. If we
mispredict, we need to flush the instruction already fetched and restart the
execution by fetching the target address.

If the branch is predicted as taken, the BTB gives the predicted target address.
If we predict correctly, we preserve performance. Otherwise we need to flush the
branch target instruction already fetched and restart the execution by fetching
the next instruction.

We have **3 different techniques for implementing the BOP**. We are going to see
them one by one.

##### Branch history table

It is a **table that has 1 bit for each entry that says whether the branch was
recently taken or not**. The table is **indexed by the lower k-bits of the
address of the branch** (exploiting locality, we do not expect changes in the
higher bits of the address).

The prediction is a **hint that is assumed to be correct: since we do not have
tags, we are not sure if a colliding branch overwrote our prediction**.

The 1-bit suffers in loops: it will mispredict twice, once when the loop exists
and once when the loop is reentered again. We can mitigate this problem by
extending the entry to 2-bit: we require that a branch is taken/untaken two
times to be changed.

We can **extend it to an n-bit counter**: if the **counter is grater than or
equal to half the maximum it is predicted as taken, otherwise as untaken**.
**The counter is incremented on branch taken and decrement on branch untaken**.

Usually 2-bit is enough.

##### Correlating branch predictors

The BHT uses only the recent behaviour of a single branch to predict the future
behaviour of that branch. Here **we try to exploit the fact that the behaviour
of recent branches is correlated and can influence the prediction of the current
branch**. Branch predictors that make use of the outcome of correlated branches
are called **correlating predictors or 2-level predictors**.

A **(1,1)-correlating-predictor indicates a predictor with 1-bit of correlation,
meaning that the behaviour of the last branch is used to choose among a pair of
1-bit branch predictors**. For implementing such a predictor we need 2 1-bit
BHTs:

1. One used if the last branch was taken
2. One used if the last branch was not taken.

Usually a **(m,n)-correlating-predictor chooses considers the $m$ last branches
and chooses from $2^m$ $n$-bit predictors**. If we use more than 1 branch for
prediction, the **buffer holding the last $m$ branch outcomes is called the
global branch history**. The **BHT can be indexed by using a concatenation of
the branch-index and the $m$-bit global history**.

The **number of bits** necessary for this predictor is:

$$
  2^m \cdot n \cdot \text{Number of prediction entries selected by the branch address}
$$

A simple 2-bit BHT is a (0,2)-correlating-predictor. Comparing the performance
of the BHT and a (2,2)-predictor having the same total number of bits, the
second one outperforms the first even if it had an unlimited number of entries.

##### 2-level adaptive branch predictors

**The first level history is recorded in one or more k-bit shift registers**
(Branch History Registers or BHRs). This structure records the outcomes of the
most $k$ recent branches.

**The second level history is recorded in one or more tables called Pattern
History Tables (PHTs) of two-bit saturating counters. The BHR is used to index
the BHT and select which counter to use**. The prediction is made using the same
method as the 2-bit counter scheme.

With this scheme, **we lose the branch-address of the previous predictors** (GA
predictor). To **re-correlate the BHR with the PC, we can XOR the lower k-bit of
the PC with the BHT before indexing** (GShare predictor).

##### Implementing the BTB

The Branch Target Buffer is an **associative cache storing the predicted target
addresses**. We can **access** the values stored within it **in the IF stage by
using the address of the fetched branch instruction**.

We can **combine the BTB and the branch outcome predictor** (prediction bit
output of the predictor).
