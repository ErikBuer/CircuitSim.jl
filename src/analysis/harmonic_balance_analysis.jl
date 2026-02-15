"""
    HarmonicBalanceAnalysis(; harmonics, frequency=1e9, name="HB1", iabstol=1e-12, vabstol=1e-6, reltol=1e-3, max_iterations=150)

Harmonic balance analysis for steady-state analysis of nonlinear circuits
with periodic excitation.

## Parameters

- `harmonics::Int`: Number of harmonics to include (required)
- `frequency::Real`: Fundamental frequency in Hz (default: 1e9)
- `name::String`: Analysis name (default: "HB1")
- `iabstol::Real`: Current absolute tolerance (default: 1e-12)
- `vabstol::Real`: Voltage absolute tolerance (default: 1e-6)
- `reltol::Real`: Relative tolerance (default: 1e-3)
- `max_iterations::Int`: Maximum number of iterations (default: 150)

## Example

```julia
# Harmonic balance at 1GHz with 7 harmonics
analysis = HarmonicBalanceAnalysis(harmonics=7, frequency=1e9)

# RF mixer analysis at 100MHz with custom tolerances
analysis = HarmonicBalanceAnalysis(harmonics=11, frequency=100e6, reltol=1e-4)
```
"""
struct HarmonicBalanceAnalysis <: AbstractAnalysis
    name::String
    harmonics::Int
    frequency::Real
    iabstol::Real
    vabstol::Real
    reltol::Real
    max_iterations::Int
end

function HarmonicBalanceAnalysis(;
    harmonics::Int,
    frequency::Real=1e9,
    iabstol::Real=1e-12,
    vabstol::Real=1e-6,
    reltol::Real=1e-3,
    max_iterations::Int=150,
    name::String="HB1"
)
    harmonics >= 1 || throw(ArgumentError("Number of harmonics must be at least 1"))
    frequency > 0 || throw(ArgumentError("Frequency must be positive"))
    iabstol > 0 && iabstol < 1 || throw(ArgumentError("Current absolute tolerance must be in range (0, 1)"))
    vabstol > 0 && vabstol < 1 || throw(ArgumentError("Voltage absolute tolerance must be in range (0, 1)"))
    reltol > 0 && reltol < 1 || throw(ArgumentError("Relative tolerance must be in range (0, 1)"))
    max_iterations >= 2 && max_iterations <= 10000 || throw(ArgumentError("Maximum iterations must be in range [2, 10000]"))

    HarmonicBalanceAnalysis(name, harmonics, frequency, iabstol, vabstol, reltol, max_iterations)
end

function to_qucs_analysis(a::HarmonicBalanceAnalysis)::String
    parts = [".HB:$(a.name)"]
    push!(parts, "n=\"$(a.harmonics)\"")
    push!(parts, "f=\"$(format_value(a.frequency))\"")
    push!(parts, "iabstol=\"$(format_value(a.iabstol))\"")
    push!(parts, "vabstol=\"$(format_value(a.vabstol))\"")
    push!(parts, "reltol=\"$(format_value(a.reltol))\"")
    push!(parts, "MaxIter=\"$(a.max_iterations)\"")
    return join(parts, " ")
end
