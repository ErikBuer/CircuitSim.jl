# Ground

```@example ground
using CircuitSim

V = DCVoltageSource("V1", voltage=5.0)
R1 = Resistor("R1", resistance=1000.0)
R2 = Resistor("R2", resistance=2000.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, V)
add_component!(circ, R1)
add_component!(circ, R2)
add_component!(circ, GND)

@connect circ V.nplus R1.n1
@connect circ R1.n2 R2.n1
@connect circ R2.n2 GND
@connect circ V.nminus GND

result = simulate_qucsator(circ, DCAnalysis())

v_r1 = get_voltage_across(result, R1, :n1, :n2)
v_r2 = get_voltage_across(result, R2, :n1, :n2)
v_gnd = get_pin_voltage(result, GND, :n)

println("Voltage divider referenced to ground:")
println("  V_R1 = ", round(v_r1, digits=3), " V")
println("  V_R2 = ", round(v_r2, digits=3), " V")
println("  V_GND = ", round(v_gnd, digits=6), " V (should be 0)")
```