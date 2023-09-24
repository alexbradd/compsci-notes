# Distributed Systems

## Intro

Definition of distributed system:

1. A collection of independent computers that appears to its users as a single
   coherent system
2. One in which hardware or software components located at networked computers
   communicate and coordinate their actions only by passing messages
3. One on which I cannot get any work done because some machine I have never
   heard of has crashed

Some defining features are:

- Concurrency
- Absence of a global lock
- Independent (and partial) failures

And some common problems for DSs are:

1. Heterogeneity: different machines have different specs/os/architecture with
   components written in different programming languages
2. Openness: whether a system can be extended and re-implemented in various ways
3. Security: needs to provide CIA and be resilient to attacks
4. Scalability: ability to increase the size of the system in terms of
   users/resources, geographic span, administrative span
5. Failure handling: detect/mask/tolerate/recover from failures
6. Concurrency
7. Transparency: we need to hide to the upper layers some details of the
   distributed system (by providing abstractions) as much as possible

## Modeling

### Software architecture

We have **two usual architectures**:

1. **Network OS based**:

   ```txt
   ┌─────────┐┌─────────┐┌─────────┐
   │         ││         ││         │
   │         ││         ││         │
   │┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓│
   │┃   Distributed Application   ┃│
   │┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛│
   │┌───────┐││┌───────┐││┌───────┐│
   ││Net. OS││││Net.OS ││││Net.OS ││
   │└───────┘││└───────┘││└───────┘│
   │┌───────┐││┌───────┐││┌───────┐│
   ││Kernel ││││Kernel ││││Kernel ││
   │└───────┘││└───────┘││└───────┘│
   └─────────┘└─────────┘└─────────┘
   ```

2. **Middleware based**: Middleware provides “business-unaware” services through
   a standard API. Usually it provides:

   - Communication and coordination services
   - Special application services
   - Management services

   ```txt
   ┌─────────┐┌─────────┐┌─────────┐
   │         ││         ││         │
   │         ││         ││         │
   │┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓│
   │┃   Distributed Application   ┃│
   │┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛│
   │┌─────────────────────────────┐│
   ││          Middleware         ││
   │└─────────────────────────────┘│
   │┌───────┐││┌───────┐││┌───────┐│
   ││Kernel ││││Kernel ││││Kernel ││
   │└───────┘││└───────┘││└───────┘│
   └─────────┘└─────────┘└─────────┘
   ```

### Run-time architecture

The runtime-architecture is usually one of a small set of very well-known
architectural styles like:

- **Client-server**
- **Service Oriented**: built around the concepts of

  - **Services**: loosely coupled units of functionality
  - **Service providers**: export services
  - **Service brokers**: hold the description of available services
  - **Service consumer**: those who bind and invoke the services they need

  **Orchestration** is the process of invoking a set os services in an ad-hoc
  workflow to satisfy a given goal

  A **web service** is "a software designed to support interoperable
  machine-to-machine interaction over a network". Its **interface** is described
  in **WSDL** and is invoked through the SOAP protocol. **UDDI** describes the
  **rules that allows web services to be exported and searched through a
  registry**.

- **REST**: _REpresentational State Transfer_ is a set of principles that define
  how web standards are supposed to be used

  - Key **goals**:
    - **Scalability** of component interactions
    - **Generality of interfaces**
    - **Independent deployment of components**
    - Intermediary components to **reduce latency**, **enforce security** and
      **encapsulate** legacy systems
  - Main **constraints**:
    - **Client-server** and **stateless interactions** (state must be
      transferred from clients to servers)
    - The **data** within a response must be **labeled as cacheable or not**
    - Each component cannot "see" beyond the immediate layer with which they are
      interacting (**layered**)
    - (Optional) Clients must support **code on-demand**
    - Components expose a **uniform interface** with the following
      **constraints:**
      - **Identification of resources** (each resource must have and ID)
      - **Manipulation** of resources **through representations**
      - **Self-descriptive messages**
      - **Hypermedia as the engine of application state**

- **Peer-to-peer**: all components play the **same role**
  - Why:
    - **Client-server does not scale well** due to the centralization (it was
      dominant when there where less clients)
    - A server is a central point of failure
    - P2P leverages the availability of broadband and processing power at the
      end-host to overcome the scalability issues
  - P2P **promotes the sharing of resources and services** through direct
    exchange between peers
