"""
    ACAnalysis(start, stop, points; type=LOGARITHMIC, name="AC1")

AC small-signal frequency sweep analysis.

Computes the small-signal AC response over a frequency range.

# Parameters

- `start::Real`: Start frequency in Hz
- `stop::Real`: Stop frequency in Hz
- `points::Int`: Number of frequency points
- `sweep_type::SweepType`: Type of frequency sweep (LINEAR or LOGARITHMIC, default: LOGARITHMIC)
- `name::String`: Analysis name (default: "AC1")

# Example

```julia
# Logarithmic sweep from 1Hz to 1MHz with 101 points
analysis = ACAnalysis(1.0, 1e6, 101)

# Linear sweep
analysis = ACAnalysis(100.0, 10e3, 100, sweep_type=LINEAR)
```
"""
struct ACAnalysis <: AbstractSweepAnalysis
    name::String
    start::Real
    stop::Real
    points::Int
    sweep_type::SweepType

    function ACAnalysis(start::Real, stop::Real, points::Int;
        sweep_type::SweepType=LOGARITHMIC, name::String="AC1")
        start > 0 || throw(ArgumentError("Start frequency must be positive"))
        stop > start || throw(ArgumentError("Stop frequency must be greater than start"))
        points >= 2 || throw(ArgumentError("Number of points must be at least 2"))
        new(name, start, stop, points, sweep_type)
    end
end

function to_qucs_analysis(a::ACAnalysis)::String
    type_str = a.sweep_type == LOGARITHMIC ? "log" : "lin"
    parts = [".AC:$(a.name)"]
    push!(parts, "Type=\"$type_str\"")
    push!(parts, "Start=\"$(format_value(a.start))\"")
    push!(parts, "Stop=\"$(format_value(a.stop))\"")
    push!(parts, "Points=\"$(a.points)\"")
    return join(parts, " ")
end

function to_spice_analysis(a::ACAnalysis)::String
    type_str = a.sweep_type == LOGARITHMIC ? "dec" : "lin"
    # SPICE uses decades for log sweep, so we need to calculate points per decade
    if a.sweep_type == LOGARITHMIC
        decades = log10(a.stop / a.start)
        points_per_decade = ceil(Int, a.points / decades)
        ".ac $type_str $points_per_decade $(a.start) $(a.stop)"
    else
        ".ac $type_str $(a.points) $(a.start) $(a.stop)"
    end
end
