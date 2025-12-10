# Power Probe

Power probe for measuring incident and reflected wave power in S-parameter analysis.

**Note**: WProbe is an RF measurement component used in S-parameter simulations to measure power waves. It requires 4 terminals (2 ports) and is primarily used for advanced RF circuit analysis.

Simple transmission line measurement with power probe.

```@example power_probe
using CircuitSim

circ = Circuit()

# Components  
port1 = ACPowerSource("P1", 1, impedance=50.0)
port2 = ACPowerSource("P2", 2, impedance=50.0)
tline = TransmissionLine("TL1", z0=50.0, length_m=0.05)
gnd = Ground("GND")

add_component!(circ, port1)
add_component!(circ, port2)
add_component!(circ, tline)
add_component!(circ, gnd)

# Connect transmission line between ports
@connect circ port1.nplus tline.n1
@connect circ port1.nminus tline.n2
@connect circ tline.n3 port2.nplus
@connect circ tline.n4 port2.nminus
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd

# S-parameter analysis to measure power transfer
sp_analysis = SParameterAnalysis(1e9, 3e9, 11, z0=50.0)
result = simulate_qucsator(circ, sp_analysis)

# Calculate power from S-parameters
s21 = result.s_matrix[(2,1)]
power_transfer_dB = 20 * log10(abs(s21[1]))
println("Power transfer S21: ", round(power_transfer_dB, digits=2), " dB")
```
