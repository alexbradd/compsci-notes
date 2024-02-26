# Cryptography and Architectures for Computer Security

## Basics

Basic definitions:

- **Alphabet** $\mathcal{A}$: a finite set of symbols
- **Message space** $\mathcal{M}$: a set of strings over an alphabet
  - An element of the message space is called the message
- **Ciphertext space** $\mathcal{C}$: a set of strings over an alphabet (may
  differ from $\mathcal{M}$)
  - An element of the ciphertext space is called a ciphertext
- **Keyspace** $\mathcal{K}$: set of elements called keys
  - The cardinality of the keyspace is one of the figures of merit employed to
    assess the security margin provided by a crypto-system
- **Encryption transformation**: given an element $e\in\mathcal{K}$,
  $\mathbb{E}_e: \mathcal{M}\mapsto\mathcal{C}$ uniquely identifies a bijective
  map
- **Decryption transformation**: given an element $d\in\mathcal{K}$,
  $\mathbb{E}_d: \mathcal{C}\mapsto\mathcal{M}$ uniquely identifies a bijective
  map
- **Cryptoscheme**: defined by the following elements:

  - Alphabet
  - Message space
  - Ciphertext space
  - Keyspace
  - Set of encryption transformations
  - Set of decryption transformations

  Some **fundamental properties** are:

  - **Correctness**: it is possible to successfully decrypt the plaintext from
    every ciphertext only employing the correct key(s)
  - **Efficiency and Strength**: both $\mathcal{E}$ and $\mathcal{D}$ should be
    fast to compute given the correct values of $e$ and $d$, and unfeasible (or
    impossible) to compute without them

Some **common encryption paradigms** are:

- **Symmetric** (or Secret-Key) Cryptosystems: **every user is bound to a single
  secret key**, with fixed length, used by both encryption and decryption
  transformations

  - Provides **confidentiality and/or data authentication**, but it **cannot
    provide non-repudiation**

  There are **two main strategies** to implement the transformations:

  - **Block ciphers** (AES, 3DES): act on a fixed length plain/ciphertext
  - **Stream ciphers**: act on an arbitrary length plain/ciphertext

  Pros: **very efficient**\
  Cons:

  - **Secret key must be exchanged over a separate secure channel**
  - **Key management is cumbersome**:
    - Each pair of parties should shader a different key (a group of $n$ users
      requires $\approx n^2$ keys)
    - When a user is added/removed to/from the group, he must communicate with
      potentially n users to send/invalidate his keys

- **Asymmetric** (or Public-Key) Cryptosystems: **every user is bound to a
  key-pair**: a **public key** used to encrypt (can be shared) and a **private
  key** used to decrypt (must be kept secret).

  - Provides **confidentiality, data authentication and non-repudiation**

  Pros: **Scalable key management** and non-repudiation\
  Cons:

  - **Substantially slower** than symmetric systems
  - **Longer key length** is required to achieve the same level of security of a
    symmetric scheme
  - The **public key needs authentication to avoid identity theft**

  **To provide non-repudiation** we need two entities:

  - **Digital Signature**: allows to **verify the unambiguous association** of a
    **user** to their **public-key**
    - Can be obtained by applying the decryption transformation to the message
      $m$, which should be authenticated
    - Everyone can check the validity of the signed message
    - Assuming $\mathbb{D}_e$ and $\mathbb{E}_e$ as signature and verification
      primitives respectively can be done only when RSA is in use
  - **Certification Authority**: **independent and trusted third party**
    **certifies the binding** of a public-key to the identity of the
    corresponding user
    - It **digitally signs a document** (digital certificate) containing the
      identity, public-key of a user + metadata, this document is stored in
      public repositories
    - The assumption is that **everybody knows the public keys of the CAs**,
      thus every certificate can be checked through verifying a CA signature
    - The system can be **hierarchically organized** with CAs authenticating
      other CAs: this structure is known as Public Key Infrastructure

- **Identity-based** Cryptosystem: a **public-key system where the user identity
  is used to uniquely derive the public key**

  - Identity: any previously recognized and publicly known piece of information
    bound to a specified user
  - Public Key: is uniquely derived from the Identity chosen by the user; may be
    known to everybody
  - **Private Key**: is **released to each user** by a **Trusted Authority**
    (TA) who **combines the user identity and a master secret parameter** to
    compute it
    - Private key is **known only to the user and TA** (key escrow)

  Pros:

  - **No need for digital certificates** and their management
  - **Multiple private keys can be bound to the same user** identity

  Cons:

  - The **key escrow** might not be a desired feature in open networks
  - Significantly **more complex** than both asymmetric and symmetric systems

