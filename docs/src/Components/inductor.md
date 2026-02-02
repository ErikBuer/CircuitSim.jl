# Inductor

```@example inductor
using CircuitSim

V = DCVoltageSource("V1", voltage=10.0)
L = Inductor("L1", inductance=1e-3)
R = Resistor("R1", resistance=100.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, V)
add_component!(circ, L)
add_component!(circ, R)
add_component!(circ, GND)

@connect circ V.nplus L.n1
@connect circ L.n2 R.n1
@connect circ R.n2 GND
@connect circ V.nminus GND

result = simulate_qucsator(circ, DCAnalysis())

i = get_component_current(result, "V1")
v_inductor = get_voltage_across(result, L, :n1, :n2)

println("DC: L acts as short circuit")
println("  Voltage across L: ", round(v_inductor*1e6, digits=2), " μV")
println("  Current: ", round(abs(i)*1e3, digits=2), " mA")
```