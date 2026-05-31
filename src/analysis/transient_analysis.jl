"""
    TransientAnalysis(; name="TR1", type="lin", start=0.0, stop=1e-3, points=10,
                       integration_method="Trapezoidal", order=2,
                       initial_step=1e-9, min_step=1e-16, max_step=0.0,
                       max_iter=150, abstol=1e-12, vntol=1e-6, reltol=1e-3,
                       lte_abstol=1e-6, lte_reltol=1e-3, lte_factor=1.0,
                       temp=26.85, solver="CroutLU", relax_tsr=false,
                       initial_dc=true)

Time-domain transient analysis aligned with qucsator TR properties.

## Parameters

- `type::String`: Sweep type, `"lin"` or `"log"` (default: `"lin"`)
- `start::Real`: Start time in seconds (default: `0.0`)
- `stop::Real`: Stop time in seconds (default: `1e-3`)
- `points::Int`: Number of points (default: `10`, min: `2`)
- `integration_method::String`: `"Euler"`, `"Trapezoidal"`, `"Gear"`, or `"AdamsMoulton"`
- `order::Int`: Integration order (default: `2`, range: `1..6`)
- `initial_step::Real`: Initial step size in seconds (default: `1e-9`)
- `min_step::Real`: Minimum step size in seconds (default: `1e-16`)
- `max_step::Real`: Maximum step size in seconds (`0.0` lets solver auto-select)
- `max_iter::Int`: Maximum Newton iterations (default: `150`, range: `2..10000`)
- `abstol::Real`: Current absolute tolerance (default: `1e-12`)
- `vntol::Real`: Voltage tolerance (default: `1e-6`)
- `reltol::Real`: Relative tolerance (default: `1e-3`)
- `lte_abstol::Real`: LTE absolute tolerance (default: `1e-6`)
- `lte_reltol::Real`: LTE relative tolerance (default: `1e-3`)
- `lte_factor::Real`: LTE safety factor (default: `1.0`, range: `1..16`)
- `temp::Real`: Temperature in degC (default: `26.85`)
- `solver::String`: Linear solver algorithm
- `relax_tsr::Bool`: Relax time-step raster (default: `false`)
- `initial_dc::Bool`: Perform initial DC solve (default: `true`)

Compatibility aliases supported: `step`, `max_iterations`, `iabstol`, `vabstol`, `maxstep`, `minstep`.
"""
mutable struct TransientAnalysis <: AbstractAnalysis
    name::String
    type::String
    start::Real
    stop::Real
    points::Int
    integration_method::String
    order::Int
    initial_step::Real
    min_step::Real
    max_step::Real
    max_iter::Int
    abstol::Real
    vntol::Real
    reltol::Real
    lte_abstol::Real
    lte_reltol::Real
    lte_factor::Real
    temp::Real
    solver::String
    relax_tsr::Bool
    initial_dc::Bool
end