The **strength** of a cryptoscheme is evaluated **against different attack
models**, where the **adversary** is classified as:

- **Passive**: **only monitors** the communication channel; only **threatens
  confidentiality**
- **Active**: **attempts to delete, add, or alter the messages** transmitted
  over a channel; **threatens data integrity, authentication and
  confidentiality**

There are **several possible assumptions** on information available to a passive
attacker:

- **Basic** (Kerckhoff principle): the alphabet, the structure of plaintexts and
  the details of the encryption/decryption scheme are known
- **Brute force** attack: given a ciphertext, it **checks all possible keys**
  until the correct one is found
  - Attacker must be able to distinguish the correct plaintext from a valid but
    incorrect one
  - Used against any computationally or provably secure scheme
  - **Perfectly secure schemes are not attackable via brute force**
- **Ciphertext-only** attack (COA): attacker **knows the ciphertext** of a
  number of **messages encrypted with same key**
  - **Recovers either the plaintext or the key** by **comparing the statistical
    distributions** of ciphertext and plaintext symbols
- **Known-plaintext** attack (KPA): attacker **knows plain-ciphertext pairs**,
  encrypted with same key
  - **Analyzes the differences** among the different ciphertexts/plaintexts and
    **reconstructs the secret key**
- **One-wayness under Chosen-Plaintext** Attack (OW-CPA):
  - Attacker **chooses at will plaintexts** to be encrypted (all with the **same
    unknown key**) and **obtains the corresponding ciphertexts**
  - Defender **picks** $m\gets\mathcal{M}$ and **sends back the ciphertext
    computed** with the **same unknown key** to the attacker
  - Attacker must **guess/recover** $m$
- **Indistinguishability under Chosen-plaintext** attack (IND-CPA): similar to
  OW-CPA, however the flow is a bit different:

  - Attacker **chooses at will plaintexts to be encrypted** (all with the same
    unknown key) and **obtains the corresponding ciphertexts**
  - Attacker **chooses 2 plaintexts** $m_0$ , $m_1$ and **sends them** to the
    defender
  - Defender **tosses a coin and sends back one encryption** depending on said
    coin
  - Attacker **must guess if the ciphertext is the one of either** $m_0$ or
    $m_1$ with a **probability higher than 50%**

  $\mathrm{IND-CPA}\implies\mathrm{OW-CPA}$

- **Chosen-Ciphertext** attack (CCA):

  - The defender **performs both encryptions and decryptions of attacker
    supplied material** under the **same unknown key except for the challenge
    message** $m$ **and the coin flip**.
  - OW and IND definitions match the one for CPA with this attacker’s scenario
  - The **goal is to gradually reveal information about the plaintext**, or
    about the decryption key itself

  If the **defender performs decryptions even after sending the challenge**, the
  attacker model is called **adaptive-chosen-ciphertext** attack (CCA2).

**COA and KPA models are too weak** to be used in real-world cipher design. A
CCA model models well an attacker able to interact with a device containing a
private key. **IND-CCA2 is the reference property to be guaranteed in proper
cipher design**.

## Historical ciphers and unconditional security

### Historical ciphers

- **Shift cipher**:

  - Given the usual latin alphabet, identify each letter with a number, consider
    a message space that includes messages composed of single letter
  - the key of the cipher is a number $0\leq k\leq 25$ ($|\mathcal{K}| = 26$)
  - To encrypt replace each plaintext letter $p$ by the letter $p + k \mod 26$

  Analysis:

  - Easily brute-forceable: maximum 26 keys

- **Monoalphabetic substitution cipher**: generalization of a shift cipher

  - The message space is defined over an alphabet $\mathcal{A}_m$, the
    ciphertext space is defined over an alphabet $\mathcal{A}_c$
    - The sizes of the two alphabets must match
  - The message spaces $\mathcal{M},\mathcal{C}$ include messages composed of a
    single letter respectively
  - The **encryption transformation can be defined as the application of any
    bijective map between the elements of** $\mathcal{M}$ **and the elements
    of** $\mathcal{C}$
  - The keyspace is the amount of possible bijective maps, which is
    $26! \approx 2^{88}$

  Analysis:

  - More resilient to brute forcing
  - **COA easily reveals the key**:
    - The statistics of the plaintext distribution is known
    - The statistics of the ciphertext space can be computed over the available
      ciphertexts
    - The substitution map can be inferred easily by matching the symbols
      occurring with similar frequencies

