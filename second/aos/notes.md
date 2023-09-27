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

### Basics and CFS

See Love's Linux Kernel Development Ch. 4 <!-- Get used to it -->

#### Runqueues

The **central data structure** of the scheduler is known as the run queue. There
is **one per CPU** in order to avoid contention over task selection.

Each runqueue has **different run queues for each scheduling class**.

#### Scheduling classes

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

#### Cgroups

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

### Task scheduling in depth

A task, in this context, can be thought of as a **synonymous of a thread**.
However remember that it has no fixed definition: it is **simply the basic
scheduling unit**.

A **scheduler** is the OS component in charge of **establishing the execution
order of tasks**. The **ordering algorithm** is the **scheduling policy**.

```txt
                                preemption
                        ╭───────────────────────╮
                        ▼                       │
╭─────╮ activation ┌─────────┐ dispatching ╭─────────╮ termination
│Tasks│───────────>│ │ │ │ │ │────────────>│Execution│────────────>
╰─────╯            └─────────┘             ╰─────────╯
                   ready queue           ┏━━━━━━━━━━━━━┓
                        ^                ┃  processor  ┃
                   ┌─────────┐           ┗━━━━━━━━━━━━━┛
                   │ │ │ │ │ │<─────────────────╯
                   └─────────┘
                    I/O queue
```

**Preemption** is the operation of **temporarily suspending the execution of a
task in order to execute another task**. Can be task-triggered (unusual) or
OS-triggered (more common). Preemption is performed via a context switch.

#### Task model

We can model a task $i$ with the following **parameters**:

- $a_i$: **Arrival time** (or Request time); the time instant at which task is
  ready for execution and put into the ready queue
- $s_i$: **Start time**; the time instant at which execution actually starts
- $W_i$: **Waiting time**; the time spent waiting in the ready queue
  ($W_i = s_i-a_i$)
- $f_i$: **Finishing time**; time instant at which execution terminates
- $C_i$: **Computation time**; amount of time necessary for the processor to
  execute the task without interruptions
- $Z_i$: **Turnaround time**; difference between finishing and arrival time (not
  necessarily $W_i + C_i$)

  In case of preemption/suspension $Z_i$ also contains interferences from other
  tasks and the time the task is interrupted

Depending on the type of operations dominating the lifetime of a task, we may
identify **two bounds** for a task:

- **CPU-bound**: spends most of the time executing
  - $Z_i \approx W_i + C_i$ excluding preemptions
- **I/O-bound**: spends most of the time waiting for I/O
  - $Z_i \gg W_i + C_i$ excluding preemptions

#### Platform model

A computing system is composed of:

1. $m$ **processing elements** (PEs) $\{CPU_1, \ldots, CPU_m\}$
   - Each PE, at each $t$, is assigned zero or one task
     $A_{cpu}(CPU_k, t) = \tau_i \lor \emptyset$
   - A task $\tau_i$ can execute at time $t$ only if
     $\exists A(CPU_k, t) = \tau_i$
2. $s$ **additional resources** $\{R_1, \ldots, R_s\}$
   - Each resource, at each $t$, is assigned to zero or more tasks:
     $A\_{cpu}(CPU_k,t)=\{\tau_i,\tau_j,\ldots\}\lor\emptyset\}$
   - Depending on the type of resource, it may be exclusive
   - A task $\tau_i$ can execute at time $t$ if $\tau_i\in A(R_k, t)$ for all
     $R_k$ requires to run the task

#### Problem statement

Given:

1. A set of $n$ tasks $T$
2. A set of $m$ PEs
3. A set of resources
4. (Optionally) A set of precedent relationships and constraints

Compute an optimal schedule and allocations.

It is a **NP-complete problem** (usually reduced to the knapsack problem).

#### Metrics

The scheduler aims at **optimizing one or more objectives**. Some metrics that
help to determine if a policy is good are:

- **Processor utilization**: percentage of time the CPU is busy
- **Throughput**: number of tasks completing their execution per time unit
- **Waiting time**: time the tasks spends in the ready queue
- **Fairness**: do the tasks have a fair allocation of processor resources?
- **Overhead**: amount of time spent taking scheduling decisions and
  context-switches
