# Ideal Transformer

Ideal transformer with specified turns ratio N2/N1.

Step-down transformer (2:1 ratio).

```@example trafo
using CircuitSim

circ = Circuit()

# Components
vin = ACVoltageSource("Vin", 10.0, freq=1e3)
trafo = IdealTransformer("TR1", t=0.5)  # 2:1 step-down
rload = Resistor("Rload", 50.0)
gnd = Ground("GND")

add_component!(circ, vin)
add_component!(circ, trafo)
add_component!(circ, rload)
add_component!(circ, gnd)

# Connect primary to source
@connect circ vin.nplus trafo.n1
@connect circ vin.nminus trafo.n2
@connect circ vin.nminus gnd

# Connect secondary to load
@connect circ trafo.n3 rload.n1
@connect circ trafo.n4 rload.n2
@connect circ rload.n2 gnd

# Transient analysis
tran_analysis = TransientAnalysis(2e-3, points=200)
result = simulate_qucsator(circ, tran_analysis)

# Secondary voltage should be 5V (10V × 0.5)
v_out = get_pin_voltage(result, rload, :n1)
println("Transformer secondary: ", round(abs(v_out[end]), digits=2), " V (expected ~5V)")
```
