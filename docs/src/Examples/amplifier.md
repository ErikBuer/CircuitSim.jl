# RF Amplifier

S-parameter analysis of a 20 dB RF amplifier from 500 MHz to 6 GHz.

## Circuit

```@example amp_sp
using CircuitTypes
using CairoMakie

# Create circuit
circ = Circuit()

# Amplifier: 20 dB gain = linear gain of 10, 3 dB NF = linear NF of 2
amp = Amplifier("AMP1", 100.0, 1.0)
add_component!(circ, amp)

# AC power sources (S-parameter ports)
p1 = ACPowerSource("P1", 1, impedance=50.0)
p2 = ACPowerSource("P2", 2, impedance=50.0)
add_component!(circ, p1)
add_component!(circ, p2)
# Ground
gnd = Ground("GND")
add_component!(circ, gnd)

# Connect: P1 -> Amp -> P2
@connect circ p1.nplus amp.n1
@connect circ amp.n2 p2.nplus
@connect circ p1.nminus gnd.n
@connect circ p2.nminus gnd.n

nothing # hide
```

## S-Parameter Simulation

```@example amp_sp
# S-parameter analysis: 500 MHz to 6 GHz
analysis = SParameterAnalysis(500e6, 6e9, 201, z0=50.0)

# Run simulation
dataset = simulate_qucsator(circ, analysis)

# Extract S-parameters
sp_result = extract_sparameter_result(dataset)

# Get frequency in GHz
freq_GHz = sp_result.frequencies_Hz ./ 1e9

# Extract S-parameters
s21 = sp_result.s_matrix[(2,1)]  # Forward gain
s11 = sp_result.s_matrix[(1,1)]  # Input return loss
s12 = sp_result.s_matrix[(1,2)]  # Reverse isolation

# Convert to dB
s21_dB = 20 .* log10.(abs.(s21))
s11_dB = 20 .* log10.(abs.(s11))
s12_dB = 20 .* log10.(abs.(s12))

nothing # hide
```

## Plot

```@example amp_sp
fig = Figure(size=(900, 600))

ax = Axis(fig[1, 1],
    xlabel = "Frequency [GHz]",
    ylabel = "Magnitude [dB]",
    title = "Amplifier S-Parameters (20 dB gain, 50 Ω)"
)

lines!(ax, freq_GHz, s21_dB, label="S₂₁ (Forward Gain)", linewidth=2.5, color=:blue)
lines!(ax, freq_GHz, s11_dB, label="S₁₁ (Input Return Loss)", linewidth=2, color=:red)
lines!(ax, freq_GHz, s12_dB, label="S₁₂ (Reverse Isolation)", linewidth=2, color=:green)

hlines!(ax, [0], linestyle=:dash, color=:gray, linewidth=1)
axislegend(ax, position=:rb)

ylims!(ax, -60, 25)

fig
```
