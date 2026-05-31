# RLCG Transmission Line

```@example rlcg
using CircuitSim

circ = Circuit()

# Components
port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
port2 = ACPowerSource("P2", port_num=2, impedance=50.0)
line = RLCGTransmissionLine("RL1", length_m=0.05)
gnd = Ground("GND")

add_component!(circ, port1)
add_component!(circ, port2)
add_component!(circ, line)
add_component!(circ, gnd)

# Connect ports through RLCG line
@connect circ port1.nplus line.n1
@connect circ line.n2 port2.nplus
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd

# S-parameter analysis
sp_analysis = SParameterAnalysis(start=1e6, stop=1e9, points=41, z0=50.0)
result = simulate_qucsator(circ, sp_analysis)

freq = result.frequencies_Hz
s21 = result.s_matrix[(2,1)]
println("RLCG S21 at ", freq[1] / 1e6, " MHz: ", round(abs(s21[1]), digits=3))
```
