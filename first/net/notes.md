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

## Datacenter load balancing

### Layer 3 load balancing

Many distributed applications run in a datacenter, these generate traffic within
the datacenter with very variable characteristics. To best support distributed
applications we need a high bisection bandwidth. Lots of paths available from
one rack to the other, so **how do we best utilize network resources**? This is
the goal of L3 load balancing. This is hard because flows come and go and we
have a mix of short and long flows.

A **simple technique** is to do **packet spraying**: we "spray" the packets to
all the possible paths.

- Pros: **traffic is well spread** (even with heavy flows)
- Cons: **interacts very badly with TCP**:
  - Packet reordering can trigger duplicated ACKs
  - Sender will reduce the sending rate as it thinks packets are lost

This solution is **simple but very bad**. We will see some better ones.

#### Equal Cost Multi Path (ECMP)

We use **per-flow load balancing**. This can be **implemented with a hash
function**: `port.output = hash(packet.tuple)`; the tuple of fields used is
switch-implementation-dependant.

Basically **all packets belonging to a flow (i.e. packets that have the same
tuple hash) are routed to the same path**.

- Pros: **a flow follows a single path**
- Cons:
  - The **performance depends on traffic characteristics** (hash collisions)
  - **No optimal load balancing** (on average it could be optimal)

The main **problem** with ECMP is that it **is static and completely oblivious
to link utilization**. More over, it **can cause long-term flow collisions due
to hash collisions**. It has been proven that ECMP on average wastes 61% of the
bisection bandwidth.

#### Hedera

It is a solution proposed to **improve and complement ECMP**. It is **built to
work on top of a SDN network and tested with the OpenFlow protocol**.

**Given a dynamic traffic matrix of flow demands, how do you find paths that
maximize network bisection bandwidth?**

> A traffic matrix is a two-dimensional matrix with its ij-th element ($t_{ij}$)
> determining the amount of traffic sourcing from a node i and exiting node j

Assuming we have OpenFlow switches and a centralized controller, we can
**execute the following loop forever**:

1. **Pull stats** from the switches and **detect large flows**
2. **Compute the demands**
3. **Compute the placement**
4. **Place the flows**

We **schedule only elephant flows since ECMP is enough to deal with shorter
flows**.

Flow rates are a poor indicator of flow demand: the network could be the
bottleneck. **Hedera's approach to computing flow demands is assuming no
bottleneck in the network, we compute each flow's demands by considering shares
of sender and receiver flows**.

For **placing flows**, we have **two policies**:

1. **Global first-fit**: when a new flow is detected, we linearly search all
   possible paths from source to a destination. We place the flow on the first
   path whose component links can fit that flow.
2. **Simulated annealing**: probabilistically search for good solutions that
   maximize bisection bandwidth

In **global first-fit a large flow can be rerouted upon detection and is
essentially pinned to its reserved links. Simulated annealing, on the other
hand, waits for the next scheduling tick and uses previously computed flow
placements to optimize the current placement**.

Problems with this approach:

1. **Dynamic workloads can generate large-flow-turnover faster than the control
   loop**, meaning the controller will be continuously chasing the traffic
   matrix.
2. **Can it scale to really large datacenters**?

#### In-network load-balancing (HULA)

If the problem is the centralized controller, **can we get rid of it and
implement load balancing back in the switches (as ECMP was doing)?** This
**makes sense because datacenter traffic is very bursty and upredictable**,
meaning that there is not much time available for the control loop.

The problem with ECMP is that it is static... **What if as a new flow arrives we
assign it the least congested port? Why are we working per-flow and not
per-packet**? Per-packet load balancing would be ideal but introduce
packet-reordering which is bad for TCP; per-flow load balancing is fine but too
coarse-grained to fully utilize the network.

We can **divide a flow into flowlets: bursts of packets from a flow that are
separated by large enough gaps. If the gap is large enough then it is possible
to route the two flowlets to different paths without risking reordering**.

Putting it all together we **obtain a congestion-aware load balancing solution
with flowlet switching, built to work on P4 programmable switches**: HULA
(Hop-by-hop Utilization-aware Load-balancing)! The challenges we face are:

1. If we want to create a congestion-aware algorithm, how to keep track scalably
   of all the possible paths?
2. How to do this continuously (in a proactive manner)?
3. How to implement such an algorithm given the constraints of programmable
   switches?

**Hula switches exchange probes to propagate path utilization** (allowing
continuous monitoring of network status). **Each switch remembers only the best
next hop, removing scalability/topology problems. We will use flowlets to split
elephant flows into smaller chunks**.

A HULA probe is a minimum-sized IP packet, including the HULA header:

```txt
+---------------------------------+
| Standard IP Header              |
+----------------+----------------+
| HULA switch ID | HULA path util |
+----------------+----------------+
```

Some questions:

1. What happens on **link failure**?
   - **Switches update their table only considering probes they receive**. The
     probes act as a sort of **heartbeat**.
2. Shall we **run the probes more or less frequently**?
   - **Frequent probes generate more overhead but provide better network
     visibility**
3. What’s the **right flowlet timeout**?
   - **It depends on the network RTT**

### Layer 4 load balancing

