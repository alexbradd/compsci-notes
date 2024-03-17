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

## Open challenges

1. System-level **optimization**: understand how to **generate** and
   **optimize** an **efficient SoC architecture** also given the technology
   constraints and the synthesis process
2. **Programmability**: understand the interactions between hardware and
   software, and how to optimally control the component execution
   - Divided into **2 orthogonal concerns: component generation and system
     integration**
   - Our components need to have the following **properties**:
     - **Modularity**: possibility of creating an SoC as a collection of
       components
     - **Flexibility**: possibility of adapting one component to changes in the
       behavior of the others
     - **Scalability**: possibility of creating larger SoCs without significant
       performance degradations
     - **Reusability**: possibility of reusing pre-existing components
3. **Reliability/Fault tolerance**: understand how to **protect** the system
   execution **against random faults**
   - No two transistors are equal, we can have slower or faster ones, due to
     process variations or degradation (due to aging)
   - Transistors can come out broken
   - Input can also be corrupted/garbage
4. **Testability**: Design needs to be testable to ensure proper behaviour
   - Needs to be **accounted for during design since components** (depending on
     application) **need to be reliable in all conditions**
   - Needs to be **accounted for during the design phase since it requires
     additional resources** (e.g. JTAG)
5. Hardware **security**: understand how to protect the IP but also the data
   within the SoC itself
   - **Increasing complexity demands design & reuse approaches**
   - **Possibility of different attacks at different levels**:
     - Supply-chain attacks
     - Hardware trojan horses (HTH)
     - Microarchitectural side-channel attacks
   - IPs can be stolen/cloned
6. Input language for system verification:
   - Verilog/VHDL or HLS?
   - **Synthesis is very dependent on how the code is written**
7. **Coprocessor coupling**: two main models
   - **Tightly-Coupled Accelerator** (TCA) shares key resources with the CPU
     (registers, MMU, L1 cache etc...)
   - **Loosely-Coupled Accelerator** (LCA) is outside the CPU and uses an
     integrated DMA controller to transfer data between their memory and the
     system memory
8. **Memory**: which type and how much memory will we use?
   - Registers: many ports at the cost of more area, good for small to medium
     structures
   - IP blocks: area efficient provided by technology providers, good for medium
     to large arrays; limited ports
9. **Data footprint gap**: the data the algorithms process is becoming much more
   than what is needed for the chip itself to run
10. **Increasing manufacturing costs**: chips are becoming bigger and scaling is
    expensive
    - Smaller transistors require newer lithography instruments with larger
      error margins
    - **Reduce costs by reusing pre-designed components** (programmability
      suffers)
    - **Reduce costs by outsourcing fabrication** (security suffers)

## Latency insensitive design

A **system** with multiple components **works correctly as far as it is running
with a clock period that is the maximum of the clock periods of the components**
(reg to reg). What happens if the **wire delay is greater than the component
delay**?

In a deep **sub-micron** process technology (< 90nm), **process variability is a
serious concern**. Technology improvements are on the transistors but not on the
wires at the same level. This means that **long wires will play significant role
in logic synthesis optimization**. We need a global protocol that is insensitive
to delays.

To **design** a complex system in a **correct** way we need to:

- **Relax time constraints** during the early phases
- **Simplify the composition of sequential modules** in pipeline mode
- **Facilitate the insertion of extra pipeline stages between one module and the
  next one** with the purpose of **buffering** those signals which propagate on
  long wires

Asynchronous systems require designer to think digital systems completely
differently (e.g. removing the concept of global clock and use an event-based
architecture). A **latency-insensitive design is a specified synchronous system
where components are still synchronous but can tolerate arbitrary communication
delays**.

A **simple communication protocol is to stall the transmission if the data link
is not ready**.

In a Latency-Insensitive Design (LID), a **design is correct if and only if the
sequence of the events (and not their timing) is correct**: **timing** becomes a
**non-functional metric** to evaluate the quality of the evaluation. LID
introduces the **following concepts**:

- A **relay station** is a module that is inserted wherever it is necessary to
  tolerate delays
- Each relay station introduces one **stalling event**
- A **modules receiving a stalling event as input emits stalling events as
  outputs at the next cycle**

We call a **shell a wrapper that encapsulates a module and interfaces with
channels**, providing services to it like: getting incoming module, filtering
void packets, etc. It **guarantees input synchronization and data propagation**.

There are tools that implement latency-insensitive primitives. The area overhead
for these wrappers is usually 3%.

## Communication synthesis

**Multiprocessors** can communicate in **two methods**:

1. **Shared addresses**: offer to the programmer a single memory address space
   that all processors share/
   - Different processors communicate through shared variables in memory, with
     all processors capable of accessing all memory locations
   - Simpler, but less scalable
   - Memory access time can be uniform or non-uniform. NUMA machines can scale
     to a much larger size so there is more potential for performance.
2. **Message passing**: Communicating between multiple processors by explicitly
   sending and receiving information
   - More complex (requires protocols) but more scalable

Processors can be **connected with**:

- **Busses**:
  - Low area, simple interface
  - Lower scalability (due to bus contention) and cache coherency problems
- **NoC**:
  - Higher performance, much more scalable
  - Higher area of occupation, we still have cache coherency problems

**The connection type is orthogonal to the type of communication type**.
