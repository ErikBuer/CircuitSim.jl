# Circular Loop Inductor

A single-turn circular loop inductor for RF and antenna applications.

```@example circular_loop
using CircuitSim

circ = Circuit()

# Components
port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
port2 = ACPowerSource("P2", port_num=2, impedance=50.0)
loop = CircularLoop("CL1", r=5e-3, w=0.5e-3)  # 5mm radius, 0.5mm width
gnd = Ground("GND")

add_component!(circ, port1)
add_component!(circ, port2)
add_component!(circ, loop)
add_component!(circ, gnd)

# Connect loop between ports
@connect circ port1.nplus loop.n1
@connect circ loop.n2 port2.nplus
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd

# S-parameter analysis
sp_analysis = SParameterAnalysis(100e6, 2e9, 20, z0=50.0)
result = simulate_qucsator(circ, sp_analysis)

freq = result.frequencies_Hz
s21 = result.s_matrix[(2,1)]
println("Loop S21 at ", freq[1]/1e6, " MHz: ", round(abs(s21[1]), digits=3))
```
