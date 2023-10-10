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

## Randomized algorithms

Algorithms are deterministic: for a given input, it will run always in the same
time. To analyze them we can:

- Assume a probability distribution of the input
- Analyze interesting items over the distribution

The caveat is that specific inputs may have much worse performance. Also if our
model is wrong we could have misleading performance figures.

**Randomized algorithms will run differently for the same input**. They **work
well with high probability on every input**, but **may fail on every input with
low probability**. The key **tools** for analyzing them are:

1. **Indicator variables**:

   Suppose we want to study random variable $X$ that represents a composite of
   many random events. Define a collection of "indicator" variables $X_i$ that
   focus on individual events; typically $X = \Sigma X_i$

2. **Linearity of expectation**:

   Let $X,Y,Z$ be random variables such that $X=Y+Z$. Then $E[X] = E[Y] + E[Z]$

3. **Recurrence relations**

If we receive some input from a very bad distribution (or we base our assumption
on incorrect facts), **we can actively shuffle the input** to induce a more
favorable distribution. Typically **we analyze the average case behavior for the
worst possible input**.

### Las Vegas and Monte Carlo

##### Las Vegas algorithms

The **only variation** from one run to the other is its **running time**.

##### Monte Carlo algorithms

We can **bound the probability of an incorrect solution**.

For **decision problems** (i.e. those with YES/NO output), there are **two kinds
of Mont Carlo algorithms**:

1. **One-sided error**: there is a **zero probability for error in at least one
   of the two possible outputs**
2. **Two-sided error**: there is a **non-zero probability that it errors** when
   it outputs

Note: a Las Vegas algorithm is special case of Monte Carlo algorithms.

##### Efficient Las Vegas algorithm

A Las Vegas algorithm is an **efficient Las Vegas algorithm if on any input its
expected running time is bounded by a polynomial function of the input size**.

##### Efficient Monte Carlo algorithm

A Monte Carlo algorithm is an **efficient Monte Carlo algorithm if on any input
its worst-case running time is bounded by a polynomial function of the input
size**.

### The min-cut algorithm

