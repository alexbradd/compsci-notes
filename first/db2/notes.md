# Data bases 2

## Transaction manager

The transaction manager is one of the modules that make up a DBMS. The system
handles, as the name implies, transactions, **elementary/atomic units of work
performed by applications**. Each transaction is conceptually encapsulated by
the `begin transaction` and `end transaction` commands. Within one, one of
`commit-work` or `rollback-work` is executed to respectively commit the
transaction or abort it. Each transaction obeys the ACID properties.

### Concurrency control

Manages the simultaneous execution of transactions and avoids the insurgence of
anomalies. The goal of this controller is to achieve the maximum number of
transaction per second (TPS). Two concurrent transaction may be executed
_interleaved_ or _nested_.

We can encounter the following anomalies:

1. **Lost update**: one of the updates is overwritten by the other; It occurs
   when both transactions read the same data and then apply the update.
   Pattern: `r1 - r2 - w2 - w1`
2. **Dirty read**: one of the transactions reads data modified by a transaction
   that will abort. Pattern: `r1 - w1 - r2 - abort1 - w2`
3. **Non-repeatable read**: another transaction interferes with the data used by
   a transaction. Pattern: `r1 - r2 - w2 - r1`
4. **Phantom update**: a constraint is broken because another transaction
   interfered with the data. Pattern: `r1 - r2 - w2 - r1`
5. **Phantom insert**: one transaction inserts new data that may change the
   values used in a different transaction. Pattern: `r1 - w2(new) - r1`

Concurrency theory builds upon a model of transaction and concurrency control
that helps understanding real systems. Commercial systems exploit implementation
level mechanisms which help achieve some of the desirable properties postulated
by theory.

#### Scheduler

An operation is a read/write of a specific datum by a specific transaction. A
schedule is sequence of operations performed by concurrent transactions that
respects the order of operations of each transaction. For a 2 transactions we
have 6 different orderings: 2 serial, 2 interleaved and 2 nested.

Our goal is to reject schedules that cause anomalies. A scheduler is the
component that accepts or rejects the operations requested by transactions. The
only schedule that does not cause anomalies it the serial one: one in which the
action of each transaction occur continuously. If we have an interleaved/nested
one, we need to check that it causes the same modifications as a serial one: **a
serializable schedule is a schedule that leaves the database in the same state
as some serial schedule**.

At first we will consider with the following assumptions:

1. The transactions always succeeds (no aborts)
2. The transactions are observed a-posteriori

The cardinality of the set of serial schedules of $n$ transactions of $k_i$ is
$N_s = n!$, however the cardinality of the total number of possible schedules
is $N_d = \frac{(\sum_i^n k_i)!}{\prod_i^n (k_i)!}$. We have that $N_s \ll
N_d$.

#### View serializability

1. **$r_i(x)$ reads from $w_j(x)$ in a schedule when $w_j(x)$ precedes
   $r_i(x)$**
2. **$w_i(x) is a final write if it is the last write on $x$ that occurs in a
   schedule**

Two schedules are **view-equivalent if they have the same operations, the same
reads-from relationships, the same final writes**. A schedule is
**view-serializable if it is view-equivalent to serial one on the same
transactions**. The class of view-serializable schedules is named VSR.

Determining the view equivalence of a schedule is done in polynomial time.
However we need to try all possible serial schedules, which are $n!$, thus VSR
is a **NP-complete problem**. 

#### Conflict serializability

To have a faster algorithm, we need to restrict VSR. Two definitions:

1. **Two operations $o_i$ and $o_j$ ($i \neq j$) are in conflict if they address
   the same resource and at least one of them is a write**
2. Two schedules are **conflict equivalent ($\approx_C$) if both contain the
   same operations and in all the conflicting pairs the transactions occur in the
   same order**

A schedule is **conflict-serializable if and only if it is conflict-equivalent
to a serial schedule of the same transactions**. The class of
conflict-serializable schedules is named CSR. We have that $CSR \subset VSR$, so
then we have $CSR \implies VSR$.

We can test CSR with the **conflict graph**:

