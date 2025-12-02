"""
    Capacitor <: AbstractCapacitor

Ideal capacitor with two terminals.

# Fields
- `name::String`: Component identifier
- `n1::Int`: First terminal node number (assigned during circuit analysis)
- `n2::Int`: Second terminal node number (assigned during circuit analysis)
- `value::Real`: Capacitance in Farads

# Example
```julia
C1 = Capacitor("C1", 100e-9)  # 100nF capacitor
```
"""
mutable struct Capacitor <: AbstractCapacitor
    name::String
    n1::Int
    n2::Int
    value::Real
    Capacitor(name::AbstractString, value::Real) = new(String(name), 0, 0, value)
end

function to_qucs_netlist(comp::Capacitor)::String
    "C:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) C=\"$(format_value(comp.value))\""
end

function to_spice_netlist(comp::Capacitor)::String
    "C$(comp.name) $(comp.n1) $(comp.n2) $(comp.value)"
end

function _get_node_number(component::Capacitor, pin::Symbol)::Int
    if pin == :n1
        return component.n1
    elseif pin == :n2
        return component.n2
    else
        error("Invalid pin $pin for Capacitor. Use :n1 or :n2")
    end
end