- **Energy, power, temperature** and many more

Of course, some **trade-offs** have to be made since:

- We want to maximize utilization, throughput and fairness
- While we minimize the turnaround, waiting and completion time and overhead

And these goals clash with each other.

Whatever is the algorithm/policy, **the scheduler must guarantee that all tasks
are served**. **Starvation is the perpetuated condition where one or more tasks
cannot execute due to the lack of resources**.

#### Algorithm classification

- **Preemptive vs non preemptive**
  - Preemptive: tasks can be interrupted by the os at any time to make room for
    other tasks
  - Non-preemptive: once started, tasks are executed to completion, guaranteeing
    the lowest overhead
- **Static vs dynamic**
  - Static: scheduling decisions are based on fixed parameters
  - Dynamic: scheduling decisions are based on parameters that change at runtime
- **Offline vs online**
  - Offline: the scheduler is executed on a set of known tasks before their
    activation, the output is the sequence of tasks (the scheduler must also be
    static)
  - Online: the scheduler executes at runtime
- **Optimal vs heuristic**
  - Optimal: based on an algorithm optimizing a given cost (high overhead)
  - Heuristic: based on heuristic functions

## IPC

### Fork-wait

**Forking** is the operation whereby **a process spawns a new process which is a
copy** of itself. When we call `fork()`:

1. A new process is created and runs concurrently
2. The virtual address space is copied: All the variables have the same value
   with the exception of the `fork()`'s return value
3. Most of the physical pages in the memory are marked as "CoW"

**Every process** has exactly **one parent** and may have an **arbitrary number
of children**. The only exception is the **init process which is the ancestor of
all processes**. Every process has a:

- `PID`: Process ID
- `PPID`: Parent Process ID

In Linux the PID is of type `pid_t`.

The `exec*` family of functions allow us to **load a new program** and replace
the current process memory with it. The syscall they call is `execve`.

The **simplest synchronization** method between parent and child is the `wait()`
function.

```c
#include <sys/types.h>
#include <sys/wait.h>

// Suspend execution until one of the children exits
// Param:
// - status: pointer to a varaible where to return the exit status of the child
//
pid_t wait(int *status);

// Suspend the execution until a specific child process terminates (or changes
// state)
// Param:
// - pid: pid of the child to wait
// - status: pointer to a varaible where to return the exit status of the child
pid_t waitpid(pid_t pid, int *status, int options);
```

When a **process terminates**, the Linux kernel changes the **state to "zombie"
and saves its return value**, which is **returned to the parent when the parent
calls** `wait()` (or `waitpid()`) on the child process.

If the **parent terminates before calling** `wait`-ing, the child is **adopted
by** `init`. The `init` process `wait`-s on all children freeing the memory and
the PID number.

### Signals

A signal is an **asynchronous, unidirectional "message" with no data transfer**.
The **only information sent is the signal type**. Signals are used for
**communication between processes** (not threads). They can be sent either by
other processes or by the OS.

Most common signals:

| SIG       | Number | Action             | Description                                    |
| --------- | ------ | ------------------ | ---------------------------------------------- |
| `SIGHUP`  | 1      | Terminate          | Terminal disconnected                          |
| `SIGINT`  | 2      | Terminate          | Terminal interrupt                             |
| `SIGILL`  | 4      | Terminate and dump | Illegal instruction                            |
| `SIGABRT` | 6      | Terminate          | Process abort signal                           |
| `SIGKILL` | 9      | Terminate          | Process killed                                 |
| `SIGSEGV` | 11     | Terminate and dump | Segmentation fault                             |
| `SIGSYS`  | 12     | Terminate and dump | Invalid syscall                                |
| `SIGPIPE` | 13     | Terminate          | Write on a pipe with no readers                |
| `SIGTERM` | 15     | Terminate          | Process terminated                             |
| `SIGUSR1` | 16     | Terminate          | User-defined                                   |
| `SIGUSR2` | 17     | Terminate          | User-defined                                   |
| `SIGCHLD` | 18     | Ignore             | Child process terminated, stopped or continued |
| `SIGSTOP` | 23     | Suspend            | Process stopped                                |

