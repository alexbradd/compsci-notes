# Embedded systems

## Intro

Main topics to be accounted for by research and industry:

1. Energy and power dissipation
2. Dependability
3. Complexity is reaching unmanageable level and yet still grows

All future killer applications will have some of these four characteristics:

1. Compute-intensive
2. Connected to other systems,(wired or wireless) either always or
   intermittently online
3. Entangled physically, which means that they will not only be able to observe
   the physical environment that they are operating in, but also to control it.
4. Smart and able to interpret data from the physical world

The application requirements can be easily measured in `OPS/W`

The metric we are optimizing for is:

$$
\frac{\mathrm{Functionality}}{\mathrm{Energy}\times\mathrm{Cost}}
$$

We are spending more for energy to power devices than the devices themselves. So
small savings in energy are linked to huge savings on operation costs.

### Hitting the power limit

We have hit a plateau on what CMOS technology can do:

- First we pushed single-cores until we hit the power limit
- Then we pushed multi-core until we hit the power limit

And we cannot push performance any further by simply putting without huge power
draw (the end of Moore's law). Moreover, we cannot push down the VDD any more
(plateau at 1.2/1.1 with a possible 1.0).

The solution to power problem is to keep adding more transistors, but just not
power everything (the un-powered stuff is called "dark silicon"). These extra
transistors can be used for:

1. Multi-cores
2. Many-cores
3. Domain-specific processors

This all points to heterogeneous processing and aggressive power management:
computation needs to be done in the most efficient place.

### Hitting the processing limit

We are heading towards a world in which we can collect more data than we can
process. This is the data "deluge" gap.

### Networks-on-chip reliability wall

Small transistors have big problems:

1. Each device is slightly different than the others (silicon lottery): the
   smaller the process, the bigger the variation

   With multi-cores this problem is also present on the same chip (different
   cores have different "quality")

2. They are less resistant to physical defects
3. They "age" (performance degradation) (c.f.r NBTI)
4. Since they are smaller, they are more packed meaning:
   - Increased power density
   - Problems in cooling

Networks-on-chip need a high-performance interconnect since it can easily become
the bottleneck of the system. However, this needs mores silicon and more power
(in a commercial 10 core chip, 30% of it is only the network fabric).

Since the single chip is basically a distributed system, also the thermal design
plays a role: the floorplan of the chip directly affect the thermal performance
since we can introduce "hotspots" that are difficult to cool.

A way to tackle this is partitioning the system in islands differing in terms of
voltage and frequency, with the possibility to be switched off (power gating).

### Overview of HPC cooling

- Air cooling:
  - Pros:
    - cheap and portable
  - Cons:
    - Very low HTC and chip uniformity
    - Large heat sinks
    - Noisy
    - Expensive maintenance
    - Complex air management
- Water cooling:
  - Pros:
    - Less fans/ducts
    - Better HTC
    - Smaller heat sinks
    - Possible heat recovery
    - Problems with water contaminants
  - Cons: large pumps
- Two phase cooling:
  - Pros:
    - Smaller pump
    - Higher HTC
    - Better chip uniformity
    - Isothermal coolant
    - Good hot spot cooling
    - Possible heat recovery
  - Cons: low pump efficiency and reliability

Cooling becomes even more complex since chips are becoming multi-layer.

## Microprocessors

See **ACA notes**.
