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
