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

### Worst-case linear order statistics

**We base off the previous algorithm**, but we change a bit the pivot selection.
The rough algorithm outline is:

1. **Divide** the $n$ element **into groups of 5**. **Find the median of each**
   5-element group.
2. Recursively **apply this algorithm to find the median** $x$ **of the**
   $\lfloor\frac{n}{5}\rfloor$ **group medians** to be the **pivot**
3. **Partition around the pivot** $x$. Let $k = \mathit{rank}(x)$.
4. Lastly we **compare** $i$ and $k$ exactly **like in the last lines of**
   `RandSelect`

From the analysis (see slides), we can see that **the recurrence is**:

$$
T(n) = T(\frac{n}{5}) + T(\frac{3}{4}n) + \Theta(n)
$$

Which by substitution we can prove to be **bounded by** $cn$, provided that $c$
is chosen large enough.

Since the work at each level of recursion is a constant fraction (19/20)
smaller, the work per level is a geometric series dominated by the linear work
at the root. **In practice this algorithm runs slowly, because the constant in
front of $n$ is large**.

## Primality test

The **naive primality test** algorithm is the following:

```txt
procedure IsPrime(n)
  if n = 2 then return true
  if n % 2 == 0 then return false
  for i = 1 to sqrt(n/2) do
    if 2i + 1 % n == 0 then return false
  return true
```

The **complexity** is $\Theta(\sqrt{n})$. We can **improve** this by using a
**false-biased Monte Carlo** approach:

- If we **return "not prime"**, then $n$ is **surely not prime**
- If we **return "prime"**, then the **probability that** $n$ **is not prime is
  at most** $p$

Like with Krager's algorithm, we can **run $k$ iterations** to reduce the
probability of error to $p^k$.

##### Fermat's little theorem

Let $p$ be a prime and $0 < a < p$ not divisible by $p$. Then
$a^{p-1} \mod p = 1$.

From this theorem we can observe that each odd prime number $p$ divides
$2^{p-1} - 1$. Thus we can **write the following simple primality** test:

```txt
procedure IsPrime(n)
  z = 2^(n-1) % n # takes at most log(n) time
  if z = 1 then
    return true  # n is possibly prime
  else
    return false # n is composite
```

We call a base-$a$ ($a>1$) **pseudoprime** a natural number $n$ such that $n$ is
composite and $a^{n-1} \mod n = 1$. For the base-2 pseudoprimes, one of such
numbers is 341.

We can **improve our primality test by choosing** $a$ **randomly**:

```txt
procedure IsPrime(n)
  a = rand(2, n-1)
  z = a^(n-1) % n # takes at most log(n) time
  if z = 1 then
    return true  # n is possibly prime
  else
    return false # n is composite
```

The above test **still fails with Carmichael numbers**, i.e. an integer
$n \geq 2$ that is composite and for which for any $0 < a < n$ coprime with $n$
we have $a^{n-1} \mod n = 1$.

##### Theorem

If $p$ prime and $0 < a < p$, then the only solutions to $a^2 \mod p = 1$ are
$a = 1$ or $a = p - 1$

##### Definition: Non-trivial square root

$a$ is called non-trivial square root of $1 mod n$, if $a^2 \mod n = 1$ and
$a\neq 1$ and $a\neq n-1$

Using the two above facts, we can **improve** our primality test **by checking
during the computation of** $a^{n-1}$ that $a$ **is not non-trivial square root
of** $n$. For computing exponentiation we will implement the fast exponentiation
algorithm ($\mathcal{O}(\log n)$).

```txt
isProbablyPrime;

prodecure power(a, p, n): # calculates a^p % n
  if p == 0 then return 1
  x = power(a, p/2, n)
  result = (x * x) % n

  if result == 1 and x != 1 and x != n-1 then
    isProbablyPrime = false
  if p % 2 == 1
    result = (a * result) % n

  return result

procedure isPrime(n):
  a = random(2, n-1)
  isProbablyPrime = true
  result = power(a, n-1, n)

  if result != 1 or !isProbablyPrime then
    return false
  else
    return true
```

##### Theorem

If $n$ is composite, there are at most $n - \frac{9}{4}$ integers $0 < a < n$
for which the above `isPrime(n)` fails.

### RSA

The RSA cryptosystem uses the following procedure for generating public and
private keys:

1. Randomly selects two primes $p$ and $q$ of similar size, each with
   $l+1 \geq 500$ bits
2. Let $n = pq$ and $e$ be an integer that does not divide $(p-1)(q-1)$
3. Calculate $d = e^{-1} \mod (p-1)(q-1)$ i.e. $de = 1\mod(p-1)(q-1)$
4. Publish $P=(e,n)$ as the public key
5. Keep $S = (d, n)$ as the private key

