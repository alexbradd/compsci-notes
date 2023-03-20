# Network computing

## Data centers

We have 2 main types of traffic inside the data center network:

1. **North-south**: requests come from the user and traverse in depth the
   network
2. **East-West**: computations that send requests intra-data center

The **majority of traffic inside a center is east-west**. The implication of
this is that we need to have **any-to-any communication** that needs to happen
at full speed, which requires a **high bandwidth**, and a consistent low
latency, this means that the **worst case (tail) latency needs to be low**.

At a birds-eye view, a data center is just a massive switch offering billions of
network ports to different users. The practical approach is to have a **network
of switches (fabric)**.

### Traditional tree-like topology

Originally data center is composed of **multiple racks of servers**. On top of
each rack there is a **top-of-rack switch. ToR-switches are in turn connected to
aggregation-switches. Aggregation-switches are then connected to the
core-switches that connect the network to the outside**. An **aggregation of
racks** was called a **pod**. **Connections between servers-tor-aggregation
switches is L2 and is called edge layer; connections between aggregate and core
switches are on L3 and is called core layer**.

L2 vs L3 switches have different advantages and disadvantages:

1. **L2 has fixed IP addresses** and have **auto-configuration** but **scale
   worse**;
2. **L3 routing** is more scalable through **hierarchical addressing**. We can
   also have **multipath routing** through equal cost multipath. **However, they
   require more configuration** and **migrations** would be problematic since
   they **would require IP address changes**.

A few definitions:

1. **Diameter**: max number between any two points;
2. **Bisection bandwidth**: if the network would be bisected, the bisection
   bandwidth of the topology is the bandwidth available between the two
   partitions;
3. **Full bisection bandwidth**: the ability for all hosts in one half to
   simultaneously talk at full speed to all host of the other half.

**Scaling up the traditional tree-topology is very costly** since going up the
tree we require higher and higher bandwidth.

A band-aid is **over-subscribing**: we **provision less than the full
bandwidth** for the hosts. We can define over-subscription as the **ratio of the
worst-case achievable aggregate bandwidth among the end hosts to the total
bisection bandwidth of a particular communication topology**. Over-subscription
easily baloons as we go up the tree.

### Fat tree topology

We have two approaches:

1. scale-up: stick to the tree and simply buy bigger links
2. scale-out: scale for bigger amount of hosts

Some **noteworthy topologies** are: the **fat-tree, bcube and jellyfish. The
most-standard topology is the fat-tree**.

The **fat-tree** is a special type of **Clos network**: a type of non-blocking,
multistage switching architecture that reduces the number of ports required in
an interconnected fabric.

A **fat-tree is characterized by a parameter** $k$. A k-ary fat-tree has a three
layer topology with:

- Each pod consists of $(k/2)^2$ servers and 2 layers of $k/2$ k-port switches;
- Each edge switch connects to $k/2$ servers and $k/2$ aggregate switches;
- Each aggregate switch connect to $k/2$ edge and $k/2$ core switches
- We have $(k/2)^2$ core switches that connect to $k$ pods.

We have some **interesting properties**:

1. **Identical bandwidths at any bisection**
2. **Each layer has the same aggregated bandwidth**
3. Can be **built using cheap devices at uniform capacity**
4. **Scalability is very good** (a k-port switch supports $k^3/4$ servers).

The fat-tree brings **additional problems**: we **need a routing protocol that
exploits all paths** and **transport protocol must fill all pipes**.

### Flows

Flows in data centers have different characteristics: **we have applications
that generate bursty flows, large flows or short flows**. This implies that our
fabric needs to **satisfy two different constraints**:

1. **Short messages require low latencies**
2. **Large flows require high throughput**

This two styles of flows **interfere with each other**: we need **intelligent
routing** to avoid that large-flows clash with small flows to fulfill our
requirements.

The problem is, however, not only about routing: let's say we have data striped
across different servers. We might incur in a problem called **TCP Incast**: we
cram $n$ flows into only one link, resulting into packet loss and triggering TCP
shenanigans. Solving this problem **requires smarter congestion control**.

