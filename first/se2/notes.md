# Software Engineering 2

## Requirement engineering

It is the process of discovering a purpose, by identifying stakeholders and their
needs, and documenting these in a form that is amenable to analysis,
communication and subsequent implementation.

It analyses the real-world goals, functions of and constraints on systems. It is
also concerned with the relationship of these factors to precise specifications
of software behaviour, and to their evolution over time and across software
families.

A requirement can be: 

1. Functional: describes the interaction between the system and its environment
   independent from implementation
2. Non-functional: user-visible aspects of the system not directly related to
   functional behaviour.

   They are independent of the application domain, however the domain determines
   their relevance and prioritization. They can have a big impact on the
   structure of the system. Also called Quality of service (QoS).
3. Constraints: imposed by the client or the environment in which the system
   operates.

Poor requirements are ubiquitous. RE is the most difficult part and course
correcting later in development is too costly. 

### Steps

1. Elicitation and modeling
2. Analysis and validation
3. Generation of deliverables

### The world and the machine

- the machine: the portion of system to be developed
- the world: the portion of real world affected by the machine

Requirements engineering is concerned with phenomena occurring in the world, as
opposed to ones occurring in the machine. Requirement models are models of the
world.

The overlap between the world and the machine are the requirements we need to
describe:

- Goals (`G`) are prescriptive assertions formulated in terms of world phenomena
- Domain (`D`) properties/assumptions are descriptive assertions assumed to hold
  in the world
- Requirements (`R`) are prescriptive assertion formulated in terms of shared
  phenomena.

  The requirements `R` are complete if:

  1. `R` ensures staisfaction of the goals `G` in the context of the domain
     properties `D` ($R \land D \models G$)
  2. `G` adequately captures all the stakeholders' needs
  3. `D` represents valid properties/assumptions about the world