Let $G = (V, E)$ be a connected undirected graph. Let $n = |V|, m = |E|$. For
$S \subset V$, the set $\delta(S) = \{(u, v) \in E : u \in S, v \in S' \}$ is a
cut since their removal from $G$ disconnects $G$ into more than one component.
Our goal is to find the cut of minimum size.

**Closely related is the minimum st-cut problem**, in which we are given as
input two vertices $s$ and $t$ and our aim is to find the set $S$ where
$s \in S$ and $t \notin S$ which minimizes the size of the cut $(S, S')$, i.e.,
$|\delta(S)|$.

**Traditionally, the min-cut problem was solved by solving the $n-1$ min st-cut
problems**. The size of the min-st-cut is **equal to the value of the
max-st-flow** (the **dual** problem). The **fastest algorithm for solving
max-st-flow** runs in $\mathcal{O}(nm\log(\frac{n^2}{m}))$. All $n − 1$
max-st-flow computations can be done **simultaneously** with the same time
bounds.

A clever algorithm to **solve the min-cut problem (without the st-condition)
without using any max-flow computations** is from Karger and is **based on a
Monte Carlo approach**. This algorithm has been later refined in a faster
version.

The algorithm will **start initially with a simple graph as input**, and then it
will **contract edges generating multigraphs** (a multigraph is a graph where
there be multiple edges between a pair of vertices). **We do not have self
loops**.

Let us define **edge contraction**. Let $G = (V, E)$ be a multigraph without
self loops. For $e = \{u, v\} \in E$, the contraction with respect to $e$,
denoted $G/e$, is formed by:

1. **Replacing vertices** $u$ and $v$ with a **new vertex** $w$
2. **Replacing all edges** $(u,x)$ or $(v,x)$ **with** $(w,x)$
3. **Remove possible self loops** on $w$

**Observation**: if we **contract** an edge $(u, v)$ then we **preserve those
cuts** where $u$ and $v$ are **both in** $S$ or **both in** $S'$.

The algorithm steps are:

1. **Pick an edge uniformly at random** and **merge** the two vertices at **its
   end points**
2. The algorithm **continues the contraction process until only two vertices
   remain** ($n − 2$ edges contracted)

   These two vertices **correspond to a partition** $(S, S')$ **of the original
   graph** **and the edges remaining in the two vertex graph correspond to**
   $\delta(S)$ in the original input graph.

##### Lemma

Let $\delta(S)$ be a cut of minimum size of the graph $G=(V,E)$. The
**probability that Karger's algorithm ends with** $\delta(S)$ is:

$$
\mathbb{P}(\delta(S)) \geq \frac{1}{\binom{n}{2}}
$$

In order to **boost the probability of success**, we can **simply repeat the
algorithm** $l\binom{n}{2}$ times. The **probability that at least one run
succeeds is**:

$$
\left(1-\frac{1}{\binom{n}{2}}\right)^{l\binom{n}{2}} \geq 1 - e^{-l}
$$

Setting $l = c\log n$ we have an **error probability bounded by**
$\frac{1}{n^c}$.

It is easy to write an implementation of Karger's algorithm that is
$\mathcal{O}(n^2)$ for a simple run. **We can calculate that we have**
$\mathcal{O}(n^4 \log n)$ time with **error probability** of
$\frac{1}{\mathit{poly}(n)}$.

#### Improved version

The improved version is based on the **following consideration**: in the
**initial contractions it is unlikely we contracted an edge in the minimum
cut**; **towards the end this probability grows**.

The **pseudocode** of the improved version is the following:

```txt
procedure contract(G = (V,E), t):
  while |V| > t:
    e = pick_rand_from(E)
    G = G/e
  return G

procedure fastmincut(G = (V,E)):
  if |V| < 6:
    return mincut(V)
  else:
    t = ceil(1 + |V|/sqrt(2))
    G1 = contract(G, t)
    G2 = contract(G, t)
    return min(fastmincut(G1), fastmincut(G_2))
```

We can compute:

1. The **recurrence**:
   $T(n) = 2n^2 + 2T(\frac{n}{\sqrt{2}}) = \mathcal{O}(n^2\log n)$ (from the
   master's theorem)
2. **Probability of success**:
   $\mathbb{P}(n) \geq 1-(1-0.5\mathbb{P}(\frac{n}{\sqrt{2}}+1))^2 = \Omega(\frac{1}{\log n})$

Hence, similar to the unoptimized version of the algorithm, **with**
$\mathcal{O}(\log^2 n)$ **runs the probability of success is greater than**
$1-\frac{1}{\mathit{poly}(n)}$.

#### Corollary of Krager's algorithm

Any **graph** has **at most** $\mathcal{O}(n^2)$ **minimum cuts**.

## Sorting

### Quicksort

Quicksort is a **divide and conquer** algorithm that works like this:

1. **Divide**: **partition** the array into two sub-arrays **around a pivot**
   $x$ such that **elements in the lower array are less than the pivot and
   elements in the upper array are greater than the pivot**
2. **Conquer**: **recursively sort** the two sub-arrays
3. **Combine**

The key to quicksort's efficiency is the **linear partitioning routine**. The
pseudocode for the whole thing is:

```txt
procedure Quicksort(A, p, r) # Initial call is Quicksort(A, 1, n)
  if p >= r || p < 0 then
    return
  q = Partition(A, p, r)
  Quicksort(A, p, q-1)
  Quicksort(A, q+1, r)

procedure Partition(A, p, q) # A[p..q]
  x = A[p]
  i = p
  for j = p + 1 to q do
    if A[j] <= x then
      i = i+1
      swap(A[i], A[j])
  swap(A[p], A[i])
  return i

# Invariant
# ╭───┬──────┬──────┬────────────╮
# │ x │ <= x │ >= x │ ???        │
# ╰───┴──────┴──────┴────────────╯
# p          i      j            q
```

We are considering the **case** where we **do not have duplicated items**. In
the **worst cases**, which are when the **input is already sorted or reverse
sorted**, we pivot around the min/max element, meaning **one of the sub-arrays
will be empty**:

$$
\begin{aligned}
  T(n) &= T(0) + T(n - 1) + \Theta(n) \\
       &= \Theta(1) + T(n - 1) + \Theta(n) \\
       &= T(n - 1) + \Theta(n) \\
       &= \Theta(n^2)
\end{aligned}
$$

In the **best case**, `Partition` **splits the array evenly** and leads to
$T(n) = \Theta(n\log n)$, which is equal to merge sort. **Even if we have an
uneven split** like $frac{1}{10} : \frac{9}{10}$ we have $\Theta(n\log n)$.
**Even if we alternate "lucky"** (array is split into non empty subarrays) **and
"unlucky"** (one of the two subarrays is empty), we still get $\Theta(n\log n)$.

How can we **make sure we are usually lucky**? We **partition** the array around
a **random item**. This scheme means that **no input elicits worst-case
performance**, only a RNG. Moreover, no assumptions are made on the input
distribution.

#### Analysis

Let $T(n)$ be the **random variable for the running time** of randomized
quicksort on an input of size $n$, assuming random numbers are independent. For
$k = 0,1,\ldots n-1$ we define the **indicator random variable**:

$$
X_k = \begin{cases}
  1 \quad\text{if Partition generates a } k:n-k-1 \text{ split} \\
  0 \quad\text{otherwise}
\end{cases}
$$

$E[X_k] = \mathbb{P}(X_k = 1) = \frac{1}{n}$ since **all splits are equally
likely**, assuming all elements distinct. After some calculations (see slides),
we can **prove that in the average case quicksort is upper-bounded by**
$an\log n$ with $a$ chosen accordingly.

### Linear time sorting

**Sorting based on comparisons is** $\Omega(n\log n)$ (for proof see API or
slides). If we **do not make any comparisons between elements, we can go
faster** than $\Omega(n\log n)$ **up to linear** (we need to see all elements at
least once).

**Counting sort**, or bucket sort, is a simple **linear sort algorithm**.

```txt
procedure CountingSort(A, C) # A[j] is in the [1;k] range, C is and auxillary
                             # array k items long
  for i = 1 to k
    C[i] = 0
  for j = 1 to n
    C[A[j]] = C[A[j]] + 1
  for i = 2 to k
    C[i] = C[i] + C[i - 1]
  for j = n downto 1
    B[C[A[j]]] = A[j]
    C[A[j]] = C[A[j]] - 1
  return B
```

It is trivial to se that the complexity is $\Theta(n + k)$ and if
$k = \mathcal{O}(n)$, then the overall complexity is $\Theta(n)$.

**Counting sort is a stable sort**, meaning it **preserves the input order among
equal elements**. **Quicksort**, on the other hand, is **usually not stable**.

Another linear sort useful for numbers is **radix-sort**. The idea is to **sort
with an auxiliary stable sort the various digits of the elements starting from
the least-significant digit**. The algorithm can be proven correct by induction
(see slides). **Assuming that counting sort is the stable sort used**, we can
calculate the **complexity** of radix sort:

1. We sort $n$ computer words of $b$ bits each
2. Each **word can be viewed as having** $\frac{b}{r}$ base $2^r$ **digits**
   - For example, with $r=8, b=32$ we need 4 passes of counting sort on
     base-$2^8$ digits
3. If each $b$-bit word is broken into $r$-bit pieces, with **each pass taking**
   $\Theta(n + 2^r)$. Since there are $\frac{b}{r}$ **passes**, we have

   $$
   T(n,b) = \Theta\left(\frac{b}{r}(n+2^r)\right)
   $$

   Choosing a bigger $r$ means fewer passes, however as $r \gg \log n$, the time
   grows exponentially

4. To **choose** $r$, we can minimize $T(n,b)$ by differentiating and setting it
   to $0$, or by observing that we don't want $2^r \gg n$ and **there is no harm
   in choosing** $r$ **asymptotically near this constraint**. This means that
   **we choose** $r = \log n$, meaning $T(n,b) = \Theta(b\frac{n}{\log n})$. For
   **numbers in the** $[0; n^d - 1]$ range we have $b=d\log n$, meaning that
   **radix sort is**:

   $$
   T(n,d) = \Theta(dn)
   $$

Radix sort can be **easily parallelized**, but unlike quicksort, it **displays
little locality of reference**, and thus **a well-tuned quicksort fares better
on modern processors**, which feature steep memory hierarchies.

## Order statistics

We consider the following **problem**: given a **set of** $n$ **distinct
numbers**, and an integer $i$, we need to **find the element** $x\in A$ **with
rank** $i$ that is **larger than exactly** $i-1$ **other elements of** $A$.

**A naive method is first sorting** the array and **then picking the** $i$-th
element. This leads to a **worst case** $\Theta(n\log n)$ complexity.

The **selection algorithm has a** $\mathcal{O}(n)$ lower bound because a
selection algorithm that can handle inputs in an arbitrary order **must look at
all of its inputs**. If any one of its input values is not compared, that one
value could be the one that should have been selected, and the algorithm can be
made to produce an incorrect answer. The **exact number of comparisons** can be
calculated for some special cases like:

1. **Minimum/maximum**: $n-1$ comparisons because each of the $n-1$ values not
   selected must be determined to be non-minimal/maximal
2. **Both maximum and minimum**: in general less than
   $3\lfloor\frac{n}{2}\rfloor$ comparisons

For solving two problems we have **two algorithms**:

1. Randomized divide and conquer (**linear in average**)
2. Deterministic algorithm (based on pivoting, **linear worst-case**)

### Average-case linear order statistics

The pseudocode is the following:

```txt
procedure RandSelect(A, p, q, i) # select i-th smallest of A[p..q]
  if p = q then return A[p]
  r = RandPartition(A, p, q) # randomized partitioning like in random quicksort
  k = r - p + 1
  if i = k then
    return A[r]
  else if i < k then
    return RandSelect(A, p, r - 1, i)
  else
    return RandSelect(A, r + 1, q, i - k)
```

Lets do a **quick best/worst/average** case analysis

1. **Best case (lucky)**: $T(n) = T(9n / 10) + \Theta(n) = \Theta(n)$
2. **Worst case (unlucky)**: $T(n) = T(n - 1) + \Theta(n) = \Theta(n^2)$
3. **Average case**: analysis is very similar to that of randomized quicksort
   (for the full thing see slides). We prove that **on average we have a** $cn$
   **upper bound**, if $c$ is chosen accordingly

