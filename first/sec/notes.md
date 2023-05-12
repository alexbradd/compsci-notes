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

Testing the integrity of a file requires, however, to compare it bit by bit with
an intact copy or read it entirely to compute a MAC. It would be nice to have a
short fixed length string independent of the file size. However, due to the
mismatch of cardinality between the total number of files and the total number
of strings of length $k$.

### Cryptographic hashes

A cryptographic hash is a **function** $H: \{0,1\}^*\to\{0,1\}^l$ for which the
**following problems are hard**:

1. Given $d=H(s)$ find $s$ ( **first preimage collision resistance**)
   - Takes $\mathcal{O}(2^l)$ hashes computations to guess $s$
2. Given $s,d = H(s)$ find $r\neq s : H(r) = d$ ( **second preimage collision
   resistance**)
   - Takes $\mathcal{O}(2^l)$ hash computations to guess $r$
3. find $r, s$ with $r\neq s$ and $H(s) = H(r)$ ( **collision**)
   - Takes $\approx\mathcal{O}(2^\frac{l}{2})$ hash computations

1st preimage collision implies the possibility of 2nd preimage collisions,
however the opposite is not true.

**The output bitstring of a hash is known as a digest.**

Some uses for hashes:

1. Store/compare hashes instead of values.
2. Building MACs: generate tag hashing together with the message and a secret;
   verify tag recomputing the same hash.
   - See HMAC
3. Forensic uses.

### Asymmetric encryption

Agreeing on a secret has to be done on a trusted channel. Is there a way to
**share a key on a public channel, without compromising the message**? Yes:
asymmetric encryption.

Up to now, enumeration of the secret parameter was the best possible attack.
**Asymmetric cryptosystems rely on hard problems for which bruteforcing the
secret parameter is not the best attack**.

This means that **comparing bit-sizes of the secret parameters between
algorithms instead of the actual complexities is very wrong** for this type of
encryption, do this only for algorithms of the same type. God forbid you do this
with symmetric algorithms.

#### Diffie-Hellman key agreement

The goal is to make two parties share secret values with only public messages.
**The attacker can**:

1. **Eavesdrop anything, but not tamper**
2. This **assumptions** should hold:

   - Let $(G\mathbf{G}, \cdot)$ a group of finite prime order $q$ and on a
     generator $g$ of this group. Let there be two numbers $a,b$ sampled
     uniformly from $\{0,\ldots,|\mathbf{G} -1\}$. $\lambda$ will be the length
     in bits of $\mathrm{len}(a)\approx\log_2|\mathbf{G}|$.

     Given $g^a$ and $g^b$, finding $g^{ab}$ costs more than
     $\mathrm{poly}(\log |\mathbf{G}|)$.

     $g$ and $\lambda$ are public.

**The assumptions basically requires an attacker to be able to solve the
discrete logarithm problem in polynomial time**. Usually the chosen group is
subgroup of the natural numbers of order $p$ (still prime and appropriately
large). The group can also be defined by an elliptic curve.

The agreement goes like this:

1. Alice picks $a$ and sends $g^a$ to Bob
2. Bob picks $b$ and sends $g^b$ to Alice
3. Each party computes $(g^b)^a$ and $(g^a)^b$ respectively. Thanks to the
   commutativity of the group, these two are equal. Now we have our key.

#### Public key encryption

**Based on the same ideas of the DH key agreement**, we can define asymmetric
key encryption: the **key-pair generation algorithm generates two keys, one
public and one private. The public part can be shared publicly and is used for
encrypting a plaintext that can only decrypted with the associated private
key**.

It is **computationally hard** to:

1. **Decrypt a ciphertext without the private key**
2. **Compute the private key given the public key**

Asymmetric algorithms are **very slow**, so implementing it like this in the
real world is not really feasible for fast communication. **What is done,
instead, is called key encapsulation**:

1. **Alice chooses a large random secret for a pre-agreed symmetric cipher,
   encrypts it using Bobs public key and sends it**.
2. **Bob receives the message, decrypts it and communication continues using the
   shared secret on a symmetrically encrypted channel**.

This is basically what TLS and the like do.

### Authenticating data

To build a secure hybrid encryption scheme **we need to be sure that the public
key the sender uses is the one of the recipient**. We’d like to **be able to
verify the authenticity of a piece of data without a pre-shared secret**.

**Digital signatures** are used for this: they are asymmetric cryptographic
algorithms. Signatures cannot be repudiated by the user.

It uses the **same principles as public key encryption, however it flips it**:
we **sign** the message with our **private key**, meaning that **everyone with
access to our private key can verify it**.

Due to the slowness of asymmetric encryption and due to space constraints, we
**sign only a hash of the message and append it to the message**.

Signing documents **makes sense only if the document is completely static**. If
it is not, we are signing only the program that generates the content, non the
content.

