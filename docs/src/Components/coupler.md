# Coupler

Directional coupler with specified coupling factor and phase.

## Parameters

- `coupling`: Coupling factor (linear, 0 to 1), default: √(1/2) ≈ 0.7071 (≈ 3 dB)
- `phase`: Phase shift in degrees, default: 0° (range: -180° to +180°)
- `z0`: Reference impedance, default: 50 Ω

## Conversion: dB to linear coupling

- 3 dB: coupling = √(1/2) ≈ 0.7071
- 6 dB: coupling = 10^(-6/20) ≈ 0.501
- 10 dB: coupling = 10^(-10/20) ≈ 0.316
- 20 dB: coupling = 10^(-20/20) = 0.1

## Example

```@example coupler
using CircuitSim

# 3 dB (50/50) directional coupler
cpl1 = Coupler("CPL1")

# 10 dB directional coupler
cpl2 = Coupler("CPL2", coupling=0.316)

# 90° hybrid coupler (3 dB with 90° phase shift)
cpl3 = Coupler("CPL3", phase=90.0)

# Custom impedance coupler
cpl4 = Coupler("CPL4", coupling=0.7071, z0=75.0)
```