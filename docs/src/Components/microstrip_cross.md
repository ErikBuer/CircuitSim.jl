# Microstrip Cross Junction

Microstrip cross-junction for connecting four transmission lines.

## Parameters

- `w1`: Port 1 width in meters, default: 1e-3
- `w2`: Port 2 width in meters, default: 2e-3
- `w3`: Port 3 width in meters, default: 1e-3
- `w4`: Port 4 width in meters, default: 2e-3
- `substrate`: Substrate reference name, default: "Subst1"
- `disp_model`: Dispersion model, default: "Kirschning"
- `model`: Microstrip model, default: "Hammerstad"

## Example

```@example mcross
using CircuitSim

circ = Circuit()

# Substrate definition
sub = Substrate("Sub1", er=4.5, h=1.6e-3, t=35e-6)
add_component!(circ, sub)

# Components
port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
port2 = ACPowerSource("P2", port_num=2, impedance=50.0)
port3 = ACPowerSource("P3", port_num=3, impedance=50.0)
port4 = ACPowerSource("P4", port_num=4, impedance=50.0)
cross = MicrostripCross("MX1", substrate="Sub1", w1=1.5e-3, w2=1.5e-3, w3=1.5e-3, w4=1.5e-3)
gnd = Ground("GND")

add_component!(circ, port1)
add_component!(circ, port2)
add_component!(circ, port3)
add_component!(circ, port4)
add_component!(circ, cross)
add_component!(circ, gnd)

# Connect 4-port cross junction
@connect circ port1.nplus cross.n1
@connect circ port2.nplus cross.n2
@connect circ port3.nplus cross.n3
@connect circ port4.nplus cross.n4
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd
@connect circ port3.nminus gnd
@connect circ port4.nminus gnd

# S-parameter analysis
sp_analysis = SParameterAnalysis(start=1e9, stop=10e9, points=20, z0=50.0)
result = simulate_qucsator(circ, sp_analysis)

freq = result.frequencies_Hz
s21 = result.s_matrix[(2,1)]
println("Cross S21 at ", freq[1]/1e9, " GHz: ", round(abs(s21[1]), digits=3))
```
