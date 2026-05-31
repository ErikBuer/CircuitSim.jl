# Coupled Transmission Line

```@example ctline
using CircuitSim

circ = Circuit()

# Components
port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
port2 = ACPowerSource("P2", port_num=2, impedance=50.0)
cl = CoupledLine("CL1", ze=60.0, zo=40.0, length_m=0.02)
gnd = Ground("GND")

add_component!(circ, port1)
add_component!(circ, port2)
add_component!(circ, cl)
add_component!(circ, gnd)

# Connect: port1 drives line 1, port2 on line 2
@connect circ port1.nplus cl.n1
@connect circ port1.nminus cl.n2
@connect circ cl.n3 port2.nplus
@connect circ cl.n4 port2.nminus
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd

# S-parameter analysis
sp_analysis = SParameterAnalysis(start=1e9, stop=5e9, points=21, z0=50.0)
result = simulate_qucsator(circ, sp_analysis)

freq = result.frequencies_Hz
s21 = result.s_matrix[(2,1)]
println("CoupledLine S21 at ", freq[1]/1e9, " GHz: ", round(abs(s21[1]), digits=3))
```
