# Amplifier S-Parameters

## Circuit Setup

Two-port measurement with 20 dB gain amplifier.

```@example amp
using CircuitTypes

# Create circuit
circ = Circuit()

# AC power sources (S-parameter ports)
port1 = ACPowerSource("P1", 1, impedance=50.0)
port2 = ACPowerSource("P2", 2, impedance=50.0)

# Amplifier voltage gain: 20 dB gain = linear gain of 10, NF = 2.0
amp = Amplifier("AMP1", 10.0, 2.0)

# Ground
gnd = Ground("GND")

# Add components
add_component!(circ, port1)
add_component!(circ, amp)
add_component!(circ, port2)
add_component!(circ, gnd)

# Connections
@connect circ port1.nplus amp.n1
@connect circ amp.n2 port2.nplus
@connect circ port1.nminus gnd.n
@connect circ port2.nminus gnd.n
```

## S-Parameter Simulation

Measure S-parameters at 2.4 GHz (qucsator requires at least 2 points).

```@example amp
# S-parameter analysis: 2.4 GHz with minimal span (2 points required by simulator)
analysis = SParameterAnalysis(2.4e9, 2.4001e9, 2, z0=50.0)

# Run simulation
dataset = simulate_qucsator(circ, analysis)

# Extract S-parameters
sp_result = extract_sparameter_result(dataset)

# Get S-parameters at first frequency point
s11 = sp_result.s_matrix[(1,1)][1]
s21 = sp_result.s_matrix[(2,1)][1]
s12 = sp_result.s_matrix[(1,2)][1]
s22 = sp_result.s_matrix[(2,2)][1]

s11_dB = 20 * log10(abs(s11))
s21_dB = 20 * log10(abs(s21))
s12_dB = 20 * log10(abs(s12))
s22_dB = 20 * log10(abs(s22))

println("S11 (input reflection) = $(s11_dB) dB")
println("S21 (forward gain) = $(s21_dB) dB")
println("S12 (reverse isolation) = $(s12_dB) dB")
println("S22 (output reflection) = $(s22_dB) dB")
```
