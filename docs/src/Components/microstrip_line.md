# Microstrip Line

Microstrip transmission line segment.

## Parameters

- `w`: Line width in meters, default: 1e-3
- `l`: Line length in meters, default: 10e-3
- `substrate`: Substrate reference name, default: "Subst1"
- `disp_model`: Dispersion model, default: "Kirschning" (options: "Getsinger", "Schneider", "Yamashita", "Kobayashi", "Pramanick", "Hammerstad", "Kirschning")
- `model`: Quasi-static model, default: "Hammerstad" (options: "Wheeler", "Schneider", "Hammerstad")
- `temp`: Temperature in Celsius, default: 26.85°C

## Example

```@example microstrip_line
using CircuitSim

circ = Circuit()

sub = Substrate("Sub1", er=4.5, h=1.6e-3, t=35e-6)
add_component!(circ, sub)

port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
port2 = ACPowerSource("P2", port_num=2, impedance=50.0)
add_component!(circ, port1)
add_component!(circ, port2)

MS = MicrostripLine("MS1", substrate="Sub1", w=1e-3, l=10e-3)
add_component!(circ, MS)

gnd = Ground("GND")
add_component!(circ, gnd)

@connect circ port1.nplus MS.n1
@connect circ MS.n2 port2.nplus
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd

sparam = SParameterAnalysis(start=1e9, stop=10e9, points=100,
    sweep_type="linear",
    z0=50.0
)

result = simulate_qucsator(circ, sparam)
```