To encrypt a message, divide it in blocks of size $2l$ and interpret each block
as a binary number $0 < M < 2^{2l}$. We have:

$$
  P(M) = M^e \mod n \quad\quad S(C) = C^d \mod n
$$

## Random data structures

We are going to see data structure that allows us to implement a dictionary.

### Not random but still cool: splay trees

**Splaying is a strategy in a self-adjusting BST** to guarantee an **amortized
search time** of $\mathcal{O}(\log n)$. The **splay** operation simple **moves a
node to the root via a logarithmically-long sequence of tree rotations**.

The idea behind splay trees is to **use a particular implementation of the splay
operation** to **move** to the root a **node accessed by a FIND operation**. If
a node is **accessed often enough**, it will **remain close to the root** and
will not contribute much to the total running time; an infrequently accessed
node cannot contribute much to the total running time in any case.

This **guarantees only amortized logarithmic time per operation**, however it is
relatively simple to implement, it does not require explicit balance information
to be stored at nodes and can be shown to be optimal with respect to arbitrary
access frequencies.

The main drawback is the fact that they **restructure the whole tree not only
during insert but also during search**, leading to **slowdown in cached
environments**. Moreover, **during any given operation splay trees may perform a
logarithmic number of rotations**.

### Random treaps

Treaps achieve the same time bounds as splay-trees, but do not requires balance
information and the expected number of rotation performed is small for each
operation.

The approach of treaps is to **merge trees and heaps**:

- A treap is a **binary tree** where **each node contains one element** $x$ with
  a **key and priority** (**chosen** from a uniformly **random** distribution)
  where the following **properties** hold:
  1. **Search tree property on the keys**: elements in the left sub-tree have
     keys smaller than $x$, while those in the right sub-tree keys greater than
     $x$
  2. **Heap property on priorities**: for all $x,y$, if $y$ is a child of $x$
     then $priority(y) > priority(x)$. All priorities are pairwise distinct

##### Lemma: treap uniqueness

For elements $x_1, \ldots, x_n$ with $key(x_i)$ and $priority(x_i)$, **there
exists a unique treap**.

Since the **random priorities** for the elements of $S$ are **chosen
independently**, we can **assume that the priorities are chosen before
insertion**. Once the priorities have been fixed, the treap uniqueness lemma
implies that the treap is uniquely determined. This implies that **the order in
which the elements are inserted does not affect the structure of the tree**.
Thus, **without loss of generality**, we can assume that the elements are
**inserted in order of decreasing priority** (informally leading to the trap
structure lemma). An advantage of this view is that it implies that all
insertions take place at the leaves and no rotations are required to ensure the
heap order on the priorities.

##### Lemma: treap structure

**The search tree has the structure that would result if elements were inserted
in the order of their priorities**.

Both of these lemma can be both proven by induction (see slides).

#### Search

To search for an element we can use the **following procedure**:

```txt
v = root;
while v != nil do
  case
    key(v) = k:
      return "element found"; # (successful search)
    key(v) < k :
      v = RightChild(v);
    key(v) > k :
      v = LeftChild(v);
return "element not found" # (unsuccessful search)
```

