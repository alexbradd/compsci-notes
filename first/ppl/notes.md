# Principles of programming languages

## Scheme (Racket)

Based on LISP, _"it allows to use the language to explore the design,
implementation and semantics of programming languages"_. We will use it to build
new constructs and an OO language.

Like LISP, it uses s-expressions:

```scheme
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
   - Lists are the basis of the language: everthing is a list (LISP), even the
     program themselves.

Every program is an _expression_: evaluation of expressions produces a value
(opposed to statements). The computation in scheme is based on evaluating
expressions. The evaluation of `(e1 e2 e3)` is as follows:

1. `e1` (usually a symbol) is evaluated first and identifies an operation `f`
2. The other parameters are evaluated _in any order_ and then passed to `f`

Like other functional languages, lambdas are present. Procedures are still
values, hence functions are first-class citizens.

```scheme
(lambda (x y)
  (+ (* x x) (* y y)))
```

### Variables and binding

`let` binds new variables. It takes a list of 2 element lists containing name
value.

```scheme
(let ((x 1)
      (y 2)))
```

Scoping is present and is static (not dynamic like in traditional LISP).

`let` binds variables parallely, `let*` does so sequentially. If mutual
recursion is needed, `letrec` and `letrec*`.

```scheme
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

```scheme
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

```scheme
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

```scheme
(quote <expr>)
('<expr>) ; shorthand for quote
`(1 ,(+ 1 1) 3) ; shorthand for quasiquote-unqoute
                ; evaluates to (1 2 3)
```

### Eval

`eval` is function that takes a code and interprets it. It is **effectively the 
opposite of `quote`**. _Note: `eval` is considered dangerous, never use it_

```scheme
(eval '(+ 1 2 3)) ; outputs 6
```

### Begin

If we are writing procedural code, we can use the `begin` construct. It
evaluates vevery operation in order and the return value is the last one of the
block

```scheme
(begin
  (op1 ...)
  (op2 ...)
  ...
  (opn ...))
```

### Define

`define` cretes top-leve bindings. Defining a procedure is done via `define`

```scheme
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

```scheme
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

```scheme
(define (f x y) (...)) ; we are defining a function with 2 parameters
(define (f x . y) (...)) ; we are defining a function with a variable number of args
;          ~~~~~ -> we have the first argument boud to x and all the othes to y

;        ~~~~~ -> we define a function x with all variables bounded to y
(define (x . y) y)
(x 1 2 3) ; -> '(1 2 3)
```

`apply` can be used to apply a procedure to a list of elements.

```scheme
(apply + '(1 2 3 4)) ; => 10
```

### Loops

One non-idimoatic way of looping is using a named `let`:

```scheme
(let ((x 0))
  (let label ()
    (when (< x 10)
          (display x)
          (newline)
          (set! x (+ x 1))
          (label)))) ; basically a goto label
```

We can make things better by better utilizing the named `let`:

```scheme
(let label ((x 0))
  (when (< x 10)
        (display x)
        (newline)
        (label (+ x 1)))) ; applies the return value of the last expression to
                          ; the bindings
```

Every scheme implementation is required to be tail-recursive.

```scheme
(define (factorial n)
  (define (fact-rec x acc)
    (if (= x 0)
      acc
      (fact-rec (- x 1) (* x acc))))
  (fact-rec x 1))
```

For each has a peculiar syntax:

```scheme
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

```scheme
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

```scheme
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

```scheme
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

```scheme
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

```scheme
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

```scheme
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

```scheme
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

```scheme
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

```scheme
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

