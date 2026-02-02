"""
    VoltageControlledCurrentSource(name::String; g::Real=1.0, t::Real=0.0)

Create a voltage-controlled current source with 4-port configuration.

# Arguments

- `name::String`: Component identifier
- `g::Real`: Transconductance in Siemens (A/V) (default 1.0)
- `t::Real`: Time delay in seconds (default 0.0)

# Fields

- `n1::Int`: Positive input control node
- `n2::Int`: Negative input control node
- `n3::Int`: Positive output node
- `n4::Int`: Negative output node
"""
mutable struct VoltageControlledCurrentSource <: AbstractSource
    name::String

    n1::Int  # Positive input control node
    n2::Int  # Negative input control node
    n3::Int  # Positive output node
    n4::Int  # Negative output node

    g::Real  # Transconductance in Siemens (A/V)
    t::Real  # Optional time delay in seconds

    function VoltageControlledCurrentSource(name::String;
        g::Real=1.0,
        t::Real=0.0
    )
        g >= 0 || throw(ArgumentError("Transconductance g must be non-negative, got $g"))
        t >= 0 || throw(ArgumentError("Time delay t must be non-negative, got $t"))
        new(name, -1, -1, -1, -1, g, t)
    end
end

# Qucsator netlist format: VCCS:Name Node1+ Node1- Node2+ Node2- G="..." T="..."
function to_qucs_netlist(c::VoltageControlledCurrentSource)
    params = "G=\"$(c.g)\""
    if c.t > 0.0
        params *= " T=\"$(c.t)\""
    end
    return "VCCS:$(c.name) $(qucs_node(c.n1)) $(qucs_node(c.n2)) $(qucs_node(c.n3)) $(qucs_node(c.n4)) $params"
end

# SPICE netlist format: G<name> <n+> <n-> <nc+> <nc-> <transconductance>
function to_spice_netlist(c::VoltageControlledCurrentSource)
    if c.t > 0.0
        @warn "SPICE does not support time delay T for VCCS $(c.name), ignoring"
    end
    return "G$(c.name) $(c.n3) $(c.n4) $(c.n1) $(c.n2) $(c.g)"
end

function _get_node_number(c::VoltageControlledCurrentSource, pin::Symbol)
    pin == :n1 && return c.n1
    pin == :n2 && return c.n2
    pin == :n3 && return c.n3
    pin == :n4 && return c.n4
    error("Unknown pin $pin for VoltageControlledCurrentSource")
end
