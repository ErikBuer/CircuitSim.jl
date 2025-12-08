#!/usr/bin/env julia
"""
Demonstration of typed result extraction from QucsDataset.

Shows the new approach:
1. Parse raw output into QucsDataset (low-level, general)
2. Extract typed results (DCResult, ACResult, etc.) from dataset
3. Access specific data from typed structures

This keeps parsing in qucs_dataset.jl and makes it easy to add
other simulation engines later.
"""

using CircuitSim

println("="^70)
println("Typed Result Extraction Demo")
println("="^70)

# ============================================================================
# Example 1: S-Parameter Analysis with Typed Extraction
# ============================================================================

println("\n" * "="^70)
println("Example 1: S-Parameter Analysis with Typed Results")
println("="^70)

c = Circuit()

# Create 2-port amplifier circuit
P1 = ACPowerSource("P1", 1, impedance=50.0)
P2 = ACPowerSource("P2", 2, impedance=50.0)
AMP = Amplifier("AMP1", 10.0, 1.41)  # 10x gain, NF=1.41

add_component!(c, P1)
add_component!(c, AMP)
add_component!(c, P2)

@connect c P1.nplus AMP.n1
@connect c AMP.n2 P2.nplus
@connect c P1.nminus P2.nminus

println("\nRunning S-parameter analysis...")
analysis = SParameterAnalysis(1e9, 10e9, 11)
dataset = simulate_qucsator(c, analysis)

println("✓ Simulation completed")
println("  Status: $(dataset.status)")

# Extract typed S-parameter result
sp_result = extract_sparameter_result(dataset)

println("\nS-Parameter Data:")
println("  Number of ports: $(sp_result.num_ports)")
println("  Frequency points: $(length(sp_result.frequencies_Hz))")
println("  Reference impedance: $(sp_result.z0_Ohm) Ω")
println("  Frequency range: $(sp_result.frequencies_Hz[1]/1e9) - $(sp_result.frequencies_Hz[end]/1e9) GHz")

# Access S-parameters from typed structure
s21 = sp_result.s_matrix[(2, 1)]
s11 = sp_result.s_matrix[(1, 1)]

println("\nS-parameters at first frequency ($(sp_result.frequencies_Hz[1]/1e9) GHz):")
println("  S11: $(abs(s11[1])) ∠ $(angle(s11[1])*180/π)°")
println("  S21: $(abs(s21[1])) ∠ $(angle(s21[1])*180/π)°")
println("  S21 dB: $(20*log10(abs(s21[1]))) dB")

# ============================================================================
# Example 2: DC Analysis with Typed Extraction
# ============================================================================

println("\n\n" * "="^70)
println("Example 2: DC Analysis with Typed Results")
println("="^70)

c2 = Circuit()

# Voltage divider
V1 = DCVoltageSource("V1", 10.0)
R1 = Resistor("R1", 1000.0)
R2 = Resistor("R2", 1000.0)
GND = Ground("GND")

add_component!(c2, V1)
add_component!(c2, R1)
add_component!(c2, R2)
add_component!(c2, GND)

@connect c2 V1.nplus R1.n1
@connect c2 R1.n2 R2.n1
@connect c2 R2.n2 GND
@connect c2 V1.nminus GND

println("\nRunning DC analysis...")
dataset_dc = simulate_qucsator(c2, DCAnalysis())

println("✓ Simulation completed")

# Extract typed DC result
dc_result = extract_dc_result(dataset_dc)

println("\nDC Operating Point:")
println("  Voltages:")
for (node, v) in sort(collect(dc_result.voltages))
   println("    $node: $(v) V")
end

println("\n  Currents:")
for (comp, i) in sort(collect(dc_result.currents))
   println("    $comp: $(i) A")
end

# ============================================================================
# Summary
# ============================================================================

println("\n\n" * "="^70)
println("Summary: Typed Result Approach")
println("="^70)

println("""
This new approach provides:

1. Clean Separation:
   - QucsDataset: Raw parsed data (general, simulator-agnostic structure)
   - Typed Results: Analysis-specific structures (DCResult, ACResult, etc.)
   - SimulationResult: High-level component-based access (Qucsator-specific)

2. Type Safety:
   - DCResult.voltages: Dict{String,Float64}
   - ACResult.voltages: Dict{String,Vector{ComplexF64}}
   - SParameterResult.s_matrix: Dict{Tuple{Int,Int},Vector{ComplexF64}}

3. Easy Extension:
   - Add new typed results for other analysis types
   - Add extractors for other simulation engines (ngspice, etc.)
   - Keep parsing logic in qucs_dataset.jl

4. Usage Pattern:
   ```julia
   # Run simulation
   dataset = simulate_qucsator(circuit, analysis)
   
   # Extract typed data
   sp_data = extract_sparameter_result(dataset)
   
   # Access specific parameters
   s21_vs_freq = sp_data.s_matrix[(2,1)]
   freqs_GHz = sp_data.frequencies_Hz ./ 1e9
   ```

Inspired by qucs-s approach of strongly-typed result structures!
""")

println("="^70)
