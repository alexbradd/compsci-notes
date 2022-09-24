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


