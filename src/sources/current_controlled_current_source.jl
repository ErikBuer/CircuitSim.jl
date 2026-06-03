"""
    CurrentControlledCurrentSource(name::AbstractString; g::Real=1.0, t::Real=0.0)

Create a current-controlled current source with 4-port configuration.

# Arguments

- `name::AbstractString`: Component identifier
- `g::Real`: Current gain (dimensionless, can be negative) (default 1.0)
- `t::Real`: Time delay in seconds (default 0.0)

# Fields

- `n1::Int`: Positive input node (where current is sensed)
- `n2::Int`: Negative input node (where current is sensed)
- `n3::Int`: Positive output node
- `n4::Int`: Negative output node
"""
mutable struct CurrentControlledCurrentSource <: AbstractSource
    name::String

    n1::Int  # Positive input node (where current is sensed)
    n2::Int  # Negative input node (where current is sensed)
    n3::Int  # Positive output node
    n4::Int  # Negative output node

    g::Real  # Current gain (dimensionless)
    t::Real  # Optional time delay in seconds

    function CurrentControlledCurrentSource(name::AbstractString;
        g::Real=1.0,
        t::Real=0.0
    )
        t >= 0 || throw(ArgumentError("Time delay t must be non-negative, got $t"))
        new(String(name), -1, -1, -1, -1, g, t)
    end
end

# Qucsator netlist format: CCCS:Name Node1+ Node1- Node2+ Node2- G="..." T="..."
function to_qucs_netlist(c::CurrentControlledCurrentSource)
    params = "G=\"$(format_value(c.g))\""
    if c.t > 0.0
        params *= " T=\"$(format_value(c.t))\""
    end
    return "CCCS:$(c.name) $(qucs_node(c.n1)) $(qucs_node(c.n2)) $(qucs_node(c.n3)) $(qucs_node(c.n4)) $params"
end

function _get_node_number(c::CurrentControlledCurrentSource, pin::Symbol)
    pin == :n1 && return c.n1
    pin == :n2 && return c.n2
    pin == :n3 && return c.n3
    pin == :n4 && return c.n4
    error("Unknown pin $pin for CurrentControlledCurrentSource")
end