### Costs

Total costs of a data center can be upwards of 0.25 B\$ for mega-data centers.
Server costs dominate, but network costs are also predominant. We work with long
provisioning scales, where new servers are purchased quarterly at best.

Server costs include:

1. Uneven application fit: most application exhaust only on resource on the
   server, stranding the others;
2. Uncertainty in the demand of a service (spikes);
3. Risk management.

### Google jupiter's topology

Google started from a **single commercial switching asic** (to keep costs down),
and combined them into a single more powerful chip ( **chiplet-style design** ).

## Software-defined networking

Originally we had **two devices**:

1. The **switch** routes packets only based on **layer 2** data
2. The **router** routes packets only based on **layer 3** data

Internally, a **router** is usually composed of **two main components**: a **CPU
running an OS** (with all various router features like routing protocols and
tables) and an **asic that does the actual routing**. The asic works with data
given by the OS driver via a forwarding table.

When a **packet enters a router**, we **parse the header** and then decide how
to handle it:

1. If it is a **data packet**, it **stays on the asic and uses the forwarding
   table** to get sent fast
2. If it a control **layer packet**, it gets **sent to the router OS** for
   slower processing

We can do this since **control layer updates are much rarer than data**.

What if we need to run our network on a **routing protocol not yet supported by
our router**? We could possibly request an update from the vendor, but this is
slow and not very flexible.

The basic idea of **SDN** is to **separate even more the control from the data
plane**: the two layers are even **separated physically**. The **control plane**
is now a **remote machine** that is connected to the data-plane via a
communication channel. Since we do not need to change the data plane often, we
can have a **simple API** to it and then implement what we want in the control
plane.

This architecture lets us have **many packet-forwarding devices and a single
network OS with user-controlled features**. To do this **we need**:

1. A **network OS** that provides the necessary abstractions
2. **Consistent, up-to-date global network view**
3. Open **interface to packet forwarding**

We can then **write programs that take the global network view as input and
outputs a configuration of each of the network devices**. The **interface
between OS and programs is the _northbound interface_**, while the **interface
between OS and the packet-forwarding devices is the _southbound interface_**.

### OpenFlow

OpenFlow is **realization of SDN**. It is a **set of protocols and APIs**. The
CPU of an openflow switch runs an openflow daemon that handles communication
with the server.

A program can do a variety of things such as adding/removing flow rules at
switches, collect statistics and establishing connectivity at switches.

The **default** behaviour (called **reactive**) is the following: **when a
packet arrives at the switch try to match it to the rules, if a match can be
found it is processed accordingly, otherwise processing is interrupted and the
header is sent to the controller; the controller then processes the header and
sends a new ad-hoc rule**.

The default behaviour, or **mode**, has the advantage of having **high control
granularity and making efficient use of flow tables**. However it incurs in
**additional setup costs for every new flow**. Moreover **if the connectivity to
the controller is lost, the switch could become a paperweight**.

Complementing the default mode, another one (called **proactive**) exists:
**instead of interrupting the flow of packets, at setup time the controller
pre-populates all possible rules (using wildcards to match every possibility)**.

This second mode **exchanges granularity for speed**. However we have zero
additional setup costs and our switch is always up, even in case of loss of
connection to the controller.

Is an openFlow switch a switch or a router: it depends. The flexibility enables,
however, **flexibility in the control plane level**. We can also have a legacy
compatibility mode with other control planes protocols.

The **problem** is that **openFlow assumes that most network switches do the
same things** and that switches **have a fixed, well-known behaviour**. Instead
of **repeatedly extending the standard** we can define a **flexible mechanism
for parsing arbitrary packets and matching header fields through a common
interface**.

### p4

Usually network systems are configured bottom-up. However, how we did in all
other branches of IT, the more flexible approach is to **do things top-down**.
This means we need **programs to compile and execute directly on the switch,
that now becomes programmable**.

p4 is an **attempt at bringing to networking what RISC brought to computing**.

The most important **aspects to consider** are:

1. **Chip speed**: **we can now make programmable switches chips as fast as
   fixed ones**
