# Current Exponential Source

```@example current_exponential
using CircuitSim

I = CurrentExponentialSource("I1", i1=0.0, i2=10e-3, t1=1e-9, t2=10e-9, tr=1e-9, tf=2e-9)
R = Resistor("R1", 1000.0)
L = Inductor("L1", 1e-6)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, I)
add_component!(circ, L)
add_component!(circ, R)
add_component!(circ, GND)

@connect circ I.nplus L.n1
@connect circ L.n2 R.n1
@connect circ R.n2 GND
@connect circ I.nminus GND

analysis = TransientAnalysis(15e-9, start=0.0, points=150)
result = simulate_qucsator(circ, analysis)

v_r = get_pin_voltage(result, R, :n1)

println("L/R time constant: ", round((1e-6 / 1000.0) * 1e9, digits=1), " ns")
println("Peak voltage: ", round(maximum(abs.(v_r)), digits=1), " V")
```
