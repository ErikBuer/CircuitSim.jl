# Gyrator

A gyrator is a passive, linear, lossless two-port device that inverts the impedance. It can convert a capacitor into an inductor or vice versa.

Gyrator converting capacitive load to inductive behavior.

```@example gyrator
using CircuitSim

circ = Circuit()

# Components
pac = ACPowerSource("P1", 1, impedance=50.0)
gyrator = Gyrator("GYR1", r=100.0, zref=50.0)
cap = Capacitor("C1", 1e-9)  # 1nF capacitor
gnd = Ground("GND")

add_component!(circ, pac)
add_component!(circ, gyrator)
add_component!(circ, cap)
add_component!(circ, gnd)

# Connect power source to gyrator port 1
@connect circ pac.nplus gyrator.n1
@connect circ pac.nminus gyrator.n2
@connect circ pac.nminus gnd

# Connect capacitor to gyrator port 2 (will appear inductive at port 1)
@connect circ gyrator.n3 cap.n1
@connect circ gyrator.n4 cap.n2
@connect circ cap.n2 gnd

assign_nodes!(circ)

# S-parameter analysis
sp_analysis = SParameterAnalysis(1e9, 2e9, 11, z0=50.0)
result = simulate_qucsator(circ, sp_analysis)

freq = result.frequencies_Hz
s11 = result.s_matrix[(1,1)]
println("Gyrator S11 at ", freq[1]/1e9, " GHz: ", round(abs(s11[1]), digits=3))
```
