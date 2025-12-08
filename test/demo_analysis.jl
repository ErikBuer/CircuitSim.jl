#!/usr/bin/env julia
# Demo: Analysis Types for Qucsator Simulation
#
# This demonstrates all the analysis types supported by CircuitSim.jl

using CircuitSim

println("="^70)
println("CircuitSim.jl - Analysis Types Demo")
println("="^70)

# Part 1: Show all Analysis Types

println("\n### Available Analysis Types ###\n")

println("1. DCAnalysis() - DC operating point")
dc = DCAnalysis()
println("   $(dc)")
println("   Netlist: $(to_qucs_analysis(dc))")

println("\n2. ACAnalysis(start, stop, points) - AC frequency sweep")
ac = ACAnalysis(1.0, 1e6, 101)
println("   $(ac)")
println("   Netlist: $(to_qucs_analysis(ac))")

println("\n3. TransientAnalysis(stop) - Time-domain simulation")
tr = TransientAnalysis(1e-3, points=1001)
println("   $(tr)")
println("   Netlist: $(to_qucs_analysis(tr))")

println("\n4. SParameterAnalysis(start, stop, points) - S-parameter sweep")
sp = SParameterAnalysis(1e6, 1e9, 201)
println("   $(sp)")
println("   Netlist: $(to_qucs_analysis(sp))")

println("\n5. ParameterSweep(param, start, stop, points, inner) - Parameter sweep")
inner_dc = DCAnalysis(name="DC_inner")
sweep = ParameterSweep("R1", 1e3, 10e3, 5, inner_dc)
println("   $(sweep)")
println("   Netlist:")
for line in split(to_qucs_analysis(sweep), '\n')
    println("     $line")
end

println("\n6. HarmonicBalanceAnalysis(freq) - Harmonic balance")
hb = HarmonicBalanceAnalysis(1e9, harmonics=7)
println("   $(hb)")
println("   Netlist: $(to_qucs_analysis(hb))")

println("\n7. NoiseAnalysis(start, stop, points, out, src) - Noise analysis")
noise = NoiseAnalysis(10.0, 100e3, 101, "_net1", "V1")
println("   $(noise)")
println("   Netlist: $(to_qucs_analysis(noise))")

# Part 2: Build a test circuit (RC low-pass filter)

println("\n" * "="^70)
println("### Building RC Low-Pass Filter Circuit ###")
println("="^70)

c = Circuit()

# 10V DC source + 1V AC for frequency response
V1 = ACVoltageSource("V1", 1.0, dc=0.0, freq=1000.0)  # 1V AC
R1 = Resistor("R1", 1e3)      # 1kΩ
C1 = Capacitor("C1", 100e-9)  # 100nF -> fc ≈ 1.6kHz
G = Ground("GND")

add_component!(c, V1)
add_component!(c, R1)
add_component!(c, C1)
add_component!(c, G)

@connect c V1.nplus R1.n1
@connect c R1.n2 C1.n1
@connect c C1.n2 G.n
@connect c V1.nminus G.n

fc = 1 / (2π * 1e3 * 100e-9)
println("\nCircuit: RC Low-Pass Filter")
println("  V1 (1V AC) → R1 (1kΩ) → C1 (100nF) → GND")
println("  Cutoff frequency: fc = 1/(2πRC) = $(round(fc, digits=1)) Hz")

println("\nGenerated Qucs Netlist:")
println(netlist_qucs(c))

# Part 3: Run DC Analysis

println("\n" * "="^70)
println("### DC Analysis ###")
println("="^70)

println("\nRunning: simulate_qucsator(c, DCAnalysis())")
result_dc = simulate_qucsator(c, DCAnalysis())

if result_dc.dataset.status == SIM_SUCCESS
    v_in = voltage(result_dc, V1, :nplus)
    v_out = voltage(result_dc, C1, :n1)
    println("  V_in  = $(v_in) V")
    println("  V_out = $(v_out) V")
    println("  (DC gain = $(v_out/max(v_in, 1e-10)) - capacitor blocks DC)")
    println("  ✓ DC Analysis completed!")
else
    println("  ✗ Failed: ", result_dc.dataset.errors)
end

# Part 4: Run DC Analysis with custom parameters

println("\n" * "="^70)
println("### DC Analysis with Custom Parameters ###")
println("="^70)

println("\nRunning: simulate_qucsator(c, DCAnalysis(temp=85.0, save_all=true))")
result_dc2 = simulate_qucsator(c, DCAnalysis(temp=85.0, save_all=true))

if result_dc2.dataset.status == SIM_SUCCESS
    println("  Simulation at 85°C completed!")
    println("  Available vectors: ", list_vectors(result_dc2.dataset))
    println("  ✓ Custom DC Analysis completed!")
else
    println("  ✗ Failed: ", result_dc2.dataset.errors)
end

# Part 5: Show generated analysis commands

println("\n" * "="^70)
println("### Summary of Analysis Netlist Commands ###")
println("="^70)

analyses = [
    ("DC (default)", DCAnalysis()),
    ("DC (85°C, save all)", DCAnalysis(temp=85.0, save_all=true)),
    ("AC (1Hz to 1MHz, 101pts, log)", ACAnalysis(1.0, 1e6, 101)),
    ("AC (1kHz to 10kHz, 50pts, linear)", ACAnalysis(1e3, 10e3, 50, sweep_type=LINEAR)),
    ("Transient (0 to 1ms, 1001pts)", TransientAnalysis(1e-3, points=1001)),
    ("Transient (0 to 10μs, 10ns step)", TransientAnalysis(10e-6, step=10e-9)),
    ("S-Parameter (1MHz to 1GHz)", SParameterAnalysis(1e6, 1e9, 201)),
    ("S-Parameter (75Ω ref)", SParameterAnalysis(1e6, 1e9, 101, z0=75.0)),
    ("Harmonic Balance (1GHz, 5 harmonics)", HarmonicBalanceAnalysis(1e9)),
]

for (desc, analysis) in analyses
    println("\n$desc:")
    println("  $(to_qucs_analysis(analysis))")
end

println("\n" * "="^70)
println("Demo complete!")
println("="^70)
