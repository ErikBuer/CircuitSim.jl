"""
Test file-based voltage and current sources.
"""

using CircuitSim

println("\n=== Testing File-Based Sources ===\n")

println("1. Testing FileVoltageSource with vectors")
time_vec = [0.0, 1e-9, 2e-9, 3e-9, 4e-9]
voltage_vec = [0.0, 1.0, 1.0, 0.5, 0.0]

V1 = FileVoltageSource("V1", time_vec, voltage_vec)
println("   Created: $(V1.name)")
println("   Data points: $(length(V1.time_vector))")
println("   Interpolator: $(V1.interpolator)")

println("\n2. Testing FileCurrentSource with vectors")
current_vec = [0.0, 0.001, 0.002, 0.001, 0.0]
I1 = FileCurrentSource("I1", time_vec, current_vec, interpolator="cubic", repeat=true)
println("   Created: $(I1.name)")
println("   Data points: $(length(I1.current_vector))")
println("   Interpolator: $(I1.interpolator)")
println("   Repeat: $(I1.repeat)")

println("\n3. Testing netlist generation (vector mode)")
R1 = Resistor("R1", 50.0)
GND = Ground("GND")
circ = Circuit()
add_component!(circ, V1)
add_component!(circ, I1)
add_component!(circ, R1)
add_component!(circ, GND)

connect!(circ, pin(V1, :nplus), pin(R1, :n1))
connect!(circ, pin(R1, :n2), pin(I1, :nplus))
connect!(circ, pin(I1, :nminus), pin(GND, :node))
connect!(circ, pin(V1, :nminus), pin(GND, :node))

assign_nodes!(circ)
netlist = netlist_qucs(circ)
println(netlist)

println("\n4. Checking that data files were created")
if isfile("V1_data.dat")
    println("   ✓ V1_data.dat created")
    content = read("V1_data.dat", String)
    println("   File preview:")
    for (i, line) in enumerate(split(content, '\n')[1:8])
        println("      ", line)
    end
else
    println("   ✗ V1_data.dat not found")
end

if isfile("I1_data.dat")
    println("   ✓ I1_data.dat created")
else
    println("   ✗ I1_data.dat not found")
end

println("\n5. Testing FileVoltageSource with external file")
V2 = FileVoltageSource("V2", "V1_data.dat", interpolator="linear", gain=2.0)
println("   Created: $(V2.name)")
println("   File: $(V2.file)")
println("   Gain: $(V2.gain)")

println("\n6. Testing FileCurrentSource with external file")
I2 = FileCurrentSource("I2", "I1_data.dat", delay=1e-9)
println("   Created: $(I2.name)")
println("   File: $(I2.file)")
println("   Delay: $(I2.delay)")

println("\n7. Testing netlist for file-based sources")
println("   V2 netlist: ", to_qucs_netlist(V2))
println("   I2 netlist: ", to_qucs_netlist(I2))

println("\n=== File-Based Sources Tests Complete ===\n")

# Cleanup
rm("V1_data.dat", force=true)
rm("I1_data.dat", force=true)
println("Temporary files cleaned up.")
