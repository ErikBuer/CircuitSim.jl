# Microstrip Mitered Bend

A mitered 90° microstrip bend with corner cut for improved high-frequency performance.

```@example mbend
using CircuitSim

circ = Circuit()

# Substrate definition
sub = Substrate("Sub1", er=4.5, h=1.6e-3, t=35e-6)
add_component!(circ, sub)

# Components
port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
port2 = ACPowerSource("P2", port_num=2, impedance=50.0)
bend = MicrostripMiteredBend("MB1", substrate=sub, w=3.0e-3)
gnd = Ground("GND")

add_component!(circ, port1)
add_component!(circ, port2)
add_component!(circ, bend)
add_component!(circ, gnd)

# Connect mitered bend
@connect circ port1.nplus bend.n1
@connect circ bend.n2 port2.nplus
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd

# S-parameter analysis
sp_analysis = SParameterAnalysis(1e9, 20e9, 50, z0=50.0)
result = simulate_qucsator(circ, sp_analysis)

freq = result.frequencies_Hz
s21 = result.s_matrix[(2,1)]
s11 = result.s_matrix[(1,1)]
println("Mitered bend S21 at ", freq[1]/1e9, " GHz: ", round(20*log10(abs(s21[1])), digits=2), " dB")
println("Mitered bend S11 at ", freq[1]/1e9, " GHz: ", round(20*log10(abs(s11[1])), digits=2), " dB")
```