```c
#include <signal.h>
#include <sys/types.h>

// Send signal to process
int kill(pid_t pid, int sig);

// Specify how to handle a signal
// Params:
// - signum: signal to catch
// - act: new settings
// - oldact: output variable - old settings
int sigaction(int signum, const struct sigaction *act, struct sigaction *oldact);

struct sigaction {
  void (*sa_handler)(int);                        // handler function
  void (*sa_sigaction)(int, siginfo_t *, void *); // alternative handler,
                                                  // available with POSIX
                                                  // real-time extension
  sigset_t sa_mask;                               // mask to block certain signals
  int sa_flags;                                   // various options
  void (*sa_restorer)(void);                      // DO NOT USE
};
```

The POSIX real-time extension adds some new functionality:

- `sigqueue()`: send a queued signal
- `sigwaitinfo()`: synchronously wait a signal
- `sigtimedwait()`: synchronously wait a signal, with timeout
- the `sa_sigaction` field allows us to specify a handler that accepts input
  data; flags must contain `SA_SIGINFO`

**A signal can be masked to avoid disruption**: it is similar to `SIG_IGN`, but
the **signal is not dropped and is instead enqueued to be managed later** when
the signal is unmasked. `SIGKILL` and `SIGSTOP` cannot be masked.

```c
// Mask a signal
// Params:
// - how:
//  - SIG_BLOCK: add to the mask
//  - SIG_UNBLOCK: remove from the mask
//  - SIG_SETMASK: replace the mask
// - set: set of signals
// - oldset: output variable - previous set of signals
int sigprocmask(int how, const struct sigset_t *set, struct sigset_t *oldset);
```

### Unnamed pipes

Based on the **producer/consumer pattern: one producer writes, one consumer
reads** (guaranteed by the OS in Linux). It is unidirectional. Data is written
and read in **FIFO order**.

```c
#include <unistd.h>
#include <fcntl.h>

// Create an unnamed pipe
// Params:
// - pipefd: arry of 2 integers to be filled with two file descriptors:
//  - [0]: fd for the read end of the pipe
//  - [1]: fd for the write end of the pipe
// - flags:
//  - O_CLOEXEC:  close fds if exec*() is called
//  - O_DIRECT:   perform I/O in "packet mode"
//  - O_NONBLOCK: avoid blocking in case of an empty pipe
int pipe(int pipefd[2]);
int pipe2(int pipefd[2], int flags);

// Low level read/write
ssize_t write(int fildes, const void *buf, size_t nbyte);
ssize_t read(int fildes, void *buf, size_t nbyte);

// Or we can transform our FS into a stream and use all stdio functions with it
FILE *fdopen(int fildes, const char *mode);
```

### Named pipes (FIFO)

**Same behaviour of unnamed pipes**, but instead of working with raw fds, we are
**using special files created by the OS. Note: no disk I/O is done**, the file
is just an abstraction.

```c
#include <sys/types.h>
#include <sys/stat.h>
// Create a new named pipe
// Params:
// - pathname: name of the pipe
// - mode: permissions of the file (e.g. S_IWUSR for 0200)
int mkfifo(const char *pathname, mode_t mode);
```

Then we just read from the file like normal.

### Message queues

IPC method suitable for **multiple readers and multiple writers**. Based on a
**priority-queue where producers enqueue messages and consumers dequeue
messages**. The **status of the message queue can be observable** (all files
available in `/dev/mqueue`). Requires linking with the POSIX real time library
(`-lrt`).

