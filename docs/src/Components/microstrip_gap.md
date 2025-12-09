# Microstrip Gap

```@example microstrip_gap
using CircuitSim

circ = Circuit()

sub = Substrate("Sub1", er=4.5, h=1.6e-3, t=35e-6)
add_component!(circ, sub)

port1 = ACPowerSource("P1", 1, impedance=50.0)
port2 = ACPowerSource("P2", 2, impedance=50.0)
add_component!(circ, port1)
add_component!(circ, port2)

GAP = MicrostripGap("GAP1", sub, w1=1e-3, w2=1e-3, s=0.5e-3)
add_component!(circ, GAP)

gnd = Ground("GND")
add_component!(circ, gnd)

@connect circ port1.nplus GAP.n1
@connect circ GAP.n2 port2.nplus
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd

sparam = SParameterAnalysis(1e9, 10e9, 100,
    sweep_type=LINEAR,
    z0=50.0
)

result = simulate_qucsator(circ, sparam)
```