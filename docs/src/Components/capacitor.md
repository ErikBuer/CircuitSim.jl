# Capacitor

```@example capacitor
using CircuitSim
using GLMakie

P1 = ACPowerSource("P1", port_num=1, impedance=50.0)
P2 = ACPowerSource("P2", port_num=2, impedance=50.0)
C = Capacitor("C1", capacitance=1e-9)

circ = Circuit()
add_component!(circ, P1)
add_component!(circ, P2)
add_component!(circ, C)

@connect circ P1.nplus C.n1
@connect circ C.n2 P2.nplus
@connect circ P1.nminus P2.nminus

sp = simulate_qucsator(circ, SParameterAnalysis(1e6, 10e9, 100))

freq_GHz = sp.frequencies_Hz ./ 1e9
s11_db = 20 * log10.(abs.(sp.s_matrix[(1,1)]))
s21_db = 20 * log10.(abs.(sp.s_matrix[(2,1)]))

fig = Figure(size=(800, 500))
ax = Axis(fig[1, 1], xlabel="Frequency (GHz)", ylabel="Magnitude (dB)",
          title="1 nF Capacitor S-Parameters")
lines!(ax, freq_GHz, s11_db, label="S₁₁ (Reflection)")
lines!(ax, freq_GHz, s21_db, label="S₂₁ (Transmission)")
axislegend(ax, position=:lb)
fig
```
