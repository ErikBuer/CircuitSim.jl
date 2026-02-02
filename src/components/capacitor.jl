"""
    Capacitor <: AbstractCapacitor

Ideal capacitor with two terminals.

# Fields

- `name::String`: Component identifier
- `n1::Int`: First terminal node number (assigned during circuit analysis)
- `n2::Int`: Second terminal node number (assigned during circuit analysis)
- `capacitance::Real`: Capacitance in Farads
- `initial_voltage::Real`: Initial voltage across the capacitor (default: 0.0)

# Example

```julia
C1 = Capacitor("C1", capacitance=100e-9)  # 100nF capacitor
C2 = Capacitor("C2", capacitance=10e-6, initial_voltage=5.0)  # 10µF capacitor with 5V initial voltage
```
"""
mutable struct Capacitor <: AbstractCapacitor
    name::String

    n1::Int
    n2::Int

    capacitance::Real
    initial_voltage::Real

    function Capacitor(name::AbstractString;
        capacitance::Real=1e-9,
        initial_voltage::Real=0.0
    )
        new(String(name), 0, 0, capacitance, initial_voltage)
    end
end

function to_qucs_netlist(comp::Capacitor)::String
    netlist = "C:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) C=\"$(format_value(comp.capacitance))\""
    if comp.initial_voltage != 0.0
        netlist *= " V=\"$(comp.initial_voltage)\""
    end
    return netlist
end

function to_spice_netlist(comp::Capacitor)::String
    netlist = "C$(comp.name) $(comp.n1) $(comp.n2) $(comp.capacitance)"
    if comp.initial_voltage != 0.0
        netlist *= " IC=$(comp.initial_voltage)"
    end
    return netlist
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
