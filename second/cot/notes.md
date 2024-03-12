# Code optimization and transformation

## Immediate representations

A compiler is split in two:

1. The **front end** handles lexical/syntactic analysis and semantic checks
2. The **back end** generates code, allocates registers and applies
   target-dependent optimization

The **front end generates an intermediate representation** (IR) and the backend
operates on that. An IR is **composed of**:

1. **Intermediate language**: a functional representation of the source
2. **Metadata**: information about the source code useful for optimization

There are **3 main types** of IR:

- **Expression trees**
- **Three address instructions**: pseudo assembly languages (register based)
- **VM bytecode**: like java bytecode or DotNet CIL (usually a stack-based
  language)

An IR, ideally, needs to be **convenient to be produced during semantic analysis
and to translate into machine code** (first conflict: one mandates that it
should be similar to the source language while the other similar to assembly);
moreover **each construct must have a simple and clear meaning**, such that we
can easily specify and implement optimizing transformations. For interpreted
IRs, other requirements may arise.

### IR Trees

IR constructs are **nodes of a tree**, where **child nodes contain the
operands** of the parent node. **Each** IR construct **must describe very simple
operations** such as fetch/store/add/jump.

We will consider the following node types:

1. `CONST(i)` integer constant
2. `NAME(n)`: symbolic constant
3. `TEMP(t)`: a temporary to be later mapped to a register
4. `BINOP(o, e1, e2)`: binary operator applied to operands, each obtained by
   evaluating the operand expressions in order
5. `MEM(e)`: content of a word, starting at address e
6. `CALL(f, l)`: call function with given argument list

... and the following statements:

1. `MOVE(temp T, e)`: evaluate `e` and move the result into temporary `t`
2. `MOVE(MEM(e1), e2)`: evaluate `e1` and `e2` and move the result into memory
   at address `e2`
3. `JMP(l)`: unconditional jump
4. `CJUMP(o, e1, e2, t, f)`: evaluate the two expressions, compare the results
   with operator `o`; if true jump to `t`, otherwise to `f`
5. `LABEL(N)`: define symbolic constant as the current code address

Example code:

```py
a = b if x < 5 else 7
```

Translated into our IR:

```txt
          CJUMP(LT, TEMP x, CONST 5, NAME t, NAME f)
LABEL t   MOVE (TEMP a,TEMP b)
          JMP (NAME out)
LABEL f   MOVE (TEMP a,CONST 7)
LABEL out
```

In our expression tree representation, we need to **introduce a** `SEQ` **pseudo
node that encodes the sequential nature of the program**.

### Basic blocks

A basic block is defined as a **sequence of statements that is always entered at
the beginning and exited at the end**. The **first statement should be** a
`LABEL` and the **last statement** a `JUMP`/`CJUMP`, with **no other label or
jump in between**.

To **construct basic blocks** from generic IR code we can apply the following
algorithm:

- **Scan** the statement sequence
  - **When** `LABEL` is **found**, **start** a **new** block
  - **When** a jump is **found**, **end** the **current** block and **start** a
    **new** one
- Any **block opened with no label gets a new one**
- Any **block closed with no jump receive a jump to the next block label**
- A **final block with just a label** statement is **inserted at the end**

Basic blocks are very important since they are self contained and can be
relocated however we please.

### Control flow graph (CFG)

It is a **directed graph** such that:

1. There is **one node** $i$ for **each IR statement** (`stat_i`)
2. There are **two additional nodes** `i_in` and `i_out`
3. There is **one edge** $(i,i')$ if `stat_i'` is **executed immediately after**
   `stat_i`
4. Each node must **have at most two immediate successors**
5. For the **first statement** (`stat_0`) there is an **arc** $(i_{in}, i_0)$
6. An **arc** $(j, i_{out})$ is added **for each node** $j$ bound to a statement
   `stat_j` **preceding an exit point** of the program

A **basic block is recognized as a sequence of nodes**
$\langle i_0, \ldots, i_n\rangle$ **such that**:

1. There are **arcs** $(i_0, i_1)$, ..., $(i_{n-1}, i_n)$
2. **No other arc** in the CFG **has any node of the sequence except** $i_0$ as
   its **target**
3. **No other arc** in the CFG **has any node of the sequence except** $i_n$ as
   its **starting** node

CFGs are very useful in detecting loops. **Loops in a CFG appear as a directed
cycle** in the CFG. A loop is a **strongly connected component**, which is
defined as:

> A set of nodes such that **each one is reachable from every other node** in
> the set.

**Definition** (Dominance relation):

> A node $d$ dominates a node $n$ if $m$ occurs before $n$ on every directed
> path from the start node $s_0$ to $n$. Moreover every node dominates itself.

**Definition** (Immediate dominator):

> A node $m\neq n$ is an immediate dominator of $n$ if
>
> $$
> m \,\mathit{dom}\, n \land (d \,\mathit{dom}\, m \; \forall d : d\,\mathit{dom}\,n)
> $$

### Static single assignment

Many optimizations require to represent definitions and uses of variables. One
possibility is to maintain an explicit structure representing all information
about variables; an improvement is to put code into "static single assignment
form" (SSA). **SSA is an IR where each variable has only one definition**, but
this **definition can be in a loop**.

```txt
# Non SSA
a = x + y
b = a - 1
a = y + b

# SSA
a1 = x + y
b1 = a1 - 1
a2 = y + b1
```

The **advantages** of SSA are:

1. It **simplifies data-flow analysis** and program **optimizations**
2. **Reduce** the **space and time needed to represent definitions and uses**
   - Assume that $N$ uses $M$ definitions in about $N + M$ instructions, then an
     explicit structure for definitions and uses is $\mathcal{O}(MN)$ while SSA
     is $\mathcal{O}(M+N)$
3. **Simplifies register allocation**
4. **Unrelated uses** of the same variable **disappear**

To **convert a basic block into SSA** we have that:

1. Each **new definition of a variable** `a` is modified to **define a fresh
   variable** `a1`, `a2`, etc...
2. Each **use of the variable is changed to use the most recently defined
   version**

The second point poses a problem: **when a statement has more than one
predecessor** (e.g. because of two conditional branches converging), **the idea
of "most recent definition" becomes nonsense** since the definition used to
assign the new value depends on the control flow. We thus **introduce** the
$\phi$-function, a **special notation that denotes a runtime choice of the
predecessor**. The $\phi$-function has as many arguments as predecessors. To
know which edge was taken, if the program has to be made executable, we
**place** a `MOVE` instruction **on each incoming edge**; during compilation
**data-flow analysis will provide the connection** between a use `a_i` and a
definition `a_j`.

**Dominance properties**:

1. If `x` has the `j`-th argument of a $\phi$-function in block `n`, then the
   **definition** of `x` **is always executed before** (pre-dominates) the
   `j`-th predecessor of `n`
2. If `x` is **used in a non**-$\phi$-**statement** in block `n`, then the
   **definition** of `x` **must dominate** `n`

$\phi$-function conversion algorithm outline:

0. Hypothesis: the start node contains an implicit definition of every variable
1. Inserting $\phi$ functions
2. Assigning subscripts

We know already how to do the second point. The first one is more difficult. One
way to do it is verify the **path-convergence criterion**:

> Place a $a = \phi(\ldots)$ at node `z` if all conditions are met:
>
> 1. There exist two basic blocks such that $x: a = \ldots$ and $y: a = \lots$
> 2. There exist two non-empty paths $P_{xz}$ from `x` to `z`, and $P_{yz}$ from
>    `y` to `z` such that:
>
>    1. $P_{xz}$ and $P_{yz}$ do not have any node in common except $z$
>    2. Node `z` does not occur within both $P_{xz}$ and $P_{yz}$ prior to the
>       end

The algorithm then becomes:

```txt
while exists blocks x,y,z staisfying PCC and z does not contain a phi for a
  insert "a = phi(a, a, ldots, a)" at z
... # relabel
```

This algorithm is **simple**, but **very slow** since verifying the PCC implies
verifying two existential quantifiers over all of the instructions space.

**Another way is to leverage the dominance properties of SSA**. First let us
introduce some **preliminaries**:

1. Node $x$ **strictly dominates** node $w$ if $x$ dominates $w$ and $x \neq w$
2. Predecessor/successor denote CFG relations
3. Parent/child denote dominance tree relations
4. In a tree, an **ancestor** of node $n$ is the parent of $n$ or the parent of
   an ancestor of $n$
   - An ancestor is proper if it is not the parent

**Definition** (Dominance frontier):

> The dominance frontier $DF(x)$ of a node $x$ is the set of all nodes $w$ such
> that $x$ dominates a predecessor of $w$, but does not strictly dominate $w$
>
> If $x$ dominated all predecessor of $w$ it would dominate $w$ too.

Intuitively, DF is the border between dominated and non-dominated nodes,
therefore it is a point of convergence of disjoint paths.

To **implement the algorithm using DF, for each variable defined in node** $x$
we **insert** a $\phi$ function **in every node that is in** `DF(x)`. This is
**equivalent to the path convergence criterion**:

1. If $a_x$ is the i-th argument of a $\phi$ function in block z, then the
   definition $x : a = \ldots$ dominates the i-th predecessor of z
2. If $a$ is used in a non-$\phi$ statement in block $n$, then the definition of
   $a$ dominates $n$

Since a $\phi$ function is a kind of definition, we must **apply the criterion
to each newly introduced** $\phi$ functions. This requires an **iterative
procedure** that terminates when no nodes need new $\phi$ functions.

## Instruction selection

After we have our IR, we need to **generate instructions for said** IR. The
**mapping** between the two **can vary depending on CPU ISA** type:

- **RISC** architectures usually have a **one-to-one or one-to-many** relation
  between IR nodes and target instructions
  - Instructions are very simple and often we need may instructions to do a
    single operation
- **CISC** architectures usually **may also have a many-to-one** relation
  - Instructions are complex and can do multiple operations

We have **two main strategies**:

1. **Tabular**: we have a lookup table where each node is translated to snippet
   of machine code
   - **Very simple** method
   - Works **very well for RISC** targets where we have one-to-one or
     one-to-many
2. **Pattern matching** algorithms
   - More **complicated**
   - Works very well for CISC targets where we have many-to-one

Since the tabular method is trivial to implement, we will outline the pattern
matching one.

### Pattern matching

The main idea is the following:

1. **For each IR instruction**, we define a **subtree-pattern** (called tile)
   and a relative output instruction
2. We apply a **tree-covering algorithm**

This way we can **reduce** the problem to a **minimum-cost tree-covering**. The
**cost criterion depends on our application** requirements (execution time,
energy, code size etc...).

There are many algorithms for doing what we need, one of the simplest is the
**top-down greedy algorithm**:

1. Consider the **root** $O$ of the tree
2. Choose the **largest instruction tile matching** $O$ and possibly some of its
   siblings (`munch(O)`)
3. Let $O_1, O_2, \ldots, O_k$ be the roots of subtrees which border with the
   covered tile
   - **Recursively call** `munch` on $O_1, 0_2, \ldots, O_k$ (in that order)
4. **Terminate** when the **entire tree has been munched**
5. **While** the algorithm **visits** the tree in depth-first order, it
   **appends the tiles to a list**, to produce the actual code, the list is
   reversed.

The algorithm is fast and operates in **linear time**, w.r.t the tree size.

We can **improve** this approach in different ways:

- Use **different cost criterion** instead of tile size
- Improve the performance by leveraging **dynamic programming**

### Other code generation approaches

One alternative approach is "**peephole optimization**". Consider some
**generated suboptimal code** created using a simple approach. Using a **sliding
window** on the instruction sequence, **apply pattern matching** to detect
sequences of instructions that admit a replacement with a faster semantically
equivalent code snippet.

To leverage **idiomatic complex instructions** (like vector instructions or
packed shifts etc...), we need to have a **pre-pass and match them as early as
possible**, since they would be very difficult to generate afterwards,
especially with a top down algorithm.

## Data-flow analysis

To perform data-flow analysis, we **start from the CFG**. We will **work at the
function granularity**. Program **variables** and procedure **arguments** are
**undifferentiated, and treated as temporary symbols**. The **entry point** has
**no predecessor**, the **return point** has **no successor**.

An assignment to a variable is termed a definition. An occurrence of a variable
in an expression is termed a use. A **node** `p` has **two sets of properties**:
`def(p)` and `use(p)` **such that**:

- `p: a = a + b` implies `def(p) = {a}`, `use(p) = {a,b}`
- `read(a)` and `a = 7` implies `def(p) = {a}`, `use(p) = {}`

An **instruction may be replaced by the indication of the variables that occur
in the instruction**, qualified as used or defined.

We can **read our CFG as a FSA** where:

- Terminal **alphabet**: instruction **labels** `l`
- The **language of strings** on `l**` which label a path in the CFG from the
  initial state to a final state\*\*

**Not all paths accepted by the CFG automaton are feasible**, e.g. contradictory
conditionals are ignored. Thus, **answers from static analysis are conservative
approximations**.

### Liveness analysis

Consider a CFG graph and an edge `(p, q1)`. A variable `a` is **live on the edge
if it exists a path** `(p, q1, ..., qn)` with $n\geq 1$ reaching `qn` **such
that**:

1. `a` **is** in `use(qn)`
2. **None of the nodes traversed on this path defines** `a` (excluding `p` and
   `qn`)

The node `qn` may coincide with `p`.

If `p` has two successors, we say that `a` is **live on exit from** `p` if it is
**live on one or the other edge**. `a` **being live on exit** from node `p` does
**not imply that the variable is defined in** `p`.

`a` is **live on entry to node** `p` if it is **live on any of the edges
entering** the node.

We can **formalize** the property of being **live on exit** as follows:

- Consider the sets `D(a)` and `U(a)` respectively defining the sets defining
  and using `a`
- In the **language** `L(A)` **of the CFG automaton there exists a string** (a
  path) of the following form:

  ```txt
  u*vqw
  ```

  Where:

  - `u` is a path from the initial node
  - `v` is an instruction that does not define `a`
  - `q` are instructions that use `a`
  - `w` is a path to the final node

  This forms a **regular language**.

For each node `p`, we can define **two equations** that:

- **Correlate the variables live on exit with that on entry** of `p`
- **Correlate the variables live on exit** of `p` to those on **entry of the
  immediate successor** of `p`.

Let $live_{in}(p)$ and $live_{out}$ be the sets of vars live on entry and exit.
Let $suc(p)$, $pred(p)$ be the immediate successors and predecessors. For a
final node `p` we have $live_{out}(p) = \emptyset$. For any other node:

$$
\begin{aligned}
  live_{in}(p)  &= use(p) \cup (live_{out(p)} \setminus def(p)) \\
  live_{out}(p) &= \bigcup_{\forall q \in succ(p)} live_{in}(q)
\end{aligned}
$$

The **solution to the equations can be solved by iteration**, starting with the
empty sets as iteration `0`. We iterate substituting the unknowns until two
different subsequent iterations do not differ. This is the **fixed point**,
which is the **solution** to the system. To guarantee convergence, let us see if
these equations respect the **convergence criterion**:

1. **Bounded cardinality**: both sets has a finite size bounded by the number of
   variables in the subprogram
2. **Monotonicity**: an iteration never removes a variable from the previous
   approximation
3. **Halt**: if an iteration lets the previous approximation unchanged, the
   algorithm halts

Thus the algorithm converges. The **speed of convergence is dependant on the
scanning order**, the **solution** is, however, **always the same**.

Considering the following algorithm:

```txt
for each n
  in(n) = {}
  out(n) = {}

repeat
  for each n
    in'(n) = in(n)
    out' = out(n)
    in(n) = join(use(n), minus(out(n), def(n)))
    out(n) = for each q in succ(n) join(q)
until for each n in'(n) = in(n) and out'(n) = out(n)
```

Each join on the in/out sets takes linear time. The inner for loop computes a
constant number of unions per CFG node (at most $N$), since there are
$\mathcal{O}(N)$ nodes we have that the loop takes $\mathcal{O}(N^2)$. Each
iteration must add some elements to some set, but each set has a cardinality
bounded by the number of variables $N$. The sum of the cardinalities of all in
and out sets is therefore bounded by $2N^2$ . It follows that the repeat loop
can iterate at most $2N^2$ times. Hence the **worst-case run time** of the
algorithm is $\mathcal{O}(N^4)$.

To optimize the complexity we can choose between **two set data structures**:

- **Bit vector**: each element is a bit in an integer; union and intersection
  are implemented with a OR and AND respectively
  - Set operation take $N/|w|$ cycles, independently of how many values are in
    the set
  - Better for **dense sets**
- **Linked list**: the elements in a set are represented by a linked list. The
  union of two sets is realized by merging the two lists and discarding
  duplicated elements
  - The time to perform union is proportional to the size of the sets being
    united
  - Better for **sparse sets**

### Generalization

The method for computing liveness can be **generalised into a general
framework** for performing other kinds data-flow analysis:

- **For forward analysis**:

  - For each node in a basic block, define **two sets** `gen(p)` and `kill(p)`
  - **Compute iteratively** the two sets:

    ```txt
    out(p) = transfer(in(p), gen(p), kill(p))
    in(p) = for each q immediate predecessor of p: join(q)
    ```

  Where the `transfer()` function is a function that combines in some way the
  three argument sets

- **For backward analysis**:

  - For each node in a basic block, define **two sets** `gen(p)` and `kill(p)`
  - **Compute iteratively** the two sets:

    ```txt
    in(p) = tranfer(out(p), gen(p), kill(p))
    out(p) = for each q immediate successor of p: join(q)
    ```

E.g. liveness analysis is a backward analysis where:

- `gen` and `kill` are equivalent to `use` and `def`
- $transfer(\cdot) =  use(p) \cup (out(p) \setminus def(p))$

The same properties we have seen for liveness stil hold.

Using this framework we can define **different kinds of analysis** such as:

- **Useless definitions**: an instruction defining a variable which is not in
  the live-out set is useless (dead-code), and may be deleted (provided it does
  not have side-effects)
- **Elimination of common subexpressions**: if an expression is computed more
  than once, save the result into a temporary the first time is computed, and
  eliminate the subsequent computations
- **Constant folding**: if the operands of an expression are constant, do the
  computation at compile time, thus saving the code for computing the
  expressions
- **Constant propagation**: If a temporary is assigned a constant value, replace
  a subsequent use of the temporary with the constant

Usually analysis are done in a loop of three phases:

1. Statically analyze the program to gather information on program properties
2. Use the information to identify the instructions or instruction patterns that
   can be transformed
3. If a transformation improves the program, apply it
4. After the transformation, the program has changed, and static analysis may be
   partially invalidated, repeat the steps

**Since the optimization phase may change, delete, and generate IR statements,
machine-code generation phase typically comes after**.

### Reaching definitions

See FLC notes.

## Register allocation

Access to registers much faster than access to memory, thus we want to **map the
most used variables to registers**. However, the **number of live variables may
exceed available registers**, meaning we **need to save variables into memory**
to free the needed registers (e.g. for some instruction).

The **scopes** at which we can do register allocation is:

1. Complex expressions
2. Basic blocks
3. Procedure
4. Program

A **smaller allocation unit is easier to work with**, can be easily integrated
into the instruction-selection phase and can be more suitable for dynamic
compilation. **Global management of registers across procedure can improve
performance, but is much more complex**. We will look at intra-procedural
regalloc.

The **principles** we are working with are the following:

1. If **two variables are both live** in the **same program point**, they
   **cannot be stored in the same register**
2. If the **liveness intervals** of two variables are **disjoint**, the **same
   register can be used**

### Graph coloring approach

**Definition** (Liveness interference relation):

> A binary, symmetric relation between two variables a and b denoting the fact
> that the liveness intervals of a and b overlap. The interference relation can
> be depicted as a non-directed graph.

This relation can be **represented as a graph**, and **registers can be viewed
as colors**. The assignment needs to **paint nodes of the graph with colors, so
that adjacent nodes differ in color**. This is the **graph-coloring problem and
is not always solvable**, we however have heuristics that are polynomial. **To
solve the intractability, we spill (store) variables to memory and recompute
liveness until we can color the graph**.

Algorithm **outline**:

- Repeat until successful
  1. **Build**: construct the Liveness Interference Graph
     - Until the graph is empty:
       1. **Simplify**: Reduce the graph removing colorable nodes
       2. **Spill**: Select from remaining nodes a candidate for spilling
  2. **Select**: Assign registers or mark nodes as spilled
  3. Start over: modify code to manage spills

Let us look more in depth at the most important procedures:

- **Simplify**:
  1. If `G` contains a node `m` with fewer than `K` neighbours
  2. Construct the graph `G' = G \ {m}`
  3. Push `m` on `S`
  4. Repeat until fixed point
- **Spill**:
  1. If `G = {}`, all remaining nodes have `>= K` neighbours
  2. Choose a node `s` and mark it as candidate for spilling
  3. Push `s` on `S` and compute `G' = G \ {s}`
  4. Retry simplify
- **Select**:
  1. For each node `s in S`, assign a color to it
  2. If `s` does not interfere with the previous popped node, reuse the same
     color
  3. As long as `s` is not marked for spilling, it is guaranteed to be colorable
  4. If `s` is a spilling candidate, either the node can be colored or the
     potential spill is marked as an actual spill

WCET is $\mathcal{O(n^3)}$, but in average is almost quadratic (most expensive
operation is building the live interference graph).

### Linear scan

Guarantees linear time.

```txt
def LinearScan:
  active = {}
  for each live interval i, in order of increasing start point:
    ExpireOldIntervals(i)
    if length(active) = R:
      SpillAtInterval(i)
    else:
      register[i] = a register removed from the pool of free registers
      active += {i} // sorted by increasing end point

def ExpireOldIntervals:
  for each interval j in active, in order of increasing end point:
    if endpoint[j] >= startpoint [i]:
      return
    else:
      active \= {j}
      add_to_free_pool(register[j])

def SpillAtInterval:
  spill = active.tail
  if endpoint[spill] > endpoint[i]:
    register[i] = register[spill]
    location[spill] = get_new_stack_location()
    active \= {spill}
    active += {i} // sorted by increasing end point
  else:
    location[i] = get_new_stack_location()
```

Let `V` be the number of variables and `R` be the number of registers. Since
`|active| <= R`, if `R` is assumed to be smaller than `V`, linear scan is
$\mathcal{O}(V)$. In architecture with a lot of available registers, the
complexity is more $\mathcal{O}(V\times R)$.

### Register allocation with SSA

**SSA form makes it easy to perform interference analysis** due to the
**dominance property** (definitions dominate uses). **Liveness analysis should
be done before** $\phi$-function translation.

For each variable `v`, **start from each use site and walk backwards** on the
CFG, **stopping when the definition site is reached**. The algorithm processes
only the blocks where `v` is live. Thus the **running time becomes proportional
to the size of the interference graph** that it constructs.

## Optimization

In this sections we will explore some optimizations assuming a procedural
language compiled for a hypothetical superscalar processor called S-DLX.

Characteristics of the **source language**:

1. Similar to **Fortran 90**
2. We use `do all` **loops** to indicate that all iterations may be **executed
   concurrently**
3. **Arrays are stored contiguously in memory in column-major form**
4. **All arguments are passed by reference**

The optimization are not limited to by this assumptions, it's just that these
assumptions simplify the explanation.

For a compiler to apply an optimization to a program, it must do 3 things:

1. Decide a part of the program to optimize and the transformation to apply
   - Most difficult and poorly understood part
2. Verify that the transformation is acceptable
3. Transform the program
   - This will be our focus

### Correctness

**Definition** (Legal transformation):

> A transformation is legal if the **original and the transformed programs**
> produce exactly the **same output for all identical executions**.

**Definition** (Identical executions):

> Two executions are identical if they are **supplied with the same input data**
> and if every **corresponding pair of non-deterministic operations** in the two
> executions produces the **same result**.

**Definition** (Semicommutative and semiassociative):

> We call operations that are **algebraically but not computationally
> commutative** (or associative) semicommutative (or semiassociative).

We can now define when a transformation is legal:

Definition (Criterion for legal transformation):

> A transformation is legal if, **for all semantically correct program
> executions**, the **original and the transformed programs produce exactly the
> same output for identical executions**.

For languages that define a specific semantics for exceptions (i.e. IEEE
floating-point standard), **meeting the previous definition tightly constraints
the permissible transformations**.

If we **assume** that **exceptions are only generated when the program is
semantically incorrect**, a transformed program **can produce different results
when an exception occurs and still be legal**. An **alternative** correctness
criterion is to **consider equivalent all permutations of semicommutative
operations**. In practice we **check whether the numeric results differ by more
than a certain tolerance**, and if they do, force the compiler to employ the
previous definition.
