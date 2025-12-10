# Short Circuit

A short circuit provides zero-resistance connection between two nodes.

```@example short
using CircuitSim

circ = Circuit()

# Create components
vdc = DCVoltageSource("V1", 5.0)
rload = Resistor("R1", 100.0)
short = Short("S1")
gnd = Ground("GND")

add_component!(circ, vdc)
add_component!(circ, rload)
add_component!(circ, short)
add_component!(circ, gnd)

# Connect short across resistor (effectively bypassing it)
@connect circ vdc.nplus rload.n1
@connect circ rload.n1 short.n1
@connect circ rload.n2 short.n2
@connect circ short.n2 gnd
@connect circ vdc.nminus gnd

assign_nodes!(circ)

# DC analysis
dc_analysis = DCAnalysis()
result = simulate_qucsator(circ, dc_analysis)

# Check voltage across resistor (should be ~0V due to short)
v_r1 = get_voltage_across(result, rload, :n1, :n2)
println("Voltage across R1: ", round(v_r1, digits=6), " V (expected ~0V)")
```
