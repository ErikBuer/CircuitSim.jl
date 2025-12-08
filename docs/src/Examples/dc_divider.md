# DC Analysis - Resistor Divider

```@example dc_divider
using CircuitSim

# 10V source with resistor divider (1kΩ and 500Ω)
V = DCVoltageSource("V1", 10.0)
R1 = Resistor("R1", 1000.0)
R2 = Resistor("R2", 500.0)
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

# Run DC analysis
result = simulate_qucsator(circ, DCAnalysis())

# Read voltages across components using helper functions
v_r1 = get_voltage_across(result, R1, :n1, :n2)
v_r2 = get_voltage_across(result, R2, :n1, :n2)
i_source = get_component_current(result, "V1")

println("Resistor Divider (10V, 1kΩ, 500Ω):")
println("  V_R1 = ", round(v_r1, digits=3), " V")
println("  V_R2 = ", round(v_r2, digits=3), " V")
println("  I = ", round(abs(i_source)*1e3, digits=3), " mA")
println("  Expected V_R2 = ", round(10.0 * 500/(1000+500), digits=3), " V")
```
