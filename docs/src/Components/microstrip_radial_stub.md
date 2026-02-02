# Microstrip Radial Stub

A microstrip radial (butterfly) stub for wideband impedance matching and filtering.

```@example mrstub
using CircuitSim

circ = Circuit()

# Substrate definition
sub = Substrate("Sub1", er=4.5, h=1.6e-3, t=35e-6)
add_component!(circ, sub)

# Components
port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
ms_line = MicrostripLine("MS1", sub, w=3.0e-3, l=10e-3)
rstub = MicrostripRadialStub("RS1", sub, ri=0.5e-3, ro=5.0e-3, wf=1.0e-3, alpha=60.0)
gnd = Ground("GND")

add_component!(circ, port1)
add_component!(circ, ms_line)
add_component!(circ, rstub)
add_component!(circ, gnd)

# Connect line with radial stub
@connect circ port1.nplus ms_line.n1
@connect circ ms_line.n2 rstub.n1
@connect circ port1.nminus gnd

# S-parameter analysis
sp_analysis = SParameterAnalysis(1e9, 10e9, 50, z0=50.0)
result = simulate_qucsator(circ, sp_analysis)

freq = result.frequencies_Hz
s11 = result.s_matrix[(1,1)]
println("Radial stub S11 at ", freq[1]/1e9, " GHz: ", round(20*log10(abs(s11[1])), digits=2), " dB")
```