- **Object-oriented**: the components **encapsulate a data structure providing
  an API to access and modify it**; each component is responsible for the
  integrity of said structure and hides the details of its implementation
  - Components interact through **RPC**
  - It is a "P2P" model but is often used to implement client-server
- **Data-centered**: components **communicate synchronously through a common
  (usually passive) repository through (usually) RPC**

  **Linda** is a data sharing model proposed in the 80s, mostly used for
  parallel computation and recently revitalized in the context of distributed
  computing.

  In Linda data is **contained in typed tuples, stored in a persistent global
  shared space** (tuple space). Standard operations are:

  - `out(t)`: write the tuple in the tuple space
  - `rd(p)`: returns a copy of a tuple matching the pattern, blocking if no
    match is found
  - `in(p)`: like `rd(p)`, but withdraws the matching tuple from the space
  - `eval(a)`: (optional) inserts a tuple generated by execution of the process
    `a`

  Many variants are **also async and provide other non-standard primitives and
  non-trivial distributed applications**

- **Event-based**: components collaborate by **exchanging information about
  occurring events**

  - Components **publish notifications** about events they observe
  - They **subscribe** to the events they are interest about

  The communication is:

  - Purely message based
  - Async
  - Multicast
  - Implicit
  - Anonymous

  It **requires a central event-broker** that keeps track of all the
  subscribe/publish relations. It is usually provided by middleware.

- **Mobile code**: it is based on the ability of **relocating code at runtime**.
  It can implement different paradigms based on how it is implemented:

  - **Client-server**: I tell the remote what I want to do and it does it
    (REST-like)
  - **Remote evaluation**: I send the code to the remote that executes it in its
    environment (e.g. Google Colab)
  - **Code on-demand**: I ask a remote to send me the code to execute
    (JavaScript on the web)
  - **Mobile agent**: I move the whole process (code + state) to a remote (sort
    of like VM migration) (used rarely)

  A system provides:

  - **Strong mobility**: if it has the ability to migrate both the code and the
    execution state to a different environment (like the mobile agent case);
  - **Weak mobility**: if it has the ability to allow code movement across
    different environments (like code on-demand and remote evaluation).

  **Pros**: the **mobility**; **Cons**: the **security**

### Interaction model

Traditional programs can be described in terms of the algorithm they implement,
however distributed systems are composed of many processes, which interact in
complex ways. The behaviour of a distributed system is described by a
distributed algorithm:

> A distributed algorithm is a definition of the steps taken by each process,
> including the transmission of messages between them.

To formally **analyze the behavior of a distributed system we must distinguish**
(at least in principle) between:

1. **Synchronous** distributed systems:
   - **The time to execute each step of a process has known lower and upper
     bounds**
   - **Each message transmitted** over a channel is received within a **known
     bounded time**
   - **Each process has a local clock whose drift rate** from real time has a
     **known bound**
2. **Asynchronous** distributed systems:
   - There are **no bounds** for process execution speeds, message transmission
     delays, clock drift rates

**Any solution that is valid for an asynchronous distributed system is also
valid for a synchronous one** (but the vice versa is clearly false)

### Failure model

Both processes and communication channels may fail. The **failure model defines
the ways in which failure may occur**. We distinguish between:

1. **Omission failures**:
   - Processes: fail stop
   - Channels: send omission, channel omission, receive omission
2. **Byzantine failures**:
   - Processes: may omit intended processing steps or add more
   - Channels: message content may be corrupted, non-existent messages may be
     delivered or real messages may be delivered more than once
3. **Timing failures** (only for synchronous systems):
   - occur when one of the time limits defined for the system is violated

Distributed consensus has been formally demonstrated to be impossible. To make
the problem possible we need to either:

1. Change the assumptions (e.g. make links reliable)
2. Reduce the guarantees (e.g. only probabilistic instead of deterministic)

**We can describe algorithms only for synchronous systems, with bounds large
enough that they work even in the asynchronous world with high enough
probability**.

## Communication

Middleware includes common services and protocols that can be used by many
different applications. We can see the **middleware layer as a protocol layer**.

Middleware may **offer different form of communication** like:

