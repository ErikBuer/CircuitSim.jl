# Externally Controlled Voltage Source

A two-terminal source with externally controlled output voltage (`ECVS`).

## Example

```@example ecvs
using CircuitSim

src = ExternallyControlledVoltageSource("E1", u=1.2, interpolator="linear", tnext=1e-6)
rload = Resistor("R1", resistance=50.0)
gnd = Ground("GND")

circ = Circuit()
add_component!(circ, src)
add_component!(circ, rload)
add_component!(circ, gnd)

@connect circ src.n1 rload.n1
@connect circ src.n2 gnd
@connect circ rload.n2 gnd

analysis = TransientAnalysis(stop=1e-6, points=50)
result = simulate_qucsator(circ, analysis)

v_out = get_pin_voltage(result, rload, :n1)
println("ECVS final voltage: ", round(v_out[end], digits=3), " V")
```