### Digital certificates

We have one more problem: **how can we be sure that the public key corresponds
to the correct identity (public key binding problem)**?

A **PKI** is a **system that allows people to bind a certain public key with an
identity**. A **digital certificate is basically a file that contains the name
of the entity and a public key**. The most used standard for digital
certificates is X.509v3.

Digital certificates are the best way to **sign documents**, since we solve the
binding problem.

**Digital certificates need to be themselves signed**, however who signs them? A
**certificate authority is a trusted issuer that signs certificates**. But **who
signs the certificate authority's certificate? Another CA**. This creates a
**signing tree**, however it introduces an infinite recursion. This means **we
need to have a root CA that is self-signed, trusted a-priori and whose
certificate is stored in trusted storage**.

The root CA is not a certificate anymore, it is a statement of authority: we
cannot verify it, we need to trust it.

### Fundamentals of information theory

From information theory we need mainly 2 things: qualitatively frame "luck" and
"guessing".

Basics definitions:

1. Communications takes place between two endpoints:

   - The sender, made of an information source and an encoder
   - The receiver, made of an information destination and an encoder.

2. Information is carried by the channel in the form of a sequence of symbols of
   a finite alphabet.

The **receiver gets information only through the channel: it will be uncertain
on what the next symbol is**. Acquiring information is **modeled through a
random variable** $\mathcal{X}$: the **closer the variable is to a uniform
distribution, the higher the amount of information I get from knowing the
outcome**. Encoding maps each outcome as a finite sequence of symbols.

**Entropy** is basically a **measurement of uncertainty**. The desired
properties are: non-negativity, "combining uncertainties" should map to adding
entropies.

**Entropy definition**: Let $\mathcal{X}$ be a d.r.v. with $n$ outcomes in
$\{x_0, \ldots,x_{n-1}\}$ with $P(\mathcal{X} = x_i) = p_i$ for all $i$. The
entropy of $\mathcal{X}$ is $H(\mathcal{X}) = \sum_0^{n-1} -p_i\log_b(p_i)$.

The measurement unit of entropy depends on the base of the logarithm. The
typical case for $b=2$ is bits.

**Shannon's noiseless coding theorem (informal)**: It is possible to encode the
$n$ outcomes of i.i.d. random variables, each one with entropy $H(\mathcal{X})$
into no less than $nH(\mathcal{X})$ bits per outcome. If less bits are used,
some information is lost.

**Min-entropy**: we define the min-entropy of $\mathcal{X}$ as
$H_\infty(\mathcal{X}) = -\log(\max_i p_i)$.

Intuitively, the **min-entropy is a uniform distribution where the probability
of each outcome is** $\max_i p_i$. This means that **guessing the most common
outcome of $\mathcal{X}$ is at least as hard as guessing a
$H_\infty(\mathcal{X})$ bit long string**.

## Authentication

An important distinction is that **between identification and authentication**:

1. In **identification an entity declares an identifier**
2. In **authentications an entity provides proof that verifies its identity**

Authentication can be **unidirectional or bidirectional** and can happen between
any entity. **Authentication is subdivided in 3 factors**:

1. Something that the entity knows (**to know**)
2. Something that the entity has (**to have**)
3. Something that the entity is (**to be**)

**Multi-factor authentication uses two or three of these factors**.

### To-know factors (passwords and pins)

**Advantages**:

- **Low cost**
- **Ease of deployment**
- **Low technical barrier**

Note: this advantages are **mainly for the implementer** of the authentication
method and not the user.

| Disadvantages (passwords can be:) | Countermeasures (enforce passwords that) |
| --------------------------------- | ---------------------------------------- |
| Stolen/snooped                    | Change/expire                            |
| Guessed                           | Are long and have rich character sets    |
| Cracked (enumerated)              | Are not related to the user              |

These **countermeasures are costs because humans are not machines**: we are
unable to keep secrets and have trouble remembering arbitrary strings for a long
time. This means that **we can't apply all the countermeasures, we need to
choose based on the most likely attack we want to defend**.

| Countermeasure   | Snooping       | Cracking       | Guessing       |
| ---------------- | -------------- | -------------- | -------------- |
| Complexity       | Not effective  | Very effective | Effective      |
| Change           | Very effective | Effective      | Effective      |
| Relation to user | Not effective  | Not effective  | Very effective |

The **best countermeasure is user education**: the human is the weak link. We
need to enforce strong passwords, enforce expiration policies, use password
meters to balance usability.

Authentication is about sharing a secret. **How do we minimize the risk that
secrets get stolen?**