2. **Chip complexity**: there are **too many protocols to correctly hard-code in
   silicon**
3. **Chip technology**: the **difference in chip area and power between
   programmable and fixed function is going away**

On these types of chips, **serial IO is massive**: almost 30% of the area of the
chip. Due to **Moore's law**, **each generation we halve the size of the serial
IO chip**. If we maintain the **area the same, we can double the speed of the
IO**.

The **remaining part** that does not do IO is **divided between packet
processing (50%) and buffers/queues (20%)**. Of the **packet processing logic,
half is only memories while the rest is actual logic**. Like with serial IO,
**we can double the memory each generation while maintaining the same area
surface**; **however** with logic **we do not implement new logic every
generation, meaning that the logic part shrinks every year**.

Since only the logic part is the one differentiating between programmable and
non-programmable switches, **the part that actually makes a difference is become
smaller each generation**.

P4 is **not openFlow 2.0, it addresses a much more general problem**:
**programming the dataplane**; openFlow is just a system for dynamically
enabling/disabling rules. **With p4 it is possible to implement an openflow
switch**, for instance.

p4 programs are **built against a p4 architecture model**. This makes it
possible for the same program to compile for different targets. **The binary
file generated by the compiler gets loaded onto the switch**. The **program
effectively creates a new "control plane" that interacts with the data plane
through an API**.

### PISA (Protocol independent switch architecture)

We have **a set of identical pipeline stages**. Each of them is **designed to
perform a set of match-action operations that can be done in parallel**. **A
programmable parser extracts the headers from the incoming packet** and **feeds
them to the pipeline**.

A **packet header vector** (PHV) is **used as a container that hosts the match
keys for the match+action units**. Based on match entries, **we can perform some
actions that can change/add/remove packet headers**. This is **done for each
stage** of the pipeline. Finally, the **packet gets reassembled in the
deparser**.

To add even more flexibility, the **pipeline outputs into a traffic manager**,
that does the switching. This manager **then feeds directly into another
pipeline that can modify the packet, but not change its switching**. This way
**we have pre-switching (ingress) and post-switching (egress) processing**,
enabling us to also do matching on the destination.

**Each pipeline stage is composed of different match logic units** (associative
memories that match headers against rules) **and action logic unit** (simple
ALUs).

The **P4 compiler first does dependency analysis on our code and maps it onto
the various pipeline stages. The placement depends both on match and cation
dependencies**.

### Ternary content-addressable memory

The **matching logic** in our PISA is basically a **mix of SRAM and ternary
content-addressable memory (TCAM)** used for lookup and other things.

A switch/router, to do routing, it needs to quickly compute the longest-prefix
match of the packet in a set of rules. Since we run a pipeline, we want this
match to be deterministic and always take a set amount of time in order to not
stall the pipeline.

**TCAM is a special type of associative memory that compares input data against
the stored data and returns the address of matching data**. They **produce the
result of the query in a single clock cycle**. They are **very expensive**, so
they need to be as few as possible.

TCAMs are called ternary because they use **ternary logic**: 0, 1, and \_ (don't
care).

The TCAM's buckets correspond to addresses in a RAM that contains the output
port. This means that to match a rule we need:

- 1 TCAM access to get the address in RAM (constant time operation)
- 1 RAM access to get the output port (constant time operation)

**A match is done in 2 memory accesses**, which can be done in a single clock
cycle.

Whether a TCAM matches the longest/shortest prefix is user-configurable and adds
extra control logic to the memory.

TCAM is not cheap, so we cannot have a lot of it. We need the help of other data
structure to efficiently create rules without using much memory.

### Some data structures

#### Bloom filters

A traditionally implemented set is not very well suited to our case: the output
is deterministic, however the number of required operations cannot be known
a-priori. What if **we can exchange the deterministic nature of the output for a
deterministic time complexity?**

Traditional sets are very space inefficient: they tend to have a high
probability of hash collisions for densly filled tables. To keep the conflicts
down we need a very over-dimensionated table.

