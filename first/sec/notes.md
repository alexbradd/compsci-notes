# Computer security

## Intro

Security **always has an adversarial component**: there is someone that wants to
abuse the system.

**A vulnerable system is a system where exists a shortcut that is not known to the
system designer**.

If the system secured is a computer, **for it to be secure we need it to have 3
main properties (CIA)**:

1. **Confidentiality**: information should be accessed only from authorized people
2. **Integrity**: information should be modified only by persons authorized to do so
3. **Availability**: information should be available to all authorized parties
   within specified time constraints

Providing these three elements is an engineering problem.

The **availability constraint is the business requirement** and the most difficult
one to keep satisfied: data is always more and to be made more readily
available.

**A vulnerability is something that allows us to violate one of the constraint**. On
the other hand, **exploits are a specific way to use one or more vulnerability to
accomplish a specific objective that violates the constraint**.

> In the case of a vulnerable lock: the vulnerability is friction, the exploit
> is using tension wrench and pick to pick the lock

In computers, there are scenarios in which we can change the vulnerable code but
there are also cases in which we cannot due to various reason (cost, legacy
compatibility etc).

**The security of a system is not correlated to the level of protection of said
system**. We can have protected system be less secure than unprotected ones.
Even for protection, **we need to define what threats we protect from**. When we are
talking about security, **we always need to define the threat model, otherwise our
discussion is useless**.

**Assets are what is valuable for an organization**. Since we are talking about
computer security, we are talking about IT assets. **Most of the time, it is not
the computer that is valuable, but what they do (for example the data they handle
or the industrial process they manage)**. Even reputation can be an asset.

**A threat is a circumstance potentially causing a CIA violation**.

**An attack is an intentional use of one or more exploits with the objective of
compromising a system's CIA. Threat agent is someone/something that makes an
attack happen**.

In general **risk is the statistical and economical evaluation of the exposure to
damage because of the presence of vulnerabilities and threats**.

$$ \mathrm{Risk} = \mathrm{Asset}\times\mathrm{Vulnerabilities}\times\mathrm{Threats} $$

**Assets and vulnerabilities are controllable, while threats are not**. **Security is
the balance of reduction of vulnerabilities + damage containment vs cost**.

The **cost of security is both direct** (management, operational and equipment) **and
indirect** (less usability, lower performance and reduced productivity). A **fallacy**
is **changing the system to reduce privacy to increase security**. This paradigm is
**always a net loss for the system** since we are **exchanging the confidentiality of
users** (confidentiality) with a **small increase of security of the system**.

Another problem is that, often, **security measures impose a cost on the users but
do not benefit them**. This means that **if users do not see value in the measures,
they are going to go out of their way to avoid them**.

In security, **throwing money around does not solve problems: the best way to
increase security is often to do nothing than to do something badly**. **Once a
measure has been introduced, however, no one would bear the cost of the
possiblity (even low) of an attack made possible by said removal**. Thus once
security measures are made permanent **they are very rarely reverted**.
