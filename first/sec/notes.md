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
