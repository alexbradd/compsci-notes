# Performance evaluation and applications

## Intro

_Performance evaluation_ is the quantitative and qualitative study of systems,
to evaluate, measure, predict and ensure target behaviors and performances.

We abstract a system as a **set of events and states that describe the temporal
evolution of some task**. The model defines:

- Which tasks are carried out
- When they are executed in
- Which way they are selected to be run
- How long they last

And many other details. These details determine the events and the evolution of
the state of the model.

The **metrics** we are going to use are:

- **Workload**: accounts for the difficulty, length and number of tasks that
  have to be performed
  - **Arrival rate** $\lambda$: the frequency at which jobs arrive at a given
    station
  - **Inter-arrival time** $a_i$: the time between two consecutive arrivals
  - **Service time** $s_i$: the time required by a job to complete its service
- **Performance indices**: measure the ability of the system to perform its task
  - **Utilization** $U$: the fraction of time the system is busy
  - **Response time** $r_i$: the time spent by the $i$-th job at a service
    center, including service and queuing time
  - **Queue length** $N(t)$: number of jobs in a service station
  - **Throughput** $X$: rate at which jobs are served and depart from the
    station

**Utilization, arrival rate and throughput are long-run measures**: they are
meaningful **only when considering a sufficiently long amount of time where the
system exhibits a similar behavior**. Sufficiently long is relative to the
application. Similar behavior is more difficult to define, and can include
different time scales and oscillations. In most of the cases it means that
workload is constant, or it repeats several times according to an identical
statistical pattern.

**Number of jobs, inter-arrival times, service time and response time are
job-dependant measures. In most cases we care only in the average measures**:

- Avg number of jobs $N$
- Avg service time $S$
- Avg response time $R$
- Avg inter-arrival time $\bar{A}$

The **workload** measures are **measured on the real system**, while
**performance indices are measured both on the real system and the model**.
Indices derived from the model should match those of the real system: this is
model validation.

Once the **model has been validated** with the considered workload, it is
**studied with varying arrival rates, service times, and other parameters** to
see their effects on the performance indices.

### Basic measures

Let us define the most basic measures based on the number of arriving jobs
($A(T)$) and the number of completed jobs exiting the system ($C(T)$) up to time
$T$:

$$
\begin{aligned}
  \lambda &= \lim_{T\to\infty} \frac{A(T)}{T} \\
  X       &= \lim_{T\to\infty} \frac{C(T)}{T} \\
\end{aligned}
$$

From the graphs of $A(t)$ and $C(T)$, or with some other probes, we can measure
the busy time $B(T)$, i.e. the time the system has not been idle during $T$. We
can then define

$$
U = \lim_{T\to\infty} \frac{B(T)}{T}
$$

Measuring the service time is not easy in practical situation since tasks may be
interrupted many time to allow multi-tasking. We can compute the average service
time in two ways:

$$
\begin{aligned}
  S &= \lim_{T\to\infty} \frac{B(T)}{C(T)} \\
  S &= \lim_{T\to\infty} \frac{\sum_{i=1}^{C(T)}s_i}{C(T)} \\
\end{aligned}
$$
