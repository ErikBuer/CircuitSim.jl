# Microstrip Corner

```@example microstrip_corner
using CircuitSim

circ = Circuit()

sub = Substrate("Sub1", er=4.5, h=1.6e-3, t=35e-6)
add_component!(circ, sub)

port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
port2 = ACPowerSource("P2", port_num=2, impedance=50.0)
add_component!(circ, port1)
add_component!(circ, port2)

CORNER = MicrostripCorner("CORNER1", sub, w=1e-3)
add_component!(circ, CORNER)

gnd = Ground("GND")
add_component!(circ, gnd)

@connect circ port1.nplus CORNER.n1
@connect circ CORNER.n2 port2.nplus
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd

sparam = SParameterAnalysis(1e9, 10e9, 100,
    sweep_type=LINEAR,
    z0=50.0
)

result = simulate_qucsator(circ, sparam)
```