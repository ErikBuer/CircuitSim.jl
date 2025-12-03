# LC Lowpass Filter

This example demonstrates designing a simple LC lowpass filter, 
simulating its S-parameters using Qucsator, and plotting the results with CairoMakie.

## Circuit Design

A Pi-type lowpass filter uses shunt capacitors to ground and a series inductor.
This creates a 3rd-order filter with a well-defined cutoff frequency.

```@example lpf
using CircuitTypes
using CairoMakie

# Create circuit
circ = Circuit()

# Ports
port1 = PowerSource("P1", 1, z0=50.0, power=-30.0, freq=1e9)
port2 = PowerSource("P2", 2, z0=50.0, power=-30.0, freq=1e9)
add_component!(circ, port1)
add_component!(circ, port2)

# Components
L1 = Inductor("L1", 80e-9)    # 80 nH
C1 = Capacitor("C1", 32e-12)  # 32 pF  
C2 = Capacitor("C2", 32e-12)  # 32 pF
add_component!(circ, L1)
add_component!(circ, C1)
add_component!(circ, C2)

# Ground
gnd = Ground("GND")
add_component!(circ, gnd);
```

## Connecting Components

```@example lpf
# Shunt capacitor C1 from Port1 to ground
@connect circ port1.nplus C1.n1
@connect circ C1.n2 gnd.n

# Series inductor from Port1 to Port2
@connect circ port1.nplus L1.n1
@connect circ L1.n2 port2.nplus

# Shunt capacitor C2 from Port2 to ground  
@connect circ L1.n2 C2.n1
@connect circ C2.n2 gnd.n

# Port ground connections
@connect circ port1.nminus gnd.n
@connect circ port2.nminus gnd.n
```

## S-Parameter Simulation

Simulate S-parameters from 1 MHz to 1 GHz.

```@example lpf
# Define S-parameter analysis
sparam = SParameterAnalysis(1e6, 1e9, 201,
    sweep_type=LOGARITHMIC,
    z0=50.0
)

# Run simulation
result = simulate_qucsator(circ, sparam)

println("Available vectors: ", list_vectors(result))
```

## Plotting Results

```@example lpf
# Extract frequency and S-parameters
freq_vec = get_real_vector(result, "frequency")
freq_mhz = freq_vec ./ 1e6

# Get S11 and S21 (complex values)
s11_complex = get_complex_vector(result, "S[1,1]")
s21_complex = get_complex_vector(result, "S[2,1]")

# Convert to dB
s11_db = 20 .* log10.(abs.(s11_complex))
s21_db = 20 .* log10.(abs.(s21_complex))

nothing # hide
```

### S-Parameter Magnitude

```@example lpf
fig = Figure(size=(900, 600), fontsize=14)

ax1 = Axis(fig[1, 1],
    xlabel = "Frequency [MHz]",
    ylabel = "Magnitude [dB]",
    title = "LC Lowpass Filter (L=80nH, C=32pF)",
)

lines!(ax1, freq_mhz, s21_db, label="S₂₁ (Insertion Loss)", linewidth=2)
lines!(ax1, freq_mhz, s11_db, label="S₁₁ (Return Loss)", linewidth=2)

ylims!(ax1, -50, 5)
xlims!(ax1, 0, 1000)
axislegend(ax1, position=:lb)

fig
```
