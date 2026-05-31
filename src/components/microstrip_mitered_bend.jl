"""
    MicrostripMiteredBend <: AbstractMicrostripMiteredBend

A mitered microstrip 90° bend with corner cut for improved performance.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Node 1 (input)
- `n2::Int`: Node 2 (output)
- `w::Real`: Line width in meters (default: 1e-3)
- `substrate::String`: Substrate reference name (default: "Subst1")

# Example

```julia
using CircuitSim
# Default mitered bend
bend1 = MicrostripMiteredBend("MB1", w=3.0e-3)

# Custom substrate reference
bend2 = MicrostripMiteredBend("MB2", substrate="Sub1", w=3.0e-3)
```

# Qucs Format

`MMBEND:Name Node1 Node2 W="width" Subst="SubstName"`
"""
mutable struct MicrostripMiteredBend <: AbstractMicrostripMiteredBend
    name::String

    n1::Int
    n2::Int

    w::Real            # Width (m)
    substrate::String  # Substrate reference name

    function MicrostripMiteredBend(name::AbstractString;
        w::Real=1e-3,
        substrate::String="Subst1"
    )
        w > 0 || throw(ArgumentError("Width must be positive"))
        new(String(name), 0, 0, w, substrate)
    end
end

function to_qucs_netlist(mb::MicrostripMiteredBend)::String
    parts = ["MMBEND:$(mb.name)"]
    push!(parts, qucs_node(mb.n1))
    push!(parts, qucs_node(mb.n2))
    push!(parts, "W=\"$(format_value(mb.w))\"")
    push!(parts, "Subst=\"$(mb.substrate)\"")
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
