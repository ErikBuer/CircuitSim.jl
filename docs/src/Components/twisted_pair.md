# Twisted Pair

```@example twist
using CircuitSim

circ = Circuit()

# Components
port1 = ACPowerSource("P1", port_num=1, impedance=100.0)
port2 = ACPowerSource("P2", port_num=2, impedance=100.0)
tp = TwistedPair("TP1", length_m=10.0, turns_per_m=100, er=2.2)
gnd = Ground("GND")

add_component!(circ, port1)
add_component!(circ, port2)
add_component!(circ, tp)
add_component!(circ, gnd)

# Connect differential ports through the twisted pair
@connect circ port1.nplus tp.n1
@connect circ port1.nminus tp.n2
@connect circ tp.n3 port2.nplus
@connect circ tp.n4 port2.nminus
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd

# S-parameter analysis
sp_analysis = SParameterAnalysis(start=1e6, stop=100e6, points=31, z0=100.0)
result = simulate_qucsator(circ, sp_analysis)

freq = result.frequencies_Hz
s21 = result.s_matrix[(2,1)]
println("TwistedPair S21 at ", freq[1] / 1e6, " MHz: ", round(abs(s21[1]), digits=3))
```
