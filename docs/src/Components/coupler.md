# Coupler

```@example coupler
using CircuitSim

circ = Circuit()

port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
port2 = ACPowerSource("P2", port_num=2, impedance=50.0)
port3 = ACPowerSource("P3", port_num=3, impedance=50.0)
port4 = ACPowerSource("P4", port_num=4, impedance=50.0)
add_component!(circ, port1)
add_component!(circ, port2)
add_component!(circ, port3)
add_component!(circ, port4)

CPL = Coupler("CPL1", 3.0)
add_component!(circ, CPL)

gnd = Ground("GND")
add_component!(circ, gnd)

@connect circ port1.nplus CPL.n1
@connect circ port2.nplus CPL.n2
@connect circ port3.nplus CPL.n3
@connect circ port4.nplus CPL.n4
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