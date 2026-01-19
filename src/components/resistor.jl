"""
    Resistor <: AbstractResistor

Ideal resistor with two terminals.

# Fields

- `name::String`: Component identifier
- `n1::Int`: First terminal node number (assigned during circuit analysis)
- `n2::Int`: Second terminal node number (assigned during circuit analysis)
- `resistance::Real`: Resistance in Ohms
- `temp::Real`: Operating temperature in Kelvin (default: 26.85)
- `tc1::Real`: First order temperature coefficient (default: 0.0)
- `tc2::Real`: Second order temperature coefficient (default: 0.0)
- `tnom::Real`: Nominal temperature in Kelvin (default: 26.85)

# Example

```julia
R1 = Resistor("R1", 1000.0)  # 1kΩ resistor
R2 = Resistor("R2", 2200.0, 85.0, 0.001, 0.0, 25.0)  # 2.2kΩ resistor with temperature coefficients
```
"""
mutable struct Resistor <: AbstractResistor
    name::String

    n1::Int
    n2::Int

    resistance::Real
    temp::Real
    tc1::Real
    tc2::Real
    tnom::Real

    function Resistor(name::AbstractString, resistance::Real, temp::Real=26.85, tc1::Real=0.0, tc2::Real=0.0, tnom::Real=26.85)
        new(String(name), 0, 0, resistance, temp, tc1, tc2, tnom)
    end
end

function to_qucs_netlist(comp::Resistor)::String
    netlist = "R:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) R=\"$(format_value(comp.resistance))\""
    if comp.temp != 26.85
        netlist *= " Temp=\"$(comp.temp)\""
    end
    if comp.tc1 != 0.0
        netlist *= " Tc1=\"$(comp.tc1)\""
    end
    if comp.tc2 != 0.0
        netlist *= " Tc2=\"$(comp.tc2)\""
    end
    if comp.tnom != 26.85
        netlist *= " Tnom=\"$(comp.tnom)\""
    end
    return netlist
end

function to_spice_netlist(comp::Resistor)::String
    "R$(comp.name) $(comp.n1) $(comp.n2) $(comp.resistance)"
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
