# S-Parameter File

Load S-parameters from a Touchstone file (`.snp`) for black-box modeling.



```@example spfile
using CircuitSim
using GLMakie

circ = Circuit()

# Components
port1 = ACPowerSource("P1", 1, impedance=50.0)

# Load S-parameters from file (1-port antenna)
spf = SPfile("ANT1", "../assets/test_files/70 mm L1 L5 Single feed.s1p", data_format="rectangular", interpolator="linear")

gnd = Ground("GND")

add_component!(circ, port1)
add_component!(circ, spf)
add_component!(circ, gnd)

# Connect 1-port S-parameter file
@connect circ port1.nplus spf.n1
@connect circ port1.nminus gnd
@connect circ spf.ref gnd

sparam = SParameterAnalysis(1e9,2e9, 601,
    sweep_type=LINEAR,
    z0=50.0
)

sp_result = simulate_qucsator(circ, sparam)
```

```@example spfile
# Get frequency vector in MHz
freq_mhz = sp_result.frequencies_Hz ./ 1e6

# Extract S-parameters from typed result
s11_complex = sp_result.s_matrix[(1,1)]

# Convert to dB
s11_db = 20 .* log10.(abs.(s11_complex))

nothing # hide
```

### Plot S-Parameter Magnitude

```@example spfile
fig = Figure(size=(900, 600), fontsize=14)

ax1 = Axis(fig[1, 1],
    xlabel = "Frequency [MHz]",
    ylabel = "Magnitude [dB]",
    title = "",
)

lines!(ax1, freq_mhz, s11_db, label="S₁₁ (Return Loss)", linewidth=2)

ylims!(ax1, -25, 5)
xlims!(ax1, 1000, 2000)
axislegend(ax1, position=:lb)

fig
```