- **Transient/persistent**: transient is communication that requires both
  parties to be available at the same time (e.g. a phonecall)
- **Synchronous/asynchronous**: synchronicity w.r.t the middleware software,
  reception or response

We will se some communication methods.

### RPC

In a local procedure call, parameters are passed on the stack, in different ways
(value, reference, copy/restore). **What if the procedure we executed was on a
remote machine**? The **remote communication can be hidden by the procedure call
mechanism**.

```txt
                              Procedure execution
                             ┌╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶╶┐
╭─────────────────────╮     ╭┼───────────────────┼╮
│┃    app code       ▲│     │┃      app code     ▲│
│┃───────────────────┃│     │┃───────────────────┃│
│▼   client stub     ┃│     │▼    server stub    ┃│
│┃   (middleware)    ▲│     │┃    (middleware)   ▲│
│┃───────────────────┃│     │┃───────────────────┃│
│▼ network transport ┃│     │▼ network transport ┃│
╰─────────────────────╯     ╰─────────────────────╯
 ╏                   ┗╺╺╺╺╺╺╺┛                   ▲
 ╏                   Reply msg                   ╏
 ╏                                               ╏
 ┗╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺╺┛
                 Invocation message
```

In RPC **parameter passing** poses **two problems**:

1. **Structured data must be flattened** in a byte stream (**serialization**)
2. **Hosts may use different data representation** and proper conversions are
   needed (**marshalling**)

**Middleware** provides **automated support** by automatically generating
marshalling/serialization code **from the function signature**.

RPC is enabled by a **platform and language independent representation of the
procedure's signature**, a Interface Definition Language (**IDL**), **and a data
representation format** to be used during communication. It **separates the
service interface from its implementation**. The IDL comes with mappings onto
target programming languages.

We still have the **problem of passing parameters by reference**/pointer. Often
this is **unsupported**. A possibility is to change the semantics and make the
passing by value/result.

The gold standard is Sun Microsystem's RPC (also called Open Network Computing
RPC). The Distributed Computing Environment is another set of standards, more
modern than sun's.

#### Binding

RPC poses the problem of **finding which server provides a given method**
(binding the cline to the sever). This problem is divided in **two other
sub-problems**:

1. Find out **where the server process is**
2. Find out **how to establish communication** with it

**Sun's solution** is to include a daemon (`portmap`) that is basically a
forwarding table: it **maps procedures to server/port couples**. This solution,
however, **solves only the second problem** because the client needs to know in
advance where the service resides.

**DCE's solution** is a **directory service**, aka a binder daemon, that enables
location transparency. Client need to know only the location of the directory
service. It can then query the directory to get the service's location. Servers
simply register their presence in the directory.

#### Dynamic activation

To start the server process on demand, we can use a standard daemon (`inted`)
that **launches the needed process only when a packet arrives on the configured
port**.

#### Lightweight RPC

**RPC can be used in any case where there is a need for communication between
processes**. If the two processes are **running on the same machine**, we can
build a **lightweight variant** of the RPC protocol **using e.g. shared memory
maps** for communication.

#### Asynchronous RPC

**RPC is by definition synchronous** since it is trying to emulate the natural
call behaviour. We can also **make RPC async by modifying the call semantics**
(introducing callbacks on procedure termination etc).

**We can also implement batched/queued RPC to achieve very efficient
communication and high performance**.

### RMI

It starts from the **same idea as RPC**, but it uses different programming
constructs. The **aim is to obtain the advantages of OOP in the distributed
setting**.

An important difference w.r.t RPC is that **remote object references can be
passed around: we need to maintain the aliasing relationship**. This is easier
in a OOP setting since **we interact with objects only through their
interfaces**. This means that **passing a reference to an object is equivalent
to passing a reference to a proxy implementing the remote call procedure**. In
contrast to RPC, **in RMI true pass-by-value is instead impossible**.

In RMI, we can use the fact that the separation between interface and
implementation is a basic principle and have **very rich IDLs that can model
complex relationships and behaviours** (e.g. inheritance, exceptions).

Implementation is similar to that of RPC, so much so that often it is
implemented on top of a RPC layer.

Two popular RMI middlewares are:

1. Java RMI (everything must be java)
2. OMG Corba (multilanguage/multiplatform)
