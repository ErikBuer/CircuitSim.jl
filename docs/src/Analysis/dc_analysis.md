# DC Operating Point Analysis

DC analysis computes the operating point of a circuit by solving the nonlinear DC equations iteratively.

## Constructor

```julia
DCAnalysis(; name="DC1", max_iter=150, abstol=1e-12, vntol=1e-6, reltol=1e-3,
           save_ops=false, save_all=false, temp=26.85,
           conv_helper="none", solver="CroutLU")
```

## Parameters

- `name::String`: Analysis name (default: `"DC1"`)
- `max_iter::Int`: Maximum iterations for nonlinear solver (default: 150, range: 2-10000)
- `abstol::Real`: Absolute tolerance (default: 1e-12)
- `vntol::Real`: Voltage tolerance (default: 1e-6)
- `reltol::Real`: Relative tolerance (default: 1e-3)
- `save_ops::Bool`: Save operating points of nonlinear devices (default: false)
- `save_all::Bool`: Save all node voltages and branch currents (default: false)
- `temp::Real`: Simulation temperature in °C (default: 26.85)
- `conv_helper::String`: Convergence helper strategy (default: `"none"`)
  - `"none"`: No special convergence aid
  - `"SourceStepping"`: Gradually increase source magnitudes
  - `"gMinStepping"`: Add parallel conductance for convergence
  - `"LineSearch"`: Search along Newton direction
  - `"Attenuation"`: Attenuate step size
  - `"SteepestDescent"`: Use steepest descent direction
- `solver::String`: Linear solver algorithm (default: `"CroutLU"`)
  - `"CroutLU"`: Crout LU decomposition
  - `"DoolittleLU"`: Doolittle LU decomposition
  - `"HouseholderQR"`: QR decomposition
  - `"HouseholderLQ"`: LQ decomposition
  - `"GolubSVD"`: Singular Value Decomposition

## Examples

### Basic DC operating point

```@example dc_basic
using CircuitSim

# Simple voltage divider
V_in = DCVoltageSource("V1", voltage=10.0)
R1 = Resistor("R1", resistance=1e3)
R2 = Resistor("R2", resistance=2e3)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, V_in)
add_component!(circ, R1)
add_component!(circ, R2)
add_component!(circ, GND)

@connect circ V_in.nplus R1.n1
@connect circ R1.n2 R2.n1
@connect circ R2.n2 GND
@connect circ V_in.nminus GND

analysis = DCAnalysis()
result = simulate_qucsator(circ, analysis)

# Compute output voltage (divider ratio: R2/(R1+R2) * V_in)
v_out = get_pin_voltage(result, R2, :n1)
expected = 10.0 * 2e3 / (1e3 + 2e3)
println("V_out: ", round(v_out, digits=3), " V (expected: ", round(expected, digits=3), " V)")
```

### Nonlinear circuit: diode operating point

```@example dc_diode
using CircuitSim

# Diode circuit with load line
V_cc = DCVoltageSource("V_CC", voltage=5.0)
R_load = Resistor("R_L", resistance=1e3)
diode = Diode("D1")
GND = Ground("GND")

circ = Circuit()
add_component!(circ, V_cc)
add_component!(circ, R_load)
add_component!(circ, diode)
add_component!(circ, GND)

@connect circ V_cc.nplus R_load.n1
@connect circ R_load.n2 diode.anode
@connect circ diode.cathode GND
@connect circ V_cc.nminus GND

# Standard DC operating point
analysis = DCAnalysis()
result = simulate_qucsator(circ, analysis)

v_diode = get_pin_voltage(result, R_load, :n2)
println("Diode anode voltage: ", round(v_diode, digits=4), " V")
```
