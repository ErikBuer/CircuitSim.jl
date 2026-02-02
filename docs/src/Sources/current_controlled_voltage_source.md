# Current-Controlled Voltage Source

A voltage source whose output is proportional to the current through a control element.

## Example

```@example ccvs
using CircuitSim

# Input current source (1 mA AC at 1kHz)
iin = ACCurrentSource("Iin", ac_mag=0.001, freq=1e3)

# Sense resistor for current measurement
rsense = Resistor("Rsense", resistance=100.0)

# CCVS with transresistance 1000 Ω
ccvs = CurrentControlledVoltageSource("H1", g=1000.0)

# Load resistor
rload = Resistor("Rload", resistance=1000.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, iin)
add_component!(circ, rsense)
add_component!(circ, ccvs)
add_component!(circ, rload)
add_component!(circ, GND)

# Connect current source through sense resistor
@connect circ iin.nplus rsense.nplus
@connect circ iin.nminus GND
@connect circ rsense.nminus GND
# Connect CCVS sensing the current
@connect circ rsense.nplus ccvs.n1
@connect circ rsense.nminus ccvs.n2
# Connect CCVS output
@connect circ ccvs.n3 rload.nplus
@connect circ ccvs.n4 rload.nminus
@connect circ rload.nminus GND

# Transient analysis
tran_analysis = TransientAnalysis(2e-3, points=200)
result = simulate_qucsator(circ, tran_analysis; suppress_warnings=true)

# Output voltage = input current × transresistance = 1mA × 1000Ω = 1V
v_out = get_pin_voltage(result, rload, :n1)
println("CCVS output: ", round(abs(v_out[end]), digits=2), " V (expected ~1.0V)")
```
