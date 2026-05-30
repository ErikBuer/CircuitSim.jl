# Spiral Inductor

Planar spiral inductor component based on substrate-dependent RF model.

## Parameters

- `geometry`: Inductor geometry, default: "Circular" (options: "Circular", "Square", "Hexagonal", "Octogonal")
- `w`: Track width in meters, default: 25e-6
- `di`: Inner diameter in meters, default: 200e-6
- `s`: Track spacing in meters, default: 25e-6
- `turns`: Number of turns, default: 3
- `substrate`: Substrate reference name, default: "Subst1"
- `temp`: Temperature in Celsius, default: 26.85

```@example spiral_inductor
using CircuitSim

sub = Substrate("Sub1", er=4.5, h=1.6e-3, t=35e-6)
V = DCVoltageSource("V1", voltage=1.0)
SP = SpiralInductor("SP1", substrate="Sub1", geometry="Circular", w=25e-6, di=200e-6, s=25e-6, turns=3)
R = Resistor("R1", resistance=50.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, sub)
add_component!(circ, V)
add_component!(circ, SP)
add_component!(circ, R)
add_component!(circ, GND)

@connect circ V.nplus SP.n1
@connect circ SP.n2 R.n1
@connect circ R.n2 GND
@connect circ V.nminus GND

result = simulate_qucsator(circ, DCAnalysis())

i = get_component_current(result, "V1")
v_sp = get_voltage_across(result, SP, :n1, :n2)

println("Spiral inductor (5 turns, 100μm diameter)")
println("  DC voltage drop: ", round(v_sp*1e6, digits=2), " μV")
println("  Current: ", round(abs(i)*1e3, digits=2), " mA")
```