"""
    Inductor <: AbstractInductor

Ideal inductor with two terminals.

# Fields

- `name::String`: Component identifier
- `n1::Int`: First terminal node number (assigned during circuit analysis)
- `n2::Int`: Second terminal node number (assigned during circuit analysis)
- `inductance::Real`: Inductance in Henries

# Example

```julia
L1 = Inductor("L1", inductance=10e-6)  # 10μH inductor
```
"""
mutable struct Inductor <: AbstractInductor
    name::String

    n1::Int
    n2::Int

    inductance::Real
    Inductor(name::AbstractString;
        inductance::Real
    ) = new(String(name), 0, 0, inductance)
end

function to_qucs_netlist(comp::Inductor)::String
    "L:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) L=\"$(format_inductance(comp.inductance))\""
end

function to_spice_netlist(comp::Inductor)::String
    "L$(comp.name) $(comp.n1) $(comp.n2) $(comp.inductance)"
end

function _get_node_number(component::Inductor, pin::Symbol)::Int
    if pin == :n1
        return component.n1
    elseif pin == :n2
        return component.n2
    else
        error("Invalid pin $pin for Inductor. Use :n1 or :n2")
    end
end
