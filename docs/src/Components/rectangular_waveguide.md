# Rectangular Waveguide

```@example rectwg
using CircuitSim

circ = Circuit()

port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
port2 = ACPowerSource("P2", port_num=2, impedance=50.0)
wg = RectangularWaveguide("WG1", a=2.86e-2, b=1.016e-2, length_m=100e-3)
gnd = Ground("GND")

add_component!(circ, port1)
add_component!(circ, port2)
add_component!(circ, wg)
add_component!(circ, gnd)

@connect circ port1.nplus wg.n1
@connect circ wg.n2 port2.nplus
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd

sp_analysis = SParameterAnalysis(start=8e9, stop=12e9, points=21, z0=50.0)
result = simulate_qucsator(circ, sp_analysis)

freq = result.frequencies_Hz
s21 = result.s_matrix[(2,1)]
println("RectangularWaveguide S21 at ", freq[1] / 1e9, " GHz: ", round(abs(s21[1]), digits=3))
```
