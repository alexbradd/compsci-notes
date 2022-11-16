# Principles of programming languages

## Scheme (Racket)

Based on LISP, _"it allows to use the language to explore the design,
implementation and semantics of programming languages"_. We will use it to build
new constructs and an OO language.

Like LISP, it uses s-expressions:

```racket
(= x (+ y (* 3 x) z)) ; comment
```

Advantages of s-expressions:

1. **It allows arbitrary number of arguments**
2. **The programmer is describing the syntax tree of its program**
   - Very simple compilers/interpreters
   - Metaprogramming is very easy

### Basics

Basic types:

1. Booleans: `#t`, `#f`
2. Numbers: any precision, floating, complex; expressed with scientific
   notation or ratio
3. Chars: `#\a`
4. Symbols: `a-symbol?`, `another-symbol?`
5. Vectors: `#(1 2 3 4)`
6. Strings: `"aaa"`
7. Pairs and lists: `(1 2 #\a)`
   - Lists are the basis of the language: everything is a list (LISP), even the
     program themselves.

Every program is an _expression_: evaluation of expressions produces a value
(opposed to statements). The computation in scheme is based on evaluating
expressions. The evaluation of `(e1 e2 e3)` is as follows:

1. `e1` (usually a symbol) is evaluated first and identifies an operation `f`
2. The other parameters are evaluated _in any order_ and then passed to `f`

Like other functional languages, lambdas are present. Procedures are still
values, hence functions are first-class citizens.

```racket
(lambda (x y)
  (+ (* x x) (* y y)))
```

### Variables and binding

`let` binds new variables. It takes a list of 2 element lists containing name
value.

```racket
(let ((x 1)
      (y 2)))
```

Scoping is present and is static (not dynamic like in traditional LISP).

`let` binds variables parallely, `let*` does so sequentially. If mutual
recursion is needed, `letrec` and `letrec*`.

```racket
(let ((x 1)
      (y 2)
      (let ((x y) ; swaps x and y
            (y x))
      ...x)))

; vv this is wrong vv
(let ((x 1)
      (y (* 2 x))) ; x is still not defined at this point. We need to use let*
  ...)

(letrec ((f (lambda () (f))))
```

#### Static vs dynamic scoping

Consider the following:

```racket
(let ((a 1))
  (let ((f (lambda ()
              (display a))))
    (let ((a 2))
      (f))))
```

In scheme (static scoping) the result is `1`. Static scoping is derived from how
logic (like FOL) works. With dynamic scoping the result would be `2`.

### Homoiconicity

Scheme is **homoiconic: there is no distinction between code and data**. We have
that code is data, and this is very effective for metaprogramming.

_Note: machine code is itself homoiconic: both instruction and data are bytes,
the meaning depends on the interpretation_

### Syntactic forms

Not everything is a procedure or value: e.g. `if` is a syntactic form. Unlike
functions, `if` does not evaluate all its arguments. Similarly, `lambda` also is
a syntactic form. **We can define new syntax using macros**.

```racket
(if <condition> <then> <else>)
(when <condition> <then>)
(unless <condition> <else>)
```

Syntactic forms are needed beacuse we cannot create a language using only
call-by-value semantics: and `if(cond, then, else)` can be defined and wrapping
each branch in lambdas, but then how can we define lambdas?

### Quoting

**We can prevent evaluation by "quoting" an expression**. `quote` prevents
evaluation, `quasiquote` and `unquote` are used for partial evaluation:

1. `quasiquote` blocks external evaluation
2. `unqoute` forces evaluation

```racket
(quote <expr>)
('<expr>) ; shorthand for quote
`(1 ,(+ 1 1) 3) ; shorthand for quasiquote-unqoute
                ; evaluates to (1 2 3)