- One **node for each transition $T_i$**
- One **arc from $T_i$ to $T_j$ if there exists at least one conflict between an
  operation $o_i$ of $T_i$ and an operation $o_j$ of $T_j$ such that $o_i$
  precedes $o_j$**.

**A schedule is in CSR if and only if its conflict graph is acyclic**.

#### Concurrency control in practice

CSR can be useful only if we know the conflict graph in advance. However this
cannot happen irl. A scheduler must be capable of working online. We need to
remove the "a posteriori" hypothesis.

Until now we have been working with an "a posteriori" view of the execution.
When working with online schedulers, we need to consider **arrival sequences,
i.e sequences of operations requests emitted by transactions**. We will abuse
notation and refer to arrival sequences in the same way as "a posteriori" views.

We have two approaches to online scheduling:

1. **Pessimistic, based on locks**
2. **Optimistic, based on timestamps**

##### Locking

The most common method. A transaction is well formed if:

- reads are preceded with a `r_lock` (**shared lock**) and followed by
  **unlock**
- writes are preceded with a `w_lock` (**exclusive lock**) and followed by
  **unlock**

Transactions that first read and then write may acquire a `w_lock` when reading
or acquire a `r_lock` first and the upgrade it to a `w_lock` (_lock
escalation_).

An object can be in 3 different states: **free, r-locked, w-locked**.

The lock manager receives the primitives from the transactions and grants access
to the resources according to the conflict table:

| Request  | Free           | r-locked         | w-locked       |
|:--------:|:--------------:|:----------------:|:--------------:|
| `r_lock` | OK -> r-locked | OK -> r-locked++ | KO -> w-locked |
| `w_lock` | OK -> w-locked | NO -> r_locked   | KO -> w-locked |
| `unlock` | ERROR          | OK -> lock--     | OK -> free     |

Each r-lock has a counter `n` that counts the number of concurrent readers.

**When access to a resource is not granted, the transaction is put in a waiting
queue until the resource unlocks**.

Locks are implemented with **lock tables**, which are basically **hash tables**
indexed by the hash of the resource locked. **Each locked item has a linked list
associated with it**. Every node in the list represents the transaction which
requested the lock, the lock mode and the current status (granted/waiting).

**Respecting locks, however, is not enough to grant serializability**. To achieve
serializability, we **need to ensure the two-phase rule: a transaction needs to
first acquire all the needed locks and then it can start releasing them**. The
schedules generated by this methods are in the **2PL** set and we have that
$2PL \subset CSR \subset VSR$.

2PL can deal with most anomalies: non-repeatable read, lost update, phantom
update, phantom insert (needs the introduction of **predicate locks**, i.e locks
on all data that matches a predicate). We still have problems with dirty reads
and aborts. This is because we are still considering commit-projection as an
hypothesis.

To remove the commit-projection hypothesis we need to add a constraint to 2PL,
making it **strict 2PL: locks are held until commit/rollback**.

In commercial systems, different isolation levels are allowed. In SQL99 we have:

1. `READ UNCOMMITTED`: no locks, every anomaly
2. `READ COMMITTED`: it adds read locks, however without 2PL (prevents dirty
   reads)
3. `REPEATABLE READ`: 2PL for reads (prevents dirty reads, non-repeatable reads
   and phantom updates)
4. `SERIALIZABLE`: avoids all anomalies (2PL with predicate locks)

Serializable transactions don't execute serially! The requirement is that the
end result should be the same as if they executed serially. Locking introduces 
synchronization problems:

1. **Deadlocks**: two or more transactions in endless mutual wait
2. **Starvation**: a single transaction in endless wait

Thus the `SERIALIZABLE` level is used sparingly.

##### Deadlocks

Occurs because concurrent transactions hold and in turn request resources held
by other transactions. To analyze deadlocks we can draw:

1. **Lock graphs**: specifies who holds what (nodes are resources or transactions
   and arcs are lock assignments/requests)
2. **Wait-for graph**: a simplification of lock graphs in which nodes are
   transactions and arcs are _waits for_ relationships.

