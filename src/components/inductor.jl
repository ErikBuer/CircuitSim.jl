"""
    Inductor <: AbstractInductor

Ideal inductor with two terminals.

# Fields

- `name::String`: Component identifier
- `n1::Int`: First terminal node number (assigned during circuit analysis)
- `n2::Int`: Second terminal node number (assigned during circuit analysis)
- `inductance::Real`: Inductance in Henries
- `initial_current::Real`: Initial current through the inductor in Amperes (for transient analysis)

# Example

```julia
L1 = Inductor("L1", inductance=10e-6)  # 10μH inductor
L2 = Inductor("L2", inductance=1e-3, initial_current=0.1)  # 1mH inductor with 100mA initial current
```
"""
mutable struct Inductor <: AbstractInductor
    name::String

    n1::Int
    n2::Int

    inductance::Real
    initial_current::Real

    function Inductor(name::AbstractString;
        inductance::Real,
        initial_current::Real=0.0
    )
        inductance > 0 || throw(ArgumentError("Inductance must be positive"))
        new(String(name), 0, 0, inductance, initial_current)
    end
end

function to_qucs_netlist(comp::Inductor)::String
    netlist = "L:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) L=\"$(format_inductance(comp.inductance))\""
    if comp.initial_current != 0.0
        netlist *= " I=\"$(comp.initial_current)\""
    end
    return netlist
end

function to_spice_netlist(comp::Inductor)::String
    netlist = "L$(comp.name) $(comp.n1) $(comp.n2) $(comp.inductance)"
    if comp.initial_current != 0.0
        netlist *= " IC=$(comp.initial_current)"
    end
    return netlist
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
