# Advanced Operating Systems

## Intro

An **OS provides**:

- **Resource management**: by allowing programs to run as if they were assigned
  their individual resources and by multiplexing/virtualising access to ensure
  fair utilization of resources
- **Isolation and protection**:
  - Regulating/enforcing access rights to resources to avoid conflicts
  - Enforcing data access rights
  - Ensure mutual exclusion when needed
- **Portability**: by hiding the complexity of hardware access and allowing the
  same applications to work on systems equipped with different physical
  resources
- **Extensibility**: interface/implementation abstractions to allow adding new
  components ad hiding complexity associated to variants

## Processes

### TCB

The **task is the common denominator between a thread and a unix process**
(which are basically processes without threads). It contains:

1. A unique **program counter**
2. **Two stacks**, one in user mode and one in kernel mode
3. A set of **registers**
4. An **address space** (for kernel mode this is the whole kernel address space)

`task_struct`, or the Task Control Block (TCB), is the C `struct` that contains
all of the data about a given task. The **TCB is doubly linked to the
`thread_info` structure, which resides on the process's kernel mode stack**.
`thread_info` is used by the kernel to **retrieve the TCB of the currently
executing task**. One very important variable contained in `thread_info` is
`preempt_count`, which will be seen when we talk about kernel concurrency.

NOTE: `thread_info` is **architecture specific**, it could be different of even
not present at all.

When the kernel does a context switch, the **preserved registers will be saved
in** a structure called `thread_struct`.

```txt
        task_struct
┏━━━━━━━━━━━━━━━━━━━━━━━┓
┃State                  ┃
┃───────────────────────┃
┃PID                    ┃
┃───────────────────────┃
┃parent                 ┃
┃───────────────────────┃
┃          ⋅⋅⋅⋅         ┃
┃───────────────────────┃
┃mm (mm_struct)         ┃VM address space description
┃───────────────────────┃
┃          ⋅⋅⋅⋅         ┃
┃───────────────────────┃
┃fs (fs_struct)         ┃Current and root dirs
┃───────────────────────┃
┃          ⋅⋅⋅⋅         ┃
┃───────────────────────┃
┃files (files_struct)   ┃Opened files
┃───────────────────────┃
┃          ⋅⋅⋅⋅         ┃
┃───────────────────────┃
┃signal (signal_struct) ┃Signal info
┃───────────────────────┃
┃          ⋅⋅⋅⋅         ┃
┃───────────────────────┃
┃thread_struct          ┃$sp, $ra and calee saved
┗━━━━━━━━━━━━━━━━━━━━━━━┛regs at context switch

```

### Memory maps

The most important memory maps are:

- `start_stack`
- `mmap_base`: start of memory-mapped areas
- `start_brk` and `brk`: respectively start and end of heap
- `start_data` and `end_data`
- `start_code`

### Task state

```txt
   stopped ─╮       ╭▶ zombie
   ▲       SIGCONT  exit/SIGKILL
 SIGSTOP    ▼       │
   ╰───╭──────────────╮
       │             R│
       │╭ running ◀───┼─────────▶ int. sleep
       ││     │   │   │              │
       ││     ╰───┼───┼──────────────┼─╮
       ││     ╭───┼───┼─wakeup/SIG───╯ │
       ││     ▼   │   │                ▼
       │╰▶ ready ─╯◀──┼─wakeup─── unint. sleep
       ╰──────────────╯
```

### Wait queues

```C
// Source @ https://elixir.bootlin.com/linux/v6.1.5/source/include/linux/wait.h#L30
struct wait_queue_entry {
	unsigned int      flags;
	void             *private; // *task_struct
	wait_queue_func_t func;
	struct list_head  entry;
};

struct wait_queue_head {
	spinlock_t        lock;
	struct list_head  head;
};
typedef struct wait_queue_head wait_queue_head_t;

struct task_struct;
```

Each task that is sleeping is waiting for an event. **Each event has a wait
queue and tasks enqueue themselves into those queues** by calling either
`wait_event()` and `wait_event_interruptible()` and passing a callback
(`wait_queue_funct_t`).

**Events can wake up all the threads in the queue** by calling `wake_up()` and
invoke their callback. This creates a **"thundering herd"**: **only some tasks
will be able to read the data, all the others will simply wake up and then go
back to sleep**.

The solution is to **divide the queue of tasks into two parts**:

1. **Exclusive**: new tasks are put at the end of the queue
2. **Non-exclusive**: normal tasks

The kernel will **wake up all non-exclusive** tasks but **only the first
exclusive one**.

### Task hierarchies

