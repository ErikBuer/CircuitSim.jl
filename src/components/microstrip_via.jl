"""
    MicrostripVia <: AbstractMicrostripVia

A microstrip via hole connecting to ground plane.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Node (top connection)
- `substrate::Substrate`: Substrate definition reference
- `d::Real`: Via hole diameter (m)
- `t::Real`: Metal thickness (m), uses substrate if 0

# Example

```julia
sub = Substrate("FR4", er=4.5, h=1.6e-3)
via = MicrostripVia("VIA1", sub, d=0.3e-3)
```

# Qucs Format

`MVIA:Name Node1 gnd Subst="SubstName" D="diameter"`
"""
mutable struct MicrostripVia <: AbstractMicrostripVia
    name::String
    n1::Int
    substrate::Substrate
    d::Real         # Via diameter (m)
    t::Real         # Metal thickness override (m), 0 = use substrate

    function MicrostripVia(name::AbstractString, substrate::Substrate;
        d::Real=0.3e-3,
        t::Real=0.0)
        d > 0 || throw(ArgumentError("Via diameter must be positive"))
        t >= 0 || throw(ArgumentError("Metal thickness must be non-negative"))
        new(String(name), 0, substrate, d, t)
    end
end

function to_qucs_netlist(mv::MicrostripVia)::String
    parts = ["MVIA:$(mv.name)"]
    push!(parts, qucs_node(mv.n1))
    push!(parts, "gnd")  # Vias connect to ground
    push!(parts, "Subst=\"$(mv.substrate.name)\"")
    push!(parts, "D=\"$(format_value(mv.d))\"")
    if mv.t > 0
        push!(parts, "T=\"$(format_value(mv.t))\"")
    end
    return join(parts, " ")
end

function to_spice_netlist(mv::MicrostripVia)::String
    # Approximate via as a small inductance
    "* Via $(mv.name) from $(mv.n1) to ground, D=$(mv.d)m"
end

function _get_node_number(mv::MicrostripVia, terminal::Int)::Int
    terminal == 1 && return mv.n1
    terminal == 2 && return 0  # Ground
    throw(ArgumentError("MicrostripVia has only 1 signal terminal (1) plus ground (2), got $terminal"))
end
