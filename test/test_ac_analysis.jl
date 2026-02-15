@testset "test AC Analysis" begin
    # Create a new circuit for AC analysis (can't mix ACPowerSource with ACVoltageSource)
    circ_ac = Circuit()

    # AC voltage source at input
    v_source = ACVoltageSource("Vin", ac_magnitude=1.0)  # 1V AC source
    add_component!(circ_ac, v_source)

    # Output load resistor
    r_load = Resistor("Rload", resistance=50.0)  # 50Ω load
    add_component!(circ_ac, r_load)

    # Same filter components
    L1_ac = Inductor("L1", inductance=80e-9)
    C1_ac = Capacitor("C1", capacitance=32e-12)
    C2_ac = Capacitor("C2", capacitance=32e-12)
    add_component!(circ_ac, L1_ac)
    add_component!(circ_ac, C1_ac)
    add_component!(circ_ac, C2_ac)

    # Ground
    gnd_ac = Ground("GND")
    add_component!(circ_ac, gnd_ac)

    # Voltage probes
    v_in_probe = VoltageProbe("Vin_probe")
    v_out_probe = VoltageProbe("Vout_probe")
    add_component!(circ_ac, v_in_probe)
    add_component!(circ_ac, v_out_probe)

    # Connect filter: Vsource -> C1||L1 -> C2||Rload
    @connect circ_ac v_source.nplus C1_ac.n1
    @connect circ_ac C1_ac.n2 gnd_ac.n
    @connect circ_ac v_source.nplus L1_ac.n1
    @connect circ_ac L1_ac.n2 C2_ac.n1
    @connect circ_ac C2_ac.n1 r_load.n1
    @connect circ_ac C2_ac.n2 gnd_ac.n
    @connect circ_ac r_load.n2 gnd_ac.n
    @connect circ_ac v_source.nminus gnd_ac.n

    # Connect probes
    @connect circ_ac v_source.nplus v_in_probe.n1
    @connect circ_ac gnd_ac.n v_in_probe.n2
    @connect circ_ac r_load.n1 v_out_probe.n1
    @connect circ_ac gnd_ac.n v_out_probe.n2

    # AC analysis from 1 MHz to 1 GHz
    ac_analysis = ACAnalysis(start=1e6, stop=1e9, points=201, sweep_type="linear")
    ac_result = simulate_qucsator(circ_ac, ac_analysis)


    # Get frequency vector
    freq_ac_mhz = ac_result.frequencies_Hz ./ 1e6

    # Get voltages from probes (already complex vectors)
    v_in = ac_result.voltages["Vin_probe"]
    v_out = ac_result.voltages["Vout_probe"]

    # Convert to dB (magnitude)
    v_in_db = 20 .* log10.(abs.(v_in))
    v_out_db = 20 .* log10.(abs.(v_out))

    fig2 = Figure(size=(900, 600), fontsize=14)

    ax2 = Axis(fig2[1, 1],
        xlabel="Frequency [MHz]",
        ylabel="Voltage Magnitude [dB]",
        title="AC Voltage Response",
    )

    lines!(ax2, freq_ac_mhz, v_in_db, label="Input Voltage", linewidth=2)
    lines!(ax2, freq_ac_mhz, v_out_db, label="Output Voltage", linewidth=2)

    xlims!(ax2, 0, 1000)
    axislegend(ax2, position=:lb)

    save("output/ac_analysis_response.png", fig2)
end