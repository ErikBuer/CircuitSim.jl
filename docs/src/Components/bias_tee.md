# Bias Tee

```@example bias_tee
using CircuitSim

BT = BiasTee("BT1", capacitance=1e-6, inductance=1e-3)
V_dc = DCVoltageSource("V_dc", voltage=5.0)
R_load = Resistor("R_load", resistance=50.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, BT)
add_component!(circ, V_dc)
add_component!(circ, R_load)
add_component!(circ, GND)

@connect circ V_dc.nplus BT.n_dc
@connect circ V_dc.nminus GND
@connect circ BT.n_rf GND
@connect circ BT.n_out R_load.n1
@connect circ R_load.n2 GND

result = simulate_qucsator(circ, DCAnalysis())

v_out = get_pin_voltage(result, R_load, :n1)
i_dc = get_component_current(result, "V_dc")

println("Output voltage: ", round(v_out, digits=3), " V")
println("DC current: ", round(abs(i_dc) * 1000, digits=2), " mA")
```
