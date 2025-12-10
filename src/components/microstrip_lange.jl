"""
    MicrostripLange <: AbstractMicrostripLange

A Lange coupler - an interdigitated microstrip directional coupler providing tight coupling.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Node 1 (input)
- `n2::Int`: Node 2 (through)
- `n3::Int`: Node 3 (coupled)
- `n4::Int`: Node 4 (isolated)
- `substrate::Substrate`: Substrate definition reference
- `w::Real`: Finger width (m)
- `l::Real`: Finger length (m)
- `s::Real`: Finger spacing (m)
- `n::Int`: Number of fingers

# Example

```julia
sub = Substrate("RO4003C", er=3.55, h=0.508e-3)
lange = MicrostripLange("LC1", sub, w=0.15e-3, l=10e-3, s=0.1e-3, n=4)
```

# Qucs Format

`MLANGE:Name Node1 Node2 Node3 Node4 Subst="SubstName" W="width" L="length" S="spacing" N="fingers"`
"""
mutable struct MicrostripLange <: AbstractMicrostripLange
    name::String
    n1::Int
    n2::Int
    n3::Int
    n4::Int
    substrate::Substrate
    w::Real         # Finger width (m)
    l::Real         # Finger length (m)
    s::Real         # Finger spacing (m)
    nfingers::Int   # Number of fingers (renamed to avoid conflict with node fields)

    function MicrostripLange(name::AbstractString, substrate::Substrate;
        w::Real=0.15e-3,
        l::Real=10e-3,
        s::Real=0.1e-3,
        n::Int=4)
        w > 0 || throw(ArgumentError("Finger width must be positive"))
        l > 0 || throw(ArgumentError("Finger length must be positive"))
        s > 0 || throw(ArgumentError("Finger spacing must be positive"))
        n >= 3 || throw(ArgumentError("Number of fingers must be at least 3"))
        new(String(name), 0, 0, 0, 0, substrate, w, l, s, n)
    end
end

function to_qucs_netlist(ml::MicrostripLange)::String
    parts = ["MLANGE:$(ml.name)"]
    push!(parts, qucs_node(ml.n1))
    push!(parts, qucs_node(ml.n2))
    push!(parts, qucs_node(ml.n3))
    push!(parts, qucs_node(ml.n4))
    push!(parts, "Subst=\"$(ml.substrate.name)\"")
    push!(parts, "W=\"$(format_value(ml.w))\"")
    push!(parts, "L=\"$(format_value(ml.l))\"")
    push!(parts, "S=\"$(format_value(ml.s))\"")
    push!(parts, "N=\"$(ml.nfingers)\"")
    return join(parts, " ")
end

function to_spice_netlist(ml::MicrostripLange)::String
    "* Lange coupler $(ml.name) ports $(ml.n1)-$(ml.n2)-$(ml.n3)-$(ml.n4), W=$(ml.w)m, L=$(ml.l)m, S=$(ml.s)m, N=$(ml.nfingers)"
end

function _get_node_number(ml::MicrostripLange, terminal::Int)::Int
    terminal == 1 && return ml.n1
    terminal == 2 && return ml.n2
    terminal == 3 && return ml.n3
    terminal == 4 && return ml.n4
    throw(ArgumentError("MicrostripLange has 4 terminals (1, 2, 3, 4), got $terminal"))
end
