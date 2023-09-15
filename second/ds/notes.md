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
