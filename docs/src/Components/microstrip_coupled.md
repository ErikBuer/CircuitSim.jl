# Microstrip Coupled Lines

Pair of microstrip coupled transmission lines for directional couplers and filters.

## Parameters

- `w`: Line width in meters, default: 1e-3
- `l`: Line length in meters, default: 10e-3
- `s`: Line spacing in meters, default: 1e-3
- `substrate`: Substrate reference name, default: "Subst1"
- `model`: Quasi-static model, default: "Kirschning" (options: "Kirschning", "Hammerstad")
- `disp_model`: Dispersion model, default: "Kirschning" (options: "Kirschning", "Getsinger")
- `temp`: Temperature in Celsius, default: 26.85°C

## Example

```@example mcoupled
using CircuitSim

# Default with Kirschning models
coupled1 = MicrostripCoupled("MCPL1", w=1.0e-3, l=20e-3, s=0.2e-3)

# Custom substrate reference
coupled2 = MicrostripCoupled("MCPL2", substrate="Sub1", 
    w=1.0e-3, l=20e-3, s=0.2e-3)

# Using Hammerstad quasi-static model
coupled3 = MicrostripCoupled("MCPL3", w=1.0e-3, l=20e-3, s=0.2e-3,
    model="Hammerstad")

# Using Getsinger dispersion model
coupled4 = MicrostripCoupled("MCPL4", w=1.0e-3, l=20e-3, s=0.2e-3,
    disp_model="Getsinger")
```