The **running time** is $\mathcal{O}(\# elements in search path)$.

To prove this, let us start by first proving the following two properties: given
$n$ elements $x_1,\ldots,x_m$ such that the keys are totally ordered in
ascending order and a subset $M = \{x_i,\ldots,x_m\}$ of said elements

1. Let $i<m$, $x_i$ is **ancestor** of $x_m$ **iff** the element in $M$ with
   **the lowest priority is** $x_i$.

   - **Proof**:

     Let us consider the $\impliedby$ of the first property. We need to prove
     that if $x_i$ has the lowest priority, it is inserted first in $M$. This is
     valid by the lemma of the treap structure.

     Let us go now to the $\implies$ of the first property. Any element $x_l$,
     $key(x_l) > key(x_i)$ inserted that traverses the same path as $x_i$ is a
     child of $x_j$. This means that $x_i$ is the ancestor of all elements in
     $M$ since $key(x_i)$ is the smallest of those in $M$. By the lemma of the
     treap structure, this means that $x_i$ has the smallest priority.

2. The same holds if we reverse the order of M
   - Proof: the second property follows similarly.

Let us prove now that the **expected number of nodes in the search path is
logarithmic**, meaning that the search algorithm is logarithmic.

##### Harmonic number

$$
H_n = \sum_{k=1}^n \frac{1}{k} = \ln n + \mathcal{O}(1)
$$

Let us prove that:

1. **In case of a successful search, the expected number of nodes on the path
   to** $x_m$ is $H_m + H_{n-m+1} - 1$

   - **Proof**:

     $$
     \begin{aligned}
       X_{m,i} &= \begin{cases}
         1 \quad x_i \text{ ancestor of } x_m \\
         0
       \end{cases} \\
       X_m &= \text{ \# nodes on the path from the root to } x_m \\
           &= 1 + \sum_{i<m} X_{m,i} + \sum_{i>m} X_{m,i} \\
       E[X_m] = 1+E\left[\sum_{i<m} X_{m,i}\right] + E\left[\sum_{i>m} X_{m,i}\right]
     \end{aligned}
     $$

     If $i<m$ all elements in $\{x_i,\ldots,x_,\}$ have the same probability of
     being the one with the smallest priority, thus
     $E[X_{m,i}] = \frac{1}{m-i + 1}$. Same thing goes for $i>m$, thus
     $E[X_{m,i}] = \frac{1}{i-m + 1}$. Putting it all together we have:

     $$
     \begin{aligned}
       E[X_m] &= 1 + \sum_{i<m}\frac{1}{m-i+1} + \sum_{i>m}\frac{1}{i-m+1} \\
         &= 1 + \frac{1}{m} + \cdots + \frac{1}{2} + \frac{1}{2} + \cdots +
           \frac{1}{n-m + 1} \\
         &= H_m + H_{n-m+1} - 1
     \end{aligned}
     $$

2. **In case of a unsuccessful search**, let $m$ be the number of keys that are
   smaller than the search key $k$. The **expected number of nodes on the search
   path is** $H_m + H_{n-m}$
   - Proof: the second property follows analogously.

Since the $H_n = \ln(n) + \mathcal{O}(1)$, we have that the number of elements
is logarithmic, meaning that the search operation is also logarithmic.

#### Insertion and delete

To insert a new element $x$, we:

1. Choose the priority $priority(x)$
2. **Search for the position** of $x$ in the tree (pretending $x$ is present; we
   will arrive at the end)
3. **Insert** $x$ **as a leaf**
4. **Restore the heap property** with the following procedure:

   ```txt
   while priority(parent(x)) > priority(x) do
     if x is left child then
       RotateRight(parent(x))
     else
       RotateLeft(parent(x))
   ```

   The rotations are those standard for BSTs.

To **delete** an element we basically do the **inverse of an insert**:

1. Find $x$ in the tree
2. We bring $x$ down to a leaf with:

   ```txt
   while x is not a leaf do
     u = child with smaller priority
     if u is left child
       RotateRight(x)
     else
       RotateLeft(x)
   ```

3. Delete $x$

##### Lemma

**The expected running time of insert and delete operations is**
$\mathcal{O}(\log n)$. **The expected number of rotations is 2**.

We are going to analyse only insert since delete is simply the inverse. Running
time is clearly logarithmic since we basically do a search + rotations. The
number of rotations is the difference between:

1. Depth of $x$ after being inserted as leaf
   - $H_{m-1} + H_{n-m} + 1$ since without $x$ the tree contains $n-1$ elements,
     of which $m-1$ are smaller
2. Depth of $x$ after the rotations
   - $H_m + H_{n-m+1} - 1$

Thus we have: $H_{m-1} + H_{n-m} + 1 - (H_m + H_{n-m+1} - 1) < 2$

#### Extended set of operations

1. `Minimum(T)`: return the smallest key ($\mathcal{O}(\log(n)))$)
2. `Maximum(T)`: return the biggest key ($\mathcal{O}(\log(n)))$)
3. `List(T)`: return all elements in increasing order ($\mathcal{O}(n))$)
4. Split
5. Union

#### Split and Union

The `Split` operation **splits** the treap $T$ **into two treaps** $T_1$ and
$T_2$ such that:

$$
\forall x_1 \in T_1, x_2\in T_2 : key(x_1) \leq k \land k < key(x_2)
$$

Without loss of generality, we can assume that $k$ is not in $T$. If it is, we
can first delete it, do the split and then re-insert it into $T_1$. The
**general steps** are:

1. Generate a new element $x$ with $key(x) = k$ and $prio = -\infty$
2. Insert $x$ in $T$
3. Delete the new root. The left subtree is $T_1$ and the right subtree is
   $T_2$.

The `Union` operations **merges two subtreaps** $T_1$ and $T_2$ such that:

$$
\forall x_1\in T_1, x_2\in T_2 : key(x_1)<key(x_2)
$$

To **implement** it we do:

1. Determine $k$ such that $\forall x_1, x_2 key(x_1) < k < key(x_2)$
2. Generate an element $x$ with key $key(x) = k$ and $prio = -\infty$
3. Generate the treap with root $x$ and left subtree $T_1$ and right subtree
   $T_2$
4. Delete $x$ from $T$.

The **expected running times** of these two operations is $\mathcal{O}(\log n)$.

#### Implementation

The most important point in implementing a treap is **how to handle
priorities**.

