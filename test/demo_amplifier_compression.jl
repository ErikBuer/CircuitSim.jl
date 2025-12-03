"""
Amplifier Compression Demo

Demonstrates driving an amplifier 2 dB above its 1 dB compression point
using harmonic balance analysis to observe harmonic generation.
"""

using CircuitTypes

println("="^70)
println("Amplifier Compression Analysis Demo")
println("="^70)

# Create circuit
println("\nBuilding circuit...")
circ = Circuit()

# Ground reference
gnd = Ground("GND")
add_component!(circ, gnd)

# RF Amplifier: 20 dB gain, 3 dB NF, P1dB = +15 dBm
amp = Amplifier("AMP1", 20.0, 3.0, p1db=15.0, z_in=50.0, z_out=50.0)
add_component!(circ, amp)

# Calculate operating point
p1db_input = amp.p1db - amp.gain
input_power = p1db_input + 2.0  # 2 dB above compression

println("\nAmplifier Configuration:")
println("  Gain: $(amp.gain) dB")
println("  Noise Figure: $(amp.nf) dB")
println("  P1dB (output): $(amp.p1db) dBm")
println("  P1dB (input): $(p1db_input) dBm")
println("  Drive level: $(input_power) dBm (2 dB above P1dB)")

# Input source at 2.4 GHz, driven 2 dB above P1dB
p_in = PowerSource("P1", 1, z0=50.0, power=input_power, freq=2.4e9)
add_component!(circ, p_in)

# DC blocking capacitor at input
dcb_in = DCBlock("DCB_IN", 100e-9)  # 100nF
add_component!(circ, dcb_in)

# DC blocking capacitor at output
dcb_out = DCBlock("DCB_OUT", 100e-9)  # 100nF
add_component!(circ, dcb_out)

# Output port/load
p_out = PowerSource("P2", 2, z0=50.0, power=0.0, freq=2.4e9)
add_component!(circ, p_out)

# Connections
@connect circ p_in.nplus dcb_in.n1
@connect circ dcb_in.n2 amp.n1
@connect circ amp.n2 dcb_out.n1
@connect circ dcb_out.n2 p_out.nplus
@connect circ p_in.nminus gnd.n
@connect circ p_out.nminus gnd.n

println("\nCircuit built with $(length(circ.components)) components")

# Define harmonic balance analysis
hb_analysis = HarmonicBalanceAnalysis(2.4e9, harmonics=5)

println("\n" * "─"^70)
println("Harmonic Balance Analysis:")
println("─"^70)
println("  Fundamental: $(hb_analysis.frequency / 1e9) GHz")
println("  Harmonics: $(hb_analysis.harmonics)")
println("  Maximum frequency: $(hb_analysis.frequency * hb_analysis.harmonics / 1e9) GHz")

# Generate netlist
println("\n" * "─"^70)
println("Generating Qucs netlist...")
assign_nodes!(circ)
netlist = netlist_qucs(circ)

println("\nCircuit Netlist:")
println(netlist)

println("\nAnalysis Directive:")
println(to_qucs_analysis(hb_analysis))

# Expected harmonic content
println("\n" * "─"^70)
println("Expected Harmonic Content at Output:")
println("─"^70)

expected_linear_output = input_power + amp.gain
compression_db = 3.0  # Typical for 2 dB above P1dB
actual_output = expected_linear_output - compression_db

println("\nOperating Point:")
println("  Input power: $(input_power) dBm")
println("  Expected linear output: $(expected_linear_output) dBm")
println("  Actual output (compressed): ~$(actual_output) dBm")
println("  Compression: ~$(compression_db) dB")

println("\nHarmonic Spectrum (typical values):")
println("  H1 (2.4 GHz):  ~14.0 dBm  (fundamental)")
println("  H2 (4.8 GHz):  ~-15.0 dBm (2nd harmonic)")
println("  H3 (7.2 GHz):  ~-8.0 dBm  (3rd harmonic)")
println("  H4 (9.6 GHz):  ~-25.0 dBm (4th harmonic)")
println("  H5 (12.0 GHz): ~-18.0 dBm (5th harmonic)")

println("\n" * "="^70)
println("To simulate: result = simulate_qucsator(circ, hb_analysis, backend=:qucsator)")
println("="^70)
