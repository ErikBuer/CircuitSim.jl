"""
    MicrostripGap <: AbstractMicrostripGap

A microstrip series gap discontinuity providing capacitive coupling.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Node 1 (input)
- `n2::Int`: Node 2 (output)
- `w1::Real`: Width at port 1 in meters (default: 1e-3)
- `w2::Real`: Width at port 2 in meters (default: 1e-3)
- `s::Real`: Gap spacing in meters (default: 1e-3)
- `substrate::String`: Substrate reference name (default: "Subst1")
- `disp_model::String`: Dispersion model (default: "Kirschning")
- `model::String`: Microstrip model (default: "Hammerstad")

# Example

```julia
using CircuitSim
# Default gap
gap1 = MicrostripGap("MG1", w1=3.0e-3, w2=3.0e-3, s=0.2e-3)

# Custom substrate reference
gap2 = MicrostripGap("MG2", substrate="Sub1", 
    w1=3.0e-3, w2=3.0e-3, s=0.2e-3)
```

"""
mutable struct MicrostripGap <: AbstractMicrostripGap
    name::String

    n1::Int
    n2::Int

    w1::Real        # Width at port 1 (m)
    w2::Real        # Width at port 2 (m)
    s::Real         # Gap spacing (m)
    substrate::String  # Substrate reference name
    disp_model::String # Dispersion model
    model::String      # Microstrip model

    function MicrostripGap(name::AbstractString;
        w1::Real=1e-3,
        w2::Real=1e-3,
        s::Real=1e-3,
        substrate::String="Subst1",
        disp_model::String="Kirschning",
        model::String="Hammerstad"
    )
        w1 > 0 || throw(ArgumentError("Width 1 must be positive"))
        w2 > 0 || throw(ArgumentError("Width 2 must be positive"))
        s > 0 || throw(ArgumentError("Gap spacing must be positive"))
        new(String(name), 0, 0, w1, w2, s, substrate, disp_model, model)
    end
end

function to_qucs_netlist(mg::MicrostripGap)::String
    parts = ["MGAP:$(mg.name)"]
    push!(parts, qucs_node(mg.n1))
    push!(parts, qucs_node(mg.n2))
    push!(parts, "W1=\"$(format_value(mg.w1))\"")
    push!(parts, "W2=\"$(format_value(mg.w2))\"")
    push!(parts, "S=\"$(format_value(mg.s))\"")
    push!(parts, "Subst=\"$(mg.substrate)\"")
    push!(parts, "MSDispModel=\"$(mg.disp_model)\"")
    push!(parts, "MSModel=\"$(mg.model)\"")
    return join(parts, " ")
end

function _get_node_number(mg::MicrostripGap, terminal::Int)::Int
    terminal == 1 && return mg.n1
    terminal == 2 && return mg.n2
    throw(ArgumentError("MicrostripGap has only 2 terminals (1, 2), got $terminal"))
end
