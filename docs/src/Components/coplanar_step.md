# Coplanar Step

```@example cstep
using CircuitSim

circ = Circuit()

sub = Substrate("Sub1", er=3.48, h=0.508e-3, t=35e-6)
port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
port2 = ACPowerSource("P2", port_num=2, impedance=50.0)
cstep = CoplanarStep("CSTEP1", substrate="Sub1", w1=1.0e-3, w2=2.0e-3, s=4.0e-3, backside="Metal")
gnd = Ground("GND")

add_component!(circ, sub)
add_component!(circ, port1)
add_component!(circ, port2)
add_component!(circ, cstep)
add_component!(circ, gnd)

@connect circ port1.nplus cstep.n1
@connect circ cstep.n2 port2.nplus
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd

sp_analysis = SParameterAnalysis(start=1e9, stop=10e9, points=21, z0=50.0)
result = simulate_qucsator(circ, sp_analysis)

freq = result.frequencies_Hz
s21 = result.s_matrix[(2,1)]
println("CoplanarStep S21 at ", freq[1] / 1e9, " GHz: ", round(abs(s21[1]), digits=3))
```
