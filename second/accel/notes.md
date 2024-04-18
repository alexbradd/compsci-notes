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

**After system partitioning** we got a **set of tasks assigned to system
components** (processors executing software + hardware components); these
processes are **communicating through abstract channels**. **Communication
synthesis has to generate hardware and software which interconnects the system
components and enables processes to communicate with each other, with peripheral
devices and other interfaces**. Communication synthesis, as a top-down design
task, is **performed in three main steps**:

- **Channel binding**

  **Abstract channels have to be implemented using physical communication
  components**. Resources are allocated, abstract channels are partitioned,
  grouped and bound to the allocated resources; messages corresponding to
  channels in one group are multiplexed on a shared communication component.

  The **main criteria** used for channel grouping is to **avoid bus conflicts
  and reduce the total number of connecting wires**. This **can be done by
  grouping together components** that don't access the channel concurrently, or
  grouping together channels that are accessed by the same process. Depending on
  its features, **a communication unit can support a certain number of channels
  to be multiplexed on it**, without reducing the communication rate below a
  required minimum.

- **Communication refinement**

  After channel binding the **interconnection topology of the system is known
  and it is determined which channels are bound to a given communication
  support**.

  **Communication** is still quite **abstract** and has to be **refined with
  several implementation details** (width of the lines imposed by the
  foundry/technology, control strategy and communication protocol)

- **Interface generation**

  The interfaces needed for a correct functionality of the system can be
  generated; **both software and hardware components have to be generated**
  (access routings, controllers, adapters and low-level support for
  communication related tasks like interrupt control, DMA etc.).

**After communication synthesis, the initial system specification results in a
specification which can be directly synthesized to a physical implementation**.

### Communication protocols

Like said before, a bus consists of wires connecting two or more processors or
memories. **Bus protocols are usually described using timing diagrams. Others
methods can also be used, like HDL descriptions or grammar-based descriptions**.

We have the following two methods for **controlling access to the bus**:

1. **Strobe**: the **master uses one control line**, often called the request
   line, to **initiate the data transfer**; the **transfer is considered to be
   complete after some fixed time interval** after the initiation
2. **Handshake**: **master uses a request line to initiate the transfer**; the
   **slave uses an acknowledge line** to inform the master when the data is
   ready

A multiprocessor communicates with other devices through some of its pins. To
manage it from software, we have different methods called I/O addressing:

- **Port-based I/O** (or parallel I/O): the processor has **one or more**
  `N`-bit ports and it **read/writes to ports just like registers**
- **Bus-based I/O**: processor has **address, data and control ports that form a
  single bus**
  - **Communication protocol needs to be built into the processor**
  - A **single processor instruction carries out a protocol read/write** on the
    bus
- Parallel I/O peripheral: used when the processor supports bus-based I/O but
  parallel I/O is needed
  - Each port on peripheral is connected to a register that is read/written by
    the processor
- Extended parallel I/O: used when processor supports port-based I/O but more
  ports needed
  - One or more processor ports interface with parallel I/O peripherals
    extending number of ports

**Communication** with a device which produces data asynchronously is done using
**two paradigms**:

- **Polling**: repeatedly check whether data is available
- **Interrupt**: the processor checks for the presence of a particular condition
  - When an interrupt happens then the ISR is called (ISR is at a fixed
    location)
  - Vectored interrupts make it possible to determine the address at which the
    ISR resides

**DMA is implemented via a single-purpose processor which transfers data between
the internal memory of the peripheral to the processor memory**. Processor needs
to **manage bus contention** when using DMA to avoid bottlenecks.

## Hardware security

See more or less what has been said in the computer security course and in the
"open challenges in hardware design" class.

## HLS

High-Level Synthesis creates an **RTL implementation from C, C++, System C,
OpenCL kernel code**. **Extracts control and dataflow** from the source code and
**implements the design based on defaults and user applied directives**. **Many
implementation are possible from the same source description**, enabling easy
design-space exploration.

HLS brings the following advantages:

- Productivity:
  - **Easy to model higher level of complexity**
  - **Smaller source** in size compared to RTL
  - Generates RTL faster than the manual method
- Quality of results:
  - **Automatic parallelism extraction**
  - **Multi-cycle functionality**
  - **Loop optimization**
  - **Optimization of memory access**

HLS enables us to **do both functional verification**, by feeding the C code
test inputs and checking the output against a reference, **and cosimulation**,
by synthesizing the RTL design with the desired constraints/directives and
checking again the outputs. We then evaluate the implementation and iterate as
necessary.

### Control and datapath extraction

Control and datapath can be **extracted from C code for each function**. At some
point in the top-level control flow, control is passed to a sub-function.
**Sub-functions may be implemented to execute concurrently with the top-level
one and/or other sub-functions**.

High-level concepts:

- **Functions**: all code is made up of functions which represent the design
  hierarchy - the **same hierarchy in hardware**
- **Top Level IO**: the **arguments of the top-level function** determine the
  hardware RTL interface ports
