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

### Phase-locked Loops (PLL)

A phase-locked loop (PLL) is an electronic circuit that consists of **a phase
detector, a low-pass filter, and a voltage-controlled oscillator (VCO) connected
in a loop**. The closed-loop operation of the circuit is to maintain the VCO
frequency locked to that of the input signal frequency.

The basic operations are:

- **Capture and lock operation**:
  - Within a capture-and-lock frequency range, the dc voltage will drive the VCO
    frequency to match that of the input
  - While the loop is trying to achieve lock, the output of the phase comparator
    contains frequency components at the sum and difference of the signals
    compared
  - A low-pass filter passes only the lower frequency component of the signal,
    so that the loop can obtain lock between input and VCO signals
- **Lock operation**:
  - Input signal frequency is the same as that from the VCO
  - Best operation is obtained if the VCO center frequency $f_0$ is set with the
    dc bias voltage midway in its linear operating range
  - The amplifier allows this adjustment in dc voltage from that obtained as
    output of the filter circuit
  - When the loop is in lock, the two signals to the comparator are of the same
    frequency, although not necessarily in phase
  - A fixed phase difference between the two signals to the comparator results
    in a fixed dc voltage to the VCO
  - Changes in the input signal frequency then result in change in the dc
    voltage to the VCO

Due to the limited operating range of the VCO and the feedback connection of the
PLL circuit, there are two important **frequency bands** specified for a PLL:

- The **capture range** of a PLL is the frequency range centered about the VCO
  free-running frequency $f_0$ over which the loop can acquire lock with the
  input signal
- Once the PLL has achieved capture, it can **maintain lock with the input
  signal over a somewhat wider frequency range called the lock range**

Common **applications** of PLLs are:

- **Frequency synthesizers** that provide multiples of a reference signal
  frequency
  - **Clock multiplier/clock generator**
  - **Frequency synthesizers** (Fractional-N, Integer-N)
- FM demodulation networks for FM operation with excellent linearity between the
  input signal frequency and the PLL output voltage
- Demodulation of the two data transmission or carrier frequencies in
  digital-data transmission used in frequency-shift keying (FSK) operation
- Wide variety of areas including modems, telemetry receivers and transmitters,
  tone decoders, AM detectors, and tracking filters, embedded systems, computing

#### Frequency synthesis

A **frequency divider is inserted between the VCO output and the phase
comparator** so that the loop signal to the comparator is at frequency $f_0$ and
the VCO output is $Nf_0$. This **output is a multiple of the input frequency as
long as the loop is in lock**.

#### Integer-N synthesizer

The resolution of the output frequency is determined by the reference frequency
applied to the phase detector. To obtain a stable low frequency source is not
easy, because a quartz crystal oscillating in kHz region is quite bulky and not
practical. A sensible approach is to take a good stable crystal-based high
frequency source and an integer-N synthesizer to divide it down.

### Timers

A timer is a **specialized type of clock to measure time intervals**. A timer
that counts from zero upwards for measuring time elapsed is often called
stopwatch. A device that counts down from a specified time interval is used to
generate a time delay.

**A counter is very similar to a timer**:

| Timer                                                             | Counter                                                                          |
| ----------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| The register is incremented for every cycle                       | The register is incremented considering the transition in the external input pin |
| Maximum count rate is 1/12 of the oscillator freq.                | Maximum count rate is 1/24 of the oscillator freq                                |
| A timer uses the freq of the internal clock and generates a delay | A counter uses an external signal to count pulses                                |

**Timers and counters are perhaps the most pervasive peripherals in MCU
designs**:

- **About any application can use a timer or counter** to improve performance,
  reduce power, or simplify the design by replacing repetitive - or looping -
  CPU operations with a **simple timer or counter interrupt**
- Specific COTS devices or blocks of MCUs are tailored to support programmable
  timers
- Some of the most advanced **timer/counter features are used for PWM
  applications** for motor control

