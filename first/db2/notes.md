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

**When access to a resource is not granted, the transaction if put on wait until
the resource unlocks**.

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

Locking introduces the problem of deadlocks. Thus the `SERIALIzaBLE` level is
used sparingly.
