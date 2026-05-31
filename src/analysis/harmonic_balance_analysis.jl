"""
    HarmonicBalanceAnalysis(; n, f=1e9, name="HB1", iabstol=1e-12, vabstol=1e-6, reltol=1e-3, max_iter=150)

Harmonic balance analysis for steady-state analysis of nonlinear circuits with periodic excitation.

Harmonic balance solves nonlinear circuits driven by sinusoidal sources by balancing currents in the frequency domain
across multiple harmonics. It handles frequency mixing and intermodulation effects.

## Parameters

- `n::Int`: Number of harmonics to include (required, minimum: 1)
  - Each excitation frequency is expanded with its harmonics
  - Total frequency points are computed based on harmonic combinations
- `f::Real`: Fundamental frequency in Hz (default: 1e9, must be positive)
  - Primary excitation frequency
  - If circuits contain AC sources, their frequencies override this value
- `name::String`: Analysis name (default: `"HB1"`)
- `iabstol::Real`: Current absolute tolerance (default: 1e-12)
- `vabstol::Real`: Voltage absolute tolerance (default: 1e-6)
- `reltol::Real`: Relative tolerance (default: 1e-3)
- `max_iter::Int`: Maximum number of iterations (default: 150, range: 2-10000)

## Qucsator Specific

This analysis type is specific to qucsator. Results include node voltages and currents at each harmonic frequency component.
"""
mutable struct HarmonicBalanceAnalysis <: AbstractAnalysis
    name::String
    n::Int
    f::Real
    iabstol::Real
    vabstol::Real
    reltol::Real
    max_iter::Int
end

function HarmonicBalanceAnalysis(;
    name::String="HB1",
    n::Int=1,
    f::Real=1e9,
    iabstol::Real=1e-12,
    vabstol::Real=1e-6,
    reltol::Real=1e-3,
    max_iter::Int=150
)
    n >= 1 || throw(ArgumentError("Number of harmonics must be >= 1"))
    f > 0 || throw(ArgumentError("Fundamental frequency must be positive"))
    iabstol > 0 || throw(ArgumentError("Current absolute tolerance must be positive"))
    vabstol > 0 || throw(ArgumentError("Voltage absolute tolerance must be positive"))
    reltol > 0 || throw(ArgumentError("Relative tolerance must be positive"))
    max_iter >= 2 || throw(ArgumentError("max_iter must be >= 2"))
    max_iter <= 10000 || throw(ArgumentError("max_iter must be <= 10000"))

    HarmonicBalanceAnalysis(name, n, f, iabstol, vabstol, reltol, max_iter)
end

function to_qucs_analysis(a::HarmonicBalanceAnalysis)::String
    parts = [".HB:$(a.name)"]
    push!(parts, "n=\"$(a.n)\"")
    push!(parts, "f=\"$(format_value(a.f))\"")
    push!(parts, "iabstol=\"$(format_value(a.iabstol))\"")
    push!(parts, "vabstol=\"$(format_value(a.vabstol))\"")
    push!(parts, "reltol=\"$(format_value(a.reltol))\"")
    push!(parts, "MaxIter=\"$(a.max_iter)\"")
    return join(parts, " ")
end