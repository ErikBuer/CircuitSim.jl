using CircuitSim
#using GLMakie

circ = Circuit()

# Components
port1 = ACPowerSource("P1", 1, impedance=50.0)

path = joinpath(@__DIR__, "test_files", "70 mm L1 L5 Single feed.s1p")
println(path)

# Load S-parameters from file (1-port antenna)
spf = SPfile("ANT1", path, data_format="rectangular", interpolator="linear")

gnd = Ground("GND")

add_component!(circ, port1)
add_component!(circ, spf)
add_component!(circ, gnd)

# Connect 1-port S-parameter file
# SPfile has 2 nodes for 1-port: port node (n1) and ground reference (ref)
@connect circ port1.nplus spf.n1
@connect circ port1.nminus gnd
@connect circ spf.ref gnd

sparam = SParameterAnalysis(1e9, 2e9, 601,
    sweep_type=LINEAR,
    z0=50.0
)

#sp_result = simulate_qucsator(circ, sparam)
success, output, netlist = run_qucsator(circ, sparam)

println("Generated netlist:")
println(netlist)
println("\nSuccess: ", success)
println("Output: ", output)
