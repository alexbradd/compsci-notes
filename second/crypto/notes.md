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
