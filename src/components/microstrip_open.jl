"""
Microstrip open-end component.
"""

"""
    MicrostripOpen <: AbstractMicrostripOpen

A microstrip open-circuit termination with end-effect modeling.

# Fields
- `name::String`: Component identifier
- `n1::Int`: Node 1 (input)
- `substrate::Substrate`: Substrate definition reference
- `w::Real`: Line width (m)

# Example
```julia
sub = Substrate("FR4", er=4.5, h=1.6e-3)
open_end = MicrostripOpen("MO1", sub, w=3.0e-3)
```

# Qucs Format
`MOPEN:Name Node1 Subst="SubstName" W="width"`
"""
mutable struct MicrostripOpen <: AbstractMicrostripOpen
    name::String
    n1::Int
    substrate::Substrate
    w::Real

    function MicrostripOpen(name::AbstractString, substrate::Substrate;
        w::Real=1e-3)
        w > 0 || throw(ArgumentError("Width must be positive"))
        new(String(name), 0, substrate, w)
    end
end

function to_qucs_netlist(mo::MicrostripOpen)::String
    parts = ["MOPEN:$(mo.name)"]
    push!(parts, qucs_node(mo.n1))
    push!(parts, "Subst=\"$(mo.substrate.name)\"")
    push!(parts, "W=\"$(format_value(mo.w))\"")
    push!(parts, "MSModel=\"Hammerstad\"")
    push!(parts, "MSDispModel=\"Kirschning\"")
    return join(parts, " ")
end

function to_spice_netlist(mo::MicrostripOpen)::String
    "* Microstrip open $(mo.name) at node $(mo.n1), W=$(mo.w)m"
end

function _get_node_number(mo::MicrostripOpen, terminal::Int)::Int
    terminal == 1 && return mo.n1
    throw(ArgumentError("MicrostripOpen has only 1 terminal (1), got $terminal"))
end
