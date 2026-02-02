"""
    DCBlock <: AbstractDCBlock

DC blocking capacitor for RF applications.

This is essentially a large capacitor that passes AC signals while blocking DC.
Typically used to isolate DC bias points between stages.

# Fields

- `name::String`: Component identifier
- `n1::Int`: First terminal node number
- `n2::Int`: Second terminal node number
- `capacitance::Real`: Capacitance in Farads (default: 1 μF for near-ideal blocking)

# Example

```julia
using CircuitSim
# Default DC block (1 μF)
DCB1 = DCBlock("DCB1")

# Custom capacitance
DCB2 = DCBlock("DCB2", capacitance=10e-6)  # 10 μF
```
"""
mutable struct DCBlock <: AbstractDCBlock
    name::String

    n1::Int
    n2::Int

    capacitance::Real

    function DCBlock(name::AbstractString, capacitance::Real=1e-6)
        capacitance > 0 || throw(ArgumentError("Capacitance must be positive"))
        new(String(name), 0, 0, capacitance)
    end
end

function to_qucs_netlist(comp::DCBlock)::String
    "DCBlock:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) C=\"$(format_capacitance(comp.capacitance))\""
end

function to_spice_netlist(comp::DCBlock)::String
    "C$(comp.name)_dcb $(comp.n1) $(comp.n2) $(comp.capacitance)"
end

function _get_node_number(component::DCBlock, pin::Symbol)::Int
    if pin == :n1
        return component.n1
    elseif pin == :n2
        return component.n2
    else
        error("Invalid pin $pin for DCBlock. Use :n1 or :n2")
    end
end
