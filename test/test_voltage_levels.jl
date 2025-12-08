using CircuitSim

# Create AC analysis circuit with voltage source and resistive load
circ = Circuit()

# AC voltage source at input (1V magnitude)
v_source = ACVoltageSource("Vin", 1.0)
add_component!(circ, v_source)

# Output load
r_load = Resistor("Rload", 50.0)
add_component!(circ, r_load)

# Filter components
L1 = Inductor("L1", 80e-9)    # 80 nH
C1 = Capacitor("C1", 32e-12)  # 32 pF  
C2 = Capacitor("C2", 32e-12)  # 32 pF
add_component!(circ, L1)
add_component!(circ, C1)
add_component!(circ, C2)

# Ground
gnd = Ground("GND")
add_component!(circ, gnd)

# Voltage probes
v_in_probe = VoltageProbe("Vin_probe")
v_out_probe = VoltageProbe("Vout_probe")
add_component!(circ, v_in_probe)
add_component!(circ, v_out_probe)

# Connections
@connect circ v_source.nplus C1.n1
@connect circ C1.n2 gnd
@connect circ v_source.nplus L1.n1
@connect circ L1.n2 C2.n1
@connect circ C2.n1 r_load.n1
@connect circ C2.n2 gnd
@connect circ r_load.n2 gnd
@connect circ v_source.nminus gnd

# Connect probes
@connect circ v_source.nplus v_in_probe.n1
@connect circ gnd v_in_probe.n2
@connect circ r_load.n1 v_out_probe.n1
@connect circ gnd v_out_probe.n2

# Run AC analysis
ac_analysis = ACAnalysis(1e6, 1e9, 11, sweep_type=LOGARITHMIC)
ac_result = simulate_qucsator(circ, ac_analysis)

println("=== Voltage Levels ===")
for i in [1, 6, 11]  # First, middle, last
    freq_mhz = ac_result.frequencies_Hz[i] / 1e6
    v_in_mag = abs(ac_result.voltages["Vin_probe"][i])
    v_out_mag = abs(ac_result.voltages["Vout_probe"][i])
    v_in_db = 20 * log10(v_in_mag)
    v_out_db = 20 * log10(v_out_mag)

    println("@ $(round(freq_mhz, digits=1)) MHz:")
    println("  Vin: $(round(v_in_mag, digits=4)) V = $(round(v_in_db, digits=2)) dB")
    println("  Vout: $(round(v_out_mag, digits=4)) V = $(round(v_out_db, digits=2)) dB")
    println("  Attenuation: $(round(v_in_db - v_out_db, digits=2)) dB")
    println()
end
