# Microstrip Gap

Microstrip series gap discontinuity providing capacitive coupling.

## Parameters

- `w1`: Width at port 1 in meters, default: 1e-3
- `w2`: Width at port 2 in meters, default: 1e-3
- `s`: Gap spacing in meters, default: 1e-3
- `substrate`: Substrate reference name, default: "Subst1"
- `disp_model`: Dispersion model, default: "Kirschning"
- `model`: Microstrip model, default: "Hammerstad"

## Example

```@example microstrip_gap
using CircuitSim

circ = Circuit()

sub = Substrate("Sub1", er=4.5, h=1.6e-3, t=35e-6)
add_component!(circ, sub)

port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
port2 = ACPowerSource("P2", port_num=2, impedance=50.0)
add_component!(circ, port1)
add_component!(circ, port2)

GAP = MicrostripGap("GAP1", substrate="Sub1", w1=1e-3, w2=1e-3, s=0.5e-3)
add_component!(circ, GAP)

gnd = Ground("GND")
add_component!(circ, gnd)

@connect circ port1.nplus GAP.n1
@connect circ GAP.n2 port2.nplus
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd

sparam = SParameterAnalysis(start=1e9, stop=10e9, points=100,
    sweep_type="linear",
    z0=50.0
)

result = simulate_qucsator(circ, sparam)
```