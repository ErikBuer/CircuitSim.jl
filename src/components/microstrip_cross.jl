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
- `substrate::Substrate`: Substrate definition reference
- `w1::Real`: Port 1 width (m)
- `w2::Real`: Port 2 width (m)
- `w3::Real`: Port 3 width (m)
- `w4::Real`: Port 4 width (m)

# Example
```julia
sub = Substrate("FR4", er=4.5, h=1.6e-3)
cross = MicrostripCross("MX1", sub, w1=3.0e-3, w2=3.0e-3, w3=3.0e-3, w4=3.0e-3)
```

# Qucs Format
`MCROSS:Name Node1 Node2 Node3 Node4 Subst="SubstName" W1="w1" W2="w2" W3="w3" W4="w4"`
"""
mutable struct MicrostripCross <: AbstractMicrostripCross
    name::String

    n1::Int
    n2::Int
    n3::Int
    n4::Int

    substrate::Substrate
    w1::Real        # Port 1 width (m)
    w2::Real        # Port 2 width (m)
    w3::Real        # Port 3 width (m)
    w4::Real        # Port 4 width (m)

    function MicrostripCross(name::AbstractString;
        substrate::Substrate,
        w1::Real=1e-3,
        w2::Real=1e-3,
        w3::Real=1e-3,
        w4::Real=1e-3
    )
        w1 > 0 || throw(ArgumentError("Width 1 must be positive"))
        w2 > 0 || throw(ArgumentError("Width 2 must be positive"))
        w3 > 0 || throw(ArgumentError("Width 3 must be positive"))
        w4 > 0 || throw(ArgumentError("Width 4 must be positive"))
        new(String(name), 0, 0, 0, 0, substrate, w1, w2, w3, w4)
    end
end

function to_qucs_netlist(mx::MicrostripCross)::String
    parts = ["MCROSS:$(mx.name)"]
    push!(parts, qucs_node(mx.n1))
    push!(parts, qucs_node(mx.n2))
    push!(parts, qucs_node(mx.n3))
    push!(parts, qucs_node(mx.n4))
    push!(parts, "Subst=\"$(mx.substrate.name)\"")
    push!(parts, "W1=\"$(format_value(mx.w1))\"")
    push!(parts, "W2=\"$(format_value(mx.w2))\"")
    push!(parts, "W3=\"$(format_value(mx.w3))\"")
    push!(parts, "W4=\"$(format_value(mx.w4))\"")
    push!(parts, "MSModel=\"Hammerstad\"")
    push!(parts, "MSDispModel=\"Kirschning\"")
    return join(parts, " ")
end

function to_spice_netlist(mx::MicrostripCross)::String
    "* Microstrip cross $(mx.name) nodes $(mx.n1)-$(mx.n2)-$(mx.n3)-$(mx.n4)"
end

function _get_node_number(mx::MicrostripCross, terminal::Int)::Int
    terminal == 1 && return mx.n1
    terminal == 2 && return mx.n2
    terminal == 3 && return mx.n3
    terminal == 4 && return mx.n4
    throw(ArgumentError("MicrostripCross has 4 terminals (1, 2, 3, 4), got $terminal"))
end
