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
predecessor**. The $\phi$-function has as many arguments as predecessors.
