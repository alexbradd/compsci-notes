# Advanced Algorithms and Parallel Programming

## Complexity analysis

See API notes about complexity analysis.

## Divide and conquer

A common paradigm. I goes in **three steps**:

1. **Divide the problem** (instance in jargon) into sub-problems
2. **Conquer the sub-problem by solving them recursively**
3. **Combine the sub-problem solutions**

A D&C algorithm can be **easily represented with a form to which we can apply the
master theorem formula**:

$$
T(n) = aT(p) + X
$$

Where:

- $a$ is the number of subproblems for each iteration
- $p$ the subproblem size relative to the input (e.g. $\frac{n}{2}$)
- $X$ the work done in dividing and combining (e.g. $\Theta(n)$)

For any other info, see **API notes** about it.
