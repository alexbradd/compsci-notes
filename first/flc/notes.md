# Formal languages and compilers

## Basics

### Operations on strings

Review basics of strings and operations on them (API or Bioinformatics).

### Operations on languages

Operation on strings can be extended to whole languages: *the operation between
strings will be applied to each string of the language*.

**Prefix-free language**: a language where there is not any string that is
prefix of another string of the language: $prefix(L) \cap L = \emptyset$.
Note: $\epsilon$ is prefix to every string, including itself.

$$
prefix(L) = \{ y|x = yz \land x \in L \land y,z \neq \epsilon \}
$$

Concatenation is defined as such: $L'L'' = \{ xy | x\in L' \land y\in L'' \}$. The
powers are defined based on this definition. Some consequences:

1. $L^0 = \{\epsilon\}$
2. $L.\emptyset = \emptyset . L = \emptyset$
3. $L.L^0 = L^0 . L = L$

All set operations still apply. The universal languages  is defined as follows:
$L_{universal} = \bigcup_n^\infty \Sigma^n$ or $L_{universal} = \neg\emptyset$
