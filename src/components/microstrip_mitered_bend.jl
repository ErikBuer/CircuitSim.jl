"""
    MicrostripMiteredBend <: AbstractMicrostripMiteredBend

A mitered microstrip 90° bend with corner cut for improved performance.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Node 1 (input)
- `n2::Int`: Node 2 (output)
- `substrate::Substrate`: Substrate definition reference
- `w::Real`: Line width (m)

# Example

```julia
sub = Substrate("FR4", er=4.5, h=1.6e-3)
bend = MicrostripMiteredBend("MB1", sub, w=3.0e-3)
```

# Qucs Format

`MBEND:Name Node1 Node2 Subst="SubstName" W="width"`
"""
mutable struct MicrostripMiteredBend <: AbstractMicrostripMiteredBend
    name::String
    n1::Int
    n2::Int
    substrate::Substrate
    w::Real

    function MicrostripMiteredBend(name::AbstractString, substrate::Substrate;
        w::Real=1e-3)
        w > 0 || throw(ArgumentError("Width must be positive"))
        new(String(name), 0, 0, substrate, w)
    end
end

function to_qucs_netlist(mb::MicrostripMiteredBend)::String
    parts = ["MBEND:$(mb.name)"]
    push!(parts, qucs_node(mb.n1))
    push!(parts, qucs_node(mb.n2))
    push!(parts, "Subst=\"$(mb.substrate.name)\"")
    push!(parts, "W=\"$(format_value(mb.w))\"")
    return join(parts, " ")
end

function to_spice_netlist(mb::MicrostripMiteredBend)::String
    "* Microstrip mitered bend $(mb.name) from $(mb.n1) to $(mb.n2), W=$(mb.w)m"
end

function _get_node_number(mb::MicrostripMiteredBend, terminal::Int)::Int
    terminal == 1 && return mb.n1
    terminal == 2 && return mb.n2
    throw(ArgumentError("MicrostripMiteredBend has only 2 terminals (1, 2), got $terminal"))
end
