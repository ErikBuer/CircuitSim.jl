"""
    TransientAnalysis(; stop, start=0.0, points=nothing, step=nothing, name="TR1", integration_method="trapezoidal", order=2, initial_dc=true)

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

## Example

```julia
# Simulate for 1ms with 1001 points using trapezoidal
analysis = TransientAnalysis(stop=1e-3, points=1001)

# Simulate for 10μs with 10ns step using Gear order 4
analysis = TransientAnalysis(stop=10e-6, step=10e-9, integration_method="gear", order=4)

# Using backward Euler
analysis = TransientAnalysis(stop=1e-3, points=501, integration_method="euler")
```
"""
struct TransientAnalysis <: AbstractAnalysis
    name::String
    start::Real
    stop::Real
    points::Int
    integration_method::String
    order::Int
    initial_dc::Bool
end

function TransientAnalysis(;
    stop::Real,
    start::Real=0.0,
    points::Union{Int,Nothing}=nothing,
    step::Union{Real,Nothing}=nothing,
    integration_method::String="trapezoidal",
    order::Int=2,
    initial_dc::Bool=true,
    name::String="TR1"
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

    TransientAnalysis(name, start, stop, points, method_lower, order, initial_dc)
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
    return join(parts, " ")
end

function to_spice_analysis(a::TransientAnalysis)::String
    step = (a.stop - a.start) / (a.points - 1)
    uic = a.initial_dc ? "" : " uic"
    ".tran $(step) $(a.stop)$(uic)"
end