```c
#include <mqueue.h>

struct mq_attr {
  long mq_flags;   // 0 or NON_BLOCK
  long mq_maxmsg;  // max nr. messages in the queue
  long mq_msgsize; // max message size in bytes
  long mq_curmsgs; // nr. messages currently in the queue
};

// Open/create a message queue
// Params:
// - name:  Unique name for the queue (starts with /)
// - oflag: Opening flags
// - mode:  The file permissions to give to the file
// - attr:  Attributes
mqd_t mq_open(const char *name, int oflag, mode_t mode, struct mq_attr *attr);

int mq_close(mqd_t mqdes);
int mq_unlink(const char* name);
int mq_getattr(mqd_t mqdes, struct mq_attr *attr);
int mq_setattr(mqd_t mqdes, const struct mq_attr *newattr, struct mq_attr *oldattr);

// Send a message
// Params:
// - mqdes:    descriptor
// - msg_ptr:  pointer to the message to send
// - msg_len:  size of the message
// - msg_prio: priority of the message [0;31]
//    - higher msg_prio means higher priority
//    - messages of the same priority are handled in FIFO order
int mq_send(mqd_t mqdes, const char *msg_ptr, size_t msg_len, unsigned int msg_prio);

// Receive a message
// Params:
// - mqdes:    descriptor
// - msg_ptr:  output param - pointer to where to write the mesasge
// - msg_len:  size of the buffer
// - msg_prio: output param - priority of the read message
int mq_receive(mqd_t mqdes, char *msg_ptr, size_t msg_len, unsigned int *msg_prio);
```

### Shared memory

Shared memory is an IPC mechanism that allows **two processes to share a memory
segment**. In POSIX the shared memory is based on the **memory mapping**
concept. It requires the linking to the POSIX real-time extension library
(`-lrt`).

Like message queues, **opening/creation of shared memory segments are referenced
by name**. In Linux a **special file is created under** `/dev/shm/<name>`.

```c
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/fcntl.h>
#include <unistd.h>
#include <sys/types.h>

// Open/create a shared memory area
// Params:
// - name:  unique name (starting with /)
// - oflag: opening flags
// - mode:  the permissions
// Return: a file descriptor
int shm_open(const char *name, int oflag, mode_t mode);

// Setting the size of the shared segment
// Params:
// - fd:     descriptor
// - length: length in bytes
int ftruncate(int fd, off_t length);

// Map the memory to the VA space og the calling process
// Params:
// - addr:   starting address (null to let the kernel choose a value)
// - length: size of the mapped segment
// - prot:   memory protection flags
// - flags:  visibility of the updates w.r.t other processes
//   - MAP_SHARED: updates visible to other processes and carried out through an
//     update of the inderlying file
//   - MAP_PRIVATE: CoW updates
// - fd:     file descriptor
// - offset: offset to skip from the beginning of the fd
// Returns: pointer to the mapped area
void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset);

// cleanup
int munmap(void *addr, size_t length);
int shm_unlink(const char *name);
```

### Synchronization: semaphores

The `wait()/waitpid()` based approach is clearly very limited. POSIX provides
**semaphores**:

- Semaphore **counter = 0: wait**
- Semaphore **counter > 0: GO**

When the counter is maximum 1, the semaphore is called binary and behaves
similarly to a mutex.

Semaphores work with **two atomic functions**:

- `wait()`: **block until counter > 0, then decrement and proceed**
- `post()`: **increment the counter**

Similarly to pipes, POSIX semaphores can be **named or unnamed**. They require
the `-pthread` flag.

```c
#include <semaphore.h>

// Create an unnamed semaphore
// Params:
// - sem: output parameter - semaphore struct to init
// - pshared: 0 if shared among threads, otherwise shared among processes
// - value: initial value
// Returns: 0 on success, -1 on error
int sem_init(sem_t *sem, int pshared, unsigned int value);

// Destroy a semaphore
int sem_destroy(sem_t *sem);

// Create a named semaphore
// Params:
// - name
// - oflags
// - mode
// - value
// Returns: pointer to the semaphore object or SEM_FAILED in case of error
sem_t * sem_open(const char *name, int oflags);
sem_t * sem_open(const char *name, int oflags, mode_t mode, unsigned int value);

// Close and delete a named semaphore
int sem_close(sem_t *sem);
int sem_unlink(const char *name);

int sem_wait(sem_t *sem);
int sem_trywait(sem_t *sem); // non-blocking version of wait
int sem_timedwait(sem_t *sem, const struct timespec *timeout); // wait for timeout

int sem_post(sem_t *sem);
```
