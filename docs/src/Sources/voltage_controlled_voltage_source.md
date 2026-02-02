# Voltage-Controlled Voltage Source

A voltage source whose output is proportional to the voltage across another pair of nodes.

## Example

```@example vcvs
using CircuitSim

# Input voltage source (1V DC)
vin = DCVoltageSource("Vin", voltage=1.0)

# VCVS with gain of 10
vcvs = VoltageControlledVoltageSource("E1", g=10.0)

# Load resistor
rload = Resistor("Rload", resistance=50.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, vin)
add_component!(circ, vcvs)
add_component!(circ, rload)
add_component!(circ, GND)

# Connect input voltage as control signal
@connect circ vin.nplus vcvs.n1
@connect circ vin.nminus vcvs.n2
# Connect output
@connect circ vcvs.n3 rload.nplus
@connect circ vcvs.n4 rload.nminus
# Ground connections
@connect circ vin.nminus GND
@connect circ rload.nminus GND

# Transient analysis
tran_analysis = TransientAnalysis(1e-3, points=100)
result = simulate_qucsator(circ, tran_analysis)

# Output voltage should be 10x input = 10V
v_out = get_pin_voltage(result, rload, :n1)
println("Input: 1V, Gain: 10, Output: ", round(v_out[end], digits=1), " V")
```
