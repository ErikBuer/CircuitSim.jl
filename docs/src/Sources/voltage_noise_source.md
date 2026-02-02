# Voltage Noise Source

```@example voltage_noise
using CircuitSim

Vn = VoltageNoiseSource("Vn1", u=1e-6, a=0.0, c=1.0, e=0.0)
R = Resistor("R1", resistance=50.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, Vn)
add_component!(circ, R)
add_component!(circ, GND)

@connect circ Vn.nplus R.n1
@connect circ R.n2 GND
@connect circ Vn.nminus GND

println("White noise source configured")
println("PSD: ", 1e-6, " V²/Hz")
println("Frequency range: 1 MHz to 10 GHz")
```
