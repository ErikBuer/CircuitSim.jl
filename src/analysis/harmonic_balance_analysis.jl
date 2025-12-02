"""
Harmonic balance analysis for nonlinear steady-state simulation.
"""

"""
    HarmonicBalanceAnalysis(frequency; harmonics=5, name="HB1")

Harmonic balance analysis for steady-state analysis of nonlinear circuits
with periodic excitation.

# Parameters
- `frequency::Real`: Fundamental frequency in Hz
- `harmonics::Int`: Number of harmonics to include (default: 5)
- `name::String`: Analysis name (default: "HB1")

# Example
```julia
# Harmonic balance at 1GHz with 7 harmonics
analysis = HarmonicBalanceAnalysis(1e9, harmonics=7)

# RF mixer analysis at 100MHz
analysis = HarmonicBalanceAnalysis(100e6, harmonics=11)
```
"""
struct HarmonicBalanceAnalysis <: AbstractAnalysis
    name::String
    frequency::Real
    harmonics::Int

    function HarmonicBalanceAnalysis(frequency::Real; harmonics::Int=5, name::String="HB1")
        frequency > 0 || throw(ArgumentError("Frequency must be positive"))
        harmonics >= 1 || throw(ArgumentError("Number of harmonics must be at least 1"))
        new(name, frequency, harmonics)
    end
end

function to_qucs_analysis(a::HarmonicBalanceAnalysis)::String
    parts = [".HB:$(a.name)"]
    push!(parts, "n=\"$(a.harmonics)\"")
    push!(parts, "f=\"$(format_value(a.frequency))\"")
    return join(parts, " ")
end
