# JFET

Junction Field-Effect Transistor with voltage-controlled current source behavior.

## Example

N-channel JFET amplifier DC bias point.

```@example jfet
using CircuitSim

# Create circuit
circ = Circuit()

# DC sources
vdd = DCVoltageSource("VDD", 12.0)
vgs = DCVoltageSource("VGS", -1.0)

# JFET (N-channel)
jfet = JFET("J1", Type="nfet", Beta=2e-3, Vt0=-2.0)

# Load resistor
rd = Resistor("RD", 2000)
gnd = Ground("GND")

add_component!(circ, vdd)
add_component!(circ, vgs)
add_component!(circ, jfet)
add_component!(circ, rd)
add_component!(circ, gnd)

# Connections
@connect circ vdd.nplus rd.n1
@connect circ rd.n2 jfet.drain
@connect circ jfet.source gnd.n
@connect circ vgs.nplus jfet.gate
@connect circ vgs.nminus gnd.n
@connect circ vdd.nminus gnd.n

# Run DC analysis
analysis = DCAnalysis()
result = simulate_qucsator(circ, analysis)

# Get operating point (node names assigned by circuit)
v_dd = get_node_voltage(result, "_net1")     # VDD.nplus
v_drain = get_node_voltage(result, "_net2")  # Drain at RD.n2
v_gate = get_node_voltage(result, "_net3")   # VGS.nplus
v_ds = v_drain  # Source at ground = 0V
i_d = (v_dd - v_drain) / 2000  # Current through RD

println("JFET DC operating point:")
println("  VGS = $(round(v_gate, digits=2)) V")
println("  VDS = $(round(v_ds, digits=2)) V")
println("  ID = $(round(i_d * 1000, digits=2)) mA")
```