- **Polyalphabetic cipher**:

  - The plaintext and ciphertext spaces include finite sequence of letters
    (words) from the respective alphabets
  - The **encryption transformation is defined as the application of** $L > 1$
    **bijective maps between the two alphabets**
    - The encryption transformation applies $\mu_0$ to the first letter, $\mu_1$
      to the second, etc. periodically
  - The **key is constructed as the tuple of the different bijective maps**
  - The **keyspace** is $(|\mathcal{A}_m|!)^L$, which is **way too large to
    brute force**

    Famous cipher:

    - **Vigenère cipher**: it employs $L$ **cyclic shifts**, the **cipher key is
      given as a sequence of letters**, each one of them denotes the **first
      letter of a cyclic shift of the alphabet**

      - Limits the keyspace to $|\mathcal{K}|^L$

      Analysis:

      - Can be easily broken with COA:

        **Find the length of the keyword** $L$ through the **Kasisky Test**. Key
        observation: two identical segments of $2\leq l\leq L$ plaintext letters
        (l-gram), will be encrypted to the same sequence of $l$ ciphertext
        letters (when properly aligned with the keyword). The distance $d$
        between two repeated sequences of $l$ chars in the ciphertext may
        suggest a multiple of the key length $L$.

        **Split up the ciphertext** into $L$ **sequences** of letters (one
        sequence for each keyword letter): **each** sequence is **computed by
        aligning letters corresponding to the same "shift ciphertext"**.

        Apply **frequency analysis** to each "shift ciphertext" Use the
        retrieved shift cipher keys to derive the value of the keyword

    - **Beale cipher**: variant of the Vigenère cipher
      - Based on the clue that "Longer the key lengths, lower the possibility of
        re-enciphering the same d-grams in the same way"
      - **Keyword is taken as the first few words of a book** that is agreed
        upon by the cipher users

- **Permutation ciphers** (transposition cipher):

  - **Encryption transformation consists of a permutation of the positions of
    the plaintext letters**
  - The **cipher key is a random permutation with length** $L$, the key length
    is kept secret

  Analysis:

  - Pros:
    - **Keyspace can be quite large**
    - It **does not alter the d-gram frequency distribution** between plaintext
      and ciphertext message space
    - **COA is not very effective**
  - Cons:
    - It **does not alter the single letter frequency distributions**
    - **KPA and CPA can easily reveal the key** if $L$ is small

- **Affine ciphers**: it is a polyalphabetic cipher where the cipher key can be
  thought as a $m\times m$ invertible matrix of numbers modulo 26; a block of
  $m$ plaintext letters is then considered as a column vector. To encrypt we
  multiply mod 26 the cipher key with the column vector, to decrypt we invert
  the cipher key and multiply it mod 26 with a vector from the cipher text.

  Analysis:

  - Pros:
    - The **keyspace is quite large**: $\approx 26^{m^2}$
    - Cipher **alters the frequency distribution of texts in a complex way**
    - **COA is not effective**
  - Cons:
    - **KPA easily reveals the keys** by just solving a linear system of
      equations
    - Given a **pair of ctx and ptx**, the **key is computed** as $K = C P^{-1}$

Takeaways:

- The cipher **key should be long enough to withstand brute force attacks**
  - Rule of thumb: **keyspace** should have a size which is **encoded with at
    least 80-bit**
- The **mapping between ptx and ctx letters**, in the definition of the
  encryption/decryption transformation, **should not be the same for every
  occurrence** of the same ptx letter
- **Linear mapping** between ptx and ctx is **vulnerable to KPA**
- Frequency attacks **exploit the redundancy of the English language**

  - Lossless compression before encryption removes it
  - Using an uncommon/dead natural language may also help

### Perfect secrecy

A perfectly secret cipher should be **unbreakable regardless of the effort
thrown at it**. This implies that **the ciphertext alone provides no
information** to an attacker. **Shannon proved the existence** of such a scheme.

A perfectly secure cipher is proven to be resistant to COA, KPA and CCA.