A deadlock is represented by a cycle in the wait-for graph of transactions.

We have various ways of resolving deadlocks:

1. **Timeout**: we kill transactions after a long wait

   - We cannot determine if a transaction is simply waiting for along time or is
     blocked
   - Choosing a proper timeout is difficult: too long is useless in case of
     deadlocks, too short leads to un-required kills. Timeout is usually
     variable and system decided.
2. **Deadlock prevention**: transactions killed when they could be in a
   deadlock. Preventions worked using heuristics
3. **Deadlock detection**: Transactions killed when they are in a deadlock.
   Detection works by analyzing the wait-for graph

###### Deadlock prevention

We have two methods:

1. **Resource-based prevention**: restricts lock requests
   - Transactions requests resources all at once and only once
   - Resources are globally sorted and must be requested _in global order_
   - It is not easy for transactions to anticipate all requests
2. **Transaction-based prevention**: restrictions based on the transaction's ID
   - We assign IDs sequentially, making it possible to calculate a transaction's
     age
   - We can prevent older transactions waiting for younger ones to end:
     - **Non-preemptive (wait-die)**: if requesting transaction (`RT`) `T1` is
       older than conflicting transaction (`CT`) `T2`, then `T1` waits,
       otherwise it dies.
     - **Preemptive (wound-wait)**: if `RT` `T1` is older thhan `CT` `T2`, then
       `T1` is wounded, otherwise `T1` waits.
   - We can preemptively or non-preemptively choose the transaction to kill

###### Deadlock detection

Requires  an algorithm to detect cycles in the wait-for graph. It must work with
distributed resources. We will use **Obermack's algorithm**.

**Assumptions**:

1. Transactions execute on a single main node
2. Transactions may be decomposed in _sub-transactions_ running on other nodes
3. When a transaction spawns a sub-transaction, it suspends work until the
   latter completes (Synchronicity)
4. We have two wait-for relationships:
   - $T_i$ waits for $T_j$ on the same node because $T_i$ needs data locked by
     $T_j$,
   - A sub transaction of $T_1$ waits for another sub-transaction of $T_i$
     running on a different node

**Obermarck's algorithm works locally** and needs to exchange minimal amount of data
with other nodes. It does not need to keep the whole global view. **Each node has
a projection of the global dependencies**. Nodes exchange information and update
their local view. **Communication is optimized to avoid that multiple nodes detect
the same deadlock**.

A node $A$ sends its local info to $B$ only if: $A$ contains a transaction $T_1$
that is waited for from another remote transaction and waits for a transaction
$T_j$ active on $B$ and $i > j$. **Mnemonically: $A$ sends info if a distributed
transaction listed at $A$ waits for a distributed transaction listed at $B$ with
smaller index**.

Periodically:

1. **Get the graph information from "previous nodes"**
2. **Update the local graph by merging the received information**
3. **Check the existence of cycles** among transactions denoting potential
   deadlocks. **If one is found, select one of the transactions and kill it**.
4. **Send updated graph info to the "next nodes"**

There are **some arbitrary choices in the algorithm**: sending messages if $i < j$ or
$i > j$, sending messages to the following or preceding node. **Therefore there
are 4 variants of the algorithm. They are all equivalent**.

##### Limiting deadlocks

**The deadlock probability is much less than that of a conflict**. Considering a
file with $n$ records and two transactions doing two accesses to their records
the conflict is $\mathcal{O}(1/n)$ while deadlocks are $\mathcal{O}(1/n^2)$. 

**The probability of a deadlock is linear in the number of transactions, but
quadratic in record size, thus shorter transactions are healthier**.

We have techniques that can reduce the frequency of deadlocks.

###### Update locks

The **most frequent type** of deadlock occurs when **2 concurrent transactions start
by reading the same resource and then deciding to write and try to upgrade the
locks. Update locks are another type of lock that grants a read and a
successive write**. They are very easy to implement and mitigate the most common
collision: `r1(x) - r2(x) - w1(x) - w2(x)`.

