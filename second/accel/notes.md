# Design of Hardware Accelerators

## Introduction to SoCs and heterogeneous SoCs

See what has been done in ACA and ES.

## Offloading computation

We have two ways of offloading computation (not mutually exclusive):

- **Offload execution**: master CPU is on hold while accelerator works
  - Mostly improves performance/energy consumption
- **Parallel execution**: all units are active and working, mostly exploits
  task-level parallelism
  - Higher power consumption and may introduce synchronization and coherence
    problems
  - Useful in case of computation to be done on multiple independent data

A hardware accelerator not only needs to accelerate a function, but also handle
**transfer of data**. We have different ways to handle it, based on our
requirements:

1. **DMA**: very useful in case we have to support a lot of data transfers,
   since we can do it without CPU intervention
2. **Private local memory**: specialized multi-bank local storage used mainly
   for buffering and temporary results
3. **Transaction-level abstraction** and **pipelining**

**Balancing communication and computation** is crucial for performance
optimization. **Optimizing microarchitecture reduces the computation latency**,
while **input and output phases** interact with the rest of the system and **can
increase latency due to congestion/bus speed**. Thus we need to **reduce the
congestion or exploit it** to optimize the execution at the system level.

Communication is the **most critical aspect affecting system performance**: it
consumes up to 50% of total on-chip power and the ever increasing number of
wires, repeaters, bus components (arbiters, bridges, decoders etc.) increase
system cost. Thus, the design flow must include communication design.

**Buses are communication lines** connecting different parties. The principal
**components** involved in communication are:

1. **Master** (Initiator): IP component that initiates a read/write data
   transfer
2. **Slave** (Target): IP component that only responds to incoming requests
3. **Arbiter**: controls access to the shared bus
   - Implements an arbitration scheme
4. **Decoder**: component that determines which party a transfer is intended for
5. **Bridge**: connects two buses

**Bus wires** are implemented as **long metal lines** on a silicon wafer and
**transmit data using electromagnetic waves**: this puts a **cap on the speed**
we can go. As application performance requirements increase, **clock frequencies
are also increasing**, meaning that the **time allowed for a signal to travel is
also decreasing**. Thus it can take **multiple cycles to send a signal** across
a chip. Moreover, **every unit attached to the bus adds parasitic capacitance**,
therefore electrical performance degrades. Moreover, since **buses are shared**,
the **bandwidth is also shared** and **arbiters add delay** proportional to the
number of masters.

Buses are, however, **very cheap** silicon-wise, **simple** to reason about and
offer **wide compatibility**, including between very different IPs.

An evolution on top of buses is the **Network-on-Chip** architecture: we
**leverage networking principles to improve inter-component intra-chip
communication**. This brings a **throughput improvement** w.r.t a standard
shared bus. A fundamental component of NoCs are **routers**: special IPs
responsible for **routing packets from different components**. NoCs can improve
performance and delays, but **require more silicon and wires** and can
**introduce delays due to suboptimal routing**. Moreover **optimizing
communication** with an accelerator **may require an ad-hoc placement** of said
accelerator.

## FPGA technology
