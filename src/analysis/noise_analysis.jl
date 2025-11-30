"""
Noise analysis over a frequency range.
"""

"""
    NoiseAnalysis(start, stop, points, output_node, source; type=LOGARITHMIC, name="Noise1")

Noise analysis over a frequency range.

Computes noise contributions from all noise sources in the circuit.

# Parameters
- `start::Real`: Start frequency in Hz
- `stop::Real`: Stop frequency in Hz
- `points::Int`: Number of frequency points
- `output_node::String`: Output node name for noise measurement
- `source::String`: Input source name for noise reference
- `sweep_type::SweepType`: Type of frequency sweep (default: LOGARITHMIC)
- `name::String`: Analysis name (default: "Noise1")

# Example
```julia
# Noise analysis from 10Hz to 100kHz
analysis = NoiseAnalysis(10.0, 100e3, 101, "_net1", "V1")

# Linear frequency sweep for noise
analysis = NoiseAnalysis(1e3, 10e3, 100, "_net2", "V_in", sweep_type=LINEAR)
```
"""
struct NoiseAnalysis <: AbstractSweepAnalysis
    name::String
    start::Real
    stop::Real
    points::Int
    output_node::String
    source::String
    sweep_type::SweepType

    function NoiseAnalysis(start::Real, stop::Real, points::Int,
        output_node::String, source::String;
        sweep_type::SweepType=LOGARITHMIC,
        name::String="Noise1")
        start > 0 || throw(ArgumentError("Start frequency must be positive"))
        stop > start || throw(ArgumentError("Stop frequency must be greater than start"))
        points >= 2 || throw(ArgumentError("Number of points must be at least 2"))
        new(name, start, stop, points, output_node, source, sweep_type)
    end
end

# =============================================================================
# Qucs Netlist Generation
# =============================================================================

function to_qucs_analysis(a::NoiseAnalysis)::String
    type_str = a.sweep_type == LOGARITHMIC ? "log" : "lin"
    parts = [".Noise:$(a.name)"]
    push!(parts, "Type=\"$type_str\"")
    push!(parts, "Start=\"$(format_value(a.start))\"")
    push!(parts, "Stop=\"$(format_value(a.stop))\"")
    push!(parts, "Points=\"$(a.points)\"")
    push!(parts, "Output=\"$(a.output_node)\"")
    push!(parts, "Src=\"$(a.source)\"")
    return join(parts, " ")
end

# =============================================================================
# SPICE Netlist Generation
# =============================================================================

function to_spice_analysis(a::NoiseAnalysis)::String
    type_str = a.sweep_type == LOGARITHMIC ? "dec" : "lin"
    if a.sweep_type == LOGARITHMIC
        decades = log10(a.stop / a.start)
        points_per_decade = ceil(Int, a.points / decades)
        ".noise v($(a.output_node)) $(a.source) $type_str $points_per_decade $(a.start) $(a.stop)"
    else
        ".noise v($(a.output_node)) $(a.source) $type_str $(a.points) $(a.start) $(a.stop)"
    end
end
