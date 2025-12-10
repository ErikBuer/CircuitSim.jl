# Operational Amplifier

Ideal operational amplifier with configurable gain and output voltage limits.

Non-inverting amplifier configuration with gain of 11.

```@example opamp
using CircuitSim

circ = Circuit()

# Components
vin = ACVoltageSource("Vin", 0.1, freq=1e3)  # 100mV AC input
opamp = OpAmp("OP1", g=1e5, umax=12.0)
r1 = Resistor("R1", 1000.0)   # Feedback resistor
r2 = Resistor("R2", 100.0)    # Ground resistor
rload = Resistor("Rload", 10000.0)
gnd = Ground("GND")

add_component!(circ, vin)
add_component!(circ, opamp)
add_component!(circ, r1)
add_component!(circ, r2)
add_component!(circ, rload)
add_component!(circ, gnd)

# Non-inverting amplifier: Gain = 1 + R1/R2 = 1 + 1000/100 = 11
@connect circ vin.nplus opamp.ninp  # Input to non-inverting
@connect circ vin.nminus gnd
@connect circ opamp.ninn r2.n1      # Inverting to voltage divider
@connect circ r2.n2 gnd
@connect circ opamp.nout r1.n1      # Output through feedback
@connect circ r1.n2 r2.n1           # Feedback to inverting
@connect circ opamp.nout rload.n1   # Output to load
@connect circ rload.n2 gnd

assign_nodes!(circ)

# Transient analysis
tran_analysis = TransientAnalysis(2e-3, points=200)
result = simulate_qucsator(circ, tran_analysis)

# Output voltage should be ~1.1V (0.1V × 11)
v_out = get_pin_voltage(result, rload, :n1)
println("OpAmp output: ", round(abs(v_out[end]), digits=2), " V (expected ~1.1V)")
```
