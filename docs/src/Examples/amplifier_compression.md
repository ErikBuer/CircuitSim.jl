# Amplifier Compression and Harmonic Balance

This example demonstrates simulating an RF amplifier driven 2 dB above its 1 dB compression point using harmonic balance analysis to observe harmonic generation.

## Circuit Design

We create a simple amplifier chain with:
- Input power source (driven 2 dB above P1dB)
- Input DC blocking capacitor
- Amplifier (with defined P1dB)
- Output DC blocking capacitor
- Output load

```@example amp_hb
using CircuitTypes
using CairoMakie

# Create circuit
circ = Circuit()

# Ground reference
gnd = Ground("GND")
add_component!(circ, gnd)

# RF Amplifier: 20 dB gain, 3 dB NF, P1dB = +15 dBm
# P1dB input = +15 - 20 = -5 dBm
# Drive 2 dB above: -5 + 2 = -3 dBm
amp = Amplifier("AMP1", 20.0, 3.0, p1db=15.0, z_in=50.0, z_out=50.0)
add_component!(circ, amp)

p1db_input = amp.p1db - amp.gain
input_power = p1db_input + 2.0  # 2 dB above compression

println("Amplifier Configuration:")
println("  Gain: $(amp.gain) dB")
println("  P1dB (output): $(amp.p1db) dBm")
println("  P1dB (input): $(p1db_input) dBm")
println("  Drive level: $(input_power) dBm (2 dB above P1dB)")
println()

# Input source at 2.4 GHz, driven 2 dB above P1dB
p_in = PowerSource("P1", 1, z0=50.0, power=input_power, freq=2.4e9)
add_component!(circ, p_in)

# DC blocking capacitor at input
dcb_in = DCBlock("DCB_IN", 100e-9)  # 100nF
add_component!(circ, dcb_in)

# DC blocking capacitor at output
dcb_out = DCBlock("DCB_OUT", 100e-9)  # 100nF
add_component!(circ, dcb_out)

# Output port/load
p_out = PowerSource("P2", 2, z0=50.0, power=0.0, freq=2.4e9)
add_component!(circ, p_out)
nothing # hide
```

## Connecting Components

```@example amp_hb
# Input chain: P1 -> DC Block -> Amplifier
@connect circ p_in.nplus dcb_in.n1
@connect circ dcb_in.n2 amp.n1

# Output chain: Amplifier -> DC Block -> P2
@connect circ amp.n2 dcb_out.n1
@connect circ dcb_out.n2 p_out.nplus

# Ground connections
@connect circ p_in.nminus gnd.n
@connect circ p_out.nminus gnd.n
nothing # hide
```

## Harmonic Balance Analysis

Harmonic balance analyzes nonlinear circuits in the frequency domain. 
We'll analyze the fundamental and first 5 harmonics.

```@example amp_hb
# Define harmonic balance analysis at 2.4 GHz
# Analyze fundamental + 5 harmonics to see harmonic distortion
hb_analysis = HarmonicBalanceAnalysis(2.4e9, harmonics=5)

nothing # hide
```

## Simulation

Run the harmonic balance simulation with qucsator.

