# Mutual Inductor

Two coupled inductors with mutual inductance defined by coupling coefficient k.

Transformer using coupled inductors.

```@example mutual
using CircuitSim

circ = Circuit()

# Components
vin = ACVoltageSource("Vin", 1.0, freq=1e6)
r_in = Resistor("Rin", 50.0)
mutual = MutualInductor("MUT1", l1=1e-6, l2=1e-6, k=0.9)
rload = Resistor("Rload", 50.0)
gnd = Ground("GND")

add_component!(circ, vin)
add_component!(circ, r_in)
add_component!(circ, mutual)
add_component!(circ, rload)
add_component!(circ, gnd)

# Connect primary circuit
@connect circ vin.nplus r_in.n1
@connect circ r_in.n2 mutual.n1
@connect circ mutual.n2 gnd
@connect circ vin.nminus gnd

# Connect secondary circuit
@connect circ mutual.n3 rload.n1
@connect circ mutual.n4 rload.n2
@connect circ rload.n2 gnd

assign_nodes!(circ)

# AC analysis
ac_analysis = ACAnalysis(1e6, 1e7, 11)
result = simulate_qucsator(circ, ac_analysis)

freq = result.frequencies_Hz
v_out = get_pin_voltage(result, rload, :n1)
println("Mutual inductor coupling at ", freq[1]/1e6, " MHz: ", round(abs(v_out[1]), digits=4), " V")
```
