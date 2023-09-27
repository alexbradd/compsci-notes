# Advanced Algorithms and Parallel Programming

## Complexity analysis

See API notes about complexity analysis.

## Divide and conquer

A common paradigm. I goes in **three steps**:

1. **Divide the problem** (instance in jargon) into sub-problems
2. **Conquer the sub-problem by solving them recursively**
3. **Combine the sub-problem solutions**

A D&C algorithm can be **easily represented with a form to which we can apply
the master theorem formula**:

$$
T(n) = aT(p) + X
$$

Where:

- $a$ is the number of subproblems for each iteration
- $p$ the subproblem size relative to the input (e.g. $\frac{n}{2}$)
- $X$ the work done in dividing and combining (e.g. $\Theta(n)$)

For any other info, see **API notes** about it.

## Parallel machine model

The **RAM** (Random Access Machine) is a **simple model that models a single CPU
that executes instructions and has an infinite amount of RAM cells**. Each
instruction takes constant time. The time complexity is the number of
instruction executed, while the space complexity is the number of memory cells
used.

The **PRAM** (Parallel Random Access Machine) is **based on the RAM** and is a
model **applicable to parallel computers**. It is a system
$M'=\langle\{M_1,\ldots,M_i\},X,Y,A\rangle$ of **infinitely many**:

- **RAMs** $M_i$, each **called a processor** of $M'$. Each processor:
  - Is assumed to be **identical** and has the ability to recognize its own
    index
  - Doesn't have tape
  - Has **unbounded registers**
  - Can **access memory in unit time**
- **Input** cells $X(1), X(2), \ldots$
- **Output** cells $Y(1), Y(2), \ldots$
- **Shared memory** cells $A(1), A(2), \ldots$
  - All communication takes place through this shared memory

The computation happens in **5 steps**. Each processor:

1. **Reads** a value from one **input** cell
2. **Reads** one of the **shared memory** cells
3. Performs **computation**
4. **May write** into one of the **output** cells
5. **May write** into one of the **shared memory** cells

**Some subset of processors can remain idle**.

**Two or more processors may read simultaneously form the same shared cell**. A
**write conflict** occurs when **two or more processors try to write
simultaneously to the same shared cell**.

PRAMs are **classified based on their read/write** abilities. The basic
abilities are:

- **Exclusive Read** (`ER`): all processors can simultaneously read from
  distinct memory locations
- **Exclusive Writ** (`EW`): all processors can simultaneously write to distinct
  memory locations
- **Concurrent Read** (`CR`): all processors can simultaneously read from any
  memory location
- **Concurrent Write** (`CW`): all processors can simultaneously write to any
  memory location
  - What value gets written finally? We can have the following approaches:
    - **Priority** `CW`: processors are assigned a priority and the processors
      with the highest is allowed to complete the write
    - **Common** `CW`: all processors are allowed to complete the write iff all
      the values to be written are equal
    - **Arbitrary/random** `CW`: one randomly chose processors completes the
      write

The **main classifications** are **combinations** of the above atoms: `EREW`,
`CREW`, `CRCW`

The PRAM model is a very **useful** due to its qualities:

- It is **natural**: the number of operation executed at time $t$ on $p$
  processors is $p$
- It is **strong**: any processor can r/w any shared memory cell in unit time
- It is **simple**: it abstracts communication/synchronization overhead
- It can be used as a **benchmark**: if a problem is not feasible on PRAM, it is
  not feasible on real machines

##### Definition: computational power

A model $A$ is **computationally stronger** than model $B$, $A \geq B$ **iff**
an **algorithm written for $B$ will run unchanged in the same parallel time and
same basic properties** on $A$

We can create the following **hierarchy**:

$$
\mathtt{Priority}\geq\mathtt{Arbitrary}\geq\mathtt{Common}\geq\mathtt{CREW}\geq\mathtt{EREW}
$$

### Some formulas

- $T^*(n)$: time to solve a problem of input size $n$ using the best sequential
  algorithm
  - $T^* \neq T_1$
- $T_p(n)$: time to solve a problem on $p$ processors
- $\mathit{SU}_p(n) = \frac{T^*(n)}{T_p(n)}$: speedup
  - $\mathit{SU}_p \leq P$
  - $\mathit{SU}_p \leq \frac{T_1}{T_\infty}$
