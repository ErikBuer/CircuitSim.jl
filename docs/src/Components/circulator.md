# Circulator

```@example circulator
using CircuitSim

circ = Circuit()

port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
port2 = ACPowerSource("P2", port_num=2, impedance=50.0)
port3 = ACPowerSource("P3", port_num=3, impedance=50.0)
add_component!(circ, port1)
add_component!(circ, port2)
add_component!(circ, port3)

CIRC = Circulator("CIRC1")
add_component!(circ, CIRC)

gnd = Ground("GND")
add_component!(circ, gnd)

@connect circ port1.nplus CIRC.n1
@connect circ port2.nplus CIRC.n2
@connect circ port3.nplus CIRC.n3
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd
@connect circ port3.nminus gnd

sparam = SParameterAnalysis(1e9, 10e9, 100,
    sweep_type=LINEAR,
    z0=50.0
)

result = simulate_qucsator(circ, sparam)
```