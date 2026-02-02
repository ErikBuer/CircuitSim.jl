# Pin Current Example

```@example pin_current
using CircuitSim

V = DCVoltageSource("V", voltage=10.0)
R = Resistor("R", resistance=100.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, V)
add_component!(circ, R)
add_component!(circ, GND)

connect!(circ, Pin(V, :nplus), Pin(R, :n1))
connect!(circ, Pin(R, :n2), Pin(GND, :gnd))
connect!(circ, Pin(V, :nminus), Pin(GND, :gnd))

dc = simulate_qucsator(circ, DCAnalysis())

i_nplus = get_pin_current(dc, V, :nplus)
i_nminus = get_pin_current(dc, V, :nminus)

println("Current INTO nplus: ", i_nplus * 1000, " mA")
println("Current INTO nminus: ", i_nminus * 1000, " mA")
println("KCL: ", (i_nplus + i_nminus) * 1000, " mA")
```
