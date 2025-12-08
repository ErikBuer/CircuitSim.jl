# Voltage Probe

```@example voltage_probe
using CircuitSim

V = DCVoltageSource("V", 10.0)
R1 = Resistor("R1", 100.0)
R2 = Resistor("R2", 100.0)
VP = VoltageProbe("VP1")
GND = Ground("GND")

circ = Circuit()
add_component!(circ, V)
add_component!(circ, R1)
add_component!(circ, R2)
add_component!(circ, VP)
add_component!(circ, GND)

connect!(circ, Pin(V, :nplus), Pin(R1, :n1))
connect!(circ, Pin(R1, :n2), Pin(R2, :n1))
connect!(circ, Pin(R2, :n2), Pin(GND, :gnd))
connect!(circ, Pin(V, :nminus), Pin(GND, :gnd))
connect!(circ, Pin(VP, :n1), Pin(R2, :n1))
connect!(circ, Pin(VP, :n2), Pin(R2, :n2))

dc = simulate_qucsator(circ, DCAnalysis())

v_measured = CircuitSim.get_probe_voltage(dc, VP)
println("Voltage across R2: ", v_measured, " V")
```
