# Current Pulse Source

```@example current_pulse
using CircuitSim

I = CurrentPulseSource("I1", i1=0.0, i2=10e-3, t1=1e-9, t2=10e-9, tr=100e-12, tf=100e-12)
R = Resistor("R1", 1000.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, I)
add_component!(circ, R)
add_component!(circ, GND)

@connect circ I.nplus R.n1
@connect circ R.n2 GND
@connect circ I.nminus GND

analysis = TransientAnalysis(15e-9, start=0.0, points=150)
result = simulate_qucsator(circ, analysis)

v_r = get_pin_voltage(result, R, :n1)

println("Peak voltage across resistor: ", round(maximum(abs.(v_r)), digits=1), " V")
println("Expected (I*R): ", round(10e-3 * 1000.0, digits=1), " V")
```
