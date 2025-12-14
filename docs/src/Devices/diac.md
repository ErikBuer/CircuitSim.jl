# DIAC

Bidirectional trigger diode for AC control applications.

## Example

DC analysis of DIAC with voltage source.

```@example diac
using CircuitSim

# Create circuit
circ = Circuit()

# DC voltage source below breakover
vin = DCVoltageSource("VIN", 20.0)
diac = DIAC("D1", Vbo=30, Ibo=50e-6)
rs = Resistor("RS", 1000)  # Series resistor
gnd = Ground("GND")

add_component!(circ, vin)
add_component!(circ, diac)
add_component!(circ, rs)
add_component!(circ, gnd)

# Connect: vin+ -> RS -> DIAC anode, DIAC cathode -> gnd
@connect circ vin.nplus rs.n1
@connect circ rs.n2 diac.anode
@connect circ diac.cathode gnd.n
@connect circ vin.nminus gnd.n

# Run DC analysis
analysis = DCAnalysis()
result = simulate_qucsator(circ, analysis)

# Get voltages
v_anode = get_node_voltage(result, "_net2")
v_drop = v_anode  # Cathode at ground

println("DIAC DC operating point (below breakover):")
println("  Applied voltage: 20.0 V")
println("  DIAC voltage: $(round(v_drop, digits=2)) V")
```