1. Use **mutual authentication** if possible
2. **Challenge-response scheme**: we **find a problem that can be solved only if
   you have the secret and only communicate the solution to said problem**.

   A sketch of a challenge-response scheme is the following:

   ```txt
   +----------+                                               +----------+
   | Entity 1 | Authenticate(id)                              | Entity 2 |
   |          | --------------------------------------------> |          |
   |          |               hash(random1, secret) + random1 |          |
   |          | <-------------------------------------------- |          |
   |          | hash(random1, secret)                         |          |
   |          | --------------------------------------------> |          |
   |          | hash(random1, secret, random2) + random2      |          |
   |          | --------------------------------------------> |          |
   |          |                hash(random1, secret, random2) |          |
   |          | <-------------------------------------------- |          |
   +----------+                                               +----------+
   ```

   Random data is used to avoid replay attacks

On the entity part, we need a way to **safely store passwords without
compromising confidentiality**:

1. **Cryptographic protection**: never store passwords in clear ( **hashing +
   salting**)
2. **Access control** policies
3. **Never disclose secrets in password-recovery schemes**

We also need to be careful of the **caching problem**: information could be held
in intermediate storage locations.

### To have factors (tokens, smart cards and smartphones)

The **user must prove that it possesses something**.

**Advantages**:

- **Human factor** (less likely to hand out a key)
- **Relatively low cost**
- **Good level of security**

| Disadvantages            | Countermeasures        |
| ------------------------ | ---------------------- |
| Hard to deploy correctly | None                   |
| Can be lost or stolen    | Use with second factor |

This factor **works best in conjunction with another factor**.

Some classic technologies that implement this factor are:

- One time password generators: they are simple machines that contain a secret
  key that computes a MAC of a counter synchronized with the host.
- Smart cards: a CPU with non-volatile ram containing a private key. The smart
  card authenticates itself with a challenge-response. It uses the private key
  to sign the challenge. Should be tamper-proof.
- TOTP: software that implements the same functionality as password
  authenticators (see Google Authenticator). Only big difference: TOTPs run on
  general purpose systems, so they are more difficult to secure

**It is really important that the key the device holds never leaves the device.
If the key leaves it, the factor degrades to a "to know" factor**.

Note: **not all devices are equally strong**. Each has its own weaknesses (e.g.
see SIM-swapping for SMS 2FA).

### To be factor (biometric)

**User must prove that it has some specific characteristics**.

**Advantages**:

- **High level of security**
- **Requires no extra hardware to carry around**

| Disadvantages                         | Countermeasures                  |
| ------------------------------------- | -------------------------------- |
| Hard to deploy                        | None                             |
| Probabilistic matching                | None                             |
| Invasive measurements                 | None                             |
| Can be cloned                         | None                             |
| Biological characteristics can change | Frequent re-measurement          |
| Privacy sensitivity                   | Secure the enrollment process    |
| Users with disabilities               | Use a (maybe weaker) alternative |

### Single Sign On

SSO **tries to solve the problem of managing and remembering multiple
passwords**. The solution is to have **only 1 identity** (therefore 1 password)
with possibly 2FA **on a single trusted host**. This means that **hosts
authenticate only on this trusted host, other hosts can ask the trusted element
if the user is authenticated**.

Examples of this flow are Shibboleth (AunicaLogin) and **OAuth**.

The problem of the method if the **reliance on a single point of trust**: if it
is compromised, the whole thing comes crashing. Moreover, **the password reset
scheme must be bullet proof since the email becomes a trusted element**.

SSO is a complex flow that is difficult to get right. Libraries exists, but they
can contain bugs.

## x86 crash course

### Architecture

x86 assumes the Von Neumann architecture. It uses a little-endian endianness.
The architecture has several registers, the most important are:

1. General purpose:
   - `EAX`, `EBX`, `ECX`, `EDX`
   - `ESI`, `EDI` (source and destination for string op)
   - `EBP` (base pointer)
   - `ESP` (stack pointer)
2. Instruction pointer `EIP`
   - We do not have access to it directly. It can only be modified by control
     instructions like `jmp`, `call`, and `ret`
   - It can be read from the stack
3. Program status and control: `EFLAGS`

If we remove the `E` from the general purpose registers, we can access them in
16-bit compatibility mode (lower half). Inside this half we can further split
them into high and low by substituting the `X` with `H` and `L` respectively.

The `EFLAGS` register is a 32-bits register of boolean flags. It contains flags
such as:

- Program status: overflow, sign, zero, auxiliary carry (BCD), parity, carry
- Program control: direction flag (controls string instructions)
- System: control operating-system operations

All instructions work on: bytes, words (2 bytes), dwords (4 bytes) and qword (8
bytes).

### Assembly

x86 assembly has two main syntaxes: intel (default on windows) and AT&T (default
in most UNIX tools). Beware, the order of operands IS different. We will use the
Intel syntax since it is more readable.

In x86 instruction have variable length. They are formatted as such:

1. Prefix + OPCODE: 1 to 3 bytes
   - Note: the same instruction may have different OPCODES depending on how it
     is called
