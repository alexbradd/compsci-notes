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
