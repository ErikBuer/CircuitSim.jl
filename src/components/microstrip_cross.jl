"""
Microstrip cross-junction component.
"""

"""
    MicrostripCross <: AbstractMicrostripCross

A microstrip cross-junction (4-port).

# Fields
- `name::String`: Component identifier
- `n1::Int`: Node 1 (port 1)
- `n2::Int`: Node 2 (port 2)
- `n3::Int`: Node 3 (port 3)
- `n4::Int`: Node 4 (port 4)
- `w1::Real`: Port 1 width in meters (default: 1e-3)
- `w2::Real`: Port 2 width in meters (default: 2e-3)
- `w3::Real`: Port 3 width in meters (default: 1e-3)
- `w4::Real`: Port 4 width in meters (default: 2e-3)
- `substrate::String`: Substrate reference name (default: "Subst1")
- `model::String`: Microstrip model (default: "Hammerstad")
- `disp_model::String`: Dispersion model (default: "Kirschning")

# Example
```julia
using CircuitSim
# Default cross junction
cross1 = MicrostripCross("MX1", w1=1.5e-3, w2=1.5e-3, w3=1.5e-3, w4=1.5e-3)

# Custom substrate reference
cross2 = MicrostripCross("MX2", substrate="Sub1", 
    w1=1.5e-3, w2=1.5e-3, w3=1.5e-3, w4=1.5e-3)
```

# Qucs Format
`MCROSS:Name Node1 Node2 Node3 Node4 W1="w1" W2="w2" W3="w3" W4="w4" Subst="SubstName" MSDispModel="..." MSModel="..."`
"""
mutable struct MicrostripCross <: AbstractMicrostripCross
    name::String

    n1::Int
    n2::Int
    n3::Int
    n4::Int

    w1::Real        # Port 1 width (m)
    w2::Real        # Port 2 width (m)
    w3::Real        # Port 3 width (m)
    w4::Real        # Port 4 width (m)
    substrate::String  # Substrate reference name
    disp_model::String # Dispersion model
    model::String      # Microstrip model

    function MicrostripCross(name::AbstractString;
        w1::Real=1e-3,
        w2::Real=2e-3,
        w3::Real=1e-3,
        w4::Real=2e-3,
        substrate::String="Subst1",
        disp_model::String="Kirschning",
        model::String="Hammerstad"
    )
        w1 > 0 || throw(ArgumentError("Width 1 must be positive"))
        w2 > 0 || throw(ArgumentError("Width 2 must be positive"))
        w3 > 0 || throw(ArgumentError("Width 3 must be positive"))
        w4 > 0 || throw(ArgumentError("Width 4 must be positive"))
        new(String(name), 0, 0, 0, 0, w1, w2, w3, w4, substrate, disp_model, model)
    end
end

function to_qucs_netlist(mx::MicrostripCross)::String
    parts = ["MCROSS:$(mx.name)"]
    push!(parts, qucs_node(mx.n1))
    push!(parts, qucs_node(mx.n2))
    push!(parts, qucs_node(mx.n3))
    push!(parts, qucs_node(mx.n4))
    push!(parts, "W1=\"$(format_value(mx.w1))\"")
    push!(parts, "W2=\"$(format_value(mx.w2))\"")
    push!(parts, "W3=\"$(format_value(mx.w3))\"")
    push!(parts, "W4=\"$(format_value(mx.w4))\"")
    push!(parts, "Subst=\"$(mx.substrate)\"")
    push!(parts, "MSDispModel=\"$(mx.disp_model)\"")
    push!(parts, "MSModel=\"$(mx.model)\"")
    return join(parts, " ")
end

function _get_node_number(mx::MicrostripCross, terminal::Int)::Int
    terminal == 1 && return mx.n1
    terminal == 2 && return mx.n2
    terminal == 3 && return mx.n3
    terminal == 4 && return mx.n4
    throw(ArgumentError("MicrostripCross has 4 terminals (1, 2, 3, 4), got $terminal"))
end
