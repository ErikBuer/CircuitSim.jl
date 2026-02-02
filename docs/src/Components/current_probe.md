# Current Probe

```@example current_probe
using CircuitSim

V = DCVoltageSource("V", voltage=10.0)
R = Resistor("R", resistance=100.0)
IP = CurrentProbe("IP1")
GND = Ground("GND")

circ = Circuit()
add_component!(circ, V)
add_component!(circ, R)
add_component!(circ, IP)
add_component!(circ, GND)

connect!(circ, Pin(V, :nplus), Pin(IP, :n1))
connect!(circ, Pin(IP, :n2), Pin(R, :n1))
connect!(circ, Pin(R, :n2), Pin(GND, :gnd))
connect!(circ, Pin(V, :nminus), Pin(GND, :gnd))

dc = simulate_qucsator(circ, DCAnalysis())

i_measured = CircuitSim.get_probe_current(dc, IP)
println("Current through circuit: ", i_measured * 1000, " mA")
```
