"""
S-parameter frequency sweep analysis.
"""

"""
    SParameterAnalysis(start, stop, points; type=LOGARITHMIC, name="SP1", z0=50.0)

S-parameter frequency sweep analysis.

Computes S-parameters over a frequency range.

# Parameters
- `start::Real`: Start frequency in Hz
- `stop::Real`: Stop frequency in Hz
- `points::Int`: Number of frequency points
- `sweep_type::SweepType`: Type of frequency sweep (LINEAR or LOGARITHMIC, default: LOGARITHMIC)
- `z0::Real`: Reference impedance in Ohms (default: 50.0)
- `name::String`: Analysis name (default: "SP1")

# Example
```julia
# S-parameter analysis from 1MHz to 1GHz
analysis = SParameterAnalysis(1e6, 1e9, 201)

# With 75Ω reference impedance
analysis = SParameterAnalysis(1e6, 1e9, 201, z0=75.0)
```
"""
struct SParameterAnalysis <: AbstractSweepAnalysis
    name::String
    start::Real
    stop::Real
    points::Int
    sweep_type::SweepType
    z0::Real

    function SParameterAnalysis(start::Real, stop::Real, points::Int;
        sweep_type::SweepType=LOGARITHMIC,
        z0::Real=50.0,
        name::String="SP1")
        start > 0 || throw(ArgumentError("Start frequency must be positive"))
        stop > start || throw(ArgumentError("Stop frequency must be greater than start"))
        points >= 2 || throw(ArgumentError("Number of points must be at least 2"))
        z0 > 0 || throw(ArgumentError("Reference impedance must be positive"))
        new(name, start, stop, points, sweep_type, z0)
    end
end


function to_qucs_analysis(a::SParameterAnalysis)::String
    type_str = a.sweep_type == LOGARITHMIC ? "log" : "lin"
    parts = [".SP:$(a.name)"]
    push!(parts, "Type=\"$type_str\"")
    push!(parts, "Start=\"$(format_value(a.start))\"")
    push!(parts, "Stop=\"$(format_value(a.stop))\"")
    push!(parts, "Points=\"$(a.points)\"")
    push!(parts, "Z0=\"$(format_value(a.z0))\"")
    return join(parts, " ")
end
