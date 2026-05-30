# Substrate

Defines substrate properties for microstrip and planar components.

## Parameters

- `er`: Relative permittivity, range: 1 to 100, default: 9.8
- `h`: Substrate height in meters, default: 1e-3
- `t`: Metal thickness in meters, default: 35e-6
- `tand`: Loss tangent, default: 1e-3
- `rho`: Metal resistivity in Ohm*m, default: 0.022e-6
- `rough`: Surface roughness in meters, default: 0.15e-6

```@example substrate
using CircuitSim

fr4 = Substrate("FR4", er=4.5, h=1.6e-3, t=35e-6, tand=0.02)
ro4003c = Substrate("RO4003C", er=3.55, h=0.508e-3, t=17e-6, tand=0.0027)
```