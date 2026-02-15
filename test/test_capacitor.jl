using CircuitSim
using GLMakie

P1 = ACPowerSource("P1", port_num=1, impedance=50.0)
P2 = ACPowerSource("P2", port_num=2, impedance=50.0)
C = Capacitor("C1", capacitance=1e-9)

circ = Circuit()
add_component!(circ, P1)
add_component!(circ, P2)
add_component!(circ, C)

# Ground
gnd = Ground("GND")
add_component!(circ, gnd)

@connect circ P1.nplus C.n1
@connect circ C.n2 P2.nplus
@connect circ P1.nminus gnd
@connect circ P2.nminus gnd

sp_result = simulate_qucsator(circ, SParameterAnalysis(1e6, 100e6, 101; sweep_type=LINEAR))

freq_GHz = sp_result.frequencies_Hz ./ 1e9

# Get S-parameters at first frequency point
s11 = sp_result.s_matrix[(1, 1)]
s21 = sp_result.s_matrix[(2, 1)]
s12 = sp_result.s_matrix[(1, 2)]
s22 = sp_result.s_matrix[(2, 2)]

s11_dB = 20 * log10.(abs.(s11))
s21_dB = 20 * log10.(abs.(s21))
s12_dB = 20 * log10.(abs.(s12))
s22_dB = 20 * log10.(abs.(s22))

fig = Figure(size=(800, 500))
ax = Axis(fig[1, 1], xlabel="Frequency (GHz)", ylabel="Magnitude (dB)",
    title="1 nF Capacitor S-Parameters")
lines!(ax, freq_GHz, s11_dB, label="S₁₁ (Reflection)")
lines!(ax, freq_GHz, s21_dB, label="S₂₁ (Transmission)")
axislegend(ax, position=:lb)
fig
save("output/capacitor_sparams.png", fig)