We **assign priorities in the range** $[0; 1)$ and we use them only when two
elements are compared to find out which of them has the higher priority. **In
case of equality**, we **extend both priorities by bits chosen uniformly
randomly until two corresponding bits differ**.

### Skip lists

It maintains a **dynamic set of** $n$ elements in $\mathcal{O}(\log n)$ **time
per operation in expectation and with high probability**.

We **start** from the simplest data structure: a **sorted linked lists**.
Searches are linear. Suppose we had **two sorted linked lists**, where the
**second one has a subset of the items**. We can see the two linked lists as
**two train lines**:

1. **Express line** (secondary list) connects a **few of the stations**
2. **Local line** (first list) connects **all stations**
3. **Links** between lines at common stations

To search, then, we **walk on the express lane until we the last substation
before our value**, then we **switch down to the local lane** and we walk it
until we find our element.

**Which elements** can we put in the **express list**? We **evenly space** the
nodes of the local lane. But **how many** elements? Since the cost is roughly:

$$
|L_1| + \frac{|L_2|}{|L_1}
$$

We minimize and obtain that it has $\sqrt{n}$ elements. Thus the **search cost
is roughly** $2\sqrt{n}$. If we **increase** the **number of lists** to $k$, we
have that the **search time becomes** $k\sqrt[k]{n}$. If we use $\log n$
**lists**, we get that the time is $2\log n$.

The **"ideal" skip list is this** $\log n$ **linked list structure**. We need to
maintain it as good as possible on updates:

#### Insert and delete

Skip lists have as **invariant** that the **bottom list always contains all
elements**. So on insertion of a new element $x$ we are **always inserting in
the bottom list**. The question is **in which other lists we need to insert
it**.

We **flip a fair coin**: if **head we promote** $x$ **to the next level and flip
again**. We also include a **small change**: we add a **special element**
$-\infty$ at the start of every list.

To **delete** an element we **search** for it and then **remove it from every
list**.

##### Definition: high probability event

Parameterized event $E_\alpha$ occurs with high probability **if**, for any
$\alpha\geq 1$, **there is an appropriate choice of constants for which**
$E_\alpha$ **occurs with probability at least** $1 − \frac{c_\alpha}{n^\alpha}$

##### Theorem: high probability logarithmic search

**With high probability, every search in a skip list costs**
$\mathcal{O}(\log n)$.

##### Lemma

**With high probability, a** $n$ **element skip list has** $\mathcal{O}(\log n)$
levels.

## Dynamic programming

The term dynamic programming was originally used in the 1940s by Richard Bellman
to describe the process of solving problems where one needs to find the best
decisions one after another.

1. **"dynamic"** captures the **time-varying aspect** of the problems (and
   sounded impressive)
2. **"programming"** referred to the **use of a method to find an optimal
   program**

### Longest common subsequence

To explain dynamic programming we are going to use the longest subsequence
problem:

> Given two sequences $x[1 \ldots m]$ and $y[1 \ldots n]$, find a longest
> subsequence common to them both.

The brute force solution is checking every subsequence of $x[1\ldots m]$ to see
if it is also a subsequence of $y$. This means that we have $\mathcal{O}(n)$
time for $2^n$ possible subsequences, leading to a $\mathcal{O}(n2^n)$
worst-case running time.

To improve, we look at at the **length of a common subsequence**. Let us
consider the **prefixes** of our two strings $x$ and $y$. We can define:

$$
c[i,j] = |\mathit{LCS}(x[1\ldots i], y[1\ldots j])|
$$

We can **observe** that $c[m,n] = |\mathit{LCS}(x,y)|$. We can prove by
induction (proof is skipped) that the **following recursive definition holds**:

$$
c[i,j] = \begin{cases}
  c[i-1, j-1] + 1 \quad x[i] = y[j] \\
  \max\{c[i-1, j], c[i, j-1]\}
\end{cases}
$$

The definition of $c[i,j]$ is an example of the **"optimal substructure"
property** of a problem:

> An optimal solution to a problem (instance) contains optimal solutions to
> subproblems.

The recursive algorithm can be easily found:

```txt
LCS(x, y, i, j) // ignoring base cases
  if x[i] == y[j] then
    c[i, j] = LCS(x, y, i–1, j–1) + 1
  else
    c[i, j] = max{LCS(x, y, i–1, j), LCS(x, y, i, j–1)}
  return c[i, j]
```

The **worst case is when** $x[i] \neq y[j]$, in which the **algorithm evaluates
two subproblems, each with only one parameter decremented**. If we develop the
recursion tree, we can see that the height of the three is $m+n$, meaning we
potentially have exponential amount of work. However we may need to **resolve
the same subproblem multiple times**. This is the second important property,
**overlapping subproblems**, of a problem solvable by dynamic programming:

> A recursive solution contains a “small” number of distinct subproblems
> repeated many times.

