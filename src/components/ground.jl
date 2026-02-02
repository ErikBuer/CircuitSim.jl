"""
Ground reference component.
"""

"""
    Ground <: AbstractGround

Ground reference node (single pin). Maps to node 0.

# Fields

- `name::String`: Component identifier
- `n::Int`: Terminal node number (always 0 for ground)

# Example

```julia
GND = Ground("GND")
```
"""
mutable struct Ground <: AbstractGround
    name::String

    n::Int

    Ground(name::AbstractString="GND") = new(String(name), 0)
end

function to_qucs_netlist(comp::Ground)::String
    ""  # Ground is implicit at gnd node, no netlist entry needed
end

function to_spice_netlist(comp::Ground)::String
    "* Ground $(comp.name) -> node 0"
end

function _get_node_number(component::Ground, pin::Symbol)::Int
    if pin == :n
        return component.n
    else
        error("Invalid pin $pin for Ground. Use :n")
    end
end
