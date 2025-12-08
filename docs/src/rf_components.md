# RF Components Reference

This document provides an overview of the RF components available in CircuitSim.jl.

## Quality Factor Components

### CapacitorQ

Capacitor with specified quality factor for accurate RF modeling.

```julia
C1 = CapacitorQ("C1", 10e-12, 50.0)  # 10pF, Q=50 at 1GHz
C2 = CapacitorQ("C2", 100e-12, 100.0, freq=2.4e9)  # Custom frequency
```

**Parameters:**
- `value`: Capacitance in Farads
- `q`: Quality factor at specified frequency
- `freq`: Frequency where Q is specified (default: 1 GHz)

### InductorQ

Inductor with specified quality factor for accurate RF modeling.

```julia
L1 = InductorQ("L1", 10e-9, 30.0)  # 10nH, Q=30 at 1GHz
L2 = InductorQ("L2", 100e-9, 50.0, freq=2.4e9)  # Custom frequency
```

**Parameters:**
- `value`: Inductance in Henries
- `q`: Quality factor at specified frequency
- `freq`: Frequency where Q is specified (default: 1 GHz)

## DC Coupling Components

### DCBlock

DC blocking capacitor for AC coupling between stages.

```julia
DCB1 = DCBlock("DCB1")  # Default 1μF
DCB2 = DCBlock("DCB2", 10e-6)  # Custom 10μF
```

**Parameters:**
- `value`: Capacitance in Farads (default: 1 μF)

### DCFeed

RF choke for providing DC bias while blocking RF.

```julia
DCF1 = DCFeed("DCF1")  # Default 1mH
DCF2 = DCFeed("DCF2", 10e-3)  # Custom 10mH
```

**Parameters:**
- `value`: Inductance in Henries (default: 1 mH)

### BiasTee

Combines DC bias and RF signals with three ports: RF, DC, and combined output.

```julia
BT1 = BiasTee("BT1")  # Default values
BT2 = BiasTee("BT2", c_block=10e-6, l_choke=10e-3)  # Custom
```

**Parameters:**
- `c_block`: DC blocking capacitance (default: 1 μF)
- `l_choke`: RF choke inductance (default: 1 mH)

## Active Components

### Amplifier

RF/microwave amplifier with gain and noise figure.

```julia
LNA = Amplifier("LNA", 20.0, 1.5)  # 20dB gain, 1.5dB NF
PA = Amplifier("PA", 30.0, 5.0, p1db=30.0)  # Power amp with P1dB spec
```

**Parameters:**
- `gain`: Power gain in dB
- `nf`: Noise figure in dB (default: 0)
- `z_in`: Input impedance in Ohms (default: 50)
- `z_out`: Output impedance in Ohms (default: 50)
- `p1db`: 1-dB compression point in dBm (default: 20)

## Directional Components

### Isolator

Unidirectional component - passes signals forward, blocks reverse.

```julia
ISO1 = Isolator("ISO1")  # Default: 0.5dB forward, 20dB isolation
ISO2 = Isolator("ISO2", forward_loss=1.0, reverse_loss=30.0)
```

**Parameters:**
- `forward_loss`: Insertion loss in forward direction (dB) (default: 0.5)
- `reverse_loss`: Isolation in reverse direction (dB) (default: 20)
- `z0`: Reference impedance in Ohms (default: 50)

### Circulator

3-port circulator routes signals in one direction: 1→2, 2→3, 3→1.

```julia
CIRC1 = Circulator("CIRC1")  # Default specs
CIRC2 = Circulator("CIRC2", isolation=30.0)  # Better isolation
```

**Parameters:**
- `insertion_loss`: Loss through forward path (dB) (default: 0.5)
- `isolation`: Isolation to reverse path (dB) (default: 20)
- `z0`: Reference impedance in Ohms (default: 50)

## Power Control

### Attenuator

Fixed attenuator for signal level control.

```julia
ATT1 = Attenuator("ATT1", 10.0)  # 10dB attenuator
ATT2 = Attenuator("ATT2", 20.0, z0=75.0)  # 75Ω system
```

**Parameters:**
- `attenuation`: Attenuation in dB
- `z0`: Reference impedance in Ohms (default: 50)
- `temp`: Temperature in Celsius (default: 26.85)

### PhaseShifter

Introduces specified phase shift while maintaining amplitude.

```julia
PS1 = PhaseShifter("PS1", 90.0)  # 90° phase shift
PS2 = PhaseShifter("PS2", 180.0, insertion_loss=0.5)  # With loss
```

**Parameters:**
- `phase`: Phase shift in degrees
- `z0`: Reference impedance in Ohms (default: 50)
- `insertion_loss`: Insertion loss in dB (default: 0)

## Power Dividers/Combiners

### Coupler

Directional coupler - 4-port device for power splitting.

```julia
DC1 = Coupler("DC1", 3.0)   # 3dB (50/50 split)
DC2 = Coupler("DC2", 10.0)  # 10dB (90/10 split)
DC3 = Coupler("DC3", 20.0, isolation=30.0)  # Sampling coupler
```

**Ports:** 1=input, 2=through, 3=coupled, 4=isolated

**Parameters:**
- `coupling`: Coupling factor in dB
- `isolation`: Isolation in dB (default: 20)
- `insertion_loss`: Through path loss in dB (default: 0.5)
- `z0`: Reference impedance in Ohms (default: 50)

### Hybrid

Hybrid coupler - 3dB power splitter with phase relationship.

```julia
HYB1 = Hybrid("HYB1")  # 90° (quadrature hybrid)
HYB2 = Hybrid("HYB2", phase=180.0)  # 180° (rat-race)
```

**Ports:** 1=sum, 2=difference/isolated, 3=output1, 4=output2

**Parameters:**
- `phase`: Phase difference in degrees (default: 90, typically 90 or 180)
- `insertion_loss`: Insertion loss in dB (default: 0.5)
- `isolation`: Port isolation in dB (default: 20)
- `z0`: Reference impedance in Ohms (default: 50)