- $E_p(n) = \frac{T_1(n)}{pT_p(n)}$: efficiency (how many processors are idle)
  - If $T^*\approx T_1$ then
    $E_p\approx\frac{T^*}{pT_p} = \frac{\mathit{SU}_p}{p}$
  - $E_p \leq \frac{T_1}{pT_\infty}$, this means that there is no use making $P$
    larger than the maximum $\mathit{SU}$
- $T_\infty(n)$: shortest runtime on any $p$
  - $T_1 \geq T^* \geq T_p \geq T_\infty$
- $C(n)= P(n)T(n)$: cost
  - $T_1\in\mathcal{O}(C)$, $T_p\in\mathcal{O}(C/p)$
- $W(n)$: work, i.e. the total number of operations
  - $W \leq C$
  - If $p\approx\mathrm{Area}$ and $W\approx\mathrm{Energy}$, then
    $\frac{W}{T_p}\approx\mathrm{Power}$

In normal algorithms (some sequential and some parallel parts) **speedup has an
asymptotic upper bound** that it approaches with the increase in the number of
processors (calculated with **Amdahl's law**). The **efficiency**, however,
**tends to 0** with the increase in the number of processors.

Some variants of the PRAM machine are:

- Bounded number of shared memory cells
- Bounded number of processor small pram
- Bounded size of a machine word
- Handling access conflicts

##### Lemma

Assume $P' < P$. Any problem that can be solved for a $P$ processor PRAM in $T$
steps can be solved in a $P'$ processor PRAM in
$T' = \mathcal{O}(\frac{TP}{P'})$ steps.

##### Lemma

Assume $M'<M$. Any problem that can be solved for a $P$ processor and $M$-cell
PRAM in $T$ steps can be solved on a $\max\{P,M'\}$-processor $M'$-cell PRAM in
$\mathcal{O}(\frac{TM}{M'})$ steps.

Is the PRAM **implementable**? **Yes**, there are ways; it can also be **used as
an ideal model for theoretical algorithms** that then can be converted to real
machine models.

For implementations, concurrent r/w can be a bit challenging:

- Concurrent read can be implemented by detect-and-multicast
- Concurrent write is a bit more difficult, some methodologies are:
  - Common CRCW: detect-and-merge
  - Priority CRCW: detect-and-prioritize
  - Arbitrary CRCW: arbitrary resolution

### Amdahl’s law vs Gustafson’s law

Amdahl's law assumes that **computing happens in interleaved segments of two
types**:

1. **Serial** segments that cannot be parallelized
2. **Parallelizable** segments

This means that the **maximum speedup is bounded by the un-parallelizable
part**. Let us assume that the parallelizable part is a fixed fraction $f$ of
the program, we have that:

$$
\begin{aligned}
  \mathrm{SU}(P,f) &= \frac{T_1}{T_1(1-f) + \frac{T_1 f}{P}} = \frac{1}{(1-f)+\frac{f}{p}} \\
  \lim_{P\to\infty} \mathrm{SU}(P,f) = \frac{1}{1-f}
\end{aligned}
$$

Amdahl's law has been **often used as an argument against massively parallel
architectures**: given a problem with $f=0.9$ parallelizability, there is no
point in using more than 10 cores.

**Gustafson proposed that the assumptions of Amdahl's law were wrong**:

1. **Parallel portion $f$ is not fixed: it increases with the increase in data**
2. **Serial time is usually the same**

We thus have two **invariants**:

1. Fixed **serial time** $S$
2. Fixed **parallel time** ($1-S$)

Thus obtaining a fixed-time model, instead of a fixed-size model like that of
Amdahl. We can then **reformulate** the speedup:

$$
\mathrm{SU}(P) = \frac{S + P(1-2)}{S + (1-S)} = S + P(1-S)
$$

This implies a parallel speedup in the number of cores.

To recap:

- **Amdahl's law presupposes that the computing requirements will stay the same,
  given increased processing power**. In other words, an analysis of the same
  data will take less time given more computing power.
- **Gustafson, on the other hand, argues that more computing power will cause
  the data to be more carefully and fully analyzed**
