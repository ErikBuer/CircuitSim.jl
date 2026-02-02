# Resistor

## Circuit Setup

Single port with a 100 Ω resistor to ground.

```@example resistor
using CircuitSim

# Create circuit
circ = Circuit()

# AC power sources (S-parameter ports)
port1 = ACPowerSource("P1", port_num=1, impedance=50.0)

# 100 Ω resistor
res = Resistor("R1", resistance=100)

# Ground
gnd = Ground("GND")

# Add components
add_component!(circ, port1)
add_component!(circ, res)
add_component!(circ, gnd)

# Connections
@connect circ port1.nplus res.n1
@connect circ res.n2 gnd
@connect circ port1.nminus gnd
```

## S-Parameter Simulation

Measure S11 near 5 GHz (qucsator requires at least 2 points).

```@example resistor
# S-parameter analysis: 5 GHz with minimal span (2 points required by simulator)
analysis = SParameterAnalysis(5e9, 5.001e9, 2, z0=50.0)

# Run simulation - returns typed SParameterResult directly
sp_result = simulate_qucsator(circ, analysis)

# Get S11 at first frequency point (reflection coefficient)
s11 = sp_result.s_matrix[(1,1)][1]
s11_mag = abs(s11)
s11_dB = 20 * log10(s11_mag)
s11_phase_deg = angle(s11) * 180 / π

println("S11 = $(s11)")
println("S11 magnitude = $(s11_mag)")
println("S11 (dB) = $(s11_dB) dB")
println("S11 phase = $(s11_phase_deg)°")
```
