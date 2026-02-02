# Isolator

```@example isolator
using CircuitSim

circ = Circuit()

port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
port2 = ACPowerSource("P2", port_num=2, impedance=50.0)
add_component!(circ, port1)
add_component!(circ, port2)

ISO = Isolator("ISO1")
add_component!(circ, ISO)

gnd = Ground("GND")
add_component!(circ, gnd)

@connect circ port1.nplus ISO.n1
@connect circ port2.nplus ISO.n2
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd

sparam = SParameterAnalysis(1e9, 10e9, 100,
    sweep_type=LINEAR,
    z0=50.0
)

result = simulate_qucsator(circ, sparam)
```