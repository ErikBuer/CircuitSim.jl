# Voltage Pulse Source

```@example voltage_pulse
using CircuitSim

V = VoltagePulseSource("V1", u1=0.0, u2=5.0, t1=1e-9, t2=10e-9, tr=100e-12, tf=100e-12)
R = Resistor("R1", 50.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, V)
add_component!(circ, R)
add_component!(circ, GND)

@connect circ V.nplus R.n1
@connect circ R.n2 GND
@connect circ V.nminus GND

analysis = TransientAnalysis(15e-9, start=0.0, points=150)
result = simulate_qucsator(circ, analysis)

v_r = get_pin_voltage(result, R, :n1)

println("Peak voltage: ", round(maximum(abs.(v_r)), digits=2), " V")
println("Pulse width: ", round((10e-9 - 1e-9)*1e9, digits=1), " ns")
```
