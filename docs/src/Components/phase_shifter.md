# Phase Shifter

```@example phase_shifter
using CircuitSim

circ = Circuit()

port1 = ACPowerSource("P1", 1, impedance=50.0)
port2 = ACPowerSource("P2", 2, impedance=50.0)
add_component!(circ, port1)
add_component!(circ, port2)

PS = PhaseShifter("PS1", 90.0)
add_component!(circ, PS)

gnd = Ground("GND")
add_component!(circ, gnd)

@connect circ port1.nplus PS.n1
@connect circ PS.n2 port2.nplus
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd

sparam = SParameterAnalysis(1e9, 10e9, 100,
    sweep_type=LINEAR,
    z0=50.0
)

result = simulate_qucsator(circ, sparam)
```