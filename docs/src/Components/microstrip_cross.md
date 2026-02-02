# Microstrip Cross Junction

A microstrip cross-junction for connecting four transmission lines.

```@example mcross
using CircuitSim

circ = Circuit()

# Substrate definition
sub = Substrate("Sub1", er=4.5, h=1.6e-3, t=35e-6)
add_component!(circ, sub)

# Components
port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
port2 = ACPowerSource("P2", port_num=2, impedance=50.0)
port3 = ACPowerSource("P3", port_num=3, impedance=50.0)
port4 = ACPowerSource("P4", port_num=4, impedance=50.0)
cross = MicrostripCross("MX1", substrate=sub, w1=1.5e-3, w2=1.5e-3, w3=1.5e-3, w4=1.5e-3)
gnd = Ground("GND")

add_component!(circ, port1)
add_component!(circ, port2)
add_component!(circ, port3)
add_component!(circ, port4)
add_component!(circ, cross)
add_component!(circ, gnd)

# Connect 4-port cross junction
@connect circ port1.nplus cross.n1
@connect circ port2.nplus cross.n2
@connect circ port3.nplus cross.n3
@connect circ port4.nplus cross.n4
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd
@connect circ port3.nminus gnd
@connect circ port4.nminus gnd

# S-parameter analysis
sp_analysis = SParameterAnalysis(1e9, 10e9, 20, z0=50.0)
result = simulate_qucsator(circ, sp_analysis)

freq = result.frequencies_Hz
s21 = result.s_matrix[(2,1)]
println("Cross S21 at ", freq[1]/1e9, " GHz: ", round(abs(s21[1]), digits=3))
```