The **number of distinct LCS subproblems for two strings of lengths $m$ and $n$
is only** $mn$. **Memoization** is the caching of results of the various
subproblems in a data structure to avoid the cost in subsequent iterations.
Implementing memoization in our `LCS` algorithm is simple since `c[i,j]` is
already a table that stores everything we need.

```txt
LCS(x, y, i, j) // ignoring base cases
  if c[i,j] == nil then
    if x[i] == y[j] then
      c[i, j] = LCS(x, y, i–1, j–1) + 1
    else
      c[i, j] = max{LCS(x, y, i–1, j), LCS(x, y, i, j–1)}
  return c[i, j]
```

This algorithm has $\Theta(mn)$ **space and time complexity**.

Now that we have the table of lengths, we can **reconstruct the LCS by tracing
the table backwards**. The reconstruction is $\mathcal{O}(\min\{m,n\})$.

### Reduced Ordered Binary Decision Diagram

This data structure represents a **logic function as a directed acyclic graph**
of boolean decisions. This representation is more efficient that the other two
possibilities:

1. Truth table: exponential in the number of variables
2. First or second canonical forms: still exponential in the number of variables

The DAG representing the function can be made canonical.

The key idea is to **use two memoization tables**:

1. **Unique table**: find identical sub-cases and avoid replication
2. **Computed table**: reduce redundant computation of sub-cases

**Many logic operations can be performed efficiently on BDD's**, usually linear
in size of the graph and even constant for some operations. The **size** of the
BDD is **critically dependent on variable ordering**.

The graph is a DAG with **one root node and two terminals** (0 and 1); **each
node has two children and a variable**. To build the graph we are **recursively
using the Shannon's decomposition**: $f = vf|_v + \bar{v}f|_{\bar{v}}$. From the
theory of boolean algebra, we know that this way we will have $2^n$ leafs. We
can **compress** this graph by ensuring two properties:

1. **Reduced**: any node with two identical children is removed, two nodes with
   isomorphic BDD's are merged
2. **Ordered**: Co-factoring variables (splitting variables) always follow the
   same order along all paths

If the graph is **both ordered and reduced** we say that the graph is
**canonical**. **Each function has only one canonical graph**, meaning that
checking equality between two functions is reduced to equality between graphs.

We use two types of memoization tables:

1. **Unique table**: used to **avoid duplication of existing nodes** (hash table
   with collision chains)
2. **Computed table**: **avoids re-computation** of existing results (stores the
   **most frequent results**)

#### Implementation

**Variables** are **totally ordered**: If $v < w$ then $v$ occurs "higher" up in
the ROBDD. The top variable of a function $f$ is a variable associated with its
root node. **Each node** is written as a **triple** $f = (v, g, h)$ where
$g = f|_v$ and $h = f|_{\bar{v}}$. We read this triple as "if $v$, then $g$ else
$h$"; this is the **`ite` function**, defined as such:
$\mathtt{ite}(v, g, h) = vg + \bar{v}h$. We can use the `ite` function to
**implement any two variable logic function** and can be **defined
recursively**.

Before a node $(v, g, h)$ is added to the BDD, it is looked up in the
"unique-table". If it is there, then the existing pointer to the node is used to
represent the logic function. Otherwise, a new node is added to the unique table
and the new pointer returned. Thus a strong canonical form is maintained. The
left child of the node $(v, f, g)$ is $(f|_v, g|_v, h|_v)$, while the right is
$(f|_{\bar{v}}, g|_{\bar{v}}, h|_{\bar{v}})$.

```txt
procedure ITE(f, g, h)
  if f == 1
    return g
  if f == 0
    return h
  if g == h
    return g
  if (p = HASH_LOOKUP_COMPUTED_TABLE(f,g,h)) != NULL
    return p
  v = TOP_VARIABLE(f, g, h ) // top variable from f,g,h
  fn = ITE(fv,gv,hv)         // recursive calls
  gn = ITE(fv,gv,hv)
  if fn == gn                // reduction
    return gn
  if !(p = HASH_LOOKUP_UNIQUE_TABLE(v,fn,gn)
    p = CREATE_NODE(v,fn,gn) // and insert into UNIQUE_TABLE
  INSERT_COMPUTED_TABLE(p,HASH_KEY{f,g,h})
  return p
```

## Amortized analysis

We will analyze the **size of a hashtable**: how large should it be? We want it
as small as possible, but still big enough so that it doesn't overflow. We have
a problem since we don't know the size of the table in advance, meaning that
**whenever the table overflows we need to grow it by allocating a new larger
table**. This is a **dynamic table**.

Let us consider the case of a dynamic table with **starting size 1 and a "double
the size on overflow" policy**. Consider a **sequence** of $n$ insertions. The
**worst case time to execute one insertion** is $\Theta(n)$. Therefore the
**worst-case time for $n$ insertions should be** $\Theta(n^2)$... which is
**wrong**. Let $c_i$ be the cost of the $i$-th insertion, we have:

