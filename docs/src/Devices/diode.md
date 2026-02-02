# Diode

## DC Analysis Example

Simple DC circuit to verify diode forward voltage drop.

```@example diode_dc
using CircuitSim

circ = Circuit()

# DC voltage source: 5V
vin = DCVoltageSource("V1", voltage=5.0)

# Diode with default parameters
d1 = Diode("D1")

# Load resistor
rload = Resistor("RL", resistance=1000)

# Ground
gnd = Ground("GND")

add_component!(circ, vin)
add_component!(circ, d1)
add_component!(circ, rload)
add_component!(circ, gnd)

# Connect: V+ -> anode, cathode -> resistor -> GND
@connect circ d1.anode vin.nplus
@connect circ d1.cathode rload.n1
@connect circ rload.n2 gnd.n
@connect circ vin.nminus gnd.n
```

Run DC analysis to find operating point.

```@example diode_dc
analysis = DCAnalysis()
result = simulate_qucsator(circ, analysis)

# Get voltages - netlist shows Diode:D1 _net2 _net1 means cathode=_net2, anode=_net1
v_anode = get_node_voltage(result, "_net1")
v_cathode = get_node_voltage(result, "_net2")
v_drop = v_anode - v_cathode
i_load = v_cathode / 1000.0

println("Anode voltage: $(round(v_anode, digits=3)) V")
println("Cathode voltage: $(round(v_cathode, digits=3)) V")
println("Diode voltage drop: $(round(v_drop, digits=3)) V")
println("Current: $(round(i_load * 1000, digits=2)) mA")
```
