"""
Example: RF Transmitter Chain with Power Amplifier

This demonstrates a complete RF transmitter front-end:
- Signal source
- Driver amplifier
- Bias tee for PA biasing
- Power amplifier
- Directional coupler for power monitoring
- Isolator for load protection
- Attenuator for testing
"""

using CircuitTypes

println("="^70)
println("RF Transmitter Chain Example")
println("="^70)

# Create circuit
circuit = Circuit()

# Ground reference
gnd = Ground("GND")

# Input signal source (Port 1)
p1 = PowerSource("P1", 1, power=-10.0)  # -10 dBm input

# Driver amplifier (moderate gain, low NF)
driver = Amplifier("DRIVER", 15.0, 3.0)  # 15dB gain

# DC block between stages
dcb1 = DCBlock("DCB1")

# Bias tee for power amplifier
bias_tee = BiasTee("BIAS")

# Power amplifier (high gain, higher NF, specified P1dB)
pa = Amplifier("PA", 25.0, 6.0, p1db=40.0)  # 25dB gain, +40dBm P1dB

# 20dB directional coupler for power monitoring
coupler = Coupler("MONITOR", 20.0)  # -20dB tap to monitoring port

# Monitoring port (Port 3)
p3 = PowerSource("P3", 3)  # Power monitor

# Isolator for load protection
isolator = Isolator("ISO", reverse_loss=25.0)

# Optional test attenuator
test_att = Attenuator("TEST_ATT", 0.0)  # 0dB = bypass for normal operation

# Load termination (Port 2)
p2 = PowerSource("P2", 2)  # Output to antenna

# Add all components
for comp in [gnd, p1, driver, dcb1, bias_tee, pa, coupler, p3, isolator, test_att, p2]
    add_component!(circuit, comp)
end

# Build the signal chain
# P1 -> Driver -> DCB -> Bias Tee (RF) -> PA -> Coupler (in) -> Isolator -> Test Att -> P2
#                                 |                    |
#                              DC bias           Monitor (P3)

connect!(circuit, pin(p1, :nplus), pin(driver, :n1))
connect!(circuit, pin(driver, :n2), pin(dcb1, :n1))
connect!(circuit, pin(dcb1, :n2), pin(bias_tee, :rf))
connect!(circuit, pin(bias_tee, :output), pin(pa, :n1))
connect!(circuit, pin(pa, :n2), pin(coupler, :input))
connect!(circuit, pin(coupler, :through), pin(isolator, :n1))
connect!(circuit, pin(isolator, :n2), pin(test_att, :n1))
connect!(circuit, pin(test_att, :n2), pin(p2, :nplus))

# Monitoring port connection
connect!(circuit, pin(coupler, :coupled), pin(p3, :nplus))

# Ground connections
connect!(circuit, pin(p1, :nminus), pin(gnd, :node))
connect!(circuit, pin(p2, :nminus), pin(gnd, :node))
connect!(circuit, pin(p3, :nminus), pin(gnd, :node))
connect!(circuit, pin(coupler, :isolated), pin(gnd, :node))

# Note: In real design, bias_tee DC port would connect to a voltage source
# For now, we'll leave it floating (would add DC source in complete design)

println("\n--- Signal Chain ---")
println("Input (-10 dBm) -> Driver (+15dB) -> DC Block -> Bias Tee ->")
println("  -> PA (+25dB) -> Coupler (-20dB tap) -> Isolator -> Test Att -> Output")
println("\nExpected output power (ideal): -10 + 15 + 25 = +30 dBm")
println("Monitor port sees: +30 - 20 = +10 dBm")

# Calculate expected gains
input_power = -10.0  # dBm
driver_gain = 15.0
pa_gain = 25.0
coupler_loss = 0.5  # insertion loss
iso_loss = 0.5  # isolator forward loss
total_gain = driver_gain + pa_gain - coupler_loss - iso_loss
expected_output = input_power + total_gain

monitor_coupling = -20.0
expected_monitor = expected_output + monitor_coupling + 20.0  # Relative to coupled port

println("\n--- Expected Performance (with component losses) ---")
println("Total gain: $(total_gain) dB")
println("Output power: $(expected_output) dBm")
println("Monitor power: ~$(round(expected_monitor, digits=1)) dBm")

# Assign nodes and generate netlist
assign_nodes!(circuit)

println("\n--- Qucs Netlist ---")
netlist = netlist_qucs(circuit)
println(netlist)

println("\n--- SPICE Netlist (excerpt) ---")
spice_netlist = netlist_ngspice(circuit)
lines = split(spice_netlist, '\n')
println(join(lines[1:min(30, length(lines))], '\n'))
if length(lines) > 30
    println("... ($(length(lines) - 30) more lines)")
end

println("\n" * "="^70)
println("To simulate this circuit, you would run:")
println("  analysis = SParameterAnalysis(start=500e6, stop=6e9, points=501)")
println("  result = simulate_qucsator(circuit, [analysis], backend=:qucsator)")
println("="^70)
