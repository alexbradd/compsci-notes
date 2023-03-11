# Computer security

## Intro

Security **always has an adversarial component**: there is someone that wants to
abuse the system.

**A vulnerable system is a system where exists a shortcut that is not known to
the system designer**.

If the system secured is a computer, **for it to be secure we need it to have 3
main properties (CIA)**:

1. **Confidentiality**: information should be accessed only from authorized
   people
2. **Integrity**: information should be modified only by persons authorized to
   do so
3. **Availability**: information should be available to all authorized parties
   within specified time constraints

Providing these three elements is an engineering problem.

The **availability constraint is the business requirement** and the most
difficult one to keep satisfied: data is always more and to be made more readily
available.

**A vulnerability is something that allows us to violate one of the
constraint**. On the other hand, **exploits are a specific way to use one or
more vulnerability to accomplish a specific objective that violates the
constraint**.

> In the case of a vulnerable lock: the vulnerability is friction, the exploit
> is using tension wrench and pick to pick the lock

In computers, there are scenarios in which we can change the vulnerable code but
there are also cases in which we cannot due to various reason (cost, legacy
compatibility etc).

**The security of a system is not correlated to the level of protection of said
system**. We can have protected system be less secure than unprotected ones.
Even for protection, **we need to define what threats we protect from**. When we
are talking about security, **we always need to define the threat model,
otherwise our discussion is useless**.

**Assets are what is valuable for an organization**. Since we are talking about
computer security, we are talking about IT assets. **Most of the time, it is not
the computer that is valuable, but what they do (for example the data they
handle or the industrial process they manage)**. Even reputation can be an
asset.

**A threat is a circumstance potentially causing a CIA violation**.

**An attack is an intentional use of one or more exploits with the objective of
compromising a system's CIA. Threat agent is someone/something that makes an
attack happen**.

In general **risk is the statistical and economical evaluation of the exposure
to damage because of the presence of vulnerabilities and threats**.

$$
\mathrm{Risk} =
\mathrm{Asset}\times\mathrm{Vulnerabilities}\times\mathrm{Threats}
$$

**Assets and vulnerabilities are controllable, while threats are not**.
**Security is the balance of reduction of vulnerabilities + damage containment
vs cost**.

The **cost of security is both direct** (management, operational and equipment)
**and indirect** (less usability, lower performance and reduced productivity). A
**fallacy** is **changing the system to reduce privacy to increase security**.
This paradigm is **always a net loss for the system** since we are **exchanging
the confidentiality of users** (confidentiality) with a **small increase of
security of the system**.

Another problem is that, often, **security measures impose a cost on the users
but do not benefit them**. This means that **if users do not see value in the
measures, they are going to go out of their way to avoid them**.

In security, **throwing money around does not solve problems: the best way to
increase security is often to do nothing than to do something badly**. **Once a
measure has been introduced, however, no one would bear the cost of the
possibility (even low) of an attack made possible by said removal**. Thus once
security measures are made permanent **they are very rarely reverted**.

**A part of the system can be assumed to be safe** (meaning that adversary can
be assumed to not tamper): these are the **trusted elements**. **We need to
assume the safety of some components to avoid the chicken-and-egg problem**.

## Cryptography

It is the study of techniques to allow secure communication and data storage in
presence of attackers. It **provides**:

1. **Confidentiality**
2. **Integrity/freshness**: detect/prevent tampering
3. **Authenticity**: data and their origin are guaranteed
4. **Non-repudiation**: data creator cannot repudiate created data
5. Advanced features: **proof of knowledge/computation**

Note: when in cryptography we talk about the **attacker**, we are **assuming
their capabilities, not whether said attacker is feasible or not**.

**A side-channel is a characteristic that betrays a secret we are trying to
hide**.

We say that an encryption method provides **forward-secrecy if compromising the
key does not compromises all messages that came before**.

One of the **most important features** of a crypto algorithm is that **knowledge
of said algorithm does not compromise it**. The first instance separation
between key and algorithm comes from Bellaso (1553).

