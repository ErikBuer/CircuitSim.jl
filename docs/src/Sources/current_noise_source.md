# Current Noise Source

```@example current_noise
using CircuitSim

In = CurrentNoiseSource("In1", i=1e-12, a=0.0, c=1.0, e=0.0)
R = Resistor("R1", resistance=1000.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, In)
add_component!(circ, R)
add_component!(circ, GND)

@connect circ In.nplus R.n1
@connect circ R.n2 GND
@connect circ In.nminus GND

println("White noise source configured")
println("PSD: ", 1e-12, " A²/Hz")
println("Voltage noise PSD on 1kΩ: ", 1e-12 * 1000.0^2, " V²/Hz")
```