Every timer needs a **clock source or timebase**. There are often several clock
sources and one is selected; sometimes an external clock source is an option. To
**increase the count range**, the selected **clock goes to a "prescaler" which
divides the clock before it goes to a main counter**. The count range of the
main counter is set by a **"modulus" value (M) stored in a register**. This is a
down counter which reloads the modulus value on the next clock after it
reaches 0.

#### Polling and interrupts

Polling is **periodically reading status registers to detect timer events or the
current value of a counter**. This type of coordination can use a lot of
processing time or the response time can vary a lot with a complicated program.
The solution for these problems is using interrupts.

A **timer event occurs and triggers an interrupt by sending a hardware signal to
an "interrupt controller"**. This component **suspends execution of the main
program and makes the processor jump** to a software function called `ISR`,
**then resume** to normal operation. The main program does not spend time
checking for a timer event. The response to the timer event can be very fast and
predictable

#### Periodic timers

**Periodic timers produce repetitive markers or "ticks" with a fixed period**.
The major parameter is the period which is set with a counter modulus. Some
examples of periodic timers are:

1. Controlling the polling of digital inputs like pushbuttons
2. Scheduling of tasks by a real-time operating systems
3. Accurately pacing DMA transfers to a digital-to-analog converter
4. Triggering an analog-to-digital converter for accurate sample rate

#### Delay functions

Delay functions **cause something to happen after a period of time has
elapsed**. An example of delay is debouncing a pushbutton.

### Watchdog timers

A **watchdog timer** (also called a COP) is basically an **internal or external
device** (timer) that is installed in a system in order to **detect any software
anomalies that may arise** in embedded systems. It has the **responsibility to
reset and restart the processor when needed in the case of a software glitch**.

**Normally the computer regularly resets the watchdog timer to prevent it from
elapsing**, or "timing out". In the case of **hardware fault or program error**,
the computer **fails to reset the watchdog, the timer will elapse** and generate
a **timeout signal**. The timeout signal **initiates corrective actions** (not
always a reset) which typically include **placing the computer system in a safe
state and restoring normal system operation**.

Watchdog timers are **critical for IoT** since it is impossible to manually
service millions of devices.

Watchdogs are of **different types**:

1. Simple timers
2. Windowed timers
3. Smart watchdogs

Watchdogs may exist **internally to micro-controllers as hardware and
software**, **externally as hardware, and even as separate micro-controllers**
with both hardware and software components. No matter which watchdog solution is
used, the sole purpose is to monitor and recover the system. To this end, each
watchdog has its own unique characteristics and design challenges that
developers need to consider for a robust.

The **timeout is loaded** (**kicking the watchdog**) in a resettable downword
counter generating a signal when it reaches zero (terminal value). Watchdog
timers **may have either fixed or programmable time intervals**.

The watchdog is **kicked by asserting its restart input**. Some watchdogs **can
be enabled and disabled by software**. **Other** watchdogs are automatically
enabled upon system boot and **cannot be disabled at all**. SW-enabled watchdogs
are typically disabled upon system reset.

Two **corrective actions** exists:

1. **Set the MCU control outputs to safe levels** so that potentially dangerous
   devices such as motors and heaters will not pose threats to people or
   equipment.
2. After setting the outputs to safe levels **restore normal system operation**.

#### Single stage watchdog

**Single timer that invokes an immediate restart upon timeout**. This
architecture **depends on the system reset to force control outputs to their
safe states**. MCU and watchdog **may share the same clock signal**.

#### Multiple stage watchdog

**Two or more timers** can be **cascaded** to form a multistage watchdog timer.
**Only the first stage is kicked by the processor**. Upon **first stage timeout,
a corrective action is initiated and the next stage** in the cascade is
**started**. As each **subsequent stage times out**, it **triggers a corrective
action** and starts the next stage. Upon **final stage timeout**, a **corrective
action is initiated**, but **no other stage is started** because the end of the
cascade has been reached.

Multistage watchdog timeout **doesn't immediately restart MCU**; it merely
**schedules a restart to occur at a future time**. A multistage watchdog **must
work in concert with special circuitry that will switch outputs to safe states
upon timeout**, prior to the computer/MCU restart.
