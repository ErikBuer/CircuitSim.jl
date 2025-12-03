# Attenuator

## Circuit Setup

Create a 2-port measurement setup with the attenuator between two ports.

```@example att
using CircuitTypes

# Create circuit
circ = Circuit()

# Measurement ports
port1 = Pac("P1", 1)  # Port 1
port2 = Pac("P2", 2)  # Port 2

# 10 dB attenuator (linear ratio 3.162) with 50 Ω impedance
att = Attenuator("ATT1", 20)

# Add components
add_component!(circ, port1)
add_component!(circ, att)
add_component!(circ, port2)

# Ground reference
gnd = Ground("GND")
add_component!(circ, gnd);
```

## Connections

Connect Port 1 → Attenuator → Port 2 with proper grounding.

```@example att
# Port 1 to attenuator input
@connect circ port1.nplus att.n1

# Attenuator output to Port 2
@connect circ att.n2 port2.nplus

# Ground connections
@connect circ port1.nminus gnd.n
@connect circ port2.nminus gnd.n
```

## S-Parameter Simulation

Run S-parameter analysis from 1 GHz to 10 GHz to verify the attenuator performance.

```@example att
# S-parameter analysis: 1-10 GHz, logarithmic sweep
analysis = SParameterAnalysis(1e9, 10e9, 101,
    sweep_type=LOGARITHMIC,
    z0=50.0
)

# Run simulation
dataset = simulate_qucsator(circ, analysis)

# Extract typed S-parameter results
sp_result = extract_sparameter_result(dataset)
```

## Results Analysis

Extract and display the S-parameters.

```@example att
# Get frequency vector in GHz
freqs_GHz = sp_result.frequencies_Hz ./ 1e9

# Extract S-parameters from typed result
s11 = sp_result.s_matrix[(1,1)]  # Input reflection
s21 = sp_result.s_matrix[(2,1)]  # Forward transmission (insertion loss)
s12 = sp_result.s_matrix[(1,2)]  # Reverse transmission
s22 = sp_result.s_matrix[(2,2)]  # Output reflection

# Convert to dB
s11_dB = 20 .* log10.(abs.(s11))
s21_dB = 20 .* log10.(abs.(s21))
s12_dB = 20 .* log10.(abs.(s12))
s22_dB = 20 .* log10.(abs.(s22))

nothing # hide
```

## Plotting with CairoMakie

```@example att
using CairoMakie

fig = Figure(size=(900, 700), fontsize=14)

# S21 and S12 (Insertion Loss and Isolation)
ax1 = Axis(fig[1, 1],
    xlabel = "Frequency [GHz]",
    ylabel = "Magnitude [dB]",
    title = "10 dB Attenuator - Transmission",
)

lines!(ax1, freqs_GHz, s21_dB, label="S₂₁ (Forward)", linewidth=2, color=:blue)
lines!(ax1, freqs_GHz, s12_dB, label="S₁₂ (Reverse)", linewidth=2, color=:red, linestyle=:dash)

ylims!(ax1, -40, 0)
axislegend(ax1, position=:rb)

# S11 and S22 (Return Loss)
ax2 = Axis(fig[2, 1],
    xlabel = "Frequency [GHz]",
    ylabel = "Magnitude [dB]",
    title = "10 dB Attenuator - Reflection",
)

lines!(ax2, freqs_GHz, s11_dB, label="S₁₁ (Input)", linewidth=2, color=:blue)
lines!(ax2, freqs_GHz, s22_dB, label="S₂₂ (Output)", linewidth=2, color=:red, linestyle=:dash)

ylims!(ax2, -40, 0)
axislegend(ax2, position=:lb)

fig
```
