# Microstrip Radial Stub

A microstrip radial (butterfly) stub for wideband impedance matching and filtering.

## Parameters

- `ri`: Inner radius in meters, default: 1e-3
- `ro`: Outer radius in meters, default: 10e-3
- `wf`: Feedline width in meters, default: 1e-3
- `alpha`: Stub angle in degrees, default: 90.0 (range: 0 to 180)
- `substrate`: Substrate reference name, default: "Subst1"
- `eff_dimens`: Effective dimensions model, default: "OldQucsNoCorrection" (options: "OldQucsNoCorrection", "Chew_Kong", "Giannini")
- `model`: Analysis model, default: "OldQucsModel" (options: "OldQucsModel", "March", "Giannini")

## Example

```@example mrstub
using CircuitSim

circ = Circuit()

# Substrate definition
sub = Substrate("Sub1", er=4.5, h=1.6e-3, t=35e-6)
add_component!(circ, sub)

# Components
port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
ms_line = MicrostripLine("MS1", substrate="Sub1", w=3.0e-3, l=10e-3)
rstub = MicrostripRadialStub("RS1", substrate="Sub1", ri=1e-3, ro=10e-3, wf=1.0e-3, alpha=90.0)
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
sp_analysis = SParameterAnalysis(start=1e9, stop=10e9, points=50, z0=50.0)
result = simulate_qucsator(circ, sp_analysis)

freq = result.frequencies_Hz
s11 = result.s_matrix[(1,1)]
println("Radial stub S11 at ", freq[1]/1e9, " GHz: ", round(20*log10(abs(s11[1])), digits=2), " dB")
```
