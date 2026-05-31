# Transient Analysis

Transient analysis computes the time-domain response of a circuit over a specified time interval.

## Constructor

```julia
TransientAnalysis(; name="TR1", type="lin", start=0.0, stop=1e-3, points=10,
                  integration_method="Trapezoidal", order=2,
                  initial_step=1e-9, min_step=1e-16, max_step=0.0,
                  max_iter=150, abstol=1e-12, vntol=1e-6, reltol=1e-3,
                  lte_abstol=1e-6, lte_reltol=1e-3, lte_factor=1.0,
                  temp=26.85, solver="CroutLU", relax_tsr=false, initial_dc=true)
```

## Parameters

- `name::String`: Analysis name (default: `"TR1"`)
- `type::String`: Sweep type, `"lin"` or `"log"` (default: `"lin"`)
- `start::Real`: Start time in seconds (default: 0.0)
- `stop::Real`: Stop time in seconds (must be > start)
- `points::Int`: Number of time points (default: 10, minimum: 2)
- `integration_method::String`: `"Euler"`, `"Trapezoidal"`, `"Gear"`, `"AdamsMoulton"`
- `order::Int`: Integration order in range `[1, 6]`
- `initial_step::Real`: Initial transient step size in seconds
- `min_step::Real`: Minimum transient step size in seconds
- `max_step::Real`: Maximum transient step size (`0.0` means auto)
- `max_iter::Int`: Maximum Newton iterations in range `[2, 10000]`
- `abstol::Real`: Current absolute tolerance
- `vntol::Real`: Voltage tolerance
- `reltol::Real`: Relative tolerance
- `lte_abstol::Real`: Local truncation error absolute tolerance
- `lte_reltol::Real`: Local truncation error relative tolerance
- `lte_factor::Real`: Local truncation error factor in range `[1, 16]`
- `temp::Real`: Simulation temperature in degC (default: 26.85)
- `solver::String`: `"CroutLU"`, `"DoolittleLU"`, `"HouseholderQR"`, `"HouseholderLQ"`, `"GolubSVD"`
- `relax_tsr::Bool`: Relax time-step raster
- `initial_dc::Bool`: Run initial DC operating-point solve

Compatibility aliases are supported: `step`, `max_iterations`, `iabstol`, `vabstol`, `maxstep`, `minstep`.

## Examples

### RC charging

```@example transient_rc
using CircuitSim

# RC circuit charging through a pulse
V_in = VoltagePulseSource("V1", 
    u1=0.0, u2=5.0,  # 0V to 5V
    t1=1e-6,         # 1us delay
    tr=100e-9,       # 100ns rise time
    tf=100e-9,       # 100ns fall time
    t2=11e-6         # pulse ends at 11us
)
R = Resistor("R1", resistance=1e3)
C = Capacitor("C1", capacitance=1e-6)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, V_in)
add_component!(circ, R)
add_component!(circ, C)
add_component!(circ, GND)

@connect circ V_in.nplus R.n1
@connect circ R.n2 C.n1
@connect circ C.n2 GND
@connect circ V_in.nminus GND

# Transient from 0 to 50µs
analysis = TransientAnalysis(start=0.0, stop=50e-6, points=500)
result = simulate_qucsator(circ, analysis)

# Compute capacitor voltage at end
v_cap = get_pin_voltage(result, C, :n1)
println("Final capacitor voltage: ", round(v_cap[end], digits=3), " V")
```
