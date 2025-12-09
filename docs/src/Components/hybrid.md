# Hybrid (180° or 90°)

```@example hybrid
using CircuitSim

circ = Circuit()

port1 = ACPowerSource("P1", 1, impedance=50.0)
port2 = ACPowerSource("P2", 2, impedance=50.0)
port3 = ACPowerSource("P3", 3, impedance=50.0)
port4 = ACPowerSource("P4", 4, impedance=50.0)
add_component!(circ, port1)
add_component!(circ, port2)
add_component!(circ, port3)
add_component!(circ, port4)

HYB = Hybrid("HYB1")
add_component!(circ, HYB)

gnd = Ground("GND")
add_component!(circ, gnd)

@connect circ port1.nplus HYB.n1
@connect circ port2.nplus HYB.n2
@connect circ port3.nplus HYB.n3
@connect circ port4.nplus HYB.n4
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd
@connect circ port3.nminus gnd
@connect circ port4.nminus gnd

sparam = SParameterAnalysis(1e9, 10e9, 100,
    sweep_type=LINEAR,
    z0=50.0
)

result = simulate_qucsator(circ, sparam)
```