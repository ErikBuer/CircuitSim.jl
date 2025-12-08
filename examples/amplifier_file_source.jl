"""
Complete example: Amplifier circuit with FileVoltageSource

Demonstrates:
- Creating time-domain waveform input
- Using FileVoltageSource with automatic CSV file generation
- Running transient analysis with qucsator backend
- Extracting and analyzing results
- Plotting input vs output voltages
"""

using CircuitTypes
using Printf

println("="^70)
println("AMPLIFIER TRANSIENT SIMULATION EXAMPLE")
println("="^70)

# Create 1 GHz sine wave input signal (10 ns total)
t_points = 50
t = range(0, stop=10e-9, length=t_points)
time_vec = collect(t)
voltage_vec = [0.1 * sin(2π * 1e9 * ti) for ti in time_vec]  # 100 mV peak

println("\nInput Signal:")
println("  Frequency: 1 GHz")
println("  Amplitude: 100 mV peak")
println("  Duration: 10 ns")
println("  Sample points: $t_points")

# Build amplifier circuit
# FileVoltageSource automatically creates CSV data file
V_in = FileVoltageSource("V_in", time_vec, voltage_vec)
Amp = Amplifier("Amp", 10.0, 2.0)  # 10x linear gain (20 dB), 3 dB NF
R_load = Resistor("R_load", 50.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, V_in)
add_component!(circ, Amp)
add_component!(circ, R_load)
add_component!(circ, GND)

# Circuit topology: V_in -> Amplifier -> R_load (with ground return)
@connect circ V_in.nplus Amp.n1
@connect circ Amp.n2 R_load.n1
@connect circ R_load.n2 GND.node
@connect circ V_in.nminus GND.node

println("\nCircuit Configuration:")
println("  V_in (FileVoltageSource) -> Amplifier (10x) -> R_load (50Ω) -> GND")

# Run transient simulation with 100 time points
tran = TransientAnalysis(10e-9, start=0.0, points=100)
println("\nRunning transient simulation with qucsator...")
result = simulate_qucsator(circ, tran)

println("\nSimulation completed successfully!")
println("  Time points: ", length(result.time_s))
println("  Voltage nodes: ", join(sort(collect(keys(result.voltages))), ", "))
println("  Current branches: ", join(sort(collect(keys(result.currents))), ", "))

# Extract voltages
v_amp_out = result.voltages["_net1"]  # Amplifier output node (Amp.n2)
v_gnd = result.voltages["_net2"]      # Ground reference
v_amp_in = result.voltages["_net3"]   # Amplifier input node (Amp.n1)
i_source = result.currents["V_in"]    # Source current
time_ns = result.time_s .* 1e9        # Convert to nanoseconds

# Calculate statistics
v_in_peak = maximum(abs.(v_amp_in)) * 1e3  # mV
v_out_peak = maximum(abs.(v_amp_out)) * 1e3  # mV
measured_gain = maximum(abs.(v_amp_out)) / maximum(abs.(v_amp_in))
i_peak = maximum(abs.(i_source)) * 1e3  # mA

println("\nResults:")
println("  Input voltage (peak): ", round(v_in_peak, digits=2), " mV")
println("  Output voltage (peak): ", round(v_out_peak, digits=2), " mV")
println("  Measured gain: ", round(measured_gain, digits=2), "x")
println("  Source current (peak): ", round(i_peak, digits=3), " mA")

# Display sample data
println("\nSample Data (first 10 points):")
println("  Time (ns) | V_in (mV) | V_out (mV) | I_src (mA)")
println("  " * "-"^52)
for i in 1:min(10, length(time_ns))
    @printf("  %8.3f  | %9.3f | %10.3f | %10.4f\n",
        time_ns[i], v_amp_in[i] * 1e3, v_amp_out[i] * 1e3, i_source[i] * 1e3)
end

# Save results to CSV for external plotting
output_file = "/tmp/amplifier_results.csv"
open(output_file, "w") do io
    println(io, "time_ns,v_input_mV,v_output_mV,i_source_mA")
    for i in 1:length(time_ns)
        println(io, "$(time_ns[i]),$(v_amp_in[i]*1e3),$(v_amp_out[i]*1e3),$(i_source[i]*1e3)")
    end
end
println("\nResults saved to: ", output_file)
println("  Format: CSV with columns [time_ns, v_input_mV, v_output_mV, i_source_mA]")

# Plot using Unicode characters (basic text plot)
println("\nInput vs Output Voltage (Text Plot):")
println("  " * "="^60)

# Normalize for text plotting (20 character height)
plot_height = 15
v_max = max(maximum(abs.(v_amp_in)), maximum(abs.(v_amp_out))) * 1e3
plot_points = min(60, length(time_ns))  # Width of plot

for row in plot_height:-1:(-plot_height)
    line = "  "
    v_level = (row / plot_height) * v_max

    for col in 1:plot_points
        idx = round(Int, 1 + (col - 1) * (length(time_ns) - 1) / (plot_points - 1))
        v_in = v_amp_in[idx] * 1e3
        v_out = v_amp_out[idx] * 1e3

        # Determine character to plot
        char = " "
        if abs(v_in - v_level) < v_max / plot_height
            char = "▪"  # Input marker
        elseif abs(v_out - v_level) < v_max / plot_height
            char = "•"  # Output marker
        elseif abs(v_level) < v_max / plot_height
            char = "─"  # Zero line
        end
        line *= char
    end

    # Add axis label
    if row == plot_height
        line *= @sprintf("  %.1f mV", v_max)
    elseif row == 0
        line *= "    0 mV"
    elseif row == -plot_height
        line *= @sprintf(" %.1f mV", -v_max)
    end

    println(line)
end
println("  " * "─"^60)
println("  0 ns" * " "^52 * "10 ns")
println("  Legend: ▪ = input, • = output")

println("\n" * "="^70)
println("EXAMPLE COMPLETE")
println("="^70)
println("\nKey Takeaways:")
println("  ✓ FileVoltageSource simplifies time-domain waveform input")
println("  ✓ Automatically handles CSV file generation and cleanup")
println("  ✓ Transient analysis extracts voltage and current vs time")
println("  ✓ Results available as Julia arrays for analysis/plotting")
