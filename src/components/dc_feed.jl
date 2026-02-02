"""
    DCFeed <: AbstractDCFeed

DC feed (RF choke) for providing DC bias while blocking RF.

This component passes DC current while presenting high impedance to RF signals.
Typically implemented as a large inductor.

# Fields

- `name::String`: Component identifier
- `n1::Int`: First terminal node number
- `n2::Int`: Second terminal node number
- `inductance::Real`: Inductance in Henries (default: 1 mH for good RF blocking)

# Example

```julia
using CircuitSim
# Default DC feed (1 mH)
DCF1 = DCFeed("DCF1")

# Custom inductance
DCF2 = DCFeed("DCF2", inductance=10e-3)  # 10 mH
```
"""
mutable struct DCFeed <: AbstractDCFeed
    name::String

    n1::Int
    n2::Int

    inductance::Real

    function DCFeed(name::AbstractString;
        inductance::Real=1e-3
    )
        inductance > 0 || throw(ArgumentError("Inductance must be positive"))
        new(String(name), 0, 0, inductance)
    end
end

function to_qucs_netlist(comp::DCFeed)::String
    "DCFeed:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) L=\"$(format_inductance(comp.inductance))\""
end

function to_spice_netlist(comp::DCFeed)::String
    "L$(comp.name)_dcf $(comp.n1) $(comp.n2) $(comp.inductance)"
end

function _get_node_number(component::DCFeed, pin::Symbol)::Int
    if pin == :n1
        return component.n1
    elseif pin == :n2
        return component.n2
    else
        error("Invalid pin $pin for DCFeed. Use :n1 or :n2")
    end
end
