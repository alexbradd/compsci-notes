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
