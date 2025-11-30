"""
Parameter sweep analysis.
"""

"""
    ParameterSweep(param, start, stop, points, inner_analysis; type=LINEAR, name="SW1")

Parameter sweep analysis.

Sweeps a component parameter and runs an inner analysis at each point.

# Parameters
- `param::String`: Parameter name to sweep (e.g., "R1.R" for resistor R1's resistance)
- `start::Real`: Start value
- `stop::Real`: Stop value  
- `points::Int`: Number of sweep points
- `inner_analysis::AbstractAnalysis`: Analysis to run at each sweep point
- `sweep_type::SweepType`: Type of sweep (LINEAR or LOGARITHMIC, default: LINEAR)
- `name::String`: Analysis name (default: "SW1")

# Example
```julia
# Sweep R1 from 1kΩ to 10kΩ and run DC analysis at each point
dc = DCAnalysis()
sweep = ParameterSweep("R1.R", 1e3, 10e3, 10, dc)
result = simulate(circuit, sweep)

# Logarithmic parameter sweep with AC inner analysis
ac = ACAnalysis(1.0, 1e6, 101)
sweep = ParameterSweep("C1.C", 1e-12, 1e-9, 20, ac, sweep_type=LOGARITHMIC)
```
"""
struct ParameterSweep <: AbstractSweepAnalysis
    name::String
    param::String
    start::Real
    stop::Real
    points::Int
    sweep_type::SweepType
    inner_analysis::AbstractAnalysis

    function ParameterSweep(param::String, start::Real, stop::Real, points::Int,
        inner_analysis::AbstractAnalysis;
        sweep_type::SweepType=LINEAR,
        name::String="SW1")
        points >= 2 || throw(ArgumentError("Number of points must be at least 2"))
        new(name, param, start, stop, points, sweep_type, inner_analysis)
    end
end

# =============================================================================
# Qucs Netlist Generation
# =============================================================================

function to_qucs_analysis(a::ParameterSweep)::String
    type_str = a.sweep_type == LOGARITHMIC ? "log" : "lin"
    inner_str = to_qucs_analysis(a.inner_analysis)

    # The inner analysis command
    lines = [inner_str]

    # The parameter sweep command
    parts = [".SW:$(a.name)"]
    push!(parts, "Type=\"$type_str\"")
    push!(parts, "Param=\"$(a.param)\"")
    push!(parts, "Start=\"$(format_value(a.start))\"")
    push!(parts, "Stop=\"$(format_value(a.stop))\"")
    push!(parts, "Points=\"$(a.points)\"")
    push!(parts, "Sim=\"$(a.inner_analysis.name)\"")

    push!(lines, join(parts, " "))
    return join(lines, "\n")
end

# =============================================================================
# SPICE Netlist Generation
# =============================================================================

function to_spice_analysis(a::ParameterSweep)::String
    # SPICE parameter sweep is more complex, using .step
    inner_str = to_spice_analysis(a.inner_analysis)
    type_str = a.sweep_type == LOGARITHMIC ? "dec" : "lin"
    "$inner_str\n.step param $(a.param) $(a.start) $(a.stop) $(a.points)"
end
