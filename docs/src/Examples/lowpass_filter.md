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
port1 = ACPowerSource("P1", 1, impedance=50.0)
port2 = ACPowerSource("P2", 2, impedance=50.0)
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
    sweep_type=LINEAR,
    z0=50.0
)

# Run simulation - returns typed SParameterResult directly
sp_result = simulate_qucsator(circ, sparam)

println("S-parameter simulation completed:")
println("  Number of ports: ", sp_result.num_ports)
println("  Frequency points: ", length(sp_result.frequencies_Hz))
println("  Reference impedance: ", sp_result.z0_Ohm, " Ω")
```

## Plotting Results

Extract S-parameters from the typed result structure.

```@example lpf
# Get frequency vector in MHz
freq_mhz = sp_result.frequencies_Hz ./ 1e6

# Extract S-parameters from typed result
s11_complex = sp_result.s_matrix[(1,1)]
s21_complex = sp_result.s_matrix[(2,1)]

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

## AC Analysis

For AC voltage analysis, we use an AC voltage source at the input and a resistive load at the output. We add voltage probes to measure at both nodes.

```@example lpf
# Create a new circuit for AC analysis (can't mix ACPowerSource with ACVoltageSource)
circ_ac = Circuit()

# AC voltage source at input
v_source = ACVoltageSource("Vin", 1.0)  # 1V AC source
add_component!(circ_ac, v_source)

# Output load resistor
r_load = Resistor("Rload", 50.0)  # 50Ω load
add_component!(circ_ac, r_load)

# Same filter components
L1_ac = Inductor("L1", 80e-9)
C1_ac = Capacitor("C1", 32e-12)
C2_ac = Capacitor("C2", 32e-12)
add_component!(circ_ac, L1_ac)
add_component!(circ_ac, C1_ac)
add_component!(circ_ac, C2_ac)

# Ground
gnd_ac = Ground("GND")
add_component!(circ_ac, gnd_ac)

# Voltage probes
v_in_probe = VoltageProbe("Vin_probe")
v_out_probe = VoltageProbe("Vout_probe")
add_component!(circ_ac, v_in_probe)
add_component!(circ_ac, v_out_probe)

# Connect filter: Vsource -> C1||L1 -> C2||Rload
@connect circ_ac v_source.nplus C1_ac.n1
@connect circ_ac C1_ac.n2 gnd_ac.n
@connect circ_ac v_source.nplus L1_ac.n1
@connect circ_ac L1_ac.n2 C2_ac.n1
@connect circ_ac C2_ac.n1 r_load.n1
@connect circ_ac C2_ac.n2 gnd_ac.n
@connect circ_ac r_load.n2 gnd_ac.n
@connect circ_ac v_source.nminus gnd_ac.n

# Connect probes
@connect circ_ac v_source.nplus v_in_probe.n1
@connect circ_ac gnd_ac.n v_in_probe.n2
@connect circ_ac r_load.n1 v_out_probe.n1
@connect circ_ac gnd_ac.n v_out_probe.n2

# AC analysis from 1 MHz to 1 GHz
ac_analysis = ACAnalysis(1e6, 1e9, 201, sweep_type=LINEAR)
ac_result = simulate_qucsator(circ_ac, ac_analysis)

println("AC analysis completed:")
println("  Frequency points: ", length(ac_result.frequencies_Hz))
```

### Voltage Response

Compare input and output voltages to see the filter's attenuation.

```@example lpf
# Get frequency vector
freq_ac_mhz = ac_result.frequencies_Hz ./ 1e6

# Get voltages from probes (already complex vectors)
v_in = ac_result.voltages["Vin_probe"]
v_out = ac_result.voltages["Vout_probe"]

# Convert to dB (magnitude)
v_in_db = 20 .* log10.(abs.(v_in))
v_out_db = 20 .* log10.(abs.(v_out))

nothing # hide
```

```@example lpf
fig2 = Figure(size=(900, 600), fontsize=14)

ax2 = Axis(fig2[1, 1],
    xlabel = "Frequency [MHz]",
    ylabel = "Voltage Magnitude [dB]",
    title = "AC Voltage Response",
)

lines!(ax2, freq_ac_mhz, v_in_db, label="Input Voltage", linewidth=2, color=:blue)
lines!(ax2, freq_ac_mhz, v_out_db, label="Output Voltage", linewidth=2, color=:red)

xlims!(ax2, 0, 1000)
axislegend(ax2, position=:lb)

fig2
```

The AC analysis shows the same frequency response as the S-parameter analysis,
but expressed as node voltages rather than scattering parameters.
