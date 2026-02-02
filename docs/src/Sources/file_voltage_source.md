# File Based Voltage Source

```@example file_voltage_source
using CircuitSim

# 1 GHz sine wave input
t = range(0, stop=10e-9, length=50)
time_vec = collect(t)
voltage_vec = [0.1 * sin(2π * 1e9 * ti) for ti in time_vec]

# Amplifier circuit with 50 Ohm load
V_in = FileVoltageSource("V_in", time_vec, voltage_vec)
Amp = Amplifier("Amp", gain=10.0)  # 10x gain, 50 Ohm input impedance
R_load = Resistor("R_load", 50.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, V_in)
add_component!(circ, Amp)
add_component!(circ, R_load)
add_component!(circ, GND)

@connect circ V_in.nplus Amp.input
@connect circ Amp.output R_load.n1
@connect circ R_load.n2 GND.n
@connect circ V_in.nminus GND.n

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

