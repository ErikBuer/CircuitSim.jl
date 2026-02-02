# Voltage Rectangular Source

```@example voltage_rectangular
using CircuitSim

V = VoltageRectangularSource("V1", u=5.0, th=1e-6, tl=1e-6, tr=10e-9, tf=10e-9, td=0.0)
R = Resistor("R1", 50.0)
C = Capacitor("C1", capacitance=100e-12)
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

analysis = TransientAnalysis(4e-6, start=0.0, points=400)
result = simulate_qucsator(circ, analysis; suppress_warnings=true)

v_c = get_pin_voltage(result, C, :n1)

println("Capacitor peak voltage: ", round(maximum(abs.(v_c)), digits=2), " V")
println("Period: ", round((1e-6 + 1e-6)*1e6, digits=1), " μs")
```