$$
c_i = \begin{cases}
  i &\quad\text{if } i - 1 \text{ is an exact power of } 2 \\
  1 &\quad\text{otherwise}
\end{cases}
$$

Breaking down the cost we get:

$$
\begin{array}{c|cccccccccc}
  i               & 1 & 2  & 3 & 4 & 5 & 6 & 7 & 8 & 9  &   \\
  \mathit{size}_i & 1 & 2  & 4 & 4 & 8 & 8 & 8 & 8 & 16 &   \\
  \hline
  c_i             & 1 & 1  & 1 & 1 & 1 & 1 & 1 & 1 & 1  & + \\
                  &   & 1  & 2 &   & 4 &   &   &   & 8  &   \\
\end{array}
$$

Thus we can decompose the cost of $n$ insertions into:

$$
\begin{aligned}
  \sum_{i=1}^n c_i &\leq n + \sum_{j=0}^{\lfloor\log(n-1)\rfloor} 2^j
                   &\leq 3n
                   &=\Theta(n)
\end{aligned}
$$

Thus the **average case of each dynamic table operation is**
$\Theta(n)/n = \Theta(1)$.

An **amortized analysis** is any **strategy for analyzing a sequence of
operations to show that the average cost per operation is small, even though a
single operation within the sequence might be expensive**. An amortized analysis
**guarantees that the average performance of each operation in the worst case**.

There are 3 common amortization analyses:

1. **Aggregate method**
   - We have already used this in our demonstration
2. **Accounting method**
3. **Potential method**

The **aggregate method**, though **simple, lacks the precision** of the other
two methods. In particular, the accounting and potential methods allow a
specific amortized cost to be allocated to each operation.

### Accounting method

The main gist of it is to **charge** $i$-th operation a **fictitious amortized
cost** $\hat{c}_i$, where **\$1 pays for 1 unit of work** (i.e. time). This
**fee is consumed to perform the operation**. Any **amount not immediately
consumed is stored in the bank** for use by subsequent operations. The **bank
balance must not go negative**, meaning that we must ensure that:

$$
\sum_i^n c_i \leq \sum_i^n \hat{c}_i \quad \forall n
$$

The **total amortized costs provide an upper bound on the total true costs**.

For dynamic tables we have that $\hat{c}_i = \$3$ (for $i=0$ the cost is $2$):

- \$1 pays for the immediate insertion
- \$2 is stored for later table doubling
- When the table doubles, pay \$1 to move a recent item and \$1 to move an old
  item.

### Potential method

Similar to the accounting method, but **we use potential energy** instead of a
bank.

1. Start with an initial data structure $D_0$
2. Operation $i$ transforms $D_{i-1}$ in $D_i$
3. The cost of operation $i$ is $c_i$
4. Define a **"potential function"** $\Phi: \{D_i\}\to R$ such that:
   - $\Phi(D_0) = 0$
   - $\Phi(D_i) \geq 0 \quad\forall i$
5. The **amortized cost** $\hat{c}_i$ with respect to $\Phi$ is defined to be

   $$
   \hat{c}_i = c_i + \Phi(D_i) - \Phi(D_{i-1})
   $$

   The difference between $\Phi(D_i) - \Phi(D_{i-1})$ ($\Delta\Phi$) is the
   potential difference.

   1. If $\Delta\Phi > 0$ then $\hat{c}_i > c_i$, i.e. the operation stores work
      in the data structure for later use
   2. If $\Delta\Phi < 0$ then $\hat{c}_i < c_i$, i.e. the data structure
      delivers stored work to help pay for the operation

For the dynamic table case, we define the potential of the table after the
$i$-th insertion to be $\Phi(D_i) = 2i - 2^{\lceil\log i\rceil}$ for $i > 0$
with $\Phi(0) = 0$. Doing the various calculations, we obtain that
$\hat{c}_i = 3$, just like with the accounting method.

## Competitive analysis

A sequence $S$ of operations is provided one at a time. For each operation, an
**on-line algorithm** $A$ must **execute the operation immediately without any
knowledge of future** operations. An **off-line algorithm may see the whole
sequence** $S$ in advance. How do we analyze the total cost of an online
algorithm?

An on-line algorithm $A$ is $\alpha$-competitive if there **exists a constant
$k$ such that for any sequence $S$ of operations**:

$$
C_A(S) \leq \alphaC_{OPT}(S) + k
$$

Where $OPT$ is the **optimal off-line algorithm** ("God’s algorithm").

Let us consider the case of a **self-organizing list** $L$. Suppose that element
$x$ is accessed with probability $p(x)$. Then we have:

$$
E[C_A(S)] = \sum_{x\in L} p(x) \cdot \mathrm{rank}_L(x)
$$

