# Transmission Line

Transmission line between two ports.

```@example tline
using CircuitSim

circ = Circuit()

# Components
port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
port2 = ACPowerSource("P2", port_num=2, impedance=50.0)
tline = TransmissionLine("TL1", z0=50.0, length_m=0.05)  # 5cm line
gnd = Ground("GND")

add_component!(circ, port1)
add_component!(circ, port2)
add_component!(circ, tline)
add_component!(circ, gnd)

# Connect ports through transmission line
@connect circ port1.nplus tline.n1
@connect circ port1.nminus tline.n2
@connect circ tline.n3 port2.nplus
@connect circ tline.n4 port2.nminus
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd

# S-parameter analysis
sp_analysis = SParameterAnalysis(1e9, 5e9, 21, z0=50.0)
result = simulate_qucsator(circ, sp_analysis)

freq = result.frequencies_Hz
s21 = result.s_matrix[(2,1)]
println("TLine S21 at ", freq[1]/1e9, " GHz: ", round(abs(s21[1]), digits=3))
```