**Kerchoff's 6 principles for a good cypher**:

1. **It must be practically, if not mathematically, unbreakable**
2. **It should be possible to make it public, even to the enemy**
3. **The key must be communicable without written notes and changeable whenever
   the correspondents want**
4. It must be applicable to telegraphic communication (nowadays it is not very
   applicable)
5. It must be portable, and should be operable by a single person
6. Finally, given the operating environment, it should be easy to use, it should
   not impose excessive mental load, nor require a large set of rules to be
   known

Requirement number 2 it is the most basic requirement for modern cryptography:
the only thing that we need to keep safe, is the key.

**Shannon**, in 1949, **proved the existence of mathematically unbreakable
algorithms**, even though unpractical. **Nash**, in 1955, elaborated by
**proving that the effort needed to break a computationally intensive algorithm
with a long enough key is insurmountable**.

### Definitions

- **Plaintext space** $\mathbf{P}$: set of possible messages
  - $\{0,1\}^l$
- **Ciphertext space** $\mathbf{C}$: set of possible ciphertexts
  - $\{0,1\}^{l'}$, not necessarily $l = l'$
- **Key space** $\mathbf{K}$: set of possible keys
  - $\{0,1\}^\lambda$
- **Encryption function** $\mathbb{E}: \mathbf{P}\times\mathbf{K}\to\mathbf{C}$
- **Decryption function** $\mathbb{D}: \mathbf{C}\times\mathbf{K}\to\mathbf{P}$

Our design goal is to **make sure that if someone doesn't know the key, it
cannot access the plaintext**.

However, this is a simplistic view since the attacker is considered passive.
**In reality attackers can be smarter**:

- **Eavesdropper** (**ciphertexts only attack**)
- Knows a set of possible plaintexts (**known plaintext attack**)
- Active attacker may tamper with the data and observe the reactions of a
  decryption-capable entity (**chosen plaintext attack**)

### The perfect cipher (and why it's useless)

In a **perfect cipher**, for all plaintexts and ciphertexts:

$$
P(\mathit{plain sent is our plaintext}) =
  P(\mathit{plain sent is our plaintext}|\mathit{cipher sent is the ciper})
$$

In other words: **seeing a ciphertexts gives us no information on what the
plaintext corresponding to it could be**.

**Theorem**: any **symmetric cipher** with $\mathbf{P}=\mathbf{K}=\mathbf{C}$ is
**perfectly secure iff**:

1. **every key is used with equal probability**
2. a **unique key maps a given plaintext into a given ciphertext**.

Basically this theorem gives us a **perfect (but useless) cipher**.

A **simple algorithm** needs a **fresh perfectly random key for every message of
length equal to the message**. We can simply **XOR the message with the key to
encrypt, and XOR the ciphertext with the key to decrypt it**. The algorithm is
obviously impractical due to the length of the key and also the need to extract
a fresh key for every message.

A more **practical assumption is to try to achieve not mathematic perfection,
but to make our cipher practically unbreakable**. This means we need to **make
our attacker solve a problem that is exponentially complex**.

An outline for proving the computational security of problem is:

1. Define the ideal attacker
2. Assume a given computational problem is hard
3. Prove that any non-ideal attacker solves the hard problems

**An attacker is represented as a program able to call given libraries**,
libraries implement the cipher at hand. We define the **security property as
answering to a given question**. The **attacker wins the game if it breaks the
security property more often than what is possible through a random guess**.

### Cryptographically safe PRNGs

**A CSPRNG is a deterministic function** $\{0,1\}^\lambda\to\{0,1\}^{\lambda+l}$
**whose output cannot be distinguished from a uniform random sampling** of
$\{0,1\}^{\lambda+l}$ in $\mathrm{poly}(\lambda)$. $l$ is the **generator's
stretch**.

In practice, **we have only candidate CSPRNGs**: we do not have proof that such
a function exists; moreover proving that a CSPRNG exists implies $P\neq NP$.
Practically CSPRNG are built with Pseudorandom Permutations (PRPs), which
themselves are built from Pseudorandom functions.

### Random functions and permutations (block ciphers)

Consider the set of all functions $\mathbf=\{\{0,1\}^{in}\to\{0,1\}^{out}\}$.
**A uniformly randomly sampled** $f\gets^\$\mathbf{F}$ can be **encoded** by a
$2^{in}$ entries **table**, each entry $out$ bit wide. This means that
$|\mathbf{F}| = (2^{out})^{2^{in}}$.

A **pseudorandom function is a function** $\mathit{prf}_{seed}$ **taking an
input and a** $\lambda$ bit **seed**. The **entire function is described by the
value of the seed**. It **cannot be told apart from a random function**
extracted from $\mathbf{F}$ in $\mathit{poly}(\lambda)$.

A **pseudorandom permutation is a bijective PRF**. It is:

1. Uniquely identified by the value of the seed
2. **It is not possible to tell apart** in $\mathit{poly}(\lambda)$ from a
   **random function**
3. It is a **permutation of all the possible** $\{0,1\}^{len}$ **strings**

Operatively speaking, it acts on a block of bits and outputs another of the same
size. The output "looks unrelated" to the input. Its actions is fully identified
by the seed.

**No formally proven PRP exists** (for the same reasons as CSPRNGs). A typical
construction is starting with a small bijective boolean function $f$ and
sequentially computing $f$ until we are satisfied.

Real world PRPs go by the **historical name of block cyphers**. They are
considered broken if with less than $2^\lambda$ operations, we can tell them
apart from a PRP, e.g. via deriving the input corresponding to an output without
the key. The key length $\lambda$ is chosen to be large enough so that computing
$2^\lambda$ guesses is not practically feasible.

Some famous block ciphers are:

- **AES**: most common block cypher
- **DES**: broken, the key is to short. A patch is to apply the algorithm three
  ties

#### Block cipher modes

Block ciphers can be used in a variety of different encryption modes:

1. **ECB** (Electronic code book) consists of **applying the cipher with the
   same key to each block independently**. The biggest flaw of this method is
   that **if two blocks are identical, they will be equal even when encrypted**.
   Furthermore, it has very weak integrity protection since the cipher cannot
   tell if any block has been altered.
2. **Counter** (CTR) mode consists of **feeding a counter to each block cipher.
   The output of the cipher is then XORed with the plaintext** to obtain the
   ciphertext for that block. This mode, however, is **not effective against
   chose plaintext attacks**: the encryption is **deterministic** (the counter
   always starts at 0).
3. **CPA-secure CTR** is like the regular CTR, however **for each encryption a
   NONCE (one time use number) is used as the counter start**. To enable
   decryption, **the nonce needs to be public**.
4. Symmetric **ratcheting** is a technique that **makes impossible to roll-back
   the encryption procedure**.

A problem that all these schemes suffer is that of **malleability**: **making
changes to the ciphertext maps to predictable changes in the plaintext**. To
**avoid** this issue we can: create a non-malleable scheme (not easy) or **add a
mechanism for validating data integrity**.

#### Data integrity

To provide integrity, we can **add a small piece of information (tag) that
allows us to test for the message integrity of the encrypted message itself**.
Adding it to the plaintext and then encrypting it is not a good idea. These tags
are called **MACs** (Message Authentication Codes) (name is very misleading:
they do not authenticate anything).

A MAC is comprised of a **pair of functions**:

1. `compute_tag(string, secret_key) -> tag`: returns the tag for the input
   string
2. `verify_tag(string, tag, secret_key) -> bool`: returns whether the tag is
   valid

The ideal attacker **knows as many message-tag pairs as he wants**. However **he
cannot forge a valid tag** (including splicing other messages' tags) **for a
message for which he does not know the tag already**.

We can **build a MAC using a block cipher in the CipherBlock Chaining mode**:

1. **For each block** we **XOR the plaintext block with the previous block's
   result**
   - All ciphers use the same secret key
2. For the first block we use 0 as the init

**CBC-MAC is secure for prefix-free messages. If we encrypt the tag once more we
solve this issue**.
