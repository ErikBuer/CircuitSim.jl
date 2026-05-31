"""
    DCAnalysis(; name="DC1", max_iter=150, abstol=1e-12, vntol=1e-6, reltol=1e-3,
               save_ops=false, save_all=false, temp=26.85,
               conv_helper="none", solver="CroutLU")

DC operating point analysis.

Computes the DC operating point of the circuit by solving nonlinear equations iteratively.

## Parameters

- `name::String`: Analysis name (default: `"DC1"`)
- `max_iter::Int`: Maximum iterations for nonlinear solver (default: 150, range: 2-10000)
- `abstol::Real`: Absolute tolerance (default: 1e-12)
- `vntol::Real`: Voltage tolerance (default: 1e-6)
- `reltol::Real`: Relative tolerance (default: 1e-3)
- `save_ops::Bool`: Save operating points of nonlinear devices (default: false)
- `save_all::Bool`: Save all node voltages and branch currents (default: false)
- `temp::Real`: Simulation temperature in °C (default: 26.85)
- `conv_helper::String`: Convergence helper strategy (default: "none")
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

## Example

```julia
# Basic DC operating point
analysis = DCAnalysis()
result = simulate_qucsator(circuit, analysis)

# With custom temperature and convergence settings
analysis = DCAnalysis(temp=85.0, max_iter=200, conv_helper="SourceStepping")
result = simulate_qucsator(circuit, analysis)

# Save all node voltages and currents
analysis = DCAnalysis(save_all=true)
```
"""
mutable struct DCAnalysis <: AbstractAnalysis
    name::String
    max_iter::Int
    abstol::Real
    vntol::Real
    reltol::Real
    save_ops::Bool
    save_all::Bool
    temp::Real
    conv_helper::String
    solver::String
end

function DCAnalysis(;
    name::String="DC1",
    max_iter::Int=150,
    abstol::Real=1e-12,
    vntol::Real=1e-6,
    reltol::Real=1e-3,
    save_ops::Bool=false,
    save_all::Bool=false,
    temp::Real=26.85,
    conv_helper::String="none",
    solver::String="CroutLU"
)
    # Validate parameters
    max_iter >= 2 || throw(ArgumentError("max_iter must be >= 2"))
    max_iter <= 10000 || throw(ArgumentError("max_iter must be <= 10000"))
    temp >= -273.15 || throw(ArgumentError("Temperature must be >= -273.15°C"))
    abstol > 0 || throw(ArgumentError("abstol must be positive"))
    vntol > 0 || throw(ArgumentError("vntol must be positive"))
    reltol > 0 || throw(ArgumentError("reltol must be positive"))

    conv_helper_lower = lowercase(conv_helper)
    if !(conv_helper_lower in ("none", "sourcestepping", "gminsstepping", "linesearch", "attenuation", "steepestdescent"))
        throw(ArgumentError("Invalid conv_helper: \"$conv_helper\""))
    end

    if !(solver in ("CroutLU", "DoolittleLU", "HouseholderQR", "HouseholderLQ", "GolubSVD"))
        throw(ArgumentError("Invalid solver: \"$solver\""))
    end

    DCAnalysis(name, max_iter, abstol, vntol, reltol, save_ops, save_all, temp, conv_helper_lower, solver)
end

function to_qucs_analysis(a::DCAnalysis)::String
    parts = [".DC:$(a.name)"]
    push!(parts, "MaxIter=\"$(a.max_iter)\"")
    push!(parts, "abstol=\"$(format_value(a.abstol))\"")
    push!(parts, "vntol=\"$(format_value(a.vntol))\"")
    push!(parts, "reltol=\"$(format_value(a.reltol))\"")
    push!(parts, "saveOPs=\"$(a.save_ops ? "yes" : "no")\"")
    push!(parts, "saveAll=\"$(a.save_all ? "yes" : "no")\"")
    push!(parts, "Temp=\"$(format_value(a.temp))\"")
    push!(parts, "convHelper=\"$(a.conv_helper)\"")
    push!(parts, "Solver=\"$(a.solver)\"")
    return join(parts, " ")
end

function to_spice_analysis(a::DCAnalysis)::String
    return ".op"
end

