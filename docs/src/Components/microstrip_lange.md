# Microstrip Lange Coupler

An interdigitated microstrip directional coupler providing tight coupling over wide bandwidth.

```@example lange
using CircuitSim

circ = Circuit()

# Substrate definition
sub = Substrate("Sub1", er=3.55, h=0.508e-3, t=35e-6)  # RO4003C-like
add_component!(circ, sub)

# Components
port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
port2 = ACPowerSource("P2", port_num=2, impedance=50.0)
port3 = ACPowerSource("P3", port_num=3, impedance=50.0)
port4 = ACPowerSource("P4", port_num=4, impedance=50.0)
lange = MicrostripLange("LC1", sub, w=0.15e-3, l=10e-3, s=0.1e-3, n=4)
gnd = Ground("GND")

add_component!(circ, port1)
add_component!(circ, port2)
add_component!(circ, port3)
add_component!(circ, port4)
add_component!(circ, lange)
add_component!(circ, gnd)

# Connect 4-port Lange coupler
@connect circ port1.nplus lange.n1
@connect circ lange.n2 port2.nplus
@connect circ port3.nplus lange.n3
@connect circ lange.n4 port4.nplus
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd
@connect circ port3.nminus gnd
@connect circ port4.nminus gnd

# S-parameter analysis
sp_analysis = SParameterAnalysis(2e9, 6e9, 50, z0=50.0)
result = simulate_qucsator(circ, sp_analysis)

freq = result.frequencies_Hz
s31 = result.s_matrix[(3,1)]  # Coupling
s41 = result.s_matrix[(4,1)]  # Isolation
println("Lange coupling S31 at ", freq[1]/1e9, " GHz: ", round(20*log10(abs(s31[1])), digits=2), " dB")
println("Lange isolation S41 at ", freq[1]/1e9, " GHz: ", round(20*log10(abs(s41[1])), digits=2), " dB")
```
