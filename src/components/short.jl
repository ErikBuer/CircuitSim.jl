"""
    Short <: AbstractShortCircuit

Short circuit (zero resistance connection between two nodes).

# Fields

- `name::String`: Component identifier
- `n1::Int`: First terminal node
- `n2::Int`: Second terminal node

# Pins

- `:n1`, `:n2`: Two-terminal short circuit

# Example

```jldoctest
julia> short = Short("S1")
Short("S1", 0, 0)
```
"""
mutable struct Short <: AbstractShortCircuit
    name::String
    n1::Int
    n2::Int
    Short(name::AbstractString) = new(String(name), 0, 0)
end

function to_qucs_netlist(comp::Short)::String
    # Qucsator doesn't have a Short component, use very low resistance
    return "R:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) R=\"1e-6\""
end

function to_spice_netlist(comp::Short)::String
    "R$(comp.name) $(comp.n1) $(comp.n2) 0"  # Zero-ohm resistor in SPICE
end

function _get_node_number(comp::Short, pin::Symbol)
    if pin == :n1
        return comp.n1
    elseif pin == :n2
        return comp.n2
    else
        error("Invalid pin $pin for Short. Use :n1 or :n2")
    end
end
