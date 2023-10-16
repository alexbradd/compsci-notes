# Laboratory

## Intel Implicit SPMD Program Comiler (ISPC)

It compiles a C-based language for parallel computation. The compiler is based
on LLVM and freely available.

We use the Single Program Multiple Data paradigm to express parallelism across
SIMD lanes and tasks to express parallelism across cores. We will write only
some core parallelizable functions (kernel) and ISPC will compile them in a
format linkable with C/CPP objects, complete of a `hpp` file for usage in our
application.

The function(s) implemented in ISPC are executed by a "gang of program
instances". This "gang of program instances" is just a logical division, we're
not spawning new threads, but using SIMD instructions (like AVX) to vectorize
our code.

### Language

Each local variable has one of these qualifiers:

1. `uniform`: variable is shared across instances
2. `varying`: variable is "private" to each instance (default)

The ISPC language introduces ad-hoc statements to drive the parallelization,
like `foreach`. The `foreach` statement allows us to specify to specify a loop
over a possibly multi-dimensional domain of integer ranges:

```ispc
foreach(identifier = start ... end) { // identifier assumes values in [start;end)
  // body
}
```

The ISPC language exposes two sets of functions communicating between instances:

1. Cross-program instance operations: low level communication facilities
   (broadcast, rotate, shuffle)
2. Reductions: high level communication facilities (any, reduce_add, reduce_max)

To identify an instance, the compiler defines two variables:

1. `programIndex`: identifies each instance in a gang
2. `programCount`: the gang size

The two main functions of the low level interface are:

```ispc
// Input: our value and the programIndex of the sender
// Output: the value in the sender program
int32 shuffle(int32 value, int permutation);

// Input: our value and the programIndex of the sender
// Output: the value in the sender program
uniform int32 extract(int32 value, uniform int index);
```

But we want to use reductions when possible since it greatly simplifies code.

### Scaling across cores

A task is a program that executes asynchronously, each task is executed by a
gang. ISPC uses two keywords to manage tasks:

1. `launch[n]`: spawns $n$ tasks
2. `sync`: waits until all tasks terminate
   - The compiler automatically add a sync instruction before a return

A task is a function that has the `task` prefix and returns `void`:

```ispc
task void my_task_func( /* params */ ) { /* body */ }
```

We can use two built-in variables in the function body: `taskIndex` and
`taskCount` (which work exactly like `programIndex` and `programCount`). The
language, by default, does not spawn any thread for a task: how tasks are
handled at the OS level is left to the user. For example, we could integrate
OpenMP to manage tasks. We will use the example mapping that maps tasks to
posix threads.
