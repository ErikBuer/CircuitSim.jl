# Voltage-Controlled Current Source

A current source whose output current is proportional to the voltage across another pair of nodes.

## Example

```@example vccs
using CircuitSim

# Input voltage source (1V DC)
vin = DCVoltageSource("Vin", voltage=1.0)

# VCCS with transconductance 0.01 S (10 mA/V)
vccs = VoltageControlledCurrentSource("G1", g=0.01)

# Load resistor
rload = Resistor("Rload", resistance=1000.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, vin)
add_component!(circ, vccs)
add_component!(circ, rload)
add_component!(circ, GND)

# Connect input voltage as control signal
@connect circ vin.nplus vccs.n1
@connect circ vin.nminus vccs.n2
# Connect output
@connect circ vccs.n3 rload.nplus
@connect circ vccs.n4 rload.nminus
# Ground connections
@connect circ vin.nminus GND
@connect circ rload.nminus GND

# Transient analysis
tran_analysis = TransientAnalysis(1e-3, points=100)
result = simulate_qucsator(circ, tran_analysis; suppress_warnings=true)

# Output voltage = input × transconductance × load = 1V × 0.01S × 1000Ω = 10V
v_out = get_pin_voltage(result, rload, :n1)
println("VCCS output: ", round(v_out[end], digits=1), " V (expected 10V)")
```