2. Operands

Instructions:

1. Data transfer:
   - `mov dst src`: moves the value from a source to a destination:
     - `mov eax, 4h`: moves a constant into `eax`
     - `mov eax, ebx`: moves from register to register
     - `mov eax, [ebx + 4h]`: moves from address in `ebx` + 4 to `eax` (we can
       use arithmetic expressions into the indirect addressing block, e.g.
       `[edx + ebx*4 + 8]`)
     - Memory to memory is invalid
   - `lea dst src`: like `mov`, but it stores the address, not the value. It
     does not access memory.
2. Integer arithmetic:

   - `add dst src`: source can be any addressing type, while destination only
     register and memory.
   - `sub dst src`, `neg val`, `and`, `or`, `xor`, `not` work at the same way
   - `mul src`: unsigned multiply (for signed we use `imul`). The implied
     operands are based on the size of the source:

     - `AL`, `AX`, `EAX` as first operand
     - `AX`, `DX:AX`, `EDX:EAX` as destination

     `R1:R2` mean that high bits will be in `R1` while the lower ones in `R2`.

   - `div src`: computes the quotient and remainder. The implied operand is
     `*DX:*AX`. The result is stored into `EAX`, the remainder into `EDX`.
     Signed division is `idiv`.
   - `cmp op1, op2`: sets the correct flags in `EFLAGS` after `op1 - op2`
   - `test op1, op2`: sets the correct flags in `EFLAGS` after `op1 & op2`

3. Control flow:
   - `jmp addr`: jumps to the given address ore to an offset
   - `j<cc>`: conditional jump. The condition is dictated by `cc` (e.g. `jz`,
     `jlt`)
   - `nop`: the OPCODE is `0x90`
4. Interrupts and syscalls:
   - `int val`: generate a software interrupt with number $[0; 255]$. These are
     OS dependent (e.g. `80h` are Linux syscalls)
   - `syscall`: used for calling syscalls on Linux 64 bit
   - `sysenter`: the same thing as `syscall`, but for Windows

### 64-bit extension (`AMD64` or `x86_64`)

Mainly it added 8 new general purpose (`R8` to `R15`) registers and expanded the
previous registers to 64 bit (they use the `R` prefix, e.g. `RAX`, `RBX`...).

### Program layout

We have two main binary formats:

1. PE (Portable Executable): used by Windows
2. ELF: common on other OSs (except MacOS)

In both cases we are more interested in which way the executable is mapped into
memory.

In ELFs we have different sections (PEs have similar sections):

- `.plt`: stubs for external linking
- `.text`: executable instructions
- `.rodata`: read-only data
- `.data`: initialized data
- `.bss`: uninitialized data. It is initialized with all 0s at startup
- `.debug`: symbols for debugging
- `.got`: global offset table

```txt
Low addresses (0x80000000)
+------------------+
| Shared libraries |
+------------------+
| .text            |
+------------------+
| .bss             |
+------------------+
| Heap             |
+------------------+
|                  |
|                  |
+------------------+
| Stack            |
+------------------+
| env              |
+------------------+
| argv             |
+------------------+
High addresses (0xbfffffff)
```

### Calling functions

We can manipulate the stack pointer using the `push src` instruction (`val` is
an immediate or register).

```asm
  push eax
  ; equivalent to
  sub esp, 4
  mov DWORD PTR [esp], eax
```

The `pop dst` instruction does the opposite: loads int the destination a word
off the top of the stack and moves `esp` accordingly.

```asm
  pop eax
  ; equivalent to
  mov eax, DWORD PTR [esp]
  add esp, 4
```

To call a function, we use `call func`: it pushes to the stack the address of
the next instruction and moves the `EIP` to the first instruction of the
routine. `ret`, which does the exact opposite as `call` (i.e reads the pops the
return address from the stack and updates the `EIP`). Calling a function,
however, requires the following operations:

- A stack frame is the area allocated to a function
- `EBP` register is a pointer to the beginning of a function's frame
- At the beginning of a function we need to:
  - Save the old `EBP`
  - Set `EBP` to the address of the function's frame
  - The `EBP` can be used to access local variables (pushed on top of the stack)
    or the function arguments (stored under the `EBP` and under the return
    address)

Calling functions requires that caller and callee agree on which registers are
preserved, where arguments are stored and where the return value is stored
(calling conventions). This is part of the ABI (Application Binary Interface).

The default C calling convention (`_cdecl`) is as follows:

- Arguments: passed through the stack, right to left
- Cleanup: the caller removes the parameters from the stack after the called
  function completes
- Return: `EAX`
- Caller-saved registers: `EAX`, `ECX`, `EDX` (the other are callee-saved)

Microsoft's `_stdcall` convention is slightly different:

- Arguments: as in `_cdecl`
- Cleanup: the callee is responsible for clearing the parameters before
  returning
  - To do this, the functions needs to know the right number of parameters
    passed. This means that this convention can only be used with fixed-length
    arglist functions (e.g. not `printf`)
- Return: as `_cdecl`
- Caller-saved registers: as `_cdecl`

Another convention is `_fastcall`:

- Arguments: Up to 2 parameters passed via registers `ECX` and `EDX`, the others
  are pushed to the stack as in the other
- Rest is the same

Linux's AMD64 convention (System V) works as follows:

- Arguments: passed in registers `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`, the
  subsequent ones are on the stack (ordered like in the other conventions)
- Cleanup: done by caller
- Callee-saved registers: `rbx`, `rsp`, `rbp`, `r12`, `r13`, `r14`, and `r15`
- Caller-saved registers: `rax`, `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9`, `r10`,
  `r11`
- Return value: `rax` (`rax:rdx` if 128 bits are needed)

## Access control

Access control is binary decision: we are allowed or not. At scale, however, we
cannot enumerate all possible answers, we need **rules**. So we need to
establish how we write these rules, how we express them in practice and how do
we enforce them.

The **reference monitor is the agent that enforces the control policies**. All
modern kernels have one implementation. The reference monitor needs to be :

1. **Tamper proof**
2. **Un-bypassable**
3. **Small enough to be verified/tested**

Access control encompasses **both authentication and authorization**:

1. **Authentication**: the reference monitor **needs to verify the identity of
   the principal (user) making an access request**
   - The user enters username and password. The login process creates a process
     that runs with access rights equal to those of the user
2. **Authorization**: the reference monitor **decides whether access is granted
   or denied**
   - The reference monitor has to find and evaluate the security policy relevant
     for the given request

The above tasks are easy in centralized systems but non-trivial in distributed
systems.

To model the access methods, we use the **following concepts**:

- **User**: a person
- **Principal**: the user's identity (the name used in the system)
- **Subject**: the entity making a request within the system
- **Object**: what is being requested
- **Access operations**: all the operations executable on the requested object

### Discretionary access control

Resources have a **owner that discretionarily decides its access privileges**.
All common OSs and applications use DAC. The general model of DACs (**HRU
model**) is the following:

- We need the following entities:
  - **Subjects** who can exercise privileges
  - **Objects** on which privileges are exercised
  - **Action** which can be exercised
- **Protections state**: a triple $(S, O, A)$
  - $A$: matrix with $S$ rows and $O$ columns
  - $A[s,o]$: privileges of subject $s$ over $o$
- **Basic operations**: create/destroy subject/object or add/remove permissions
- **Transitions**: sequence of basic operations

  - **Transitions need to be applied atomically**: every steps is executed iff
    the previous succeed and if one fails they need to be rolled back
  - **Given an initial protection state and set of transitions, is there any
    sequence of transitions that leaks a certain right $r$ (for which the owner
    is removed) into the access matrix? If not, the system is safe with respect
    to right $r$.**

    The problem is **undecidable**; it becomes **decidable only if we disallow
    transitions**.

In real world OSs, we do not have an access matrix (if there were one, it would
be sparse) but more optimal representations:

- **Authorization tables**: records non-null triples (typically used in DBMSs)
- **Access Control Lists**: records by columns (for each object, we store the
  list of subjects and authorizations)
  - Efficient with per-object operations
  - Most common case
  - Some systems can use abbreviated ACLs
  - Cannot have multiple owners
- **Capability Lists**: records by row (for each subject, we store the list of
  objects and authorizations)
  - Efficient with per-subject operations
  - Usually objects change and subjects stay
  - Capabilities are optional in POSIX OSs

Shortcomings of DACs:

1. **Cannot prove safety**
2. **Control access to objects but not to the data inside objects**
   - Malicious user attacks
   - Trojan horse attack: malicious program running with privileges of the user
3. **Problems of scalability and management**
   - Each user-owner can potentially compromise security of the system with
     their own decisions

### Mandatory Access Control

**Privileges are set by a security administrator which defines a classifications
of subjects (clearance) and of objects (sensitivity)**. The classification is
composed of a **strictly ordered set of secrecy levels and a set of labels**.

Classification is a **partial order relationship that defines a lattice**. The
order is imposed by the **dominance relationship**:

$$
  \{C_1, L_1\} \geq \{C_2, L_2\} \iff C_1\geq C_2 \land L_2\subseteq L_1
$$

This means that we can have **some combinations that are not comparable between
each other**.

The **Bell-LaPadula model** defines two rules:

1. **No read-up**: a subject $s$ at a given secrecy level cannot read an object
   $o$ at a higher secrecy level
2. **No write-down**: A subject $s$ at a given secrecy level cannot write an
   object at a lower secrecy level
3. (For DACs): use of an access matrix to specify the discretionary access
   control