| Request   | Free | Shared | Update | Exclusive |
|:---------:|:----:|:------:|:------:|:---------:|
| Shared    | OK   | OK     | OK     | KO        |
| Update    | OK   | OK     | KO     | KO        |
| Exclusive | OK   | KO     | KO     | KO        |

Update locks are requested by using `SELECT FOR UPDATE` SQL statement.

##### Hierarchical locking

Hierarchical locking makes **locks have more granularity** than locking or not the
entire table. The objective is **locking as less as possible** to increase
concurrency. A possible hierarchy can be: table, page, tuple, value.

To implement hierarchical locking we need to **introduce new locks that express
the intention of locking at higher/lower granularity**:

1. **ISL**: intention of locking a subelement in shared mode.
2. **IXL**: intention of locking a subelement in exclusive mode.
3. **SIXL**: lock the current element in shared mode with intention of locking
   a subelement in exclusive mode (union of SL and IXL).

With new locks, we have a new granting table:

| Request | Free | ISL | IXL | SL  | SIXL | XL  |
|:-------:|:----:|:---:|:---:|:---:|:----:|:---:|
| ISL     | OK   | OK  | OK  | OK  | OK   | KO  |
| IXL     | OK   | OK  | OK  | KO  | KO   | KO  |
| SL      | OK   | OK  | KO  | OK  | KO   | KO  |
| SIXL    | OK   | OK  | KO  | KO  | KO   | KO  |
| XL      | OK   | KO  | KO  | KO  | KO   | KO  |

Locks are **requested starting from the root and going down the hierarchy. Locks
are released starting from the locked resource going up the hierarchy**.

- To **request an SL or ISL** locks on a non-root element, a transaction **must
  hold an equally or more restrictive lock (ISL or IXL) on its parent**. 
- To **request an IXL, XL or SIXL** lock on a non-root element, a transaction **must
  hold an equally or more restrictive lock (SIXL or IXL) on its parent**.

##### Timestamps

Concurrency control based on timestamps is a method **complementary to 2PL** that,
instead of assuming that conflicts will occur, **assumes that conflicts are rare**.
This means we **first run the transaction and then calidate the operation before
commit or before each operation**.

**A timestamp is an identifier that defines a total ordering of events in a
system**. Each transaction has a timestamp representing the time at which it
begun. **A schedule is accepted only if it reflects the serial ordering of the
transactions induced by their timestamps**.

The scheduler has **two counters $RTM(x)$ and $WTM(x)$ for each object**:

1. $RTM(x)$: the timestamp of the **transaction with the highest one** that has
   **read** $x$
2. $WTM(x)$: the timestamp of the **transaction with the highest one** that has
   **written** $x$

The **scheduler receives requests tagged with the timestamp of the requesting
transaction**:

1. $r_{ts}(x)$
   - Is **rejected** if $ts < WTM(x)$ and the transaction is **killed**
   - **Otherwise access is granted** and $RTM(x) = max(RTM(x), ts)$
2. $w_{ts}(x)$
   - Is **rejected** if $ts < RTM(x) \lor ts < WTM(x)$ and the transaction is **killed**
   - **Otherwise access is granted** and $WTM(x) = ts$

2PL and TS are incompatible: we can find schedules that are 2PL that are not TS
and viceversa. However we have that $TS \implies CSR$.

Basic **TS-based control works with commit-projection**. If aborts occur, the
problem of dirty reads can still occur. **To cope with it** a variant, similar to
long duration locks, must be used: **a transaction that issues $r_{ts}(x)$such
that $ts > WTM(x)$ has its operation delayed until the last transaction commits
or aborts**.

##### TS with Thomas' Rule

Thomas' rule can be used to reduce the number of transactions killed in TS. It
is a variation of basic TS.

1. $r_{ts}(x)$
   - Is rejected if $ts < WTMx$ and the transaction is killed
   - Otherwise access is granted and $RTMx = max(RTM(x), ts)$
2. $w_{ts}(x)$
   - Is **rejected** if $ts < RTM(x)$ and the transaction is **killed**
   - **Else**, if $ts < WTM(x)$ our write is obsolete and can be **skipped**
   - **Otherwise access is granted** and $WTM(x) = ts$

