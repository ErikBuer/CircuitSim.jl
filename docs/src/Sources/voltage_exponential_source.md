# Voltage Exponential Source

```@example voltage_exponential
using CircuitSim

V = VoltageExponentialSource("V1", u1=0.0, u2=5.0, t1=1e-9, t2=10e-9, tr=1e-9, tf=2e-9)
R = Resistor("R1", resistance=50.0)
C = Capacitor("C1", capacitance=10e-12)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, V)
add_component!(circ, R)
add_component!(circ, C)
add_component!(circ, GND)

@connect circ V.nplus R.n1
@connect circ R.n2 C.n1
@connect circ C.n2 GND
@connect circ V.nminus GND

analysis = TransientAnalysis(15e-9, start=0.0, points=150)
result = simulate_qucsator(circ, analysis)

v_c = get_pin_voltage(result, C, :n1)

println("RC time constant: ", round(50.0 * 10e-12 * 1e12, digits=1), " ps")
println("Peak capacitor voltage: ", round(maximum(abs.(v_c)), digits=2), " V")
```
