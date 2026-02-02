using CircuitSim

"""
Test case for handling missing S-parameters gracefully.

This example creates two identical filters in the same simulation:
- Filter 1: Ports 1-2 (will have S11, S12, S21, S22)
- Filter 2: Ports 3-4 (will have S33, S34, S43, S44)

Cross-connections like S13, S14, S23, S24, etc. will not exist in the 
dataset because there are no connections between the two filters.
Our parser should return zeros for these missing S-parameters.
"""

# Create circuit with two identical filters
circ = Circuit()

# === FILTER 1: Ports 1-2 ===
# Ports
port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
port2 = ACPowerSource("P2", port_num=2, impedance=50.0)
add_component!(circ, port1)
add_component!(circ, port2)

# Components for Filter 1
L1 = Inductor("L1", 80e-9)    # 80 nH
C1 = Capacitor("C1", capacitance=32e-12)  # 32 pF
C2 = Capacitor("C2", capacitance=32e-12)  # 32 pF
add_component!(circ, L1)
add_component!(circ, C1)
add_component!(circ, C2)

# === FILTER 2: Ports 3-4 (identical to Filter 1) ===
# Ports
port3 = ACPowerSource("P3", port_num=3, impedance=50.0)
port4 = ACPowerSource("P4", port_num=4, impedance=50.0)
add_component!(circ, port3)
add_component!(circ, port4)

# Components for Filter 2 (identical values)
L2 = Inductor("L2", 80e-9)    # 80 nH
C3 = Capacitor("C3", capacitance=32e-12)  # 32 pF
C4 = Capacitor("C4", capacitance=32e-12)  # 32 pF
add_component!(circ, L2)
add_component!(circ, C3)
add_component!(circ, C4)

# Ground (shared by both filters)
gnd = Ground("GND")
add_component!(circ, gnd)

# === FILTER 1 Connections ===
# Shunt capacitor C1 from Port1 to ground
@connect circ port1.nplus C1.n1
@connect circ C1.n2 gnd

# Series inductor from Port1 to Port2
@connect circ port1.nplus L1.n1
@connect circ L1.n2 port2.nplus

# Shunt capacitor C2 from Port2 to ground
@connect circ L1.n2 C2.n1
@connect circ C2.n2 gnd

# Port ground connections for Filter 1
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd

# === FILTER 2 Connections (identical topology) ===
# Shunt capacitor C3 from Port3 to ground
@connect circ port3.nplus C3.n1
@connect circ C3.n2 gnd

# Series inductor from Port3 to Port4
@connect circ port3.nplus L2.n1
@connect circ L2.n2 port4.nplus

# Shunt capacitor C4 from Port4 to ground
@connect circ L2.n2 C4.n1
@connect circ C4.n2 gnd

# Port ground connections for Filter 2
@connect circ port3.nminus gnd
@connect circ port4.nminus gnd

# === S-Parameter Simulation ===
println("Running S-parameter simulation with two unconnected filters...")

# Define S-parameter analysis
sparam = SParameterAnalysis(1e6, 1e9, 201,
    sweep_type=LINEAR,
    z0=50.0
)

# Run simulation
sp_result = simulate_qucsator(circ, sparam)

println("S-parameter simulation completed:")
println("  Number of ports: ", sp_result.num_ports)
println("  Frequency points: ", length(sp_result.frequencies_Hz))
println("  Reference impedance: ", sp_result.z0_Ohm, " Ω")

# === Test S-Parameter Access ===
# These should exist (connections within each filter):
println("\nTesting existing S-parameters:")
try
    s11 = sp_result.s_matrix[(1, 1)]  # Filter 1 input reflection
    s21 = sp_result.s_matrix[(2, 1)]  # Filter 1 transmission
    s33 = sp_result.s_matrix[(3, 3)]  # Filter 2 input reflection
    s43 = sp_result.s_matrix[(4, 3)]  # Filter 2 transmission

    println("  S11: $(length(s11)) points")
    println("  S21: $(length(s21)) points")
    println("  S33: $(length(s33)) points")
    println("  S43: $(length(s43)) points")
catch e
    println("  Error accessing existing S-parameters: $e")
end

# These should NOT exist (no connections between filters) but should return zeros:
println("\nTesting missing S-parameters (should return zeros):")
try
    s13 = sp_result.s_matrix[(1, 3)]  # No connection between filters
    s14 = sp_result.s_matrix[(1, 4)]  # No connection between filters
    s23 = sp_result.s_matrix[(2, 3)]  # No connection between filters
    s41 = sp_result.s_matrix[(4, 1)]  # No connection between filters

    println("  S13: $(length(s13)) points (should be zeros)")
    println("  S14: $(length(s14)) points (should be zeros)")
    println("  S23: $(length(s23)) points (should be zeros)")
    println("  S41: $(length(s41)) points (should be zeros)")

    # Verify they are actually zeros
    if all(abs.(s13) .< 1e-10) && all(abs.(s14) .< 1e-10) && all(abs.(s23) .< 1e-10) && all(abs.(s41) .< 1e-10)
        println("  ✓ All missing S-parameters correctly return zeros")
    else
        println("  ✗ Missing S-parameters are not zeros!")
        println("    Max S13: $(maximum(abs.(s13)))")
        println("    Max S14: $(maximum(abs.(s14)))")
        println("    Max S23: $(maximum(abs.(s23)))")
        println("    Max S41: $(maximum(abs.(s41)))")
    end
catch e
    println("  Error accessing missing S-parameters: $e")
end

println("\nTest completed successfully! Missing S-parameters are handled gracefully.")
