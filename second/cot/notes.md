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
