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

## Basic measures and relations

### From the basics to the utilization law

Let us define the most basic measures based on the **number of arriving jobs**
($A(T)$) and the **number of completed jobs** exiting the system ($C(T)$) up to
time $T$:

$$
\begin{aligned}
  \lambda &= \lim_{T\to\infty} \frac{A(T)}{T} \\
  X       &= \lim_{T\to\infty} \frac{C(T)}{T} \\
\end{aligned}
$$

From the graphs of $A(t)$ and $C(T)$, or with some other probes, we can measure
the **busy time** $B(T)$, i.e. the time the system has not been idle during $T$.
We can then define:

$$
U = \lim_{T\to\infty} \frac{B(T)}{T}
$$

Measuring the **service time is not easy in practical situation** since tasks
may be interrupted many time to allow multi-tasking. We can compute the
**average service time** in two ways:

$$
\begin{aligned}
  S &= \lim_{T\to\infty} \frac{B(T)}{C(T)} \\
  S &= \lim_{T\to\infty} \frac{\sum_{i=1}^{C(T)}s_i}{C(T)} \\
\end{aligned}
$$

From these quantities we can express the **Utilization law**:

$$
U = X \cdot S
$$

The proof of the law comes directly from the definitions of the quantities
involved.

### Response times and Little's law

We can measure the **response time** $r_i$ for each job $i$, as **the time
passed from the moment it entered the system, to the one in which it leaved**.
However this might not be straightforward, since sometimes a job that entered
earlier, may leave after a job that arrived later. Computing the **response time
is always easier than the service time**, since **it is always the difference of
two numbers**. We can compute the **average response time** as:

$$
R = \lim_{T\to\infty} \frac{\sum_{i=1}^{C(T)}r_i}{C(T)}
$$

**Another way** of computing the response time is to first compute the area
difference between $A(T)$ and $C(T)$ and then average it:

$$
R = \lim_{T\to\infty} \frac{\int_0^T(A(T)-C(T)) dt}{C(T)}
$$

Let us call the **integral up to $T$ as** $W(T)$. The two ways of calculating
$R$ **allow us to calculate** $W(T)$ **as either the integral or**
$\sum_{i=1}^{C(T)} r_i$.

We can compute the **average number of jobs** as:

$$
N = \lim_{T\to\infty} \frac{W(T)}{T}
$$

From all these definitions, **Little's law** comes natural:

$$
N = X\cdot R
$$

Like for the utilization law, the proof comes from the definition of the
quantities involved.

### Computing all the previous quantities with arrival/completion times

Let us call $A^{-1}(i)$ the **time of the $i$-th arrival**, while $C^{-1}(i)$
the **time of the $i$-th departure**. $A^{-1}(i)$ and $C^{-1}(i)$ can be seen as
**the inverse of $A(T)$ and $C(T)$** respectively. Let us also **define the
inter-arrival time** $a_i$ and the time between the arrivals of jobs $i$ and
$i+1$. The **inter-arrival times can be easily computed from the previously
defined functions**:

$$
a_i = A^{-1}(i + 1) - A^{-1}(i)
$$

If we have the **inter-arrival times**, we can **get back to $A(T)$**. Let us
define the **indicator function $I$** that returns 1 if a proposition is true
and false otherwise, **we have**:

$$
\begin{aligned}
  A(T) = \sum_{K=1}^{\infty} I(\sum_{i=0}^{K-1} a_i \leq T) \\
  A^{-1}(T) = \sum_{k=0}^{i-1} a_k
\end{aligned}
$$

If we know that **jobs are served on at a time, in FIFO order, without being
interrupted**, we can estimate the **response time** of job $i$ as:

$$
r_i = C^{-1}(i) - A^{-1}(i)
$$

Under the **same assumptions**, we can **determine $C(T)$** from $A(T)$ and
$r_i$:

$$
C(T) = \sum_K I(C^{-1}(k) \leq T) = \sum_K I(A^{-1}(K) + r_K \leq T)
$$