The rationale behind the rule is that of skipping a write on an object that has
already been written by a younger transaction without any killing.

**This rule extends TS into a new set (TS') that is not directly contained in
CSR nor in VSR**.

##### Multiversion concurrency control

A variation on TS is that **reads are always accepted and writes simply generate
new versions and reads access only the right version**. Once no old versions are
needed, they are discarded. **This means that there is a unique global $RTM$ and
multiple $WTM_i$ for a single resource**.

1. $r_{ts}(x)$ **always succeeds**. A copy $x_k$ is selected for reading such that:
   - If $ts \geq WTM_N(X)$ then $k=N$
   - Else tajke $k$ such that $WTM_k(x) \leq ts < WTM_{k+1}(x)$
2. $w_{ts}(x)$
   - Is **rejected** if $ts < RTM(x)$
   - **Otherwise a new version is created** for timestamp $ts$. The number $N$ of
     active versions is incremented. The **various versions are kept sorted from
     oldest to youngest**.

Like TS', the set of schedules serializable with **TS(multi) is not directly
related to VSR nor CSR**.

##### Snapshot isolation

Snapshot isolation is new isolation level that **works similarly to TS(multi): no
RTM is used, only WTMs**. Every transaction **reads the version consistent with its
timestamp and defers writes to the end**. If the **scheduler detects that the
writes of a transaction conflict** with writes of other concurrent transactions
after the snapshot timestamp, **it aborts**.

Snapshot isolation **does not guarantee serializability**. For example the following
transactions

```sql
update Balls set Color="White" where Color="Black"; -- T1
update Balls set Color="Black" where Color="White"; -- T2
```

Serial execution will produce either balls that are all white or black. An
execution under SI in which the two transactions start from the same snapshot
will just swap colors. This anomaly is called **write skew**.

##### Timestamps in distributed systems

A timestamp is an indication of the current time. However, no global time
exists. We need some form of **synchronization**.

We assume that we have a system's function that gives out timestamps formatted
as **`eventId.nodeId` where `eventId` is unique for each node**. We synchronize
different nodes by sending/receiving messages and **imposing that for a given
message `send()` precedes `receive()`**. This means that **if for some reason I
receive a message from the future, I increase my timestamp such that the `receive`
is greater that the corresponding `send` (Lamport method)**.

### Reliability control

Reliability control **ensures that transactions are atomic and durable**. The
reliability manager **realizes `commit`s and `abort`s, orchestrates IO to pages
and handles recovery after failures**.

#### Durability and stable memory

Durability implies a **memory whose content lasts forever**. This means that we
cannot use conventional storage as:

- **Main memory** is not stable since it is **not persistent**.
- **Mass memory** is not stable since **it is persistent, but can be damaged**.

Of course this is an **abstraction**. In reality **stability is achieved by
replication** (online (RAID) or offline (backups)) and **write protocols**.

##### Buffers

Stable memory is slow. We **can speed things up** by using:

- **Buffers to cache data**
- **Defer writing onto secondary storage**

In main memory a DBMS stores the **buffered content, organized in pages, plus
additional metadata: how many transactions are using the page and a flag
indicating if the page has been modified and must be aligned to secondary
memory**.

The **primitives** that buffer management works with are:

1. `fix`: **loads a page into the buffer**, returns a reference to the page and
   increments the usage count
2. `unfix`: the opposite of `fix`; **deallocates** and decrements the usage count
3. `force`: **flushes synchronously** a page from buffer to disk
4. `setDirty`: **flips the dirty bit** of a page
5. `flush`: **flushes asynchronously pages** from buffer to disk **when a page is no
   longer needed**

The **`fix` primitive follows this algorithm**:

1. **Search** for the page in the buffer, **if present increment** the usage counter and
   return a reference
2. **Select a free page in the buffer** (FIFO or LRU), if present return reference
and increment usage counter. **If the dirty bit is set, flush the previous
contents of the page to disk**.
   - **If no page is found**, we select a page to deallocate by one of these two
     policies:

     1. **Steal**: grab a victim page from an active transaction and flush it to
        disk.
     2. **No steal**: put the transaction in a waiting list until a page frees.
     
**Other** buffer management **policies** include:

1. **Force**: pages are always transferred at commit
2. **No force**: transfer can be delayed by the buffer manager
3. **Pre-fetching**: anticipate loading of pages that are likely to be read
4. **Pre-flushing**: anticipate writing of de-allocated pages

#### Failure handling

A transaction is an atomic transformation from an initial state into a final
state. We have **three possible outcomes**:

1. **Commit**: yee
2. Rollback or other faults before commit: we have to **undo** the transaction
3. If we encounter a fault after the transaction we may have to **redo** it

In **case of faults**, we can have two behaviours:

- If failure occurs **between commit and buffer flush**, to ensure durability the
  reliability manager has to **redo (roll-forward) all the updates**
- If a transaction **had not committed at failure time**, the reliability manager
  has to **undo any effect of that transaction to preserve atomicity**

A **transaction log** keeps track of the various transaction happening in the DBMS.
It is a **sequential file made of records** describing the actions carried out by
the various transactions. The log records on **stable memory** in the form of **state
transitions** the actions carried out by the various transactions:

- `UPDATE(U)`: both before and after state are stored
- `INSERT`: only after state is saved
- `DELETE`: only before state is saved
 
We can use the log to apply the following transformations:

1. `UNDO T`: sets the state to the before state
2. `REDO T`: sets the state to the after state

Both **operations are idempotent**. This is necessary since the manager could
undo/redo operations twice.

The log contains **different type of records** depending on the type of operation it
records:

- Transactional commands: `B(T), C(T), A(T)`
- `UPDATE`, `INSERT` and `DELETE`: `U(T, O, BS, AS)`, `I(T,O,AS)`, `D(T,O,BS)`
- Recovery actions: `DUMP`, `CKPT(T1,..., TN)`

Where `Ti` is the transaction identifier, `O` is the object identifier and
`BS`/`AS` are respectively the before and after state.

The **log management rules** ensure that transactions implement **write operations in
a reliable way**:

- A **commit record** is always **written synchronously**
- (**Write-ahead log**) The before part of the record must be written before
  carrying out the action.
- (**Commit rule**) The after state part of the record must be written in the log
  before carrying out the commit

Since **database writes are async**, different implementations are possible with
different impacts on recovery.

- If we **write** onto the database **before commit**, a **`REDO` is not necessary** since
  the state of the database reflects that of the log.
- If we **write** onto the database **after commit**, the **`UNDO` is not necessary** and it
  **doesn't require writing the before-states** of objects on the db in order to
  **abort**.
- If we **write** onto the database **arbitrarily**, we can **better optimize buffer
  management** however in the general case **we need both `REDO` and `UNDO`**

We have **different types of failure** depending on the type of memory it fails

1. **Soft failure**: we lose the content of the **main memory**.
   - Requires a **warm restart**. We use the log to replay transactions
2. **Hard failure**: we lose part of the **secondary memory**.
   - Requires a **cold restart**. We use a dump to restore the database and the log
     to replay transactions.
3. **Disaster**: we lose **stable memory**. Not discussed.

##### Checkpoints

Periodically, the reliability manager identifies **consistent time points**:

- All **transactions that committed are flushed to disk**
- All **active transaction are recorded in the log**

The aim is to **record which transactions are still active** at a given point in
time.

We have different methods for implementing a checkpoint. A general one is as
follows:

- Acceptance of **commit/abort is suspended**
- All **dirty pages** modified by committed transactions are **`force`d to disk**
- The **identifiers of the transactions still in progress are recorded** in the
  `CKPT` record in the log. **While this record is being made no transaction can
  start**.

##### Dumps

Dumps are simpler than checkpoints, and are a **complete backup copy of the
database**. The **availability** of that copy is **recorded** in the log. The contents of
the dump are stored in stable memory.

##### Warm restart

It is a warm restart and consists in a loss of memory buffer pages. It requires
replaying transactional operations and resolving eventual problematic
situations. Log records are **read starting from the last checkpoint** and
**transactions are divided into two sets**:

1. `UNDO` set: transactions to be undone. This set consists of **transactions that
   were active at checkpoints** plus those that have been **started but not
   finished**.
2. `REDO` set: transactions to be redone. This set consists of **transactions that
   have been committed**.

The algorithm is as follows:

1. Starting from `HEAD` **find the last checkpoint**
2. **Construct the two sets** reading from checkpoint to `HEAD`
3. **Return to the first operation of the oldest active transaction while
   `UNDO`ing**
4. **Execute `REDO`** actions until the top of log.

##### Cold restart

It is a loss of secondary memory devices. Data needs to be **restored starting
from the last dump**. The **operations recorded** onto the log until failure are
**executed**. Then a **warm restart is executed**.

## Triggers

The fundamentals have been already discussed in the DB1 course.

A trigger can have 2 **execution modes**:

1. **Before**: the action of the trigger is executed before the **database 
   change** (if the condition holds). This type of **triggers cannot update the
   database directly, but can affect the transition variables in row-level
   granularity**.
2. **After**: the action of the trigger is **executed after the modification** of the
   database.

We have also two different **granularity modes**:

1. **Row-level** (`for each row`): The trigger is considered and possibly
   executed **once for each tuple affected by the activating statement**.
2. **Statement-level** (`for each statement`): The trigger is considered and
   possibly executed **once for each activating statement, independently of the
   number of affected tuples** in the target table.

**Special variables** denoting the before and after state of the modification are
**made available in trigger definition**:

- For `for each row` trigger we have `old` and `new` representing the tuple
  values respectively before and after modification
- For `for each statement` we have `old table` and `new table` working similarly
  as seen with row-level granularity

Variables `old` and `old table` are undefined for triggers activated by
`INSERT`. Dually, `new` and `new table` are unavailable for `DELETE`.

In SQL99, if multiple events are associated with the same event, an **execution
sequence is prescribed**:

1. `BEFORE` statement level triggers
2. `BEFORE` row level triggers
3. Modification is applied and integrity is checked
4. `AFTER` row level triggers
5. `AFTER` statement level triggers

If there are **several triggers in the same category**, the execution order is
**system dependant** (based on definition time or alphabetical order).

### Cascade and recursive cascading

The action of a trigger can cause another trigger to fire. We say that we are:

1. **Cascading:** when the action of **`T1` triggers `T2`**
2. **Recursive cascading**: when a **statement `S` on table `T` start a cascade of
   triggers that generates the same event `S`** on `T`

To guarantee the proper functionality of our database, we need to enforce some
rules.

#### Termination

**Termination**: for **any initial state** and **any sequence of modification**, a **final
state is always produced**.

The simplest check exploits the **triggering graph**:

- A node $i$ for each trigger
- An arc from a node to another if the execution of the trigger associated with
  the first node may activate the second one 

The graph is build with a simple syntactic analysis. If the graph is **acyclic**,
the system is **guaranteed to terminate**. If a **cycle exists**, **triggers may not
terminate (acyclicity is sufficient for termination)**.

Most systems set a maximum of 64 cascades.

### Materialized views

When a view is mentioned in a `SELECT` query, the processor rewrites the query
language using the view definition, so that the actually executed query only
uses the base tables. When **queries to a view are more frequent than the updates
on the base tables that change the view content**, then **view materialization** can
be used. Materialization consists in **storing the results of the query that
defines the view in separate table**.

Some DBMSs support the `CREATE MATERIALIZED VIEW` **command** that does this
automatically. **As an alternative** we can implement **the materialization by means
of triggers**.

### Design principles

- Use trigger to guarantee that when a specific operation is performed, related
  actions are performed.
- Do not use triggers to duplicate features of the DBMS.
- Keep triggers small.
- Use triggers only for global, centralized operations.
- Avoid recursive triggers, unless absolutely necessary.
- Use them with parsimony, as they are executed every user interaction.

