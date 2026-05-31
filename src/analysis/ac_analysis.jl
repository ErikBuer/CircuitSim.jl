"""
    ACAnalysis(; start, stop, points, sweep_type="lin", name="AC1", noise=false)
    ACAnalysis(; values, sweep_type="list", name="AC1", noise=false)

AC small-signal frequency sweep analysis.

Computes the small-signal AC response over a frequency range. Optionally compute noise parameters.

## Parameters

For LINEAR or LOGARITHMIC sweeps:
- `start::Real`: Start frequency in Hz (default: 1e9)
- `stop::Real`: Stop frequency in Hz (default: 10e9)
- `points::Int`: Number of frequency points (default: 10, min: 2)
- `sweep_type::String`: "lin"/"linear" or "log"/"logarithmic" (default: "lin")

For LIST sweeps:
- `values::Vector{<:Real}`: List of frequency points in Hz
- `sweep_type::String`: Must be "list"

Common parameters:
- `name::String`: Analysis name (default: "AC1")
- `noise::Bool`: Enable noise analysis (default: false)

## Example

```julia
# Linear AC sweep from 1 GHz to 10 GHz with 10 points
analysis = ACAnalysis(start=1e9, stop=10e9, points=10)

# Logarithmic sweep with noise analysis
analysis = ACAnalysis(start=100e6, stop=1e9, points=100, sweep_type="log", noise=true)

# List of specific frequencies
analysis = ACAnalysis(values=[100e6, 500e6, 1e9, 5e9], sweep_type="list")
```
"""
mutable struct ACAnalysis <: AbstractSweepAnalysis
    name::String
    start::Union{Nothing,Real}
    stop::Union{Nothing,Real}
    points::Union{Nothing,Int}
    values::Union{Nothing,Vector{<:Real},Real}
    sweep_type::String
    noise::Bool
end

# Main constructor
function ACAnalysis(;
    name::String="AC1",
    start::Real=1e9,
    stop::Real=10e9,
    points::Int=10,
    values::Union{Vector{<:Real},Real}=1e9,
    sweep_type::String="lin",
    noise::Bool=false
)
    sweep_lower = lowercase(sweep_type)
    if !(sweep_lower in ("lin", "linear", "log", "logarithmic", "list"))
        throw(ArgumentError("Invalid sweep_type: \"$sweep_type\". Must be 'lin'/'linear', 'log'/'logarithmic', or 'list'"))
    end

    points >= 2 || throw(ArgumentError("Number of points must be >= 2"))
    start > 0 || throw(ArgumentError("Start frequency must be positive"))
    stop > 0 || throw(ArgumentError("Stop frequency must be positive"))

    ACAnalysis(name, start, stop, points, values, sweep_lower, noise)
end

function to_qucs_analysis(a::ACAnalysis)::String
    noise_str = a.noise ? "yes" : "no"
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

    push!(parts, "Noise=\"$noise_str\"")
    return join(parts, " ")
end

function to_spice_analysis(a::ACAnalysis)::String
    sweep_lower = lowercase(a.sweep_type)

    if sweep_lower in ("lin", "linear")
        return ".ac lin $(a.points) $(format_value(a.start)) $(format_value(a.stop))"
    elseif sweep_lower in ("log", "logarithmic")
        return ".ac dec $(a.points) $(format_value(a.start)) $(format_value(a.stop))"
    elseif sweep_lower == "list"
        freqs = isa(a.values, Vector) ? a.values : [a.values]
        freq_str = join(format_value.(freqs), " ")
        return ".ac list $(freq_str)"
    else
        error("Unknown sweep type: $(a.sweep_type)")
    end
end
