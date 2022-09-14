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
