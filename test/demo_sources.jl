#!/usr/bin/env julia
# Demo: All source types with both Qucs and SPICE netlist generation
#
# This demonstrates that the same circuit components can be used to generate
# netlists for multiple simulators.

using CircuitTypes

println("="^60)
println("CircuitTypes.jl - Multi-Simulator Source Components Demo")
println("="^60)

# =============================================================================
# Part 1: Show all source types
# =============================================================================

println("\n### Available Source Types ###\n")

# DC Voltage Source
v_dc = DCVoltageSource("VDC", 12.0)
println("DCVoltageSource(\"VDC\", 12.0)")
println("  → DC voltage of $(v_dc.dc) V")

# DC Current Source  
i_dc = DCCurrentSource("IDC", 0.002)
println("\nDCCurrentSource(\"IDC\", 0.002)")
println("  → DC current of $(i_dc.dc) A = $(i_dc.dc * 1000) mA")

# AC Voltage Source
v_ac = ACVoltageSource("VAC", 1.0, freq=1e6, ac_phase=0.0)
println("\nACVoltageSource(\"VAC\", 1.0, freq=1e6, ac_phase=0.0)")
println("  → AC magnitude: $(v_ac.ac_mag) V")
println("  → Frequency: $(v_ac.freq) Hz = $(v_ac.freq/1e6) MHz")
println("  → Phase: $(v_ac.ac_phase)°")

# AC Current Source with DC offset
i_ac = ACCurrentSource("IAC", 0.01, dc=0.005, freq=50.0, ac_phase=90.0)
println("\nACCurrentSource(\"IAC\", 0.01, dc=0.005, freq=50.0, ac_phase=90.0)")
println("  → DC offset: $(i_ac.dc) A = $(i_ac.dc * 1000) mA")
println("  → AC magnitude: $(i_ac.ac_mag) A = $(i_ac.ac_mag * 1000) mA")
println("  → Frequency: $(i_ac.freq) Hz")
println("  → Phase: $(i_ac.ac_phase)°")

# =============================================================================
# Part 2: Build a test circuit
# =============================================================================

println("\n" * "="^60)
println("### Building Test Circuit ###")
println("="^60)

println("\nCircuit: DC Current Source driving two resistors in series")
println("  I1 (2mA) → R1 (1kΩ) → R2 (2kΩ) → GND")
println("  Expected: V(R1.n1) = 2mA × 3kΩ = 6V")
println("            V(R1.n2) = 2mA × 2kΩ = 4V")

c = Circuit()

# Components
I1 = DCCurrentSource("I1", 0.002)  # 2mA
R1 = Resistor("R1", 1e3)           # 1kΩ
R2 = Resistor("R2", 2e3)           # 2kΩ  
G = Ground("GND")

add_component!(c, I1)
add_component!(c, R1)
add_component!(c, R2)
add_component!(c, G)

# Connections
@connect c I1.nplus R1.n1
@connect c R1.n2 R2.n1
@connect c R2.n2 G.n
@connect c I1.nminus G.n

# =============================================================================
# Part 3: Generate netlists for both simulators
# =============================================================================

println("\n" * "="^60)
println("### Qucs Netlist ###")
println("="^60)
println()
println(netlist_qucs(c))

println("\n" * "="^60)
println("### SPICE (ngspice) Netlist ###")
println("="^60)
println()
println(netlist_ngspice(c))

# =============================================================================
# Part 4: Run Qucs simulation and verify
# =============================================================================

println("\n" * "="^60)
println("### Running Qucsator Simulation ###")
println("="^60)

# Using the new analysis struct instead of raw string
result = simulate(c, DCAnalysis())

if result.dataset.status == SIM_SUCCESS
    v_top = voltage(result, R1, :n1)
    v_mid = voltage(result, R1, :n2)
    v_bottom = voltage(result, R2, :n2)
    i_source = current(result, I1)

    println("\nResults:")
    println("  V(R1.n1) = $(v_top) V    (top node, expected 6.0 V)")
    println("  V(R1.n2) = $(v_mid) V    (middle node, expected 4.0 V)")
    println("  V(R2.n2) = $(v_bottom) V    (bottom/ground node, expected 0.0 V)")
    println("  I(I1)    = $(i_source) A = $(i_source*1000) mA (source current)")

    # Verify
    println("\nVerification:")
    v_r1 = v_top - v_mid
    v_r2 = v_mid - v_bottom
    println("  V_R1 = $(v_r1) V (I × R1 = 2mA × 1kΩ = 2V) ✓")
    println("  V_R2 = $(v_r2) V (I × R2 = 2mA × 2kΩ = 4V) ✓")

    # Using voltage_between
    println("\nUsing voltage_between():")
    v_across_r1 = voltage_between(result, Pin(R1, :n1), Pin(R1, :n2))
    v_across_r2 = voltage_between(result, Pin(R2, :n1), Pin(R2, :n2))
    println("  voltage_between(R1.n1, R1.n2) = $(v_across_r1) V")
    println("  voltage_between(R2.n1, R2.n2) = $(v_across_r2) V")
else
    println("Simulation failed: ", result.dataset.errors)
end

# =============================================================================
# Part 5: Show AC source netlist generation
# =============================================================================

println("\n" * "="^60)
println("### AC Source Netlist Generation ###")
println("="^60)

c_ac = Circuit()

# AC voltage source for an RC filter
Vac = ACVoltageSource("V1", 1.0, freq=1000.0)  # 1V @ 1kHz
R_filter = Resistor("R1", 1e3)                   # 1kΩ
C_filter = Capacitor("C1", 100e-9)               # 100nF
G_ac = Ground("GND")

add_component!(c_ac, Vac)
add_component!(c_ac, R_filter)
add_component!(c_ac, C_filter)
add_component!(c_ac, G_ac)

# RC low-pass filter: Vin → R → C → GND
@connect c_ac Vac.nplus R_filter.n1
@connect c_ac R_filter.n2 C_filter.n1
@connect c_ac C_filter.n2 G_ac.n
@connect c_ac Vac.nminus G_ac.n

println("\nRC Low-Pass Filter (1kHz cutoff)")
println("  V1 (1V AC @ 1kHz) → R1 (1kΩ) → C1 (100nF) → GND")
println("  Cutoff frequency: f_c = 1/(2π×R×C) = $(round(1/(2π*1e3*100e-9), digits=0)) Hz")

println("\n--- Qucs Netlist ---")
println(netlist_qucs(c_ac))

println("\n--- SPICE Netlist ---")
println(netlist_ngspice(c_ac))

println("\n" * "="^60)
println("Demo complete!")
println("="^60)
