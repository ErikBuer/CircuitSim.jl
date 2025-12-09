# DC Feed

```@example dc_feed
using CircuitSim

V_dc = DCVoltageSource("V_dc", 5.0)
DCF = DCFeed("DCF1")
R = Resistor("R1", 50.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, V_dc)
add_component!(circ, DCF)
add_component!(circ, R)
add_component!(circ, GND)

@connect circ V_dc.nplus DCF.n1
@connect circ DCF.n2 R.n1
@connect circ R.n2 GND
@connect circ V_dc.nminus GND

result = simulate_qucsator(circ, DCAnalysis())

v_out = get_pin_voltage(result, R, :n1)
i_dc = get_component_current(result, "V_dc")

println("DC Feed: passes DC, blocks AC")
println("  Output voltage: ", round(v_out, digits=3), " V")
println("  DC current: ", round(abs(i_dc)*1e3, digits=2), " mA")
```