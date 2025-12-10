# Coaxial Line

Coaxial transmission line with physical dimensions and material properties.

Coaxial cable between two ports.

```@example coax
using CircuitSim

circ = Circuit()

# Components
port1 = ACPowerSource("P1", 1, impedance=50.0)
port2 = ACPowerSource("P2", 2, impedance=50.0)
# RG-58 like: εr=2.3, inner=0.9mm, outer=2.95mm
coax = CoaxialLine("COAX1", er=2.3, length_m=1.0, d_mm=0.9, d_outer_mm=2.95)
gnd = Ground("GND")

add_component!(circ, port1)
add_component!(circ, port2)
add_component!(circ, coax)
add_component!(circ, gnd)

# Connect ports through coax (2-terminal line)
@connect circ port1.nplus coax.n1
@connect circ coax.n2 port2.nplus
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd

# S-parameter analysis
sp_analysis = SParameterAnalysis(1e9, 3e9, 11, z0=50.0)
result = simulate_qucsator(circ, sp_analysis)

freq = result.frequencies_Hz
s21 = result.s_matrix[(2,1)]
println("Coax S21 at ", freq[1]/1e9, " GHz: ", round(abs(s21[1]), digits=3))
```
