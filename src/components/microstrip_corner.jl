"""
Microstrip corner (90° bend) component.
"""

"""
    MicrostripCorner <: AbstractMicrostripCorner

A 90° microstrip corner/bend.

# Fields
- `name::String`: Component identifier
- `n1::Int`: Node 1 (input)
- `n2::Int`: Node 2 (output)
- `substrate::Substrate`: Substrate definition reference
- `w::Real`: Line width (m)

# Example
```julia
sub = Substrate("FR4", er=4.5, h=1.6e-3)
corner = MicrostripCorner("MC1", sub, w=3.0e-3)
```

# Qucs Format
`MCORN:Name Node1 Node2 Subst="SubstName" W="width"`
"""
mutable struct MicrostripCorner <: AbstractMicrostripCorner
    name::String
    n1::Int
    n2::Int
    substrate::Substrate
    w::Real

    function MicrostripCorner(name::AbstractString, substrate::Substrate;
        w::Real=1e-3)
        w > 0 || throw(ArgumentError("Width must be positive"))
        new(String(name), 0, 0, substrate, w)
    end
end

function to_qucs_netlist(mc::MicrostripCorner)::String
    parts = ["MCORN:$(mc.name)"]
    push!(parts, qucs_node(mc.n1))
    push!(parts, qucs_node(mc.n2))
    push!(parts, "Subst=\"$(mc.substrate.name)\"")
    push!(parts, "W=\"$(format_value(mc.w))\"")
    return join(parts, " ")
end

function to_spice_netlist(mc::MicrostripCorner)::String
    "* Microstrip corner $(mc.name) from $(mc.n1) to $(mc.n2), W=$(mc.w)m"
end

function _get_node_number(mc::MicrostripCorner, terminal::Int)::Int
    terminal == 1 && return mc.n1
    terminal == 2 && return mc.n2
    throw(ArgumentError("MicrostripCorner has only 2 terminals (1, 2), got $terminal"))
end
