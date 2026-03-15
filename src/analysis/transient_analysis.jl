"""
    TransientAnalysis(; stop, start=0.0, points=nothing, step=nothing, name="TR1", integration_method="trapezoidal", order=2, initial_dc=true, reltol=1e-3, vabstol=1e-6, iabstol=1e-12, maxstep=nothing, minstep=nothing, max_iterations=150)

Time-domain transient analysis.

Simulates the circuit behavior over time.

## Parameters

- `stop::Real`: Stop time in seconds (required)
- `start::Real`: Start time in seconds (default: 0.0)
- `points::Int`: Number of time points (specify either points or step)
- `step::Real`: Time step in seconds (specify either points or step)
- `name::String`: Analysis name (default: "TR1")
- `integration_method::String`: Integration method (default: "trapezoidal")
  - "euler" - Backward Euler (order 1)
  - "trapezoidal" - Trapezoidal/Bilinear (order 2)
  - "gear" - Gear (order 1-6)
  - "adamsmoulton" - Adams-Moulton (order 1-6)
- `order::Int`: Integration order for Gear and Adams-Moulton (default: 2, range: 1-6)
- `initial_dc::Bool`: Compute initial DC operating point (default: true)
- `reltol::Real`: Relative tolerance for error control (default: 1e-3)
- `vabstol::Real`: Voltage absolute tolerance in V (default: 1e-6)
- `iabstol::Real`: Current absolute tolerance in A (default: 1e-12)
- `maxstep::Union{Real,Nothing}`: Maximum time step in seconds (default: nothing, auto-calculated)
- `minstep::Union{Real,Nothing}`: Minimum time step in seconds (default: nothing, auto-calculated)
- `max_iterations::Int`: Maximum Newton-Raphson iterations (default: 150)

## Example

```julia
# Simulate for 1ms with 1001 points using trapezoidal
analysis = TransientAnalysis(stop=1e-3, points=1001)

# Simulate for 10μs with 10ns step using Gear order 4
analysis = TransientAnalysis(stop=10e-6, step=10e-9, integration_method="gear", order=4)

# Using backward Euler with custom tolerances
analysis = TransientAnalysis(stop=1e-3, points=501, integration_method="euler", reltol=1e-4, vabstol=1e-7)

# With explicit time step control
analysis = TransientAnalysis(stop=1e-3, points=1001, maxstep=1e-6, minstep=1e-12)
```
"""
mutable struct TransientAnalysis <: AbstractAnalysis
    name::String
    start::Real
    stop::Real
    points::Int
    integration_method::String
    order::Int
    initial_dc::Bool
    reltol::Real
    vabstol::Real
    iabstol::Real
    maxstep::Union{Real,Nothing}
    minstep::Union{Real,Nothing}
    max_iterations::Int
end

function TransientAnalysis(;
    name::String="TR1",
    stop::Real=1e-3,
    start::Real=0.0,
    points::Union{Int,Nothing}=nothing,
    step::Union{Real,Nothing}=nothing,
    integration_method::String="trapezoidal",
    order::Int=2,
    initial_dc::Bool=true,
    reltol::Real=1e-3,
    vabstol::Real=1e-6,
    iabstol::Real=1e-12,
    maxstep::Union{Real,Nothing}=nothing,
    minstep::Union{Real,Nothing}=nothing,
    max_iterations::Int=150
)
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

    # Validate integration method and order
    method_lower = lowercase(integration_method)
    if !(method_lower in ("euler", "trapezoidal", "gear", "adamsmoulton", "adamsbashford"))
        throw(ArgumentError("Invalid integration_method: \"$integration_method\". Must be 'euler', 'trapezoidal', 'gear', 'adamsmoulton', or 'adamsbashford'"))
    end

    # Validate order based on method
    if method_lower == "euler"
        order = 1  # Euler is always order 1
    elseif method_lower == "trapezoidal"
        order = 2  # Trapezoidal is always order 2
    elseif method_lower in ("gear", "adamsmoulton", "adamsbashford")
        if !(order >= 1 && order <= 6)
            throw(ArgumentError("Integration order for $method_lower must be between 1 and 6"))
        end
    end

    # Validate tolerances
    reltol > 0 && reltol < 1 || throw(ArgumentError("Relative tolerance must be in range (0, 1)"))
    vabstol > 0 && vabstol < 1 || throw(ArgumentError("Voltage absolute tolerance must be in range (0, 1)"))
    iabstol > 0 && iabstol < 1 || throw(ArgumentError("Current absolute tolerance must be in range (0, 1)"))
    max_iterations > 0 || throw(ArgumentError("Maximum iterations must be positive"))

    # Validate time step bounds if provided
    if maxstep !== nothing
        maxstep > 0 || throw(ArgumentError("Maximum time step must be positive"))
        maxstep <= (stop - start) || throw(ArgumentError("Maximum time step must not exceed simulation duration"))
    end
    if minstep !== nothing
        minstep > 0 || throw(ArgumentError("Minimum time step must be positive"))
    end
    if maxstep !== nothing && minstep !== nothing
        minstep < maxstep || throw(ArgumentError("Minimum time step must be less than maximum time step"))
    end

    TransientAnalysis(name, start, stop, points, method_lower, order, initial_dc,
        reltol, vabstol, iabstol, maxstep, minstep, max_iterations)
end

function to_qucs_analysis(a::TransientAnalysis)::String
    parts = [".TR:$(a.name)"]
    push!(parts, "Type=\"lin\"")
    push!(parts, "Start=\"$(format_value(a.start))\"")
    push!(parts, "Stop=\"$(format_value(a.stop))\"")
    push!(parts, "Points=\"$(a.points)\"")

    # Map integration method to Qucs format
    method_str = if a.integration_method == "euler"
        "Euler"
    elseif a.integration_method == "trapezoidal"
        "Trapezoidal"
    elseif a.integration_method == "gear"
        "Gear"
    elseif a.integration_method == "adamsmoulton"
        "AdamsMoulton"
    elseif a.integration_method == "adamsbashford"
        "AdamsBashford"
    else
        "Trapezoidal"
    end

    push!(parts, "IntegrationMethod=\"$method_str\"")
    push!(parts, "Order=\"$(a.order)\"")
    push!(parts, "InitialDC=\"$(a.initial_dc ? "yes" : "no")\"")

    # Add tolerance and convergence parameters
    push!(parts, "reltol=\"$(a.reltol)\"")
    push!(parts, "vabstol=\"$(format_value(a.vabstol))\"")
    push!(parts, "iabstol=\"$(format_value(a.iabstol))\"")
    push!(parts, "MaxIter=\"$(a.max_iterations)\"")

    # Add time step bounds if specified
    if a.maxstep !== nothing
        push!(parts, "MaxStep=\"$(format_value(a.maxstep))\"")
    end
    if a.minstep !== nothing
        push!(parts, "MinStep=\"$(format_value(a.minstep))\"")
    end

    return join(parts, " ")
end

function to_spice_analysis(a::TransientAnalysis)::String
    step = (a.stop - a.start) / (a.points - 1)
    uic = a.initial_dc ? "" : " uic"
    ".tran $(step) $(a.stop)$(uic)"
end
