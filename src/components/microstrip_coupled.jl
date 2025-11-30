"""
Microstrip coupled lines component.
"""

"""
    MicrostripCoupled <: AbstractMicrostripCoupled

A pair of microstrip coupled transmission lines (4-port).

# Fields
- `name::String`: Component identifier
- `n1::Int`: Node 1 (line 1 input)
- `n2::Int`: Node 2 (line 1 output)
- `n3::Int`: Node 3 (line 2 input)
- `n4::Int`: Node 4 (line 2 output)
- `substrate::Substrate`: Substrate definition reference
- `w::Real`: Line width (m)
- `l::Real`: Line length (m)
- `s::Real`: Line spacing (m)

# Example
```julia
sub = Substrate("FR4", er=4.5, h=1.6e-3)
coupled = MicrostripCoupled("MCPL1", sub, w=1.0e-3, l=20e-3, s=0.2e-3)
```

# Qucs Format
`MCOUPLED:Name Node1 Node2 Node3 Node4 Subst="SubstName" W="width" L="length" S="spacing"`
"""
mutable struct MicrostripCoupled <: AbstractMicrostripCoupled
    name::String
    n1::Int
    n2::Int
    n3::Int
    n4::Int
    substrate::Substrate
    w::Real         # Line width (m)
    l::Real         # Line length (m)
    s::Real         # Line spacing (m)
    model::String   # Model name

    function MicrostripCoupled(name::AbstractString, substrate::Substrate;
        w::Real=1e-3,
        l::Real=10e-3,
        s::Real=0.2e-3,
        model::String="Kirschning")
        w > 0 || throw(ArgumentError("Width must be positive"))
        l > 0 || throw(ArgumentError("Length must be positive"))
        s > 0 || throw(ArgumentError("Spacing must be positive"))
        new(String(name), 0, 0, 0, 0, substrate, w, l, s, model)
    end
end

function to_qucs_netlist(mc::MicrostripCoupled)::String
    parts = ["MCOUPLED:$(mc.name)"]
    push!(parts, qucs_node(mc.n1))
    push!(parts, qucs_node(mc.n2))
    push!(parts, qucs_node(mc.n3))
    push!(parts, qucs_node(mc.n4))
    push!(parts, "Subst=\"$(mc.substrate.name)\"")
    push!(parts, "W=\"$(format_value(mc.w))\"")
    push!(parts, "L=\"$(format_value(mc.l))\"")
    push!(parts, "S=\"$(format_value(mc.s))\"")
    push!(parts, "Model=\"$(mc.model)\"")
    return join(parts, " ")
end

function to_spice_netlist(mc::MicrostripCoupled)::String
    "* Microstrip coupled lines $(mc.name) nodes $(mc.n1)-$(mc.n2)/$(mc.n3)-$(mc.n4), W=$(mc.w)m, L=$(mc.l)m, S=$(mc.s)m"
end

function _get_node_number(mc::MicrostripCoupled, terminal::Int)::Int
    terminal == 1 && return mc.n1
    terminal == 2 && return mc.n2
    terminal == 3 && return mc.n3
    terminal == 4 && return mc.n4
    throw(ArgumentError("MicrostripCoupled has 4 terminals (1, 2, 3, 4), got $terminal"))
end