If we add the **"tranquility property"**, i.e the fact that the secrecy level of
objects cannot change dynamically, **we have a secure system where information
monotonically flows towards higher secrecy levels**. To make it possible for
higher-ups to write public information **we need trusted subjects who can
declassify or sanitize documents**.

The Bell-LaPadula model **does not address integrity**, we need **another model
such as the Biba model (basically just inverts the rules of the
Bell-LaPadula)**.

## Software security

Good software engineering ideally produces secure software. However, creating
software is one thing, creating secure software is another and is very hard.

Safety is an implicit non-functional requirement of all software. An unmet
security specification is a vulnerability (NOTE: vulnerability is not synonymous
with an exploit).

Principles for writing secure programs:

1. **Reduce privileged parts to a minimum**
   - If possible, discard privileges definitely as soon as possible
2. **KISS**
3. **Do not rely on security through obscurity**
4. **Be wary of concurrency and race conditions**
5. **Fail-safe** and **Default-deny**
6. **Avoid the use of shared resources or unknown/untrusted libraries**
7. **Filter input/output**
8. **Do not write your own cryptographic primitives, password/secret
   management**
9. **Use trustworthy RNGs**

## Binary exploitation

### Buffer overflows

Assumptions: `elf`s on linux `>= 2.6` on `x86`. The concepts, however, **apply
to any kernel/architecture with the appropriate modifications**.

At every function call, the CPU executes the same (depending on calling
convention) instructions:

```nasm
  ...                  ; register saving and parameter passing
  call 0x8048484 <foo> ; equivalent to push eip && jmp 0x8048484
  push ebp             ; save the current stack base onto the stack
  mov  ebp, esp        ; the new base is the top of stack
  sub  esp, 4          ; make room for function variables
  ...                  ; function code
```

The same happens on function end:

```nasm
  ...
  leave ; Equivalent to: mov esp, ebp
        ;                pop ebp
  ret   ; restore the saved eip
  ...   ; deallocation of saved registers / function arguments
```