In a traditional cloud load balancing architecture, we have different levels of
load-balancing: Network (L3), Transport (L4) and Application (L5).
Application-level load-balancing is usually tenant-written software, while
network load-balancing is usually managed by the datacenter owner and is
hardware-based. L4 is usually datacenter-owned but software implemented.

Similarly to L3 load balancing, our goal is **finding a way to spread requests
over multiple servers. We have three possible approaches**:

1. Load balancer **terminates TCP and opens own connection to servers**
   - Problem: **very intensive** since we have one connection for each external
     connection and one for each internal server
2. **NAT approach**: load balancer replaces service VIP with server’s actual IP
   - Problem: we **force each stream to pass into software**
3. **DSR** (Direct Server Return): **servers bind both the VIP and the dedicated
   IP, load balancer replaces the destination MAC. Server sees the client IP and
   responds directly, i.e. exiting packets do not pass through load balancing**.
   - **Greater scalability**, particularly for asymmetric bandwidth

What **policy** do we use to equally share resources to the servers?

- **Round robin**: the load balancer has a counter, when a new request arrives,
  assign it to the server indexed by the counter and increase the counter
  - We **break-up flows**: requests may not fit into one packet and packets
    belonging to the same request must hit the same instance
  - **Processing request time may vary**: some server may be slower or some
    requests are more complex

Let us **focus on correctly spreading requests**. To tackle this issue **we must
implement a notion of persistence** for load balancers: **packets belonging to
the same flow are forwarded to the same server**; therefore we must guarantee
packets belonging to the same TCP connections hit the same server even in the
face of topological changes. We need a **uniform deterministic load-balancing
function**:

- Uniform: we need to spread loads across servers
- Deterministic: we need to guarantee connection affinity

Options:

1. Keep **per-flow state** at the load balancer, a TCP/IP tuple identifies a
   connection
   - Stateful solution that might require a **lot of memory**
2. Apply a **hash function** $h$ on the packet header. This allows us to map
   arbitrary size data into data of fixed size.
   - **Pros**: **zero state**, packets of the same flow will hit the same server
     (not necessarily of the same user)
   - **Cons**: **does not resist server-pool updates**
3. **Consistent hashing**: **every server is responsible for the hashing space
   until its predecessor**.
   - **Removing servers might lead to imbalances**: a solution might be mapping
     each server to multiple points on the circle. When adding a new node the
     load will be balanced.
   - On server addition, we still have a problem: **how do we know some of the
     connections in the new server's range were pre-existing and shall be
     forwarded to the previous server**? We would need to **reintroduce some
     statefulness**.
   - The above might not be enough: what if a **load balancer itself goes
     down**? We might **replicate state** to different load balancers (increased
     latency).

#### Cheetah

We want a stateless load-balancer, but we do not want all problems associated
with consistent hashing.

1. A **new request from a user hits the load balancer and a server is selected**
2. On the **way back, a cookie is inserted** in the reply with the originating
   server ID
3. **New packets of the same flow need to just insert the cookie**

To remove the possibility of DoS a server by forging packets **we can encrypt
the server ID by XORing the server ID with a secret hash of the connection ID**.

As a **flow-assigning strategy we can implement each strategy** (even
round-robin, although it not always the best option). We can **also implement
DSR**, but we **need to change the server's network stack** to compute the
cookie. Cheetah **does not require changes to the client side** since we can use
**standard TCP features** to store the cookie (timestamp echo).

#### Fastly's solution (faild)

This is a solution for the edge. **Requests enter a specific network through
Points of Presence** (PoPs); **requests that cannot be fulfilled by a PoP are
routed through an owned backbone network to a datacenter**. **PoPs**, then,
become **small datacenters**: this means that they need to be

1. High performance
2. Do not be a single point of failure
3. Absorb DDoS attacks
4. Do not cause service disruption on maintenance

We need a load balancing architecture which is:

- Efficient: no dedicated hardware and no much space available
- Resilient: anything that maintains state is easy to DDoS
- Graceful: ability to change services without disrupting flows

`faild` **maps the VIP to a static set of "virtual" next hops** (to avoid ECMP
rehashing). The **forwarding is controlled using the ARP table**; **on drain we
update the affected IPs and balance the virtual hops across the available
servers**. This is just consistent hashing with extra steps, however **since we
are playing with fake MACS we can**:

- Keep a **mapping history**:
  - `xx:xx:xx:xx:a:b`: `a` is the ID of the current host, `b` is the ID of the
    previous host.
  - Keeping only previous and current target conveys enough information to down
    to the host

**Each host can inspect the destination MAC of the packet and execute the
following algorithm to decide what to do with the packet**:

```txt
  ┌──────────────────────┐      True
  │ current == previous? │━━━━━━━━━━━━━━━┓
  └──────────────────────┘               ┃
            ↓ False                      ▼
    ┌────────────────┐   True     ┌────────────────┐
    │ is SYN packet? │──────────► │    Process     │
    └────────────────┘            └────────────────┘
            ↓ False                      ▲
   ┌──────────────────┐      True        ┃
   │ Is local socket? │━━━━━━━━━━━━━━━━━━┛
   └──────────────────┘
            ↓ False
         Redirect
```

This effectively means that **packets filtered through the host are only
accepted if they belong to a new connection, or if they match a local TCP
socket**.
