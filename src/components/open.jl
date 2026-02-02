"""
    Open <: AbstractOpenCircuit

Open circuit (infinite resistance between two nodes).

# Fields

- `name::String`: Component identifier
- `n1::Int`: First terminal node
- `n2::Int`: Second terminal node

# Pins

- `:n1`, `:n2`: Two-terminal open circuit

# Example

```jldoctest
julia> open_ckt = Open("Open1")
Open("Open1", 0, 0)
```
"""
mutable struct Open <: AbstractOpenCircuit
    name::String

    n1::Int
    n2::Int

    Open(name::AbstractString) = new(String(name), 0, 0)
end

function to_qucs_netlist(comp::Open)::String
    # Qucsator doesn't have an Open component, use very high resistance
    return "R:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) R=\"1e12\""
end

function to_spice_netlist(comp::Open)::String
    "* Open $(comp.name) $(comp.n1) $(comp.n2) (not connected)"
end

function _get_node_number(comp::Open, pin::Symbol)
    if pin == :n1
        return comp.n1
    elseif pin == :n2
        return comp.n2
    else
        error("Invalid pin $pin for Open. Use :n1 or :n2")
    end
end