This average is **minimized** when $L$ is **sorted in decreasing order with
respect to** $p$. Empirically, **move-to-front (MTF) is good enough** (cost is
$2\mathrm{rank}_L(x)$).

##### Theorem: MTF is $\mathcal{O}(1)$-competitive

MTF is **4-competitive** for self-organizing lists.

**Proof**. Let $L_i$ be the MTF list after the $i$-th access and let $L_i^\star$
be the optimal list after the $i$-th access. Let:

1. $c_i = 2\cdot\mathrm{rank}_{L_{i-1}}(x)$ the MTF cost for the $i$-th
   operation
2. $c_i^\star = \mathrm{rank}_{L_{i-1}^\star}(x) + t_i$ the cost of the optimal
   list for the $i$-th operation
   - $t_i$ is the number of transpositions that the optimal algorithm performs

Let us define the potential function as:

$$
\begin{aligned}
  \Phi(L_i) &= 2|\{(x,y): x \prec_{L_i} y \land y \prec_{L_i^\star} x\}| \\
            &= 2 \cdot \#\mathrm{inversions}
\end{aligned}
$$

For any $i$ the potential function is greater than zero and $\Phi(L_0) = 0$ if
MTF and the optimal algorithm start both from the same list. A transposition
create/destroys 1 inversion, so $\Delta\Phi = \pm 2$. Suppose that operation $i$
accesses element $x$, we can define:

1. $A = \{y \in L_{i-1} : y \prec_{L_{i-1}} \land x \prec_{L_{i-1}^\star} x\}$
2. $B = \{y \in L_{i-1} : y \prec_{L_{i-1}} \land y \succ_{L_{i-1}^\star} x\}$
3. $C = \{y \in L_{i-1} : y \succ_{L_{i-1}} \land y \prec_{L_{i-1}^\star} x\}$
4. $D = \{y \in L_{i-1} : y \succ_{L_{i-1}} \land y \succ_{L_{i-1}^\star} x\}$

```txt
        ┌─────────┬─┬──────┐
 L_{i-1}│A U B    │x│C U D │
        └─────────┴─┴──────┘
        ┌──────┬─┬─────────┐
L*_{i-1}│A U C │x│B U D    │
        └──────┴─┴─────────┘
```

Let $r$ and $r^\star$ be respectively the rank of $x$ in the MTF list and in the
optimal list. We have $r = |A| + |B| + 1$ and $r^\star =  |A| + |C| + 1$. When
MTF moves $X$ to the front, it creates $|A|$ inversions and destroys $|B|$
inversions. Each transpose by the optimal algorithm creates less than 1
inversion. Thus be have $\Delta\Phi \leq 2(|A| - |B| + t_i)$. The amortized cost
is going to be:

$$
\begin{aligned}
  \hat{c}_i &= c_i + \Delta\Phi(L_i) \\
            &\leq 2r + 2(|A| - |B| + t_i) \\
            &= 2r + 2(|A| - (r - 1 - |A|) + t_i) \\
            &= 2r + 4|A| - 2r + 2 + 2t_i \\
            &= 4|A| + 2 + 2t_i \\
            &\leq 4(r^\star + t_i)  \\
            &= 4c_i^\star
\end{aligned}
$$

Thus we have:

$$
\begin{aligned}
  C\sum_i^{|S|} c_i &= \sum_i^{|S|} (\hat{c}_i + \Delta\Phi(L_i)) \\
                    &\leq (\sum_i^{|S|} 4c_i^\star) + \Delta\Phi(L_i)) \\
                    &\leq 4 C_{OPT}
\end{aligned}
$$

$\square$.

If we count transpositions that move $x$ to the front as "free", then MTF is
2-competitive.

## Parallel programming introduction

### Dependencies

Parallel execution, from any point of view, will be constrained by the sequence
of operations needed to be performed for a correct result. Parallel execution
**must address control, data, and system dependences**. A **dependency** arises
when one **operation depends on an earlier operation** to complete and produce a
result before this later operation can be performed.

Our **fundamental concurrent execution assumption** will be the following:

1. **Processors execute independently of each other**
2. **No assumptions** are made **about speed** of processor execution

We want sequential consistency. This means that each statement's execution does
not interfere with each other and that computation results are the same,
independent of the order. If this holds true, we call the two statements
independent, otherwise they are dependent. We can have **3 types of
dependencies:**

1. **True (flow) dependencies**: Read After Write
2. **Output dependencies**: Write After Write
3. **Anti-dependencies**: Write After Read

**Output and Anti-dependencies are called "name" dependencies, meaning we can
get rid of them by changing the code** (with e.g. register renaming). True
dependencies cannot be removed. Two statements are said to be **independent if
there are no dependencies between them**.

