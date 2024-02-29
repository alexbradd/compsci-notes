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

## ASICs

**Logic** is **custom** and **fixed**. Since the logic is fixed and is very
**difficult to change after fabrication**, the design must be** thoroughly
tested before sending it** to the foundry. This has a very **high up-front
cost** (fixed cost or NRE (Not REcurrent) cost) and complexity. However, **after
the design is completed**, the **cost remains almost constant** since we can
fabricate full batches of them.

ASIC are **not done full-custom anymore**, but **composed of different standard
cells which are foundry dependant** (since they are optimized for a specific
capacitance/delay and other physical parameters). Cells are grouped into a
foundry-provided library that provides all information for performing accurate
simulations and analysis.

## FPGA

It is an integrated circuit that can be **configured by the user to emulate any
digital circuit** as long as there are enough resources.

FPGAs are **more expensive** than ASICs **per-transistor**, however thanks to
their configurability and reconfigurability **scale much better at the start**
thanks to the **much lower non recurrent costs**. However, **as the number of of
units increases**, FPGA cost **eventually catches up** to that of ASICs **and
surpasses it**. Thus we can choose between the two based on our market strategy:

- We have a lot of money and plan on selling billions of units? Go ASIC
  - Think Intel, AMD, NVidia
- We plan to sell a small/limited number of units (even one-off chips)? Go FPGA

The **core** is a **regular array of programmable basic logic cells**
(Configurable Logic Blocks) that can **implement combinational** as well as
**sequential logic**. These blocks are **connected through a programmable
interconnect** (switch boxes).

The **programmability is done through a "configuration memory"** (basically a
LUT) that stores the configuration data. **Each component is composed of**:

1. Its **lookup table** (implements the boolean function of the component)
2. A **flip flop** used **in case of sequential** logic
3. A **multiplexer choosing between the flip-flop** output and the **static**
   lookup table value (user configurable) used for toggling between
   combinatorial/sequential

We can see that this architecture is **very expensive in terms of power and
silicon**: even the simplest of components **requires a full truth table** (for
`n` inputs this is `2^n` entries) a **mux and a flip flop**. Moreover, having a
**lot of memory means** that the **reliability** of the system **is reduced**
since **bit-flips and other memory corruptions are always catastrophic**.

**Switch boxes** are basically composed of one **six-pass transistor for
interconnection point**, creating a **matrix of wires that are selectively
activated** based on configuration. Older switch boxes put on the programmer the
responsibility of ensuring that no shorts are present.

The **configuration is called a "bitstream"** and must include the data or all
CLBs and SBs, even unused ones. The bitstream is generated by a synthesis tool
like Vivado and then flashed onto the board.

## Design flows

We ideally would like to specify the functionality using a high level, human
readable language and have that compiled all the way down to hardware synthesis.
Moreover, as chips acquire more functionalities as said functionalities get more
complex, we want to **customize an existing architecture template with other
IPs** (**platform-based design**).

**Application and an architecture template** are **refined to meet** the given
**constraints** and then are **mapped to HW, interface and software based** on
the **estimation of performance, area and power**. This is **hardware/software
co-design**. Thus, this is an act of **balancing**:

1. The **performance** of customized **HW units**
   - Doing things in hardware is faster but costs more
2. **Programmability** of low-cost **SW components**
   - Doing things in software is slower but costs less