- Types: all variables are of a defined type (even custom). The type can
  influence the area and performance
- Loops: how these are handled can have a major impact on area and performance
- Arrays: they can influence the device IO and become performance bottlenecks
- Operators: operators in C code may require sharing to control area or specific
  hardware implementations to meet performance

**HLS maps** C code to hardware **through scheduling and binding processes**:

- **Scheduling** determines in **which clock cycle an operation will occur**,
  taking into account control, dataflow, and directives; the technology and user
  constraints impact the schedule
- **Binding** determines **which functional unit is used for each operation**,
  taking into account component delays and the given directives

### High-level functionality description

Our problem is the following:

- **Input**:
  - An **intermediate representation**
  - A set of functional **resources**
  - A set of **constraints**
    - Maximum area, maximum latency/minimum throughput
  - One or more **objectives**
    - Maximize area, minimize latency/maximum throughput
- **Output**:
  - **Hardware description** of the data-path+controller
    - Datapath: contains the functional/memory/interconnection resources
    - Controller: a FSM that determines the next action to run
- **Tasks**:
  - **Place** operations in **time** (scheduling) and **space** (binding)
  - Determine **detailed interconnection and control**

**Translation into hardware works analogously to any compilation with a standard
compiler based on e.g. LLVM**.

Given a functionality, **HLS always generates ports for each of the top-level
parameters as follows**:

- Parameters **passed by copy** are converted into **input ports** (connected to
  registers written by the CPU)
- Parameters **passed by reference** are converted into **memory interfaces**
  (access to a memory external to the component)

HLS also **adds control ports to manage start/done/reset**.

HLS can also **automatically generate standardized interfaces on top of the
basic ones** (AXI-lite for parameters or AXI-Master/Stream for memory accesses).

When dealing with **external memories**, the **scheduling** phase must have
**assumptions on the latency of the operations**:

- **Local data** (PLM or scratchpad) have **fixed-latency** access
  - Generates **simple interfaces without sync protocols**
- **Remote data** (cache or off-chip memory) have **variable-latency** access
  - Necessitates **more complex interface** with protocols to exchange data

### Scheduling and binding

**Scheduling** is the **assignment of operations to time** (control steps),
possibly **within given limits** on hardware resources and latency. It:

- Uses the **data-dependencies** identified during compilation **to identify
  parallelism**
- Exploits **mutual exclusion to avoid conflicts** on resources
- **Optimizes loops**

Generally it is **one of the first steps** in the HLS engine.

**Binding** is the **assignment of operations to hardware resources**
(functional units) **such that** there are **no conflicts in using them** and
the **total number is minimized**. To do so, it:

- **Uses scheduling information** to identify sharing opportunities
- **Exploits mutual exclusion** (e.g. operation in different BBs are never
  executed at the same time and can share resources)
- **Can be defined before scheduling**
  - Imposes constraints on scheduling

**Resource sharing** is the possibility of using the same functional unit to
implement two (or more) operations without any conflicts. Sharing opportunities
**can be defined before or after scheduling**:

1. **Before** scheduling:
   - **Pre-defined binding**: two operations that share the same resource
     **cannot be executed in the same clock cycle and must be serialized**
2. **After** scheduling:
   - **Binding algorithms on scheduled graph**. Two operations that are not
     executed in the same clock cycle can share the same functional unit

#### Scheduling

The scheduling steps **takes as input the IR, the clock period and the FU
latencies, and it produces the start time of each operations such that all
data-dependencies and resource constraints are satisfied**. Its **primary goal**
is to **optimize the circuit latency**, the **secondary** objective is to
**manage the area/latency trade-off**.

Scheduling determines the timing evolution of the circuit, so **it has a direct
impact on the latency** (or throughput) of the implementation. It has also an
**indirect effect on area**: operations in the same clock cycle require to be
assigned to different physical units so the **maximum number of concurrent
operations of the same type is an upper bound on the required number of hardware
resources**.

We can **approach** scheduling in 3 different ways:

- **Without constraints**:
  - Assumptions: **infinite resources**
  - Uses: calculate a **lower bound on clock cycles**
- With **resource constraints**:
  - Schedules operations (possibly serializing them) such that the overall
    number of used resources is with a given budget
  - Applications: limit the use of resources
- With **timing constraint**:
  - Schedules operations such that the end time of the last ones are within a
    given time budget
  - Applications: real-time scheduling

Scheduling is an **NP-hard problem**, so we need some **heuristics** to make the
problem algorithmically feasible. There are several algorithms, some are:

- As Soon As Possible (**ASAP**) and As Late As Possible (**ALAP**)
- Borrowing from compilers:
  - **List-based scheduling**
  - Force-directed scheduling
  - Path-based scheduling
  - Percolation scheduling
- **Meta-heuristic**: simulated annealing, tabu search etc...
  - As opposed to simple heuristics, meta-heuristics **explore the design
    space** and may or may not converge to one/the same solution
  - They generally provide **better solution**, but require **much more
    computational resources** than simple heuristic

##### ASAP

