# Amplifier S-Parameters

## Circuit Setup

Two-port measurement with 20 dB gain amplifier.

```@example amp
using CircuitSim

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
@connect circ port1.nplus amp.input
@connect circ amp.output port2.nplus
@connect circ port1.nminus gnd.n
@connect circ port2.nminus gnd.n
```

## S-Parameter Simulation

Measure S-parameters at 2.4 GHz (qucsator requires at least 2 points).

```@example amp
# S-parameter analysis: 2.4 GHz with minimal span (2 points required by simulator)
analysis = SParameterAnalysis(2.4e9, 2.4001e9, 2, z0=50.0)

# Run simulation - returns typed SParameterResult directly
sp_result = simulate_qucsator(circ, analysis)

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

## Noise Parameters

Enable noise parameter extraction to get noise figure, minimum noise figure, optimal source reflection coefficient, and equivalent noise resistance.

```@example amp
# S-parameter analysis with noise enabled
analysis_noise = SParameterAnalysis(2.4e9, 2.4001e9, 2, z0=50.0, noise=true)
sp_noise = simulate_qucsator(circ, analysis_noise)

# Extract noise parameters at first frequency
if !isnothing(sp_noise.F)
    F_dB = 10 * log10(sp_noise.F[1])
    Fmin_dB = 10 * log10(sp_noise.Fmin[1])
    Sopt_mag = abs(sp_noise.Sopt[1])
    Sopt_angle_deg = angle(sp_noise.Sopt[1]) * 180 / π
    Rn = sp_noise.Rn_Ohm[1]
    
    println("Noise Parameters:")
    println("  F (Noise Figure) = $(round(F_dB, digits=2)) dB")
    println("  Fmin (Minimum NF) = $(round(Fmin_dB, digits=2)) dB")
    println("  Γopt = $(round(Sopt_mag, digits=3)) ∠ $(round(Sopt_angle_deg, digits=1))°")
    println("  Rn = $(round(Rn, digits=2)) Ω")
end
```
