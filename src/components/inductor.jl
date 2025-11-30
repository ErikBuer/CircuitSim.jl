"""
Ideal Inductor component.
"""

"""
    Inductor <: AbstractInductor

Ideal inductor with two terminals.

# Fields
- `name::String`: Component identifier
- `n1::Int`: First terminal node number (assigned during circuit analysis)
- `n2::Int`: Second terminal node number (assigned during circuit analysis)
- `value::Real`: Inductance in Henries

# Example
```julia
L1 = Inductor("L1", 10e-6)  # 10μH inductor
```
"""
mutable struct Inductor <: AbstractInductor
    name::String
    n1::Int
    n2::Int
    value::Real
    Inductor(name::AbstractString, value::Real) = new(String(name), 0, 0, value)
end

# =============================================================================
# Qucs Netlist Generation
# =============================================================================

function to_qucs_netlist(comp::Inductor)::String
    "L:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) L=\"$(format_value(comp.value))\""
end

# =============================================================================
# SPICE Netlist Generation
# =============================================================================

function to_spice_netlist(comp::Inductor)::String
    "L$(comp.name) $(comp.n1) $(comp.n2) $(comp.value)"
end

# =============================================================================
# Result Access Helpers
# =============================================================================

function _get_node_number(component::Inductor, pin::Symbol)::Int
    if pin == :n1
        return component.n1
    elseif pin == :n2
        return component.n2
    else
        error("Invalid pin $pin for Inductor. Use :n1 or :n2")
    end
end
