"""
    ACAnalysis(; start, stop, points, sweep_type=LOGARITHMIC, name="AC1")
    ACAnalysis(; values, sweep_type=LIST, name="AC1")

AC small-signal frequency sweep analysis.

Computes the small-signal AC response over a frequency range.

## Parameters

For LINEAR or LOGARITHMIC sweeps:
- `start::Real`: Start frequency in Hz
- `stop::Real`: Stop frequency in Hz
- `points::Int`: Number of frequency points
- `sweep_type::String`: "lin"/"linear" or "log"/"logarithmic" (default: "log")

For LIST sweeps:
- `values::Vector{<:Real}`: List of frequency points in Hz
- `sweep_type::String`: Must be "list"

For CONSTANT sweeps:
- `values::Real`: Single frequency value in Hz
- `sweep_type::String`: Must be "const" or "constant"

Common parameters:
- `name::String`: Analysis name (default: "AC1")

## Example

```julia
# Logarithmic sweep from 1Hz to 1MHz with 101 points
analysis = ACAnalysis(start=1.0, stop=1e6, points=101)

# Linear sweep
analysis = ACAnalysis(start=100.0, stop=10e3, points=100, sweep_type="lin")

# List of specific frequencies
analysis = ACAnalysis(values=[1e3, 10e3, 100e3, 1e6], sweep_type="list")

# Single frequency
analysis = ACAnalysis(values=1e6, sweep_type="const")
```
"""
mutable struct ACAnalysis <: AbstractSweepAnalysis
    name::String
    start::Real
    stop::Real
    points::Int
    values::Union{Vector{<:Real},Real}
    sweep_type::String
end

# Main constructor
function ACAnalysis(;
    name::String="AC1",
    start::Real=1e6,
    stop::Real=100e6,
    points::Int=101,
    values::Union{Vector{<:Real},Real}=1e6,
    sweep_type::String="lin",
)
    sweep_lower = lowercase(sweep_type)
    if !(sweep_lower in ("lin", "linear", "log", "logarithmic", "list"))
        throw(ArgumentError("Invalid sweep_type: \"$sweep_type\". Must be 'log'/'logarithmic', 'lin'/'linear', 'list'"))
    end

    ACAnalysis(name, start, stop, points, values, sweep_lower)
end

function to_qucs_analysis(a::ACAnalysis)::String
    parts = [".AC:$(a.name)"]
    sweep_lower = lowercase(a.sweep_type)

    if sweep_lower in ("lin", "linear")
        push!(parts, "Type=\"lin\"")
        push!(parts, "Start=\"$(format_value(a.start))\"")
        push!(parts, "Stop=\"$(format_value(a.stop))\"")
        push!(parts, "Points=\"$(a.points)\"")
    elseif sweep_lower in ("log", "logarithmic")
        push!(parts, "Type=\"log\"")
        push!(parts, "Start=\"$(format_value(a.start))\"")
        push!(parts, "Stop=\"$(format_value(a.stop))\"")
        push!(parts, "Points=\"$(a.points)\"")
    elseif sweep_lower == "list"
        push!(parts, "Type=\"list\"")
        values_str = "[" * join(format_value.(a.values), ";") * "]"
        push!(parts, "Values=\"$values_str\"")
    end

    return join(parts, " ")
end

function to_spice_analysis(a::ACAnalysis)::String
    return "TODO"
end
