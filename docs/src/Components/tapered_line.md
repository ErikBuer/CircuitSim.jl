# Tapered Line

```@example tapered
using CircuitSim

circ = Circuit()

# Components
port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
port2 = ACPowerSource("P2", port_num=2, impedance=100.0)
line = TaperedLine("TP1", z1=50.0, z2=100.0, length_m=75e-3, weighting="Exponential")
gnd = Ground("GND")

add_component!(circ, port1)
add_component!(circ, port2)
add_component!(circ, line)
add_component!(circ, gnd)

# Connect ports through tapered line
@connect circ port1.nplus line.n1
@connect circ line.n2 port2.nplus
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd

# S-parameter analysis
sp_analysis = SParameterAnalysis(start=1e9, stop=6e9, points=31, z0=50.0)
result = simulate_qucsator(circ, sp_analysis)

freq = result.frequencies_Hz
s21 = result.s_matrix[(2,1)]
println("TaperedLine S21 at ", freq[1] / 1e9, " GHz: ", round(abs(s21[1]), digits=3))
```
