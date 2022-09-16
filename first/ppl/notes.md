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

