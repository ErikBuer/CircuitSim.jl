# File Based Current Source

```@example file_current_source
using CircuitSim

# 1 GHz sine wave current
t = range(0, stop=10e-9, length=50)
time_vec = collect(t)
current_vec = [0.001 * sin(2π * 1e9 * ti) for ti in time_vec]  # 1 mA peak

# Amplifier circuit with 50 Ohm load
I_in = FileCurrentSource("I_in", time_vec, current_vec)
Amp = Amplifier("Amp", 10.0)  # 10x gain, 50 Ohm input impedance
R_load = Resistor("R_load", 50.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, I_in)
add_component!(circ, Amp)
add_component!(circ, R_load)
add_component!(circ, GND)

@connect circ I_in.nplus Amp.input
@connect circ Amp.output R_load.n1
@connect circ R_load.n2 GND.n
@connect circ I_in.nminus GND.n

# Transient simulation
tran = TransientAnalysis(10e-9, points=100)
result = simulate_qucsator(circ, tran)

# Extract voltages using helper functions
v_input = get_pin_voltage(result, Amp, :input)
v_output = get_pin_voltage(result, R_load, :n1)

println("Input:  ", round(maximum(abs.(v_input))*1e3, digits=1), " mV peak")
println("Output: ", round(maximum(abs.(v_output))*1e3, digits=1), " mV peak")
println("Gain:   ", round(maximum(abs.(v_output))/maximum(abs.(v_input)), digits=1), "x")
```