Data dependence relations can be found by comparing the $IN$ and $OUT$ sets of
each node. The $IN$ and $OUT$ sets of a statement S are defined as:

- $IN(S)$: set of memory locations (variables) that may be used in $S$
- $OUT(S)$: set of memory locations (variables) that may be modified by $S$

Thus we have:

1. $OUT(S_1)\cap IN(S_2)\neq\emptyset$: true dependency ($S_1\delta S_2$)
2. $IN(S_1)\cap OUT(S_2)\neq\emptyset$: anti-dependency ($S_1\delta^{-1} S_2$)
3. $OUT(S_1)\cap OUT(S_2)\neq\emptyset$: output dependency ($S_1\delta^0 S_2$)

### Loop-level parallelism

Significant parallelism can be identified within loops. The **"DOALL" loop**
(a.k.a. foreach loop) is the maximum in term of loop-level parallelization:
**all different iterations are independent of each other** (statements inside an
iteration might have dependencies). foreach loops can be unrolled and fully
parallelized.

Parallelism can be achieved even between two different loops if there are not
dependencies.

We have a **loop-carried dependency** if **some statements are dependant on
previous iterations**. If there are **no loop-carried dependencies** the loop is
**loop-independent**. The loop-carried dependency can be **lexically forward**
(if the source comes after the target) or **lexically backward**. This type of
dependencies can limit the parallelization we can extract: we need to pipeline
different loop executions.

## Parallel Patterns

Parallel patterns are a **recurring combination of task distribution and data
access** that solves a specific problem in parallel algorithm design. They
provide us with a "vocabulary" for algorithm design.

### Nesting pattern

Nesting is the ability to hierarchically compose patterns. "Pattern diagrams"
are used to visually show the pattern idea where each "task block" is a location
of general code in an algorithm. Each "task block" can in turn be another
pattern.

### Control patterns

#### Serial control

Structured serial programming is based on these patterns: sequence, selection,
iteration, and recursion.

1. **Sequence**: ordered list of tasks that are executed in a specific order
   - Assumption: program text ordering will be followed
2. **Selection**: condition $c$ is first evaluated; either task $a$ or $b$ is
   executed depending on the true or false result of $c$
   - Assumption: $a$ and $b$ are never executed before $c$, and only $a$ or $b$
     is executed - never both
3. **Iteration**: a condition $c$ is evaluated; if true, $a$ is evaluated, and
   then $c$ is evaluated again. This repeats until $c$ is false
4. **Recursion**: dynamic form of nesting allowing functions to call themselves
   - Tail recursion is a special recursion that can be converted into iteration

#### Parallel control

Parallel control patterns extend serial control patterns. Each parallel control
pattern is related to at least one serial control pattern, but relaxes
assumptions of serial control patterns.

1. **Fork-join**: allows control flow to **fork into multiple parallel flows,
   then rejoin later**
   - A "join" is different than a "barrier":
     - In a join, only one thread continues
     - In a barrier, all threads continue
2. **Map**: performs a **function over every element of a collection**
   - Replicates a serial iteration pattern where each iteration is independent
     of the others, the number of iterations is known in advance, and
     computation only depends on the iteration count and data from the input
     collection
     - **Basically a foreach loop**
   - The replicated function is referred to as an "elemental function"
3. **Stencil**: **elemental function accesses a set of "neighbors"**
   - It is a **generalization of map**
   - Boundary conditions must be handled carefully
4. **Reduction**: **combines every element in a collection using an associative
   "combiner function"**
5. **Scan**: computes **all partial reductions** of a collection
   - For every output in a collection, a reduction of the input up to that point
     is computed. If the function being used is associative, the scan can be
     parallelized
6. **Recurrence**: **more complex version of map**, where the **loop iterations
   can depend on one another**
   - For a recurrence to be computable, **there must be a serial ordering of the
     recurrence elements so that elements can be computed using previously
     computed outputs**

### Data management patterns

#### Serial data management

Serial programs can manage data in many ways. Data management deals with how
data is allocated, shared, read, written, and copied.

1. **Random R/W**: memory locations indexed with addresses, pointers are
   typically used to refer to memory addresses
   - Aliasing can cause problems
2. **Stack allocation**: dynamically allocate data in LIFO manner
   - Efficient and preserves locality
   - When parallelized, typically each thread will get its own stack
3. **Heap allocation**: useful when data cannot be allocated in a LIFO fashion
   - Slower and more complex than stack allocation
   - A parallelized heap allocator should be used when dynamically allocating
     memory in parallel (using e.g. different allocation pools)
4. **Objects**: language constructs to associate data with code to manipulate
   and manage that data

#### Parallel data management

To avoid things like race conditions, it is critically important to know when
data is, and isn't, potentially shared by multiple parallel workers.

Some parallel data management patterns can help us with data locality
