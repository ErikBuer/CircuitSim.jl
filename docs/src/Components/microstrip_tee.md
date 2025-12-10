# Microstrip Tee Junction

A microstrip T-junction for connecting three transmission lines.

```@example mtee
using CircuitSim

circ = Circuit()

# Substrate definition
sub = Substrate("Sub1", er=4.5, h=1.6e-3, t=35e-6)
add_component!(circ, sub)

# Components
port1 = ACPowerSource("P1", 1, impedance=50.0)
port2 = ACPowerSource("P2", 2, impedance=50.0)
port3 = ACPowerSource("P3", 3, impedance=50.0)
tee = MicrostripTee("MTEE1", sub, w1=3.0e-3, w2=3.0e-3, w3=1.5e-3)
gnd = Ground("GND")

add_component!(circ, port1)
add_component!(circ, port2)
add_component!(circ, port3)
add_component!(circ, tee)
add_component!(circ, gnd)

# Connect 3-port tee junction
@connect circ port1.nplus tee.n1
@connect circ tee.n2 port2.nplus
@connect circ tee.n3 port3.nplus
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd
@connect circ port3.nminus gnd

# S-parameter analysis
sp_analysis = SParameterAnalysis(1e9, 10e9, 50, z0=50.0)
result = simulate_qucsator(circ, sp_analysis)

freq = result.frequencies_Hz
s21 = result.s_matrix[(2,1)]
s31 = result.s_matrix[(3,1)]
println("Tee S21 at ", freq[1]/1e9, " GHz: ", round(20*log10(abs(s21[1])), digits=2), " dB")
println("Tee S31 at ", freq[1]/1e9, " GHz: ", round(20*log10(abs(s31[1])), digits=2), " dB")
```
