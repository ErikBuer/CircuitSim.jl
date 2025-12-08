# Bond Wire

```@example bond_wire
using CircuitSim

sub = Substrate("Sub1", er=4.5, h=1.6e-3, t=35e-6)
V = DCVoltageSource("V1", 1.0)
wire = BondWire("BW1", l=1e-3, d=25e-6, h=0.3e-3)
R = Resistor("R1", 50.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, sub)
add_component!(circ, V)
add_component!(circ, wire)
add_component!(circ, R)
add_component!(circ, GND)

@connect circ V.nplus wire.n1
@connect circ wire.n2 R.n1
@connect circ R.n2 GND
@connect circ V.nminus GND

result = simulate_qucsator(circ, DCAnalysis())

i = get_component_current(result, "V1")
v_wire = get_voltage_across(result, wire, :n1, :n2)

println("Bond wire (1mm, 25μm): V_drop = ", round(v_wire*1e6, digits=2), " μV")
println("Current: ", round(abs(i)*1e3, digits=2), " mA")
```