We can **create new tasks** by calling `fork()`, which **internally invokes**
`sys_clone` **which creates a new copy of the** `task_struct` struct. The
`fork`-ed process will be called a 'child' while the `fork`-ing process the
parent.

The **copy will differ from the parent in terms of**:

1. **PID and PPID** (parent PID)
2. **Certain resources**, such as pending signals, **which are not inherited**

**Rather than duplicating the process address space**, the parent and the child
can **share the same copy**. If data is written to the shared copy, a duplicate
is made and each process receives a unique copy (**CoW** i.e. Copy on Write)

The `init` **task is the first process** (`pid 0`). After **initializing the
kernel** it creates a **new kernel thread** (`pid 1`) which will:

- **Finish starting the kernel**
- **Load the initrd** in memory
- **`kernel_execve` to `/bin/init`** (the system's init system)

To get things into motion, **`pid 0` will call the first `schedule()`** so that
`pid 1` can start executing.

The **traditional init system was SystemV**, or sysv. In sysv, the
**configuration of the system is divided in "runlevels"** which are different
configurations of the system (single-user, single-user with network etc...).
**The definition of what each runlevel runs is specified in `/etc/inittab`**.
Each runlevel was **basically a script that run different modules
_sequentially_**.

The **modern** (and normal) **init system is SystemD**. SystemD **overcomes the
limitation of sequential execution and also uses a declarative model** (unit
files) instead of the imperative one (scripts) of sysv:

1. The init daemon **loads various units**, which are **plain-text files that
   contain information about the service**
   - Services are the most common type of units, but not the only one
   - They **contain the ordering** to ensure that dependencies are started
     before the requiring unit
2. **Targets are collections of units** and emulate old runlevels

## Scheduling

See Love's Linux Kernel Development Ch. 4 <!-- Get used to it -->

### Runqueues

The **central data structure** of the scheduler is known as the run queue. There
is **one per CPU** in order to avoid contention over task selection.

Each runqueue has **different run queues for each scheduling class**.

### Scheduling classes

A **scheduling class is an API that includes policy-specific** code to:

- **Update current task time statistics** (`task_tick`)
- **Pick the next task** from the queue (`pick_next_task`)
- **Select the core** on which the task must be enqueued (`select_task_rq`)
- **Put the task on that queue** (`enqueue_task`).

Scheduling classes allow developers to implement thread schedulers without
reimplementing generic code and also helps minimizing the number of bugs.

Linux implements the following **classes**:

- `SCHED_DEADLINE`: implementation of the **Earliest Deadline First** (EDF)
  scheduling algorithm
- `SCHED_RR`: a task will **repeatedly go ahead of any task with lower
  priority** than itself; if multiple tasks have the **same priority**, it will
  **Round Robin** around those tasks
- `SCHED_FIFO`: like `RR`, but **if a task does not give up the CPU it will run
  indefinitely even if other tasks are the same priority** as itself
- `SCHED_OTHER` (also `SCHED_NORMAL`): **CFS** scheduler
- `SCHED_BATCH`: **longer timeslices**, well suited for batch jobs
- `SCHED_IDLE`: scheduled **only** if the CPU is **idle**

**If multiple policies have a runnable thread**, a choice must be made to
determine which policy has the highest priority. Linux chooses a simple
**fixed‐priority list** to determine this order (deadline -> real-time -> fair
-> idle).

The scheduler performs **load balancing by migrating threads between cores** in
order to **even the number of threads of all cores**. Load balancing is done
with a work stealing approach: **each core does its own balancing and tries to
steal threads from the busiest core on the system**.

Ordering between processes is implemented with a priority $\pi$:

- $\pi\in [0;99]$: **real-time** processes (`SCHED_FIFO` and `SCHED_RR`)
- $\pi\in [100;39]$: **non real-time** processes (`SCHED_NORMAL`)
  - Priority of normal processes is a function of the **niceness**
    $v\in [-20;=19]$ and is calculated as $\pi = 120+v$

### Cgroups

CFS is not enough to guarantee optimal CPU usage, so we need a **mechanism to
throttle and account for the CPU usage by various tasks**.

Main idea: **treat users as they were single tasks within the root runqueue and
assign explicitly their own CPU weight**. Child tasks have their own runqueue
and will take turn to consume each task group's timeslice. **These task groups
are called cgroups**.

This is implemented through **groups that can recursively include other groups
of tasks up to a root task group**. Each task group has a **dedicated CFS
runqueue**.

Linux build a corresponding **hierarchy of schedule entities** (per CPU). When a
task is accounted for time, also the parent group's entity is and so on until we
arrive at the root entity. `__pick_next_entity()` **picks the entity with the
smallest virtual runtime until a real task is selected**.