Each operation is **scheduled in the first clock cycle in which is available**,
i.e. when all its predecessors have been scheduled and have completed their
execution.

- Assumption: **all operations have a bounded delay** (in clock cycles)
- Imposes **no constraint on resources/area**
- **Minimizes latency**: provides a lower bound to latency

Algorithm:

1. Initialize the set of ready vertices with the source node
2. Pick one node from the set of ready vertices and schedule it with the
   following equation

   $$
   start_time(w) = \max_{p\in Pred} end_time(op_p)
   $$

3. Define the end time of the current node

   $$
    end_time(op_i) = start_time(op_i) + delay(op_i)
   $$

4. Add all successors of the current node to the set of ready vertices
5. Repeat from step 2 until the set is empty

##### ALAP

Each operation is **scheduled in last clock cycle where it can be scheduled
without causing an extra delay**. It is the **dual problem of ASAP**: it solves
a latency-constrained problem where the latency bound is set to latency computed
by ASAP algorithm.

- Assumption: **all operations have a bounded delay** (in clock cycles)
- Imposes **no constraint on resources/area**

Algorithm:

1. Initialize the set of ready vertices with the sink node
2. Pick one node from the set of ready vertices and schedule it with the
   following equation

   $$
    end_time(op_i) = \min_{s\in Succ} start_time(op_p)
   $$

3. Define the start time of the current node

   $$
    end_time(op_i) = end_time(op_i) - dealy(op_i)
   $$

4. Add all predecessors of the current node to the set of ready vertices
5. Repeat from step 2 until the set is empty

##### Mobility

Mobility is a **metric associated with each operation and is defined as the
difference between its ALAP and ASAP schedules**.

- **Zero mobility** implies that an **operation can start only at a given time
  step** without introducing any delay on the overall schedule
- Mobility **greater than zero measures the slack** on the start time

##### List-based scheduling

**Most common heuristic for constraint-based scheduling**, it is a simple
**greedy algorithm** (does **not guarantee optimality** but it is **linear** in
complexity). It can be used both for **minimizing latency given constraints on
area/resources** (ML-RCS) or **minimizing resources given a bound on latency**
(MR-LCS).

Algorithm:

1. Construct a priority list based on some metrics (operation mobility, number
   of successors, etc...)
2. While not all operations scheduled
   1. For each available resource, select an operation in the ready list
      following the descending priority.
   2. Assign the operation to the current clock cycle
   3. Update the ready list
   4. Continue until there are no more ready operations or available resources
   5. Increment the clock cycle

##### Static vs dynamic mobility

An operation with **high mobility** (and static mobility) is **generally
postponed** to the next clock cycle. This incurs a **risk of starvation**
possible solution is to **update the mobility after each iteration** (dynamic
mobility): we decrease the mobility each time we postpone it.

##### Challenges

All algorithms assumed functional units that complete in one (single-cycle) or
more cycles (multi-cycle) and that execute at most one operation. However, we
can have **FUs** that can execute more than one operation (**multi-function**)
or start another operation before the previous one is completed (**pipelined**).

If two operations are serial and the total execution time is less than the clock
period, they can be executed one after the other (**chaining**).

Operations may have unbounded latency, e.g. accesses to external memory, and may
require **synchronization protocols**.

#### Binding

It is defined as the **spatial mapping between operations and resources**. It
tries to search for sharing opportunities.

It can be **constrained**:

- Resource-dominated circuits
- Fixed number and type of available resources

This is again an **NP-complete** problem, meaning we need to use **heuristics**.

We take as **input the scheduled graph and well defined concurrency
information** for operations. We **consider operation types independently**. We
**perform analysis on operation pairs**:

- **Compatibility**: same type, non-concurrent, etc.
- **Conflict**: concurrent, different types, etc.

These two are **dual** problems.

##### Compatibility

Let use define the **compatibility graph** $G_+$:

- Vertices represent operations
- Edges represent compatible operation pairs
  - Two operations are compatible if they are not concurrent and can be
    implemented by resources of the same type

The binding problem can be formulated as a **partitioning of the compatibility
graph**:

> Each partition is a clique (fully connected subgraph) of operations that are
> all compatible with each other. So, they can share the same resource

The **clique covering** is thus a partitioning of graph $G_+$ into the minimum
number of cliques, where each clique represents a functional unit.

It is possible to **solve the partitioning** imposing a **minimum number of
cliques** (more units, less interconnections), **or to assign weights** to edges
to prioritize some connections.

##### Conflict

We can define the **conflict graph** $G_-$, which is the **complementary of the
compatibility graph**, as such:

- Vertices represent operations
- Edges represent operations pairs in conflict
  - Two operations are in conflict if they are not compatible

The binding problem can be **formulated as a coloring problem** of the conflict
graph.

> Each node will be assigned to a color and two adjacent nodes cannot have the
> same color

The **color** will represent the **identifier of the functional unit**.

The goal is to **minimize the overall number of colors** (each node with a
different color is an admissible but trivial solution).
