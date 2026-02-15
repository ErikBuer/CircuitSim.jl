"""
    NoiseAnalysis(; start, stop, points, output_node, source, sweep_type="log", name="Noise1")

Noise analysis over a frequency range.

Computes noise contributions from all noise sources in the circuit.

## Parameters

- `start::Real`: Start frequency in Hz (required)
- `stop::Real`: Stop frequency in Hz (required)
- `points::Int`: Number of frequency points (required)
- `output_node::String`: Output node name for noise measurement (required)
- `source::String`: Input source name for noise reference (required)
- `sweep_type::String`: "lin"/"linear" or "log"/"logarithmic" (default: "log")
- `name::String`: Analysis name (default: "Noise1")

## Example

```julia
# Noise analysis from 10Hz to 100kHz
analysis = NoiseAnalysis(start=10.0, stop=100e3, points=101, output_node="_net1", source="V1")

# Linear frequency sweep for noise
analysis = NoiseAnalysis(start=1e3, stop=10e3, points=100, output_node="_net2", source="V_in", sweep_type="lin")
```
"""
struct NoiseAnalysis <: AbstractSweepAnalysis
    name::String
    start::Real
    stop::Real
    points::Int
    output_node::String
    source::String
    sweep_type::String
end

function NoiseAnalysis(;
    start::Real,
    stop::Real,
    points::Int,
    output_node::String,
    source::String,
    sweep_type::String="log",
    name::String="Noise1"
)
    start > 0 || throw(ArgumentError("Start frequency must be positive"))
    stop > start || throw(ArgumentError("Stop frequency must be greater than start"))
    points >= 2 || throw(ArgumentError("Number of points must be at least 2"))
    sweep_lower = lowercase(sweep_type)
    if !(sweep_lower in ("lin", "linear", "log", "logarithmic"))
        throw(ArgumentError("Invalid sweep_type: \"$sweep_type\". Must be 'log'/'logarithmic' or 'lin'/'linear'"))
    end
    NoiseAnalysis(name, start, stop, points, output_node, source, sweep_lower)
end

function to_qucs_analysis(a::NoiseAnalysis)::String
    sweep_lower = lowercase(a.sweep_type)
    type_str = sweep_lower in ("log", "logarithmic") ? "log" : "lin"
    parts = [".Noise:$(a.name)"]
    push!(parts, "Type=\"$type_str\"")
    push!(parts, "Start=\"$(format_value(a.start))\"")
    push!(parts, "Stop=\"$(format_value(a.stop))\"")
    push!(parts, "Points=\"$(a.points)\"")
    push!(parts, "Output=\"$(a.output_node)\"")
    push!(parts, "Src=\"$(a.source)\"")
    return join(parts, " ")
end

function to_spice_analysis(a::NoiseAnalysis)::String
    sweep_lower = lowercase(a.sweep_type)
    type_str = sweep_lower in ("log", "logarithmic") ? "dec" : "lin"
    if sweep_lower in ("log", "logarithmic")
        decades = log10(a.stop / a.start)
        points_per_decade = ceil(Int, a.points / decades)
        ".noise v($(a.output_node)) $(a.source) $type_str $points_per_decade $(a.start) $(a.stop)"
    else
        ".noise v($(a.output_node)) $(a.source) $type_str $(a.points) $(a.start) $(a.stop)"
    end
end
