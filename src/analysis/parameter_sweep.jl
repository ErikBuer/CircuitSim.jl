"""
    ParameterSweep(; param, start, stop, points, inner_analysis, sweep_type="lin", name="SW1")

Parameter sweep analysis.

Sweeps a component parameter and runs an inner analysis at each point.

## Parameters

- `param::String`: Parameter name to sweep (e.g., "R1.R" for resistor R1's resistance) (required)
- `start::Real`: Start value (required)
- `stop::Real`: Stop value (required)
- `points::Int`: Number of sweep points (required)
- `inner_analysis::AbstractAnalysis`: Analysis to run at each sweep point (required)
- `sweep_type::String`: "lin"/"linear" or "log"/"logarithmic" (default: "lin")
- `name::String`: Analysis name (default: "SW1")

## Example

```julia
# Sweep R1 from 1kΩ to 10kΩ and run DC analysis at each point
dc = DCAnalysis()
sweep = ParameterSweep(param="R1.R", start=1e3, stop=10e3, points=10, inner_analysis=dc)
result = simulate_qucsator(circuit, sweep)

# Logarithmic parameter sweep with AC inner analysis
ac = ACAnalysis(start=1.0, stop=1e6, points=101)
sweep = ParameterSweep(param="C1.C", start=1e-12, stop=1e-9, points=20, inner_analysis=ac, sweep_type="log")
```
"""
struct ParameterSweep <: AbstractSweepAnalysis
    name::String
    param::String
    start::Real
    stop::Real
    points::Int
    sweep_type::String
    inner_analysis::AbstractAnalysis
end

function ParameterSweep(;
    param::String,
    start::Real,
    stop::Real,
    points::Int,
    inner_analysis::AbstractAnalysis,
    sweep_type::String="lin",
    name::String="SW1"
)
    points >= 2 || throw(ArgumentError("Number of points must be at least 2"))
    sweep_lower = lowercase(sweep_type)
    if !(sweep_lower in ("lin", "linear", "log", "logarithmic"))
        throw(ArgumentError("Invalid sweep_type: \"$sweep_type\". Must be 'log'/'logarithmic' or 'lin'/'linear'"))
    end
    ParameterSweep(name, param, start, stop, points, sweep_lower, inner_analysis)
end

function to_qucs_analysis(a::ParameterSweep)::String
    sweep_lower = lowercase(a.sweep_type)
    type_str = sweep_lower in ("log", "logarithmic") ? "log" : "lin"
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

function to_spice_analysis(a::ParameterSweep)::String
    # SPICE parameter sweep is more complex, using .step
    inner_str = to_spice_analysis(a.inner_analysis)
    sweep_lower = lowercase(a.sweep_type)
    type_str = sweep_lower in ("log", "logarithmic") ? "dec" : "lin"
    "$inner_str\n.step param $(a.param) $(a.start) $(a.stop) $(a.points)"
end
