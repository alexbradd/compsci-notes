# Network computing

## Data centers

We have 2 main types of traffic inside the data center network:

1. **North-south**: requests come from the user and traverse in depth the network
2. **East-West**: computations that send requests intra-data center

The **majority of traffic inside a center is east-west**. The implication of this is
that we need to have **any-to-any communication** that needs to happen at full
speed, which requires a **high bandwidth**, and a consistent low latency, this means
that the **worst case (tail) latency needs to be low**.

At a birds-eye view, a data center is just a massive switch offering billions of
network ports to different users. The practical approach is to have a **network of
switches (fabric)**.

### Traditional tree-like topology

Originally data center is composed of **multiple racks of servers**. On top of each
rack there is a **top-of-rack switch. ToR-switches are in turn connected to
aggregation-switches. Aggregation-switches are then connected to the
core-switches that connect the network to the outside**. An **aggregation of racks**
was called a **pod**. **Connections between servers-tor-aggregation switches is L2 and
is called edge layer; connections between aggregate and core switches are on L3 and
is called core layer**.

L2 vs L3 switches have different advantages and disadvantages:

1. **L2 has fixed IP addresses** and have **auto-configuration** but **scale worse**;
2. **L3 routing** is more scalable through **hierarchical addressing**. We can also have
   **multipath routing** through equal cost multipath. **However, they require more
   configuration** and **migrations** would be problematic since they **would require IP
   address changes**.

A few definitions:

1. **Diameter**: max number between any two points;
2. **Bisection bandwidth**: if the network would be bisected, the bisection bandwidth
   of the topology is the bandwidth available between the two partitions;
3. **Full bisection bandwidth**: the ability for all hosts in one half to
   simultaneously talk at full speed to all host of the other half.

**Scaling up the traditional tree-topology is very costly** since going up the tree
we require higher and higher bandwidth.

A band-aid is **over-subscribing**: we **provision less than the full bandwidth** for
the hosts. We can define over-subscription as the **ratio of the worst-case
achievable aggregate bandwidth among the end hosts to the total bisection
bandwidth of a particular communication topology**. Over-subscription easily
baloons as we go up the tree.

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

Flows in data centers have different characteristics: **we have applications that
generate bursty flows, large flows or short flows**. This implies that our fabric
needs to **satisfy two different constraints**:

1. **Short messages require low latencies**
2. **Large flows require high throughput**

This two styles of flows **interfere with each other**: we need **intelligent routing**
to avoid that large-flows clash with small flows to fulfill our requirements.

The problem is, however, not only about routing: let's say we have data striped
across different servers. We might incur in a problem called **TCP Incast**: we cram
$n$ flows into only one link, resulting into packet loss and triggering TCP
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
