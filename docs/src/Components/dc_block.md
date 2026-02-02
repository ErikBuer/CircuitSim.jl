# DC Block

```@example dc_block
using CircuitSim

V_dc = DCVoltageSource("V_dc", voltage=5.0)
DCB = DCBlock("DCB1")
R = Resistor("R1", resistance=50.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, V_dc)
add_component!(circ, DCB)
add_component!(circ, R)
add_component!(circ, GND)

@connect circ V_dc.nplus DCB.n1
@connect circ DCB.n2 R.n1
@connect circ R.n2 GND
@connect circ V_dc.nminus GND

result = simulate_qucsator(circ, DCAnalysis())

v_out = get_pin_voltage(result, R, :n1)
i_dc = get_component_current(result, "V_dc")

println("DC Block: blocks DC, passes AC")
println("  Output voltage: ", round(v_out, digits=6), " V (should be ~0)")
println("  DC current: ", round(abs(i_dc)*1e9, digits=2), " nA")
```