"""
    MicrostripStep <: AbstractMicrostripStep

A microstrip width step/discontinuity.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Node 1 (input, wider/narrower side)
- `n2::Int`: Node 2 (output, other side)
- `w1::Real`: Width at port 1 in meters (default: 1e-3)
- `w2::Real`: Width at port 2 in meters (default: 1e-3)
- `substrate::String`: Substrate reference name (default: "Subst1")
- `disp_model::String`: Dispersion model (default: "Kirschning")
- `model::String`: Quasi-static model (default: "Hammerstad")

# Example

```julia
using CircuitSim
# Default microstrip step
step1 = MicrostripStep("MSTEP1", w1=3.0e-3, w2=1.5e-3)

# Custom substrate reference
step2 = MicrostripStep("MSTEP2", substrate="Sub1", w1=3.0e-3, w2=1.5e-3)
```
"""
mutable struct MicrostripStep <: AbstractMicrostripStep
    name::String

    n1::Int
    n2::Int

    w1::Real               # Width at port 1 (m)
    w2::Real               # Width at port 2 (m)
    substrate::String      # Substrate reference name
    disp_model::String  # Dispersion model
    model::String       # Quasi-static model

    function MicrostripStep(name::AbstractString;
        w1::Real=1e-3,
        w2::Real=1e-3,
        substrate::String="Subst1",
        disp_model::String="Kirschning",
        model::String="Hammerstad"
    )
        if model ∉ ("Wheeler", "Schneider", "Hammerstad")
            throw(ArgumentError("Invalid model type: $model. Must be one of Wheeler, Schneider, Hammerstad"))
        end
        if disp_model ∉ ("Getsinger", "Schneider", "Yamashita", "Kobayashi", "Pramanick", "Hammerstad", "Kirschning")
            throw(ArgumentError("Invalid dispersion model type: $disp_model. Must be one of Getsinger, Schneider, Yamashita, Kobayashi, Pramanick, Hammerstad, Kirschning"))
        end
        w1 > 0 || throw(ArgumentError("Width 1 must be positive"))
        w2 > 0 || throw(ArgumentError("Width 2 must be positive"))
        new(String(name), 0, 0, w1, w2, substrate, disp_model, model)
    end
end

function to_qucs_netlist(ms::MicrostripStep)::String
    # Qucsator expects: W1, W2, Subst, MSDispModel, MSModel (all required)
    parts = ["MSTEP:$(ms.name)"]
    push!(parts, qucs_node(ms.n1))
    push!(parts, qucs_node(ms.n2))
    push!(parts, "W1=\"$(format_value(ms.w1))\"")
    push!(parts, "W2=\"$(format_value(ms.w2))\"")
    push!(parts, "Subst=\"$(ms.substrate)\"")
    push!(parts, "MSDispModel=\"$(ms.disp_model)\"")
    push!(parts, "MSModel=\"$(ms.model)\"")
    return join(parts, " ")
end

function _get_node_number(ms::MicrostripStep, terminal::Int)::Int
    terminal == 1 && return ms.n1
    terminal == 2 && return ms.n2
    throw(ArgumentError("MicrostripStep has only 2 terminals (1, 2), got $terminal"))
end