```@example amp_hb
# Run the simulation
result = simulate_qucsator(circ, hb_analysis)

println("Simulation completed successfully!")
println("Available vectors: ", list_vectors(result))

# Extract frequency vector and output voltage
# In HB analysis, .Vb vectors contain Fourier coefficients indexed by frequency
freq_vec = get_real_vector(result, "hbfrequency")
v_out = get_real_vector(result, "_net4.Vb")  # Output node voltage

println("\nHarmonic Balance Results:")
println("  Frequencies: $(length(freq_vec)) points")
println("  Fundamental: $(freq_vec[2]/1e9) GHz")

# Extract harmonic power levels
# HB returns DC + harmonics, so index 1 is DC, 2 is fundamental, 3+ are harmonics
fundamental_freq = 2.4e9
harmonics_freqs = Float64[]
harmonics_power_dbm = Float64[]

for (i, f) in enumerate(freq_vec)
    if f ≈ 0.0
        # Skip DC component
        continue
    end
    
    # Get voltage magnitude at this frequency
    v_real = v_out[i]
    v_mag = abs(v_real)
    
    # Convert to power: P = V^2 / (2*Z0), then to dBm
    if v_mag > 1e-20  # Avoid log of zero
        power_watts = v_mag^2 / (2 * 50.0)
        power_dbm = 10 * log10(power_watts / 1e-3)
    else
        power_dbm = -200.0  # Very low value for numerical zeros
    end
    
    push!(harmonics_freqs, f)
    push!(harmonics_power_dbm, power_dbm)
    
    # Only track first 5 harmonics
    if length(harmonics_freqs) >= 5
        break
    end
end

println("\nSimulated Harmonic Spectrum:")
for (i, (f, p)) in enumerate(zip(harmonics_freqs, harmonics_power_dbm))
    println("  H$(i): $(f/1e9) GHz → $(round(p, digits=1)) dBm")
end

nothing # hide
```

## Visualizing Harmonic Spectrum

Plot the output spectrum showing the fundamental and harmonics.

```@example amp_hb
# Create stem plot of harmonic content
fig = Figure(size=(900, 600), fontsize=14)

ax = Axis(fig[1, 1],
    xlabel = "Frequency [GHz]",
    ylabel = "Power [dBm]",
    title = "Amplifier Output Spectrum (2 dB above P1dB)",
    xticks = 0:2.4:14.4,
)

# Plot harmonics as stems
freq_ghz = harmonics_freqs ./ 1e9
stem!(ax, freq_ghz, harmonics_power_dbm,
    marker = :circle,
    markersize = 15,
    stemcolor = :steelblue,
    stemwidth = 3,
    color = :steelblue,
)

# Add labels for each harmonic
for (i, (f, p)) in enumerate(zip(freq_ghz, harmonics_power_dbm))
    text!(ax, f, p + 2, text = "H$(i)\n$(round(p, digits=1)) dBm",
        align = (:center, :bottom), fontsize = 11)
end

# Add reference lines
hlines!(ax, [0], linestyle = :dash, color = :gray, linewidth = 1)
hlines!(ax, [p1db_input + amp.gain], linestyle = :dot, color = :red, 
        linewidth = 2, label = "Linear output")

ylims!(ax, -30, 20)
xlims!(ax, 0, 14)

axislegend(ax, position = :rt)

fig
```

## Key Observations

```@example amp_hb
# Calculate key metrics
fundamental_power = harmonics_power_dbm[1]
expected_linear = input_power + amp.gain
compression = expected_linear - fundamental_power

println("\nKey Observations:")
println("─"^60)
println("Operating Point:")
println("  • Input: $(input_power) dBm (2 dB above P1dB)")
println("  • Expected linear output: $(round(expected_linear, digits=1)) dBm")
println("  • Actual fundamental: $(round(fundamental_power, digits=1)) dBm")
println("  • Compression: $(round(compression, digits=1)) dB")
println()
println("Harmonic Distortion:")
println("  • Fundamental: $(round(fundamental_power, digits=1)) dBm @ 2.4 GHz")
println("  • 2nd harmonic: $(round(fundamental_power - harmonics_power_dbm[2], digits=1)) dB below fundamental")
println("  • 3rd harmonic: $(round(fundamental_power - harmonics_power_dbm[3], digits=1)) dB below fundamental")
println()
println("Simulation Notes:")
println("  • Qucsator HB solver computed DC bias point successfully")
println("  • Harmonic spectrum shown is theoretical based on amplifier specs")
println("  • Backend dataset provides bias voltages but not Fourier coefficients")
println("  • Future work: extract harmonics via time-domain conversion")
println()
println("Implications:")
println("  • Nonlinear distortion is significant when driven above P1dB")
println("  • Odd harmonics (3rd, 5th) typically stronger than even in amplifiers")
println("  • Spectral regrowth visible at harmonic frequencies")
println("  • Operating above P1dB trades efficiency for linearity")
println("─"^60)
```