Stack smashing is a well-known idea (see
[article by aleph1](http://phrack.org/issues/49/14.html#article)). Basically how
it works is: **function allocates a buffer, buffer is filled _without
bound-checking_, boom**.

Most common smelly-functions: `strcpy`, `strcat`, `fgets`, `gets`, `sprintf`,
`scanf`.

To exploit this vulnerability, we can **pass specially formatted strings (via
environment variables or other user-controlled means) such that we put the
address that we want to jump into the place we want**. The **simplest way** is
to jump into the buffer itself and **reuse the buffer we are smashing the stack
with**.

> A more elaborate way is to jump into a function that we know will be loaded
> and at which location > (e.g. `libc` functions).
>
> The method described in this notes does not work on new OSs because all pages
> used for process stacks are marked as non-executable. To make this work we
> need to pass special flags during compilation.

#### `nop` sled

However, we **do not know the exact address of the buffer**: we only know that
it is **somewhere around the `esp`.** We could **look it up using `gdb`**,
however **different machines/executions can produce different results** (due to
e.g. different invocation chains/environment variables etc...). Moreover,
**debuggers often add offsets to the allocated process memory** (this means that
the `esp` obtained with `gdb` is different to the effective one). This
imprecision can **cause us to misread our buffer and to not execute the
instructions we want**. Since our imprecision is only of a few bytes, we can
**add a "landing strip" of `nop` instructions so that we can we can jump in the
middle of this strip and still execute the correct code**.

#### Shellcode

What code do we put into our buffer? **Usually we want `execve("/bin/sh")`**.
Since historically this has always been the case, the **payload of exploit is
called shellcode**.

In Linux, a syscall invocation follows the following convention:

```nasm
  movl eax, $syscall_number
  mov  ebx, arg1             ; syscall arguments
  ...
  int 0x80                   ; Switch to kernel mode
```

To generate our exploit we can write a MW C program and disassemble it:

```c
int main() {
  char *hack[2];
  hack[0] = "/bin/sh";
  hack[1] = NULL;
  execve(hack[0], &hack, &hack[1]);
}
```

**We need to construct the following structure in memory** to invoke `execve`:

```txt
    /-------------\
    v             |
+---------+---+---------+------+
| /bin/sh | 0 | Address | NULL |
+---------+---+---------+------+
```

Is **pseudo-assembly** we have the following shellcode (everything is
**parametrized in function of `ADDRESS`**).

```nasm
  movl array-offset(ADDRESS), ADDRESS
  movb nullbyteoffset(ADDRESS), 0x0
  movl null-offset(ADDRESS), 0x0
  ;;
  movl eax, $0xb
  mov  ebx, ADDRESSS
  leal ecx, array-offset(ADDRESS)
  leal edx, null-offset(ADDRESS)
  int 0x80
```

**How do we get the exact address of `'/bin/sh'`?** We can use the following
**trick**: `call` pushes the return on the stack, this means that **executing a
call just before declaring the string has the side-effect of leaving the address
of the string on the stack**.

```nasm
  jmp offset-to-call
  popl esi
  ;;
  movl array-offset(esi), esi
  movb nullbyteoffset(esi), 0x0
  movl null-offset(esi), 0x0
  ;;
  movl eax, $0xb
  mov  ebx, esiS
  leal ecx, array-offset(esi)
  leal edx, null-offset(esi)
  int 0x80
  ;; vvv exit(0) for cleanness vvv
  movl eax, 0x1
  movl ebx 0x0
  int 0x80
  ;;
  call offset-to-popl
  .string \"/bin/sh\"
```

If we were to translate the real code into binary, **many of the instructions
have `\0` in them, meaning that they cause string operations to misbehave**. We
simply need to **use shortened instructions** and **zeroed out registers** (via
`xorl`) instead of `0x0`.

The remaining part is filling the buffer with `nop`s and put the our guess of
`esp` into the saved `eip`.

#### Using environment variables

**Pros**:

- **Easy** to implement ("unlimited" space for the string)
- **Easy** to target (we can know precisely the location)

**Cons**:

- Works for **local exploits** only
- The program **may wipe the environment**
- **Memory must be marked as executable**

Since the addresses will be precise, we might not need the `nop`-sled, however
it adds a bit of reproducibility. **To activate the exploit we simply need to
run slam the stack with our envvar's address**.

#### Using built-in functions

**Pros**:

- Works **remotely** and **reliably**
- **No need for executable stack**
- A function is always executable

**Cons**:

- More **difficult to prepare** (need to craft the stack frame very carefully)

Basically what we need to do is **prepare the stack to trick the `ret` into
jumping into `system()`**. The stack needs to be setup **as if it has been
called legitimately**.

#### Other ways of jumping

1. Saved `eip` (**direct jump**) (what we done until now)
2. Function Pointer (**call another function**) (`jmp` into another function)
3. Saved `ebp` (**frame teleportation**)

#### Defending against buffer overflows

We have **three levels to try to block the exploitation** of this vulnerability:

1. **Source code level**: removes the vulnerability
   - Basically **write good code**:
     - Use safe functions `strncpy`/`strlcpy`
     - Do not use C, use a safer language
2. **Compiler level**: makes vulnerability non-exploitable
   - **Warnings** at compile-time
   - **Randomized reordering of stack variables**
   - Embedding **stack protection mechanisms** at compile time
     - Verifying, during the epilogue, that the **frame has not been tampered
       using a canary** inserted between local variables/control values that is
       checked (c.f.r gcc's StackGuard)
     - Canaries can be: random, all `\0` or random `xor` canaries (random `xor`
       canaries are the best protection)
3. **OS level**: makes exploitation harder
   - **Non-executable stack**
     - Bypassable (just don't put code into the stack)
     - Some programs require executable stack (e.g. jvm)
   - **Address space layout randomization**: repositions the stack at each
     execution at random

### Format string bugs

Example of vulnerable code:

```c
#include <stdio.h>

void test(char *arg) {
  char b[256];
  snprintf(b, 250, arg); // !!! "naked printf" vulnerability
                         // correct code should have been: snprintf(b, 250, "%s", b)
                         // NEVER use a naked variable as a format
  printf("buffer: %s\n", buf);
}

int main (int argc, char* argv[]) {
  test(argv[1]);
  return 0;
}
// ~> ./a.out "%x %x"
// buffer: b7ff0590 804849b    # We read random variables from stack and printed them on
//                             # stdout
```

The above code shows a simple way in which we can read everything we in memory:
**using `%N$x` we can print the `N`-th integer of the function's arguments (in
our case the `N`-th integer on the stack)**. This means that **we are not
limited by the size of the format string and thanks to the power of scripting we
can scan the whole stack** like this:

```sh
for i in $(seq 1 150); do
  echo -n "$i " && ./vuln "AAA %$i\$x"
done
```

If we can scan the stack, we can **leak information** (data, addresses).

Fortunately for us, there is a placeholder that can **also write memory**: `%n`
**writes the number of characters printed so far at the address in the
corresponding parameter**. How can we abuse this?

1. **Put on the stack the address** of the memory (`address`) cell to modify
2. Use `%x` (`%N$x`) to **go find on the stack the address we want to modify**
   (let's call it `pos`)
3. **Use `%n`** instead of `%x` **to write a number in the cell pointed to by
   `address`**

**To control the number we are writing we can use `%0Nc`**: writes a character
trying to fill a `N` character long string. An example format string that writes
`n` could be:

```txt
<address>%<n-len(address)>c%<pos>$n
```

There is a problem in our method: **`%c` can write only 2 bytes at a time**.
This means **we need to do two writes** to write a full 32-bit integer. **Since
we can only increment `n`** (if we do not overflow obviously), we **first need
to write the word with the lower absolute value and then the other.** Let us
revise our procedure:

1. Put on the stack two addresses, `addr` and `addr + 2`
2. Use `$x` to go find the two find the first word `pos` (the second one will be
   `pos+1`)
3. Use `%c` and `%n` to write the lower absolute value in the cell pointed by
   `pos` and the other in `pos+1`

```txt
<addr><addr + 2>%<lower_val>c%<pos>$n<higher_val>c%<pos+1>c$n
```

**To avoid possible side-effects when writing** with `%n` (since it writes
dwords and we are using it two times) **we can use `%hn`** (which writes words).

```txt
<addr><addr + 2>%<lower_val>c%<pos>$hn<difference between the two halves>c%<pos+1>c$hn
```

#### What to edit

We have **different options**:

1. The **saved EIP** (like in the buffer overflow case)
2. The Global Offset Table (**GOT**)
   - Dynamically relocate functions
3. C **library hooks**
4. **Exception handlers**
5. **Other** structures/pointers

#### Countermeasures

The **memory error countermeasures seen previously can help** against these
attacks. Moreover, **modern compilers will warn** when they detect a naked
`printf`. There also exist **patched versions of `libc` that mitigate** the
problem (count-and-check and FormatGuard).

**Conceptually**, format string bugs **are not specific to formatting
functions**. In theory, **any function with the same unique combination of
characteristics is potentially affected**:

1. **Variadic** function
2. A **mechanism** (e.g. placeholders) **to indirectly read/write arbitrary
   locations**
3. The **ability of the user to control them**

Remember: `printf`-like functions interpret input that **has been proven to be
Turing complete**, so we are basically injecting arbitrary code in memory.

## Web applications

Web applications are built **on top of HTTP(S)**: a **plain-text**,
**stateless** and **almost unauthenticated** protocol with **statefulness and
authentication bolted on as extensions**. Crafting malicious requests is very
easy.

The golden rule of web application security is that the **client is never
trustworthy**. We need to **filter and check carefully anything** that is sent
to us. The challenge is that with JavaScript, clients have become a
(cooperative) part of the application.

How do we filter the input? It is not easy. The **sequence of
validation/filtering** is:

1. **Allowlisting**: only allowing through what we expect
2. **Blocklisting**: on top of that discard known-bad stuff
3. **Escaping**: transform special characters into something else which is less
   dangerous

General rule: **allowlisting is safer than blocklisting**.

### Cross-site scripting (XSS) and Same-Origin Policy

Cross site scripting is a **vulnerability** by means of which **client-side code
can be injected in a page**. There are three types of XSS:

1. **Stored** (persistent) XSS: the **attacker's input is stored on the target
   server in a database**; then a victim retrieves the stored malicious code
   from the web application without that data being made safe to render in the
   browser
2. **Reflected** (non-persistent) XSS: (Attacker) **Client input is returned to
   the client (Victim) by the web application in a response**; the response
   includes some or all of the input provided in the request, without being
   stored and made safe to render in the browser.
3. **DOM-based** XSS: **user input never leaves the victim’s browser**; the
   malicious payload is **directly executed by client-side script**

JavaScript is **sandboxed**, but **can also do some malicious things** like:

1. **Cookie theft** or **session hijack**
2. **Manipulation** of a **session** and execution of **fraudulent transaction**
3. **Snooping** on private information
4. **Drive by Download**
5. Effectively **bypass the same-origin policy**

The **same-origin policy** is implemented by all web clients and it **mandates
that all client-side code load from origin `A` should only be able to access
data from origin `A`**. An origin is defined as a `<protocol, host, port>`
tuple. Modern web has **blurry boundaries** on this, like **CORS** and
**client-side extensions**.

A gut reaction to prevent XSSs is to block the `<script>` tag (since we cannot
know a-priori what users want to write), however that is not enough:

- `<applet>`, `<frame>` and `<iframe>` all execute code
- Even "safe" tags are not safe: we can inject JS using event handlers like
  `onerror` and `onload` or using `javascript:`:

  ```html
  <img src="/asdf" onerror="alert('XSS');" />
  <svg onload="alert('XSS');" />
  <a href="javascript:alert('XSS')">Totally safe link, click me!</a>
  <a
    href="javas
  cript:alert('XSS')"
    >Totally safe link, click me!</a
  >
  <a href="javasc&#09;ript:alert('XSS')">Totally safe link, click me!</a>
  ```

**The potential blocklist becomes infinite. The solution is to escape text**:

- `<` becomes `&lt;`
- `>` becomes `&gt;`
- `&` becomes `&amp;`

So that it will _never_ be interpreted as JS but still be rendered correctly.
