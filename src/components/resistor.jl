"""
    Resistor <: AbstractResistor

Ideal resistor with two terminals.

# Fields
- `name::String`: Component identifier
- `n1::Int`: First terminal node number (assigned during circuit analysis)
- `n2::Int`: Second terminal node number (assigned during circuit analysis)
- `value::Real`: Resistance in Ohms

# Example
```julia
R1 = Resistor("R1", 1000.0)  # 1kΩ resistor
```
"""
mutable struct Resistor <: AbstractResistor
    name::String
    n1::Int
    n2::Int
    value::Real
    Resistor(name::AbstractString, value::Real) = new(String(name), 0, 0, value)
end

function to_qucs_netlist(comp::Resistor)::String
    "R:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) R=\"$(format_value(comp.value))\""
end

function to_spice_netlist(comp::Resistor)::String
    "R$(comp.name) $(comp.n1) $(comp.n2) $(comp.value)"
end

function _get_node_number(component::Resistor, pin::Symbol)::Int
    if pin == :n1
        return component.n1
    elseif pin == :n2
        return component.n2
    else
        error("Invalid pin $pin for Resistor. Use :n1 or :n2")
    end
end
