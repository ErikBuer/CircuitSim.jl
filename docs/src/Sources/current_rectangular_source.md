# Current Rectangular Source

```@example current_rectangular
using CircuitSim

I = CurrentRectangularSource("I1", i=10e-3, th=1e-6, tl=1e-6, tr=10e-9, tf=10e-9, td=0.0)
R = Resistor("R1", resistance=100.0)
L = Inductor("L1", inductance=10e-6)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, I)
add_component!(circ, R)
add_component!(circ, L)
add_component!(circ, GND)

@connect circ I.nplus L.n1
@connect circ L.n2 R.n1
@connect circ R.n2 GND
@connect circ I.nminus GND

analysis = TransientAnalysis(4e-6, start=0.0, points=400)
result = simulate_qucsator(circ, analysis; suppress_warnings=true)

v_r = get_pin_voltage(result, R, :n1)

println("Peak voltage across resistor: ", round(maximum(abs.(v_r)), digits=2), " V")
println("Frequency: ", round(1/(2e-6)*1e-3, digits=1), " kHz")
```