```

### Eval

`eval` is function that takes a code and interprets it. It is **effectively the 
opposite of `quote`**. _Note: `eval` is considered dangerous, never use it_

```racket
(eval '(+ 1 2 3)) ; outputs 6
```

### Begin

If we are writing procedural code, we can use the `begin` construct. It
evaluates vevery operation in order and the return value is the last one of the
block

```racket
(begin
  (op1 ...)
  (op2 ...)
  ...
  (opn ...))
```

### Define

`define` cretes top-leve bindings. Defining a procedure is done via `define`

```racket
(define <name> <what>)

(define x 12)
(define cube (lambda (x) (* x x x))) ; dot use this
(define (cube x) (* x x x)) ; use this for procedures
```

We can also use `define` in procedures instead of `let`. For assignment we can
use `set!` (_Note: functions with side-effects are by convention suffixed with `!`_).

### Lists

Lists are the center of the language (LISt Processor). Lists are **stored as
linked lists**. **Each node of the chain is pair called a _cons_ node. The first
element of the pair is data, and called `car` (Content of the Address Register),
while the second `cdr` (Content of the Data Register)**.

A **pair** is expressed in scheme as `(x . y)`. We can thus write a list as:

```racket
(1 . (2 . (3 . ())))
() ; the empty list, also called nil
```

**`car` and `cdr` functions are used as accessors. `member` checks element
presence and returns the `cdr` of the element**.

Defining data using **`'`, we are creating literal constants**. **To create a new
pair/lists/arrays we use constructors**: `cons` for pairs, `list` for lists
and `vector` for vectors.

**Procedure bodies and parameter lists are plain lists. This is used to implement
procedures with a variable number of arguments**.

```racket
(define (f x y) (...)) ; we are defining a function with 2 parameters
(define (f x . y) (...)) ; we are defining a function with a variable number of args
;          ~~~~~ -> we have the first argument boud to x and all the othes to y

;        ~~~~~ -> we define a function x with all variables bounded to y
(define (x . y) y)
(x 1 2 3) ; -> '(1 2 3)
```

`apply` can be used to apply a procedure to a list of elements.

```racket
(apply + '(1 2 3 4)) ; => 10
```

### Loops

One non-idimoatic way of looping is using a named `let`:

```racket
(let ((x 0))
  (let label ()
    (when (< x 10)
          (display x)
          (newline)
          (set! x (+ x 1))
          (label)))) ; basically a goto label
```

We can make things better by better utilizing the named `let`:

```racket
(let label ((x 0))
  (when (< x 10)
        (display x)
        (newline)
        (label (+ x 1)))) ; applies the return value of the last expression to
                          ; the bindings
```

Every scheme implementation is required to be tail-recursive.

```racket
(define (factorial n)
  (define (fact-rec x acc)
    (if (= x 0)
      acc
      (fact-rec (- x 1) (* x acc))))
  (fact-rec x 1))
```

For each has a peculiar syntax:

```racket
(for-each 
  (lambda (x)
    (display x)
    (newline))
  '(1 2 3 4))
```

### Equality

A predicate that returns a boolean by convention ends with `?` (e.g `null?`).
For testing equality between objects we have:

- `=`: used only for numbers
- `eq?`: tests if two objects are the same object
- `eqv?`: like `eq?` but defined for numbers
- `equal?`: true iff the unfolding of its arguments into regular trees are equal
  as ordered trees.

The longer the name, the more demanding the evaluation of the predicate.

### Case and cond

`case` is like a switch, while `cond` is a generalized if (if-elif chain). The
predicate used by `case` is `eqv?`

```racket
(case (car '(c d))
  ((a e i o u) 'vowel)
  ((w y) 'semivowel)
  (else 'consonant))
(cond ((> 3 3) 'greater)
       (< 3 3) 'equal)
       (else 'equal))
```

### Storage model

The language is garbage collected. Variables and objects simply refer to
locations on the heap. Constants reside in read-only memory, therefore literal
constans are immutable. Mutation, if possible, is achieved using `!` functions.

In racket, lists are immutable (so no `set-car!` or `set-cdr!`), unlike in LISP
or other dialects of scheme. There is, however, a mutable pair datatype with
`mcons`, `set-mcar!` end `set-mcdr!`.

### Evaluation strategy

Scheme uses _call by object sharing_, like java. Objects are allocated on the
heap and references to them are passed by values. It is also called _called by
value_, because objects are evaluated before the call and such values are copied
into the activation record. The copied values is not the object itself, but a
reference to it. This means that if the object is mutable, functions can exhibit
side effects.

### Structs

In scheme we can create structs (like in C). Constructor, predicate for checking
type and accessors (for mutable fields also setters) are created automatically
on delcaration.

```racket
(struct being (
  name            ; by default fields are immutable
  (age #:mutable) ; if we want to make them mutable we have to specify
  ))

(define p (being "pippo" 29)) ; `being` is automatically created
(being? p) ; `being?` is automatically created
(being-name p)
(being-age p)
(being-show p) ; like a print
(set-being-age! p 12) 
```

Structs can inherit from other structs:

```racket
(struct may-being being
  ((alive? #:mutable)))
(define (kill! x)
  (if (may-being? x)
    (set-may-being-alive?! x #f)
    (error "not a may-being" x)))
```

The main difference between the struct system and OOP is the difference between
procedures and methods: **Procedures are external, so we cannot
redefine/overrride them**.

### Closures

A closure is a **function together with a referencing environment for the
non-local variables of that function**. They are objects allocated on the heap
and can be seen as the basic unit of object orientation (data + behaviour).

#### Classic higher-order functions

These operations are supported on most languages: `map`, `filter` and folds.

Folds are more complicated. We have two of them: `foldr` and `foldl` (aka
`reduce` in python). Given $\circ$ a binary operation:

$$
\begin{gathered}
  fold_{left}(\circ, i, (e_1, \ldots, e_n)) &= (e_n \circ (e_{n-1) \circ \ldots ((e_1 \circ i))) \\
  fold_{right}(\circ, i, (e_1, \ldots, e_n)) &= (e_1 \circ (e_2 \circ \ldots (e_n \circ i)))
\end{gathered}
$$

The **left fold is more efficient, since it is easy to write as tail-recursion.
The right fold can be written to be tail recursive, however it can be
complicated and the results are not better**: the non-tail recursion uses the
stack, while the tail-recursive one uses the heap since it needs to allocate a
closure for each invocation.

### Macros

Macros are defined through `define-syntax` and `syntax-rules`. `syntax-rules`
are pairs of `(pattern expansion)`: `pattern` is matched by the compiler and
expanded into `expansion`.

```racket
(define-syntax while
  (syntax-rules ()          ; other keywords
    ((_ condition b1 ...)   ; _ is a shorthand for the keyword
                            ; ... is a keyword for matching multiple statements
     (let loop ()           ; expansion of p
        (when condition
          (begin
            b1 ...
            (loop)))))))
; Usage
(while (condition) 
  (intr1)
  (istr2))
```


**Macros are expanded recursively**, so we can have looping macros. Therefore the
macro system is Turing complete.

```racket
(define-syntax my-let*
  (syntax-rules ()
    ((_ ((var val)) istr ...)
      ((lambda (var) istr ...) val))
    ((_ ((var val) . rest) istr ...)
      ((lambda (var)
        (my-let* rest istr ...)) val))))
```

Scheme macros are **hygienic**, this means that symbols in their definition are
actually replaced with special unique symbols, meaning **it is impossible to have
name clashes** once the marco is expanded.

### Continuations

A continuation is an **abstract representation of the control state of the
program**. The **current continuation** is the continuation that, from the perspective
of running code, **would be derived from the current point in a program execution**.

Scheme natively supports continuations: **`call-with-current-continuation` (or
`call/cc`) accepts a procedure with one argument, to which it passes the current
continuation implemented as a closure**.

The **argument of the lambda** in `call/cc` is called an **escape procedure**. The
escape can be **called with an argument that becomes the result of `call/cc`**. This
means that the escape procedure abandons its own continuation and reinstates the
continuation of `call/cc`.

```racket
(+ 3
  (call/cc
    (lambda (exit)
      (for-each (lambda (x)
                  (when (negative? x)
                    (exit x)))
                '(54 0 37 -3 245 19))
      10)))
```

An escape procedure has **unlimited extend**: if stored, it **can be called after the
continuation has been invoked**.

We have two methods of implementing `call/cc`:

- **Garbage collected**: we handle function invocation via heap
  - We do not use the stack at all: **call frames are allocated on the heap**.
    Frames that are not used anymore are reclaimed by the GC. With this strategy
    `call/cc` simply saves the frame pointer of the current frame.
  - **Slows down all function calling**.
- **Stack strategy**: we use the stack as usual
  - When a `call/cc` is used, we create a **continuation object in the heap** by
    **copying the current stack**. When we call `call/cc` we need to **reinstate the
    saved stack, discarding the current one**.
  - It is **zero-overhead**: if we do not use `call/cc` we do not pay is cost
  - **The `call/cc` operation, however is very slow**.

## Playing around: implementing exceptions

Most scheme dialects have their exception systems. We will try to roll our own.

```racket
(define *handlers* (list))
(define (push-handler proc)
  (set! *handlers* (cons proc *handlers*)))
(define (pop-handler)
  (let ((h (car *handlers*)))
    (set! *handlers* (cdr *handlers))
    h))
(define (throw x)
  (if (pair? *handlers*)
    ((pop-handler) x)
    (apply error x)))

(define-syntax try
  (syntax-rules (catch)
    ((_ exp1 ... (catch what hand ...))
     (call/cc (lambda (exit)
                (push-handler (lambda (x)
                                (if (equal? x what)
                                  (exit (begin hand ...))
                                  (throw x))))
                (let ((res (begin exp1 ...)))
                  (pop-handler)
                  res))))))
```

### Object orientation

Quoting Alan Kay, the inventor of the term and Smalltalk:

> OOP to me means only messaging, local retention and protection and hiding
> of state-process, and extreme late-binding of all things. It can be done in
> Smalltalk and in Lisp. There are possibly other systems in which this is
> possible, but I’m not aware of them.
>
> Actually I made up the term "object-oriented", and I can tell you I did not
> have C++ in mind.

The classical interpretation of OOP from C++ are based on the Simula programming
language. Objective-C is a OO language that uses Smalltalk's concepts.

#### Closures

We can use closures to implement some basic OOP. We **define a procedure** which
assumes the **role of a class**. This procedure, when called, **returns closure that
works like an object**. **Access to the state is implemented through messages** to a
function that works like a dispatcher.

```racket
(define (make-object)
  (let ((my-var 0))
    (define (my-add x)
      (set! my-var (+ my-var x))
      my-var)
    (define (get-my-var) my-var)
    (define (my-display)
      (newline)
      (display "my-var is: ")
      (display my-var)
      (newline))
    (lambda (message . args)
      (apply (case message
                ((my-add) my-add)
                (else (error "Unknown method!")))
        args))))
```

**Inheritance** can be achieved by **delegation**.

```racket
(define (make-son)
  (let ((parent (make-object))
        (name "an object"))
    (define (hello) "hi!")
    (define (my-display x)
      (display "My name is: ")
      (display name)
      (display " and")
      (parent 'my-display))
    (lambda (message . args)
      (case message
        ((hello)  (apply hello args))
        ((my-display) (apply my-add args))
        (else (apply parent (cons message args)))))))
```

#### Prototypes

Take the concepts form Self: **there are no classes, new objects are obtained by
cloning and modifying existing objects** (it inspired javascript). We will
implement this model on top of scheme using **hash tables**.

```racket
(define new-object make-hash)
(define clone hash-copy)

; We could use functions, however we would need to pass `msg` already quoted
(define-syntax !! ;;; setter
  (syntax-rules ()
    ((_ object msg new-eval)
     (hash-set! object 'msg new-eval))))
(define-syntax ?? ;;; getter
  (syntax-rules ()
    ((_ object msg)
     hash-ref object 'msg)))
(define-syntax -> ;;; send message
  (syntax-rules ()
    ((_ object msg arg ...)
     ((hash-ref object 'msg) object arg ...)))) ;;; notice the first argument to
                                                ;;; the method call

;;; Example
(define Pino (new-object))
(!! Pino name "Pino")
(!! Pino hello
  (lambda (self x) ;;; defining a method. Notice the first argument
    (display (?? self name))
    (display (": hi, "))
    (display (?? x name))
    (display "!")
    (newline)))
```

**Inheritance is not typical** of systems like this. It can be achieved by
**delegation**.

```racket
(define (deep-clone obj) ;;; Recursively clone an object
  (if (not (hash-ref obj '<<parent>> #f))
    (clone obj)
    (let* ((cl (clone obj))
           (par (?? cl <<parent>>)))
      (!! cl <<parent>> (deep-clone (par))))))
(define (son-of parent) ;;; creates a new object that is the son of a given
                        ;;; parent
  (let ((o (new-object)))
    (!! o <<parent>> (deep-clone parent))
    o))

(define (dispatch object msg)
  (if (eq? object 'unknown)
    (error "Unknown message msg")
    (let ((slot (hash-ref object msg 'unknown)))
      (if (eq? slot 'unknown)
        (dispatch (hash-ref object '<<parent>> 'unknown) msg)
        slot))))
(define-syntax ??
  (syntax-rules ()
    ((_ object msg)
     (dispatch object 'msg))))
(define-syntax ->
  (syntax-rules ()
    ((_object msg arg ...)
     ((dispatch object 'msg) object arg ...))))
```
## Haskell

**Mathematical functions do not have side-effects: the result depends entirely on
the arguments**. This is called **referential transparency**.

Scheme was mainly functional as some function have side-effects (`set!`).
**Haskell**, instead, is **completely pure** and manages state and side-effects in a
different way.

### Evaluation

**In a system without side-effects, the evaluation order of parameters does not
matter**.

**Two evaluations of an expression differ in the order in which function
applications are evaluated**. A **function application ready to be performed** is
called a reducible expression (**redex**).

Some strategies are:

1. **Innermost**: when there is more than one redex, **the leftmost one that does not
   contain other redexes is evaluated**.

   With this strategy, **arguments of functions are always evaluated before
   evaluating the function itself**. This corresponds to **call-by-value**. It is the
   **faster** approach.
2. **Outermost**: dual to innermost, **we start with the redex that is not contained
   inside any other redex**.

   With this strategy, **functions are always applied before their arguments**. This
   corresponds to **call-by-name**.

   **If there is an evaluation for an expression that terminates, call-by-name
   terminates and produces the same result** (Church-Rosser confluence).

**Call-by-need** is a **memoized version of call-by-name** where, if the function
argument is evaluated, that value is stored for subsequent uses. In a pure
(side-effect-free) setting, this produces the same result as call-by-name and it
is faster.

One way to **overcome non-termination** of possible evaluations is to **use thunks**. We
can use a **`force` operation to evaluate it**. There is already an implementation
of this strategy in racket based on `delay` and `force`. We will re-implement a
version of it.

```racket
(struct promise
  (proc   ;;; thunk
   value? ;;; already evaluated?
   ) #:mutable)

(define-syntax delay
  (syntax-rules ()
    ((_ (expr ...))
     (promise (lambda () (expr ...)) #f)))) ; we created a thunk
(define (force promise)
  (cond
    ((not (promise? prom)) prom)
    ((promise-value? prom) (promise-proc prom))
    (else
      (set-promise-proc! prom ((promise-proc prom)))
      (set-promise-value?! prom #t)
      (promise-proc prom))))
```

**In Haskell call-by-need is the default**. If we need call-by-value, we need to
force evaluation (we'll see how).

### Currying

In Haskell **every function has one argument**. Functions with **multiple arguments
are curried**. This means that we turn `f: N x N -> N` into `f: N -> (N -> N)`
(parenthesis can be omitted since `->` is right associative).

To illustrate how it works let us look at this scheme example:

```racket
(define (sum-square x)
  (lambda (y)
    (+ (* x x) (* y y))))
(define ((sum-square x) y)
  (+ (* x x) (* y y)))

(display ((sum-square 3) 5)) ;;; -> 34
```

This make partial application free.

### Function definition

Functions are **declared through a sequences of equations**. This is also an example
of **pattern matching**: **arguments are matched with the right parts of equations,
top to bottom. If a match succeeds, that definitions body is called**.

```haskell
length :: [Integer] -> Integer
length []     = 0
length (x:xs) = 1 + length xs
```

### Type system

Haskell is **statically typed** with **type inference**: every well-typed expression is
guaranteed to have a unique principal type and can be inferred automatically. It
uses a **variant of the Hindley-Milner** type system (also used in other ML variants
like `F#`).

In Haskell is possible to do **parametric polymorphism by declaring type
variables**:

```haskell
-- `a` is a type variable, `[a]` indicates a list of type `a` for any `a`
length :: [a] -> Integer
```

#### User-defined types

New types are introduced using data declarations.

```haskell
-- This is like a tagged union type in C
data Bool = False | True
```

In the above, **`Bool` id the type constructor, while `False` and `True` data
constructors. These two constructors live in different namespaces so it is
possible to use the same name for both**:

```haskell
-- This is like a struct in C
data Point a = Point a a
```

If we apply a **data constructor we obtain a value** (`Point 2.3 5.7`) while with a
**type constructor we obtain a type** (`Point Float`).

#### Recursive types

Of course we can define recursive types. One example is the following:

```haskell
data Tree a = Leaf a
            | Branch (Tree a) (Tree a)
-- data constructor Branch has type Branch :: Tree a -> Tree a -> Three a

aTree :: Tree Char
aTree = Branch (Leaf 'a')
               (Branch (Leaf 'b') (Leaf 'c'))

-- example of a function working with Tree
fringe :: Tree a -> [a]
fringe (Leaf x)     = [x]
fringe (Branch l r) = fringe l ++ fringe r -- (++) is list concatenation
```

Lists are an example of recursive types. Using a scheme-like notation, they can
be defined like:

```haskell
data List a = Null 
            | Cons a (List a)
```

Haskell has special syntax for lists: `[]` is both a data and type constructor,
while `:` is an infix data constructor.

```haskell
-- Pseudo-haskell
data [a] = []
         | a : [a]
```

#### Fields

**Product types (like `Point`) are like structs in C or in Scheme. The access is
positional via pattern-matching**:

```haskell
pointX Point x _ = x
pointY Point _ y = y
```

There is also a **C-like syntax to have named fields with auto-generated
accessors**:

```haskell
data Point = Point { pointX, pointY :: Float }
```

#### Synonyms

Synonyms are defined with `type`. They are usually used for shortness or
readability.

```haskell
type String = [Char]
type Assoc a b = [(a,b)]
```

### Function composition and `$`

`(.)` is mathematical function composition: `(f.g)(x) = f(g(x))`. `$` (apply
operator) is an operator for avoiding some parenthesis, e.g 
`(10 *)(5 + 3) = (10 *) $ 5 + 3`.

### Infinite computations

**Call-by-need is very convenient for dealing with infinite computations that
provide data**.

```haskell
ones = 1 : ones -- infinite list of ones

numsFrom n = n : numsFrom (n + 1) -- equivalent to the [n..] notation
squares = map (^2) (numsFrom 0)

firstFiveSquares = take 5 squares -- perfectly legal to take a finite slice
```

**List comprehensions are here**. The syntax is inspired by that of the mathematical
set theory:

```haskell
l = [(x, y) | x <- [1,2], y <- "ciao"]
-- l = [(1, 'c'), (1, 'i'), (1, 'a'), (1, 'o'),
--      (2, 'c'), (2, 'i'), (2, 'a'), (2, 'o')]

fib = 1:1:[a + b | (a, b) -> zip fib (tail fib)]
```

### Error

Bottom ($\bot$), is defined as `bot`. **All errors have value `bot`, a value
shared by all types**. `error :: String -> a` is an outlier because it is
polymorphic in the output. The reason is that it returns `bot`.

### Pattern matching

We have already seen pattern matching: **it goes top-down, left-to-right**. Patterns
**may have boolean guards**.

```haskell
sign x | x > 0  = 1
       | x == 0 = 0
       | x < 0  = -1
```

**Patterns have to be linear: each identifier has to be unique**.

```haskell
f (x:x:xs) = undefined          -- IMPOSSIBLE
f (x:y:xs) | x == y = undefined -- POSSIBLE
```

Another way of doing pattern matching is by using `case`:

```haskell
take m ys = case (m, ys) of
              (0, _)    -> []
              (_, [])   -> []
              (n, x:xs) -> x : take (n - 1) xs

-- equivalent to:
take 0 _      = []
take _ []     = []
take n (x:xs) = x : take (n - 1) xs
```

### If-then-else

**If-then-else is also present**: `if condition then then-clause else else-clause`.
N.B: with call-by-need we can define `if` as a function:

```haskell
if True  x _ = x
if False _ y = y
```
### `let` and `where`

`let` is similar to Scheme's `letrec*`. `where` is similar but reversed:

```haskell
let x = 3
    y = 12
in x + y

powerset :: [a] -> [[a]]
powerset set = powerset' set [[]] where
  powerset' [] out = out
  powerset' (e:set) out = powset' set (out ++ [e:x | x <- out])
```

### Call-by-need and strictness

**In scheme**, we saw that **fold-left** is very **efficient** as it is **naturally tail
recursive**. **In Haskell this does not hold true: due to call by need it is very
memory intensive**.

```haskell
foldl f z []     = z
foldl f z (x:xs) = foldl f (f z x) xs
```

Most of Haskell code uses `foldr` and this is one of the reasons.

There are **various ways to enforce strictness** in Haskell:

1. In **data types**: `data Complex = Complex !Float !Float`. It tells the compiler
   to **never store unevaluated expression inside those fields**. There are
   **extensions for using `!` also for function parameters**.
   2. We can force evaluation of a function using `seq:: a -> t -> t`. **The
   semantics of `seq` are the following: `seq x y` returns `y` only if `x`
   terminates**.

   We can define a strict version of `foldl`:

   ```haskell
   foldl' f z []     = z
   foldl' f z (x:xs) = let z' = f z x
                       in seq z' (fold' f z' xs)
   ```

   **There is a convenient strict variant of `$` called `$!`**.

### Modules

Simple module, with `import`, `export` and namespaces.

```haskell
module Test where -- export everything
...

module Tree (Tree(Leaf, Branch), fringe) where
...

module Main (main) where
import Tree (Tree(Leaf,Branch))
main = print (Branch (Leaf 'a') (Leaf 'b'))
```

### Type classes

Type classes are the mechanism for providing **ad hoc polymorphism** (aka
overloading).

Let us consider a function like `elem`. What should be its type?

```haskell
x `elem` []     = False
x `elem` (y:ys) = x == y || (x `elem` ys)
```

**We need to express the fact that `==` is defined for all types acceptable by the
function**. We can use the **type class `Eq`** and declare a type to be an instance of
said class. If a **type is instance of a class it means it implements all
functions of said class**.

```haskell
class Eq a where
  (==) :: a -> a -> Bool
...

elem :: (Eq a) => a -> [a] -> Bool
...
```

`(Eq a)` is called a **constraint** on type `a`.

To define an instance for a class we use the following syntax:

```haskell
-- we added a constraint on the instance: we can check equality of `Tree a` only
-- if `a` implements `Eq`
instance (Eq a) => Eq (Tree a) where
  Leaf a == Leaf b = a == b
  (Branch l1 r1) == (Branch l2 r2) = (l1 == l2) && (r1 == r2)
  _ == _ = False
```

The **implementation** of functions **in classes are called methods**.

There is **inheritance (multiple) between classes** (e.g. `Ord`):

```haskell
class (Eq a) => Ord a where
  ...
```

**Some classes can be auto-implemented** by the compiler using the `deriving`
keyword:

```haskell
data Tree a = Leaf a | Tree a a
              deriving (Show,Eq)
```

### IO

**IO cannot be referentially transparent since it is based on state change**. This
means that if we perform a sequence of operations, they must be performed in
order.

We introduce the **IO action**. IO is an **instance of the monad class**.

```haskell
getChar :: IO Char
putChar :: Char -> IO ()
```

`main` is the default entry point of a program. For **working with actions we have
some special syntax at our disposal**:

- `do` starts a block or ordered operations
- `<-` is used to obtain a value from an action

```haskell
main :: IO ()
main = do 
  putStr "Say something: "
  thing <- getLine
  putStrLn $ "You said \"" ++ thing ++ "\"."
```

Example of program that reads a file and prints its contents:

```haskell
import System.IO
import System.Environment

main = do
  args <- getArgs
  handle <- openFile (head args) ReadMode
  contents <- hGetContents handle -- note: hGetContents lazily reads the file
  putStr contents
  hClose handle
```

#### Exceptions

**Haskell code can raise exceptions but to catch them we need an IO action**.
There are **different ways** of handling exceptions, the simplest one is `handle`

```haskell
handle :: Exception e => (e -> IO a) -> IO a -> IO a

-- usage
main = handle handler readfile
       where handler e
          | isDoesNotExistsError e = putStrLn "File does not exists"
          | otherwise = putStrLn "Something has gone wrong"
```

### Maps and arrays

Some useful data structures are **arrays and hash-tables**. However, the way of
interacting with said structures is imperative (there are libraries for using
this style). The standard Haskell way is to use **immutable versions of this
structures**: updates to them copy the structure, not change it.

```haskell
import Data.Map
import Data.Array

exmap = let m = fromList [("nose", 1), ("emerald", 27)]
            n = insert "rug" 98 m
            o = insert "nose" 9 n
        in (m ! "emerald", n ! "rug", o ! "nose")
-- exmap -> (27, 98, 9)

exarr = let m = listArray (1,3) ["alpha", "beta", "gamma"] -- (1,3) is the range of indexes
            n = m // [(2,"Beta")]                          -- `//` executes a list of updates
            o = n // [(1,"Alpha"), (3,"Gamma")] 
        in (m ! 1, n ! 2, o ! 1)
-- exarr -> ("alpha", "Beta", "Alpha")
```

### Towards monads

We saw that IO is a type construct instance of Monad. In recent versions of GHC
the **Monad class needs the introduction of: Foldable, Functor and Applicative** 
($Functor \contains Applicative \contains Monad$).

#### Foldable

Used for folding. It **requires only the definition of** `foldr` (`foldl` can be
derived from `foldr`). The basic idea is to **apply a function `f` to all the
elements in a container, starting from a value `z`**.

##### Maybe

The Maybe type is **like the Optional java type**: it has two values `Just v` and
`Nothing`. It is a **simple example of an instance of Foldable**.

```haskell
instance Foldable Maybe where
  foldr _ z Nothing  = z
  foldr f z (Just x) = f x z
```
#### Functor

Functor is the **class of all the types that offer a map operation**. The map
operation of functors is called `fmap :: (a -> b) -> f a -> f b` (just like
`map`). Defining a mapping for containers is quite natural.

```haskell
instance Functor Maybe where
  fmap _ Nothing  = Nothing
  fmap f (Just a) = Just (f a)
```

**Well defined functors should obey the following rules** (not checked by compiler,
but necessary to have it make sense):

1. `fmap id = id`
2. `fmap (f . g) = fmap f . fmap g` (homomorphism)

#### Applicative functors

Applicative functors are an **extension of functors**. The definition of the class
is peculiar:

```haskell
class (Functor f) => Applicative f where
  pure  :: a -> f a
  (<*>) :: f (a -> b) -> f a -> f b -- called apply
```

If `f` is a container, the ideas are not too complex:

1. **`pure` takes a value and returns an `f` containing it**
2. **`<*>` is like `fmap`**, but instead of taking a function, **it takes an `f`
   containing functions**, to apply it to a suitable container of the same kind

Maybe is an applicative functor, the instance definition is trivial. **Lists are
also functors**. Lets see if they are **also applicative**.

```haskell
concat :: Foldable t => t [a] -> [a]
concat l = foldr (++) [] l -- [[1,2], [3], [4,5]] => [1,2,3,4,5]

concatMap :: Foldable t => (a -> [b]) -> t a -> [b]
concatMap f l = concat $ map f l

instance Applicative [] where
  pure x    = [x]
  fs <*> xs = concatMap (\f -> map f xs) fs

-- Example of apply:
-- [(+1), (*2)] <*> [1,2,3] => [2,3,4,2,4,6]
```

### Monads

Monads are **an algebraic data structure used to represent computations**, we will
often call these computations actions. Monads allow the programmer to **chain
actions together to build an ordered sequence, in which each action is decorated
with additional processing rules provided by the monad and permed automatically**.

Monads can also be used to make imperative programming easier in a pure
functional language.

```haskell
class Applicative m => Moand m where
  -- Most important operation: bind. Sequentially composes two actions, passing
  -- any value produced by the first as an argument to the second
  (>>=) :: m a -> (a -> m b) -> m b

  -- Called then. Sequentially composes two actions, discarding any value
  -- produced by the first
  (>>) :: m a -> m b -> m b
  m >> k = m >>= \_ -> k

  -- Injects a value into the monadic type
  return :: a -> m a
  return = pure

  -- Fail with a message
  fail :: String -> m a
  fail s = error s
```

Let us look at a simple monad instance:

```haskell
instance Monad Maybe where
  (Just x) >>= k   = k x
  Nothing  >>= _   = Nothing
  fail _           = Nothing
```

#### Monadic laws

1. `return` is the **identity element**:
  
   ```txt
   (return x) >>= f  <=>  f x
   m >>= return      <=>  m
   ```

2. **Bind is associative**:

   ```txt
   (m >>= f) >>= g   <=>   m >>= (\x -> (f x >>= g))
   ```

Note: **monads are analogous to monoids** with `return = 1` and `>>= = '='`.

#### The `do` notation

The `do` notation is used as **syntactic sugar to hide `>>=` and `>>`**. The
translation of `do` is dictated by these two rules:

1. `do e1 ; e2        <=>   e1 >> e2`
2. `do p <- e1 ; e2   <=>   e1 >>= \p -> e2`

#### The list monad

The **list type is an instance of the monad class**: it involves **joining together a
set of calculations for each value in the list**. `bind` is defined as
`concatMap`. The **underlying idea** is to represent **non-deterministic computation**
with a set of possible results.

Using the list monad, we can define **list comprehensions** as:

```haskell
[(x,y) | x <- [1,2,3], y <- [1,2,3]]
--- equivalent to
do x <- [1,2,3]
   y <- [1,2,3]
   return (x,y)
```

#### The State monad

The `State` monad is a generic type that **manages state**.

```haskell
data State st a = State (st -> (st, a))
```

The constructor **takes a function** because the `State` takes two parameters and **we
need unary type constructors**. The function **takes the current state, performs the
computation and returns a tuple containing the new state and the result**.

First we need to instance **Functor**:

```haskell
-- We apply `f` to the value of `a`
instance Functor (State st) where
  fmap f (State g) = State (\s -> let (s', x) = g s
                                  in (s', f x))
```

Then instance **Applicative**:

```haskell
instance Applicative (State st) where
  pure x = State (\t -> (t, x))

  (State f) <*> (State g) =
    State (\state -> let (s, f') = f state
                         (s', x) = g s
                     in (s', f' x))
```

The same approach can be used for the **monad** definition:

```haskell
instance Monad (State state) where
  State f >>= g = State (\old ->
                          let (new, value) = f old
                              State f' = g value
                          in f' new)
```

An important aspect of this monad is that **monadic code does not get evaluated to
data, but to a function!** (Note that State is a function and bind is function
composition). To **get a value out** of the `State` monad we can define:

```haskell
runStateM :: State state a -> state -> (state, a)
runStateM (State f) st = f st
```

To actually use the state contained in our moand, we can define **some utilities
to access it**:

```haskell
getState = State (\state -> (state, state))
putState new = State (\_ -> (new, ()))
```
