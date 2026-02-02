# MOSFET

Metal-Oxide-Semiconductor Field-Effect Transistor.

## Example

N-channel MOSFET common-source amplifier.

```@example mosfet
using CircuitSim

# Create circuit
circ = Circuit()

# DC sources
vdd = DCVoltageSource("VDD", voltage=5.0)
vgs = DCVoltageSource("VGS", voltage=2.0)

# MOSFET (N-channel, W=10um, L=1um)
mosfet = MOSFET("M1", Type="nfet", Kp=200e-6, Vt0=0.7, W=10e-6, L=1e-6)

# Load resistor
rd = Resistor("RD", resistance=1000)
gnd = Ground("GND")

add_component!(circ, vdd)
add_component!(circ, vgs)
add_component!(circ, mosfet)
add_component!(circ, rd)
add_component!(circ, gnd)

# Connections (bulk tied to source)
@connect circ vdd.nplus rd.n1
@connect circ rd.n2 mosfet.drain
@connect circ mosfet.source gnd.n
@connect circ mosfet.bulk gnd.n
@connect circ vgs.nplus mosfet.gate
@connect circ vgs.nminus gnd.n
@connect circ vdd.nminus gnd.n

# Run DC analysis
analysis = DCAnalysis()
result = simulate_qucsator(circ, analysis)

# Get operating point
v_dd = get_node_voltage(result, "_net1")
v_drain = get_node_voltage(result, "_net2")
v_gate = get_node_voltage(result, "_net3")
v_ds = v_drain
i_d = (v_dd - v_drain) / 1000

println("MOSFET DC operating point:")
println("  VGS = $(round(v_gate, digits=2)) V")
println("  VDS = $(round(v_ds, digits=2)) V")
println("  ID = $(round(i_d * 1000, digits=2)) mA")
```
