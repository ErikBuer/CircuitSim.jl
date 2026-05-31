# AC Small-Signal Analysis

AC analysis computes the small-signal frequency response of a circuit using linear small-signal equivalent circuits. It supports linear, logarithmic, and explicit frequency list sweeps. Noise parameters can be optionally calculated.

## Constructor

```julia
ACAnalysis(; start, stop, points, sweep_type="lin", name="AC1", noise=false)
ACAnalysis(; values, sweep_type="list", name="AC1", noise=false)
```

## Parameters

### Linear and Logarithmic Sweeps

- `start::Real`: Start frequency in Hz (default: 1e9)
- `stop::Real`: Stop frequency in Hz (default: 10e9)
- `points::Int`: Number of frequency points (default: 10, minimum: 2)
- `sweep_type::String`: Sweep type - `"lin"` for linear, `"log"` for logarithmic (default: `"lin"`)
- `name::String`: Analysis name (default: `"AC1"`)
- `noise::Bool`: Enable noise parameter calculation (default: `false`)

### List Sweep

- `values::Vector{<:Real}`: Explicit list of frequency points in Hz
- `sweep_type::String`: Must be `"list"`
- `name::String`: Analysis name (default: `"AC1"`)
- `noise::Bool`: Enable noise parameter calculation (default: `false`)

## Description

AC analysis performs frequency domain analysis at each frequency point by:

1. Replacing nonlinear devices with their small-signal equivalent circuits
2. Solving the linear AC circuit equations
3. Optionally computing noise parameters if `noise=true`

Results include voltages and currents at each frequency point. For RF circuits, it can be used to extract S-parameters or general AC response characteristics.

## Examples

### Linear sweep

```@example ac_analysis_linear
using CircuitSim

# Simple RC low-pass filter
R = Resistor("R1", resistance=1e3)  # 1 kΩ
C = Capacitor("C1", capacitance=100e-12)  # 100 pF
V = ACVoltageSource("V1", ac_magnitude=1.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, V)
add_component!(circ, R)
add_component!(circ, C)
add_component!(circ, GND)

@connect circ V.nplus R.n1
@connect circ R.n2 C.n1
@connect circ C.n1 GND
@connect circ V.nminus GND

# Linear sweep: 1 MHz to 100 MHz
analysis = ACAnalysis(start=1e6, stop=100e6, points=50, sweep_type="lin")
result = simulate_qucsator(circ, analysis)

# Check response at first frequency
v_out = get_pin_voltage(result, C, :n1)
println("AC response first freq: ", round(abs(v_out[1]), digits=4), " V")
```

### Logarithmic sweep

```@example ac_analysis_log
using CircuitSim

# Series RLC resonance circuit
R = Resistor("R1", resistance=50.0)
L = Inductor("L1", inductance=100e-9)  # 100 nH
C = Capacitor("C1", capacitance=100e-12)  # 100 pF
V = ACVoltageSource("V1", ac_magnitude=1.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, V)
add_component!(circ, R)
add_component!(circ, L)
add_component!(circ, C)
add_component!(circ, GND)

@connect circ V.nplus R.n1
@connect circ R.n2 L.n1
@connect circ L.n2 C.n1
@connect circ C.n2 GND
@connect circ V.nminus GND

# Log sweep: 10 MHz to 1 GHz (100 points for smooth curve)
analysis = ACAnalysis(start=10e6, stop=1e9, points=100, sweep_type="log")
result = simulate_qucsator(circ, analysis)

# Compute impedance magnitude at each frequency
v_out = get_pin_voltage(result, C, :n1)
impedances = abs.(v_out)  # Normalized to 1V source
println("Log sweep completed: ", length(result.frequencies_Hz), " points")
println("Impedance at 1st point: ", round(impedances[1], digits=2), " Ω")
```