Given a **generic symmetric cipher**, assume that the attacker can analyze an
arbitrary number of chosen ptx-ctx pairs. We will make the following **basic
assumptions** about the schemes parameters:

- Each **item** in $\mathcal{M},\mathcal{K},\mathcal{C}$ is **modeled as a
  random variable** $P, K, C$ with certain distribution
- $P, K$ are **statistically independent**

Due to the statistical independence, the **probability of observing a particular
ctx** is:

$$
Pr(C = c) = \sum_{k:c\in\{\mathbb{E}_k(m) \forall m\in\mathcal{M}\}}
  Pr(K = k)Pr(P = \mathbb{D}_k(c))
$$

**When we try to break a cipher** we are interested in the **conditional
probability of guessing the ptx value**, knowing the value of the ctx, i.e.:

$$
Pr(P=m|C =c) = \frac{Pr(P = m)Pr(C = c | P - m)}{Pr(C = c)}
$$

**Definition** of perfectly secure cryptosystem:

> A symmetric-key cryptosystem is perfectly secure if the ciphertext does not
> reveal any information about the plaintext
>
> $$ Pr(P=m|C =c) = Pr(P=m) \forall m\in\mathcal{M}, c\in\mathcal{C}$$

**Lemma**:

> A symmetric-key cryptosystem is Perfectly Secure if the plaintext does not
> reveal any information about the ciphertext:
>
> $$ Pr(C=c|P=m) = Pr(C=c) \forall m\in\mathcal{M}, c\in\mathcal{C}$$
>
> > Proof on slides

**Lemma**:

> Given a perfectly secure symmetric key cryptosystem, the following condition
> hold:
>
> $$ |\mathcal{K}| \geq |\mathcal{C}| \geq |\mathcal{M}| $$
>
> > Proof on slides

**Shannon's Theorem**:

> Let a symmetric key cryptosystem where keys are picked independently of
> plaintexts values and $|\mathcal{K}| = |\mathcal{C}| = |\mathcal{M}|$. The
> cyptosystem is perfectly secure iff:
>
> 1. Every key is used with probability $\frac{1}{|\mathcal{K}|}$
> 2. $\forall (m,c)\in\mathcal{M}\times\mathcal{C}\quad\exists! k\in\mathcal{K}: \mathbb{E}_k(m) = c$
>
> > Proof in slides

Is this perfect cipher **implementable?**

In 1919 Eng. Gilbert S. Vernam patented a telegraphic device able to encrypt the
symbols typed in by an operator (in Baudot encoding - i.e., a 5-bit ASCII
encoding). The ciphertext was composed through a bitwise XOR with a sequence of
symbols provided on a paper tape (the key) having the same length of the input
message (i.e., the plaintext). This matches the premises of the Shannon Theorem.

US army General Joseph Mauborgne proposed to employ a distinct paper tape (key
value) for each ptx (condition 2 of Shannon’s Th.) containing random information
(condition 1 of Shannon’s Th.). This idea combined with the Vernam’s XOR-ing
machine became known as the **One-Time-Pad (OTP)** enciphering machine.

The aforementioned **OTP** system employed with binary keys and messages is the
**most effective implementation of a perfectly secure cryptoscheme**.

The **security** of the OTP method **DEPENDS on the fact that that each key is
used only once** and **each key must be truly random**. Moreover, the key must
be available to both communication parties. **If the same key is reused**:

- The cipher is **vulnerable to KPA**
- If the **same key** is used to encrypt **two different messages**,
  **information about the ptx is leaked from the ctx**

Also, the **Vigenère** cipher can be **modified to be perfectly secure**: just
make sure the **key is as long as the ptx and is truly random**.

### Computationally secure cipher

Computationally secure ciphers **use the fact that an attacker doesn't have
unbounded computational power**. Practically the computational limit is made so
high that no realistic attacker is able to break the cipher.

We will use the term "information" as a synonym for Uncertainty: if you are
uncertain (or unaware) about the meaning of something, then revealing the
meaning gives you fresh knowledge and hence information. From the point of view
of a crypto-analyst you want to find out the meaning of a ciphertext: the level
of uncertainty you have about either the (correct) plaintext or the (correct)
key quantifies the amount of information leaked by the ctx.

The **level of uncertainty that the receiver (Bob) has about the value of the
received answer is called entropy** of $X$, denoted as $\Eta(X)$, and measured
in bit.