function TransientAnalysis(;
    name::String="TR1",
    type::String="lin",
    start::Real=0.0,
    stop::Real=1e-3,
    points::Union{Int,Nothing}=nothing,
    step::Union{Real,Nothing}=nothing,
    integration_method::String="Trapezoidal",
    order::Int=2,
    initial_step::Real=1e-9,
    min_step::Real=1e-16,
    max_step::Real=0.0,
    max_iter::Int=150,
    max_iterations::Union{Nothing,Int}=nothing,
    abstol::Real=1e-12,
    iabstol::Union{Nothing,Real}=nothing,
    vntol::Real=1e-6,
    vabstol::Union{Nothing,Real}=nothing,
    reltol::Real=1e-3,
    lte_abstol::Real=1e-6,
    lte_reltol::Real=1e-3,
    lte_factor::Real=1.0,
    temp::Real=26.85,
    solver::String="CroutLU",
    relax_tsr::Bool=false,
    initial_dc::Bool=true,
    maxstep::Union{Nothing,Real}=nothing,
    minstep::Union{Nothing,Real}=nothing,
)
    if max_iterations !== nothing
        max_iter = max_iterations
    end
    if iabstol !== nothing
        abstol = iabstol
    end
    if vabstol !== nothing
        vntol = vabstol
    end
    if maxstep !== nothing
        max_step = maxstep
    end
    if minstep !== nothing
        min_step = minstep
    end

    stop > start || throw(ArgumentError("Stop time must be greater than start time"))
    start >= 0 || throw(ArgumentError("Start time must be >= 0"))

    if points === nothing && step === nothing
        points = 10
    elseif points === nothing && step !== nothing
        step > 0 || throw(ArgumentError("step must be positive"))
        points = ceil(Int, (stop - start) / step) + 1
    elseif points !== nothing && step !== nothing
        throw(ArgumentError("Specify either points or step, not both"))
    end
    points >= 2 || throw(ArgumentError("points must be >= 2"))

    type_lower = lowercase(type)
    type_lower in ("lin", "log") || throw(ArgumentError("type must be 'lin' or 'log'"))

    method_key = lowercase(integration_method)
    method_canonical = if method_key == "euler"
        "Euler"
    elseif method_key == "trapezoidal"
        "Trapezoidal"
    elseif method_key == "gear"
        "Gear"
    elseif method_key == "adamsmoulton"
        "AdamsMoulton"
    else
        throw(ArgumentError("integration_method must be Euler, Trapezoidal, Gear, or AdamsMoulton"))
    end

    1 <= order <= 6 || throw(ArgumentError("order must be in range [1, 6]"))
    initial_step > 0 || throw(ArgumentError("initial_step must be positive"))
    min_step > 0 || throw(ArgumentError("min_step must be positive"))
    max_step >= 0 || throw(ArgumentError("max_step must be >= 0"))
    max_step == 0 || max_step >= min_step || throw(ArgumentError("max_step must be >= min_step, or 0 for auto"))

    2 <= max_iter <= 10000 || throw(ArgumentError("max_iter must be in range [2, 10000]"))
    0 < abstol <= 1 || throw(ArgumentError("abstol must be in range (0, 1]"))
    0 < vntol <= 1 || throw(ArgumentError("vntol must be in range (0, 1]"))
    0 < reltol <= 1 || throw(ArgumentError("reltol must be in range (0, 1]"))
    0 < lte_abstol <= 1 || throw(ArgumentError("lte_abstol must be in range (0, 1]"))
    0 < lte_reltol <= 1 || throw(ArgumentError("lte_reltol must be in range (0, 1]"))
    1 <= lte_factor <= 16 || throw(ArgumentError("lte_factor must be in range [1, 16]"))
    temp >= -273.15 || throw(ArgumentError("Temperature must be >= -273.15 degC"))

    solver in ("CroutLU", "DoolittleLU", "HouseholderQR", "HouseholderLQ", "GolubSVD") ||
        throw(ArgumentError("Invalid solver: \"$solver\""))

    return TransientAnalysis(
        name,
        type_lower,
        start,
        stop,
        points,
        method_canonical,
        order,
        initial_step,
        min_step,
        max_step,
        max_iter,
        abstol,
        vntol,
        reltol,
        lte_abstol,
        lte_reltol,
        lte_factor,
        temp,
        solver,
        relax_tsr,
        initial_dc,
    )
end

function to_qucs_analysis(a::TransientAnalysis)::String
    parts = [".TR:$(a.name)"]
    push!(parts, "Type=\"$(a.type)\"")
    push!(parts, "Start=\"$(format_value(a.start))\"")
    push!(parts, "Stop=\"$(format_value(a.stop))\"")
    push!(parts, "Points=\"$(a.points)\"")
    push!(parts, "IntegrationMethod=\"$(a.integration_method)\"")
    push!(parts, "Order=\"$(a.order)\"")
    push!(parts, "InitialStep=\"$(format_value(a.initial_step))\"")
    push!(parts, "MinStep=\"$(format_value(a.min_step))\"")
    push!(parts, "MaxStep=\"$(format_value(a.max_step))\"")
    push!(parts, "MaxIter=\"$(a.max_iter)\"")
    push!(parts, "abstol=\"$(format_value(a.abstol))\"")
    push!(parts, "vntol=\"$(format_value(a.vntol))\"")
    push!(parts, "reltol=\"$(format_value(a.reltol))\"")
    push!(parts, "LTEabstol=\"$(format_value(a.lte_abstol))\"")
    push!(parts, "LTEreltol=\"$(format_value(a.lte_reltol))\"")
    push!(parts, "LTEfactor=\"$(format_value(a.lte_factor))\"")
    push!(parts, "Temp=\"$(format_value(a.temp))\"")
    push!(parts, "Solver=\"$(a.solver)\"")
    push!(parts, "relaxTSR=\"$(a.relax_tsr ? "yes" : "no")\"")
    push!(parts, "initialDC=\"$(a.initial_dc ? "yes" : "no")\"")
    return join(parts, " ")
end

function to_spice_analysis(a::TransientAnalysis)::String
    a.type == "lin" || error("ngspice transient output does not support logarithmic point spacing")
    tstep = (a.stop - a.start) / (a.points - 1)
    tmax = a.max_step > 0 ? " $(format_value(a.max_step))" : ""
    uic = a.initial_dc ? "" : " uic"
    return ".tran $(format_value(tstep)) $(format_value(a.stop)) $(format_value(a.start))$(tmax)$(uic)"
end
