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
struct ACAnalysis <: AbstractSweepAnalysis
    name::String
    start::Union{Nothing,Real}
    stop::Union{Nothing,Real}
    points::Union{Nothing,Int}
    values::Union{Nothing,Vector{<:Real},Real}
    sweep_type::String
end

# Main constructor
function ACAnalysis(;
    start::Union{Nothing,Real}=nothing,
    stop::Union{Nothing,Real}=nothing,
    points::Union{Nothing,Int}=nothing,
    values::Union{Nothing,Vector{<:Real},Real}=nothing,
    sweep_type::String="log",
    name::String="AC1"
)
    sweep_lower = lowercase(sweep_type)

    # Validate parameters based on sweep type
    if sweep_lower in ("lin", "linear", "log", "logarithmic")
        if isnothing(start) || isnothing(stop) || isnothing(points)
            throw(ArgumentError("LINEAR and LOGARITHMIC sweeps require start, stop, and points parameters"))
        end
        if !isnothing(values)
            throw(ArgumentError("LINEAR and LOGARITHMIC sweeps cannot use values parameter"))
        end
    elseif sweep_lower == "list"
        if isnothing(values) || !(values isa Vector)
            throw(ArgumentError("LIST sweep requires values as a Vector"))
        end
        if !isnothing(start) || !isnothing(stop) || !isnothing(points)
            throw(ArgumentError("LIST sweep cannot use start, stop, or points parameters"))
        end
    elseif sweep_lower in ("const", "constant")
        if isnothing(values) || !(values isa Real)
            throw(ArgumentError("CONSTANT sweep requires values as a single Real number"))
        end
        if !isnothing(start) || !isnothing(stop) || !isnothing(points)
            throw(ArgumentError("CONSTANT sweep cannot use start, stop, or points parameters"))
        end
    else
        throw(ArgumentError("Invalid sweep_type: \"$sweep_type\". Must be 'log'/'logarithmic', 'lin'/'linear', 'list', or 'const'/'constant'"))
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
    elseif sweep_lower in ("const", "constant")
        push!(parts, "Type=\"const\"")
        push!(parts, "Values=\"$(format_value(a.values))\"")
    end

    return join(parts, " ")
end

function to_spice_analysis(a::ACAnalysis)::String
    return "TODO"
end