> Let $X$ be a random variable which takes values in $\{x_1, x_2, \ldots x_n \}$
> with probability distribution $p_i = Pr(X = x_i), \forall 1\leq i\leq n$. The
> Entropy of X is defined as:
>
> $$
> \Eta(X) = -\sum_{i=1}^n p_i \log_2 p_i
> $$
>
> assuming conventionally that $p_i\log_2 p_i = 0$, if $p_i =0$.

Properties:

1. Entropy is **semipositive** and zero only if one event is certain, while the
   others are impossible
2. If the **probability distribution is uniform** then $\Eta(X) = \log_2 n$
3. If $X$ is a random variable, $0 \leq \Eta(X) \leq \log_2 n$

Some **notable definitions**:

- **Joint entropy**:
  $\Eta(X,Y) = -\sum_{i=1}^n \sum_{j=1}^m Pr(X=x_i, Y=y_i) \log_2 Pr(X=x_i, Y=y_i)$
- **Entropy given observation**:
  $\Eta(X|Y=y) = -\sum_{i=1}^n Pr(X=x_i | Y=y) \log_2 Pr(X=x_i | Y=y)$
- **Conditional entropy**:
  $\Eta(X|Y) = -\sum_{i=1}^n \sum_{j=1}^m Pr(Y=y_j)Pr(X=x_i, Y=y_i) \log_2 Pr(X=x_i|Y=y_j)$

**Notable statements**:

- $\Eta(X, Y) \leq \Eta(X) + \Eta(Y)$, equality holds if $X,Y$ are independent
- $\Eta(X,Y) = \Eta(Y) + \Eta(X|Y)$
- $\Eta(X|Y) \leq \Eta(X)$, equality holds if $X, Y$ are independent

Going back to a generic symmetric cipher, we can **apply** our formulas:

- $\Eta(P|K,C) = 0$ and $\Eta(C|P,K)=0$ are obvious
- $\Eta(C, P, K) = \Eta(P, K) + \Eta(C|P,K) = \Eta(P, K) = \Eta(P) + \Eta(K)$
- $\Eta(C, P, K) = \Eta(K, C) + \Eta(P|K, C) = \Eta(K, C)$
- From the last two points we can **deduce that**:
  $\Eta(K, C) = \Eta(P) + \Eta(K)$

**Definition** (Key equivocation):

> Key equivocation is the **amount of information (uncertainty) about the key,
> that you got by the knowledge of a ctx**:
>
> $$ \Eta(K | C) = \Eta(K, C) - \Eta(C) = \Eta(P) + \Eta(K) - \Eta(C) $$

The amount of **information about the key leaked** by a ciphertext is
$\Eta(K) - \Eta(K|C)$.

The **redundancy** of the natural language employed for the plaintext messages
is of **great help to the attackers**. We can **quantify the amount of
redundancy** with the following formula:

$$
R_L = 1 - \frac{\Eta_L}{\log_2 |\mathcal{M}|}
$$

For English we have that
$|\mathcal{M}| = 26, 1.0 \leq \Eta_L \leq 1.5, R_L \approx 0.75$.

There is the possibility that **a key may decode the message into multiple
"meaningful" but wrong plaintexts** (however only one key will ever decode the
message into the correct one); these are called **spurious keys**. Let us denote
$|K_{meaningful}(c)|$ as the number of keys which decrypt a ctx $c$ into a
meaningful ptx. The **average number of spurious keys** is:

$$
\bar{s}_n = \sum_{c\in\mathcal{C}} Pr(C = c)(|K_{meaningful}(c)| -1)
$$

As the length of the ptx and ctw words increase ($n\to\infty$) we can define the
following **lower bound**:

$$
\bar{s}_n \geq \frac{\mathcal{K}}{\mathcal{M}^{nR_L}} - 1
$$

**Definition** (Unicity distance):

> The unicity distance is the **length of ciphertext words** (i.e., the number
> of ctx) $n = n_0$ such that **the number of spurious keys is equal to zero**,
> i.e.: $\bar{s}_n = 0$
>
> $$
> n_0 = \frac{\log_2\mathcal{K}}{R_L \log_2\mathcal{M}}
> $$

Alternatively, we can see the **unicity distance as the amount of ctx symbols
you need to provide to a bruteforcer to be reasonably sure that the first
meaningful output is the right ptx**. If $R_L = 0$, $n_0 \to\infty$.
