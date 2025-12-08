# Capacitor with Quality Factor

This example demonstrates the `CapacitorQ` component, which models a capacitor with frequency-dependent losses characterized by a quality factor Q.

```@example capq
using CircuitTypes
using CairoMakie

# Create circuit for S-parameter analysis
circ = Circuit()

# Two-port configuration: Port1 -> CapacitorQ -> Port2
port1 = ACPowerSource("P1", 1, impedance=50.0)
port2 = ACPowerSource("P2", 2, impedance=50.0)
add_component!(circ, port1)
add_component!(circ, port2)

cap_q = CapacitorQ("C1", 100e-12, 100.0, freq=100e6)
add_component!(circ, cap_q)

# Ground
gnd = Ground("GND")
add_component!(circ, gnd)
```

Connect the capacitor in series between the two ports.

```@example capq
# Series connection: Port1 -> Capacitor -> Port2
@connect circ port1.nplus cap_q.n1
@connect circ cap_q.n2 port2.nplus

# Ground connections
@connect circ port1.nminus gnd.n
@connect circ port2.nminus gnd.n
```

## S-Parameter Analysis

Run S-parameter analysis from 1 MHz to 1000 MHz to characterize the capacitor's frequency response.

```@example capq
# S-parameter analysis
sparam = SParameterAnalysis(1e6, 1000e6, 1000,
    sweep_type=LINEAR,
    z0=50.0
)

# Run simulation
sp_result = simulate_qucsator(circ, sparam)

println("S-parameter simulation completed:")
println("  Frequency range: $(sp_result.frequencies_Hz[1]/1e6) - $(sp_result.frequencies_Hz[end]/1e6) MHz")
```

## Plotting Results

Extract S-parameters and convert to impedance for visualization.

```@example capq
# Get frequency vector in MHz
freq_MHz = sp_result.frequencies_Hz ./ 1e6

# Extract S-parameters and build S-matrix for each frequency
s11 = sp_result.s_matrix[(1,1)]
s21 = sp_result.s_matrix[(2,1)]
s12 = sp_result.s_matrix[(1,2)]
s22 = sp_result.s_matrix[(2,2)]

# Convert S-parameters to impedance using utility function
z_cap = [s2z_series([s11[i] s12[i]; s21[i] s22[i]], sp_result.z0_Ohm) for i in 1:length(s11)]

# Convert to dB for S-parameters
s11_db = 20 .* log10.(abs.(s11))
s21_db = 20 .* log10.(abs.(s21))

nothing # hide
```

### Impedance Magnitude and Phase

```@example capq
fig1 = Figure(size=(900, 800), fontsize=14)

# Impedance magnitude
ax1 = Axis(fig1[1, 1],
    xlabel = "Frequency [MHz]",
    ylabel = "Impedance Magnitude [Ω]",
    title = "Capacitor Impedance: 100 pF, Q=100 @ 100 MHz",
    xscale = log10,
    yscale = log10
)

lines!(ax1, freq_MHz, abs.(z_cap), linewidth=2, color=:blue)

fig1
```

### S-Parameter Magnitude

```@example capq
fig2 = Figure(size=(900, 600), fontsize=14)

ax2 = Axis(fig2[1, 1],
    xlabel = "Frequency [MHz]",
    ylabel = "Magnitude [dB]",
    title = "S-Parameters: 100 pF CapacitorQ (Q=100 @ 100 MHz)",
    xscale = log10
)

lines!(ax2, freq_MHz, s21_db, label="S₂₁ (Transmission)", linewidth=2, color=:blue)
lines!(ax2, freq_MHz, s11_db, label="S₁₁ (Reflection)", linewidth=2, color=:red)

ylims!(ax2, -30, 5)
axislegend(ax2, position=:rb)

fig2
```
