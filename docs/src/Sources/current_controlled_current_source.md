# Current-Controlled Current Source

A current source whose output current is proportional to the current through a control element.

## Example

```@example cccs
using CircuitSim

# Input current source (1 mA AC at 1kHz)
iin = ACCurrentSource("Iin", 0.001, freq=1e3)

# Sense resistor for current measurement
rsense = Resistor("Rsense", 100.0)

# CCCS with current gain of 5
cccs = CurrentControlledCurrentSource("F1", g=5.0)

# Load resistor
rload = Resistor("Rload", 1000.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, iin)
add_component!(circ, rsense)
add_component!(circ, cccs)
add_component!(circ, rload)
add_component!(circ, GND)

# Connect current source through sense resistor
@connect circ iin.nplus rsense.nplus
@connect circ iin.nminus GND
@connect circ rsense.nminus GND
# Connect CCCS sensing the current
@connect circ rsense.nplus cccs.n1
@connect circ rsense.nminus cccs.n2
# Connect CCCS output
@connect circ cccs.n3 rload.nplus
@connect circ cccs.n4 rload.nminus
@connect circ rload.nminus GND

assign_nodes!(circ)

# Transient analysis
tran_analysis = TransientAnalysis(2e-3, points=200)
result = simulate_qucsator(circ, tran_analysis)

# Output current = input × gain = 1mA × 5 = 5mA, Output voltage = 5V
v_out = get_pin_voltage(result, rload, :n1)
println("CCCS output: ", round(abs(v_out[end]), digits=1), " V (expected ~5.0V)")
```
