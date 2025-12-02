"""
Time-domain transient analysis.
"""

"""
    TransientAnalysis(stop; start=0.0, points=nothing, step=nothing, name="TR1")

Time-domain transient analysis.

Simulates the circuit behavior over time.

# Parameters
- `stop::Real`: Stop time in seconds
- `start::Real`: Start time in seconds (default: 0.0)
- `points::Int`: Number of time points (specify either points or step)
- `step::Real`: Time step in seconds (specify either points or step)
- `name::String`: Analysis name (default: "TR1")
- `initial_dc::Bool`: Compute initial DC operating point (default: true)

# Example
```julia
# Simulate for 1ms with 1001 points
analysis = TransientAnalysis(1e-3, points=1001)

# Simulate for 10μs with 10ns step
analysis = TransientAnalysis(10e-6, step=10e-9)
```
"""
struct TransientAnalysis <: AbstractAnalysis
    name::String
    start::Real
    stop::Real
    points::Int
    initial_dc::Bool

    function TransientAnalysis(stop::Real; start::Real=0.0,
        points::Union{Int,Nothing}=nothing,
        step::Union{Real,Nothing}=nothing,
        name::String="TR1",
        initial_dc::Bool=true)
        stop > start || throw(ArgumentError("Stop time must be greater than start time"))

        # Calculate points from step or use default
        if points === nothing && step === nothing
            points = 101  # Default
        elseif points === nothing && step !== nothing
            points = ceil(Int, (stop - start) / step) + 1
        elseif points !== nothing
            # Use provided points
        else
            throw(ArgumentError("Specify either points or step, not both"))
        end

        points >= 2 || throw(ArgumentError("Number of points must be at least 2"))
        new(name, start, stop, points, initial_dc)
    end
end

function to_qucs_analysis(a::TransientAnalysis)::String
    parts = [".TR:$(a.name)"]
    push!(parts, "Type=\"lin\"")
    push!(parts, "Start=\"$(format_value(a.start))\"")
    push!(parts, "Stop=\"$(format_value(a.stop))\"")
    push!(parts, "Points=\"$(a.points)\"")
    push!(parts, "IntegrationMethod=\"Trapezoidal\"")
    return join(parts, " ")
end


function to_spice_analysis(a::TransientAnalysis)::String
    step = (a.stop - a.start) / (a.points - 1)
    ".tran $(step) $(a.stop)"
end