Let us start with a simple implementation: we have **an array of $m$ bits and a
hash function. If an element is in the set, we set the bit indexed by the hash
to 1**. This structure, when queried for set-inclusion, will respond
probabilistically; it can return:

- **true**-positives/negatives
- **false-positives** (different objects can have the same hash) with a
  probability of

  $$1-(1-\frac{1}{m})^n$$

But **never false-negatives** (if a bit is 0, then all objects with said hash
are not in the set).

We just described a **bloom filter with $k=1$**. The $k$ parameter **indicates
the number of different hash functions that we will use on insertion**: each of
those will calculate an index and set the corresponding bit to 1 in the array.
To check for inclusion:

1. We calculate the $k$ hashes
2. An element is considered in the set if all hashes correspond to a 1
3. An element is not in the set if at least one hash corresponds to a 0

The usage of **$k$ hashes reduces the probability of false positives** to:

$$
(1- (1-\frac{1}{m})^{kn})^k \approx (1-e^{-\frac{kn}{m}})^k
$$

To find **how many hash functions we need, we can minimize** the above
probability and it can be proven that the minimum $k$ is $k=\frac{m}{n}\ln 2$.

To **enable element removal**, we can extend our filter to have one **integer
per cell**, instead of one bit. **On insertion we increment** the bits
corresponding to the hashes and **on removal we decrement them**. On query we
check for $>0$ and $=0$. All our previous analysis still applies. This extension
obviously **requires more memory, but also introduces the problem dimensioning
the counters**: if a counter **overflows**, we incur the risk of introducing
**false negatives**.

#### Invertible bloom lookup tables

Let us assume we have a counting bloom filter. How can we know which elements
are stored inside the filter?

Instead of having only one array, we have **3**:

1. `count`: as before
2. `keysum`: the sum of all the keys mapped to a cell
3. `valuesum`: the sum of all the values mapped to a cell

Our operations become like this:

1. Query: as a normal counting bloom filter
2. Insertion: we update the filter, then sum the key and the value to the
   respective columns
3. Deletion: we update the filter, then subtract the key and the value from the
   respective columns

The **value of a key can be found if the entry** is associated with a `count`
counter with value $1$.

To **list all inserted elements** in a IBLT, we can:

1. **For all entries with count one**:
   - Remove them from the set and store the reconstructed values
2. **If there are no entries with count 1 we cannot do anything**

#### Sketches

Let us consider the problem of computing the frequencies of different objects in
a stream. We could have a precise answer by using a counter for each type of
element, however this requires a lot of memory especially if we have a lot of
elements/element types.

**Count-min sketches are a probabilistic data structure that serves as a
frequency table of events in a stream of data**. It trades off counting
precision with performance.

It uses a **hash function to map events to frequencies**:

- We have $d$ **arrays, with one hash per array of counters**
- Each array hash $w$ **indices**

When an element is added, **for each hash, we increment the counter for the
corresponding array and index**. **Collisions** between elements can cause
**overcounting**.

When we **query** the number of occurrences of an element we return the
**minimum of all the values corresponding to our element**.

It uses similar principles as counting bloom filter but it is **designed to have
provable bounds for frequency queries**. It also **requires sub-linear space**
(unlike hash tables) since the memory requirements do not grow linearly with the
amount of data to be tracked. Due to how they work, the **counting error reduces
for more frequent elements**.

## Datacenter monitoring

At a very large scale, problems are difficult to debug: we might not even know
were they might be (network, software, hardware etc.). Even figuring out the
path of a packet is very difficult.

**Network monitoring is the use of a system that constantly monitors a computer
network for slow or failing components**. We have different ways to monitor a
network:

1. **From switches**: using their **features** (NetFlow, mirroring, SNMP) or
   **building new feature using dataplane programmability**
2. **From servers**: using **standard tools** (`netstat`, `tcpdump` or
   `traceroute`) or **ad-hoc tools**

### Network monitoring using legacy switches

We would like to work around some problems like:

- **silent packet drops**: packets dropped but not reported by the culprit, it
  is due to software bugs or faulty hardware
