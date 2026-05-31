# Harmonic Balance Analysis

Harmonic balance analysis computes the steady-state response of nonlinear circuits with periodic excitation by solving in the frequency domain across multiple harmonics.

## Constructor

```julia
HarmonicBalanceAnalysis(; n, f=1e9, name="HB1", iabstol=1e-12, vabstol=1e-6, reltol=1e-3, max_iter=150)
```

## Parameters

### Required

- `n::Int`: Number of harmonics to include (minimum: 1)
  - Each excitation frequency is expanded with its harmonics
  - Controls frequency resolution and computational cost

### Optional

- `f::Real`: Fundamental frequency in Hz (default: 1e9, must be positive)
  - Primary excitation frequency
  - Overridden if AC sources in circuit specify their own frequencies
- `name::String`: Analysis name (default: `"HB1"`)
- `iabstol::Real`: Current absolute tolerance (default: 1e-12)
- `vabstol::Real`: Voltage absolute tolerance (default: 1e-6)
- `reltol::Real`: Relative tolerance (default: 1e-3)
- `max_iter::Int`: Maximum iterations (default: 150, range: 2-10000)


## Examples

### Single-tone harmonic balance

```@example hb_single_tone
using CircuitSim

# Simple nonlinear circuit: diode rectifier
diode = Diode("D1")
V = ACVoltageSource("V1", ac_magnitude=1.0)
R = Resistor("R1", resistance=1e3)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, V)
add_component!(circ, diode)
add_component!(circ, R)
add_component!(circ, GND)

@connect circ V.nplus diode.anode
@connect circ diode.cathode R.n1
@connect circ R.n2 GND
@connect circ V.nminus GND

# Harmonic balance with 7 harmonics at 100 MHz
analysis = HarmonicBalanceAnalysis(n=7, f=100e6)
result = simulate_qucsator(circ, analysis)

println("Harmonic balance simulation status: ", result.status)
```
