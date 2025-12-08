#!/usr/bin/env julia
# Test to verify amplifier netlist generation

using CircuitSim

println("="^70)
println("Amplifier Netlist Test")
println("="^70)

# Create simple amplifier test circuit
c = Circuit()

# Power sources for S-parameter analysis
P1 = ACPowerSource("P1", 1, 1.0e9, num=1)
P2 = ACPowerSource("P2", 2, 1.0e9, num=2)

# Amplifier: gain=10 (linear), NF=1 (noiseless), 50Ω ports
AMP = Amplifier("AMP1", 10.0, 1.0)  # Linear gain of 10

add_component!(c, P1)
add_component!(c, AMP)
add_component!(c, P2)

# Connect: P1 -> AMP -> P2
@connect c P1.n AMP.n1
@connect c AMP.n2 P2.n

println("\nCircuit components:")
for comp in c.components
    println("  - $(comp.name) ($(typeof(comp)))")
end

println("\nGenerated netlist:")
println("="^70)
netlist = netlist_qucs(c)
println(netlist)
println("="^70)

println("\nChecking amplifier line:")
for line in split(netlist, '\n')
    if contains(line, "Amp:")
        println("  $line")

        # Parse to check values
        m = match(r"G=\"([^\"]+)\"", line)
        if m !== nothing
            println("    → Gain G = $(m.captures[1])")
        end
        m = match(r"Z1=\"([^\"]+)\"", line)
        if m !== nothing
            println("    → Input impedance Z1 = $(m.captures[1])")
        end
        m = match(r"Z2=\"([^\"]+)\"", line)
        if m !== nothing
            println("    → Output impedance Z2 = $(m.captures[1])")
        end
        m = match(r"NF=\"([^\"]+)\"", line)
        if m !== nothing
            println("    → Noise figure NF = $(m.captures[1])")
        end
    end
end

println("\nExpected S21 (forward gain) calculation:")
println("  Formula: S21 = 4 * z0 * sqrt(Z1*Z2) * G / (Z1+z0) / (Z2+z0)")
println("  With G=10, Z1=50, Z2=50, z0=50:")
println("  S21 = 4 * 50 * sqrt(50*50) * 10 / (50+50) / (50+50)")
println("  S21 = 4 * 50 * 50 * 10 / 100 / 100")
println("  S21 = 100000 / 10000 = 10")
println("  S21_dB = 20*log10(10) = 20 dB")