- **silent blackhole**: a routing blackhole that does not show up in forwarding
  tables, caused by corrupted TCAMs.
- **inflated e2e latency**
- **loops from buggy middlebox routing**: due to a middlebox incorrectly
  identifying packets
- **load imbalance**
- **protocol bugs**

**Problems would be easier if we could `traceroute` every packet, however at
scale this is unfeasible**. We might also need to **correlate packets over
different hops**. Also the traces might not be enough if a problem is transient.

Let us analyze Microsoft's Everflow. The tree **main ideas** behind the method
are:

1. **Match and mirror on switch**: **match** based on predefined rules **and
   mirror packets**. We mainly use matching rules for:
   - TCP's `SYN`, `FIN` and `RST`
   - A special debug bit in the header
   - All protocol traffic (BGP and others)
2. **Switch-based reshuffler**: traced traffic must be sent to different
   collectors as a single machine cannot cope with the amount of data
   - **We may use a virtual IP with a load balancer**
3. **Guided probing**: it allows to **inject any desired packet into the network
   and trace its behaviour**.

   It can be used to recover lost information with match&mirror and allows to
   check if a problem is transient or persistent. **Which bit can we use to
   signal it? The unused DSCP field and IPID fields in the IP header**: the
   first one to signal whether it is a flow of interest and the IPID to sample
   packets.

Everflow applications interact with a **central controller that knows the
routing**. The controller gets as **input the operator request and the supposed
network routing**; then it **initializes the rules on switches, configures the
analyzers and sets the appropriate debug bit into probes**. After the
configuration, the **mirrored traffic will be sent to the analyzers where they
were heuristically checked and stored if problematic**.

Takeaways: although powerful, it is still **limited by the capabilities exposed
by the switches**.

### Network monitoring using dataplane programmability

An important trade-off to consider is where to put the monitoring overhead:

1. Collectors have limited bandwidth and storage
2. Switches have limited memory and processing time

#### FlowRadar

Let us analyze FlowRadar to find a way to minimize the load between the two.
**FlowRadar allows us co compute packet counts across different flows**.

Architecture:

- **Each switch maintains a fast and efficient data structure for half-baked
  per-flow counter and sends periodic reports to collectors**.

  - We maintain a **tree column table**:
    1. `FlowXOR`:: the XOR of all the flows mapped to a bin
    2. `FlowCount`: the number of flows mapped to a bin
    3. `PacketCount`: the number of packets of all the flows mapped to a bin

  If a **flow is new, everything is updated, otherwise only the packet count**.
  We implement the following **filter using an invertible bloom filter**.

- The **collectors correlate network wide info to extract per-flow counters**.
  The work is divided into **two stages**:

  1. **Single decode**: **compute the number of packets by inverting the flow
     filter on a per-switch basis**:
     1. We find a cell with one flow (pure cell)
     2. Remove the flow from all the cells
     3. Continue removing all flows until have no more pure flows.
  2. **Network decode**: **we solve eventual stalls in the single decode by
     leveraging network wide info (info from other switches)**.

     We use merge tables into a single mega-switch table and use it in our
     algorithm. To find which switch processed what flow we can query its bloom
     filter.

#### In-band Network Telemetry

It is a **framework designed to allow the collection and report of network
state, by the data plane**. In the INT architectural model, **packets may
contain header fields that are interpreted as telemetry instructions by network
devices**. These **instructions tell an INT-capable device what state to
collect**. We can see this as a much more powerful version of Microsoft's
Everflow.

We can run INT into **three modes**:

1. `XD`: **Each nodes exports metadata** based on watchlist configuration
   - Good: no packet modification
   - Bad: pressure on collectors, query based on switch configuration
2. `MX`: **Embed only instructions in the packet. Each node exports metadata**.
   - Good: query is packet dependent
   - Bad: pressure on collectors, modified packets
3. `MD`: **Embed instruction and metadata, export at the sink node**.
   - Good: query is packet dependent, no pressure on collectors
   - Bad: impact on packet MTU (the switch will eat space into what is usable by
     the application), packets need to be modified
