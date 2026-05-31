# Coplanar Open

```@example copen
using CircuitSim

circ = Circuit()

sub = Substrate("Sub1", er=3.48, h=0.508e-3, t=35e-6)
port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
copen = CoplanarOpen("COPEN1", substrate="Sub1", w=1.2e-3, s=0.2e-3, g=5.0e-3, backside="Metal")
gnd = Ground("GND")

add_component!(circ, sub)
add_component!(circ, port1)
add_component!(circ, copen)
add_component!(circ, gnd)

@connect circ port1.nplus copen.n1
@connect circ port1.nminus gnd

sp_analysis = SParameterAnalysis(start=1e9, stop=10e9, points=21, z0=50.0)
result = simulate_qucsator(circ, sp_analysis)

freq = result.frequencies_Hz
s11 = result.s_matrix[(1,1)]
println("CoplanarOpen S11 at ", freq[1] / 1e9, " GHz: ", round(abs(s11[1]), digits=3))
```
