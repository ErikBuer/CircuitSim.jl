# Open Circuit

An open circuit provides infinite resistance (no connection) between two nodes.

Simple circuit demonstrating an open circuit.

```@example open
using CircuitSim

circ = Circuit()

# Create components
vdc = DCVoltageSource("V1", 5.0)
r1 = Resistor("R1", 1000.0)
open_ckt = Open("Open1")
r2 = Resistor("R2", 1000.0)
gnd = Ground("GND")

add_component!(circ, vdc)
add_component!(circ, r1)
add_component!(circ, open_ckt)
add_component!(circ, r2)
add_component!(circ, gnd)

# Connect with open in series (blocks current flow)
@connect circ vdc.nplus r1.n1
@connect circ r1.n2 open_ckt.n1
@connect circ open_ckt.n2 r2.n1
@connect circ r2.n2 gnd
@connect circ vdc.nminus gnd

assign_nodes!(circ)

# DC analysis
dc_analysis = DCAnalysis()
result = simulate_qucsator(circ, dc_analysis)

# Voltage at open circuit should equal source voltage
v_open = get_pin_voltage(result, r1, :n2)  # Voltage at node after R1 (open circuit node)
println("Voltage at open circuit: ", round(v_open, digits=3), " V")
```