Note that the above definition of $C^{-1}(i)$ **works only if the system starts
empty**. To calculate $C^{-1}(i)$ **from a non-idle state we can use the
following**:

$$
\begin{aligned}
  C^{-1}(i) &= \max\{A^{-1}(i), C^{-1}(i-1)\} + s_i \\
  s_i &= C^{-1}(i) - \max\{A^{-1}(i), C^{-1}(i-1)\}
\end{aligned}
$$

If we **set the time $T$ starting and ending at the instant just before a new
arrival at an empty system** we have that **the following hold**:

$$
\begin{aligned}
  A(T) &= C(T) \\
  \sum_{i=1}^{A(T)} a_i &= T \\
  \sum_{i=1}^{C(T)} s_i &= B(T)
\end{aligned}
$$

### Inter-arrival time

The **average inter-arrival time** can be computed as:

$$
\bar{A} = \lim_{T\to\infty} \frac{\sum_{i=1}^{A(T)} a_i}{A(T)}
$$

Since $T = \sum_{i=1}^{A(T)} a_i$, the arrival rate can be defined as:

$$
\lambda = \lim_{T\to\infty} \frac{A(T)}{T} = \ldots = \frac{1}{\bar{A}}
$$

### Stability condition

**If the system is stable**, i.e. it is able to serve all its jobs, there will
**always exist a point in time $T$ where $C(T) = A(T)$, thus throughput and
arrival rate are equal**.

$$
\lambda = X
$$

**If the system is unstable**, $A(T)$ and $C(T)$ will **diverge** and, after a
given point in time, the **system will never return empty again**. In this case
**we have**:

$$
\lambda > X
$$

Since **$B(T) \leq T$ by construction, then from the definition of $U$ it
follows that $U \leq 1$**. Although there exists special cases in which the
system is stable with $U = 1$, these are extremely rare. **In most cases,
$B(T) = T$ means that the system is unstable**.

The above relation **allows to define a relation between the arrival rate and
the average service time**:

$$
\begin{aligned}
  XS = \lambda S \leq 1 \\
  \lambda &\leq \frac{1}{S} \\
  S &\leq \frac{1}{\lambda} = \bar{A}
\end{aligned}
$$

### Distributions

If we have the **response times of the single jobs** $r_i$, we can **approximate
its distribution**, estimating the probability that the response time is less
than a threshold $\tau$.

$$
\begin{aligned}
  p(R \leq\tau) &= \frac{\sum_{i=1}^C(T) I(r_i < \tau)}{C} \\
  p(\Psi(R)) &= \frac{\sum_{i=1}^C(T) I(\Psi(r_i))}{C}
    \quad\text{for a general predicate }\Psi
\end{aligned}
$$

The **same formula can be applied also to the service times** $s_i$ and the
**inter-arrival times** $a_i$.

At a given point in time $t$ between two instants $t_i$ and $t_{i+1}$, **the
number of jobs in the system $n(t)$ is**:

$$
\begin{aligned}
  n(t) &= A(t) - C(t) \\
  n(t) &= A(t) - C(t) + n_0 \quad\text{if system was not empty at } t_0
\end{aligned}
$$

We can then **compute $Y_m$ as the fraction of time the system has $m$ jobs**:

$$
  Y_m = \in_0^T I(n(t) = m)dt
$$

We can then **approximate the probability of having $n$ jobs in the system**:

$$
  p(N = m) = \frac{Y_m}{T}
$$

Also in this case, the **technique can be extended to compute the probability that
a given predicate $\Psi(N)$ on the number of jobs is true**:

$$
  p(\Psi(N)) = \frac{Y_{\Psi(N)}}{T}
$$

Using $Y_m$ we can **derive the additional formulas**:

$$
\begin{aligned}
  B &= \sum_{m=1} Y_m = T - Y_0 \\
  W &= \sum_{m=1} m\cdot Y_m \\
  N &= \sum_{m=1} m\cdot p(N = m)
\end{aligned}
$$
