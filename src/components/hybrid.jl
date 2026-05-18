"""
    Hybrid <: AbstractHybridCoupler

Hybrid coupler (90° or 180° 3dB power splitter/combiner).

A hybrid coupler is a specialized 4-port device that splits power equally
between two ports with a specific phase relationship.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Port 1 node number
- `n2::Int`: Port 2 node number
- `n3::Int`: Port 3 node number
- `n4::Int`: Port 4 node number
- `phase::Real`: Phase difference in degrees (default: 0, range: -180 to +180)
- `z0::Real`: Reference impedance in Ohms (default: 50)

# Example

```julia
using CircuitSim
# Default hybrid (0° phase)
HYB1 = Hybrid("HYB1")

# 90° hybrid (quadrature hybrid)
HYB2 = Hybrid("HYB2", phase=90.0)

# 180° hybrid (rat-race, magic-T)
HYB3 = Hybrid("HYB3", phase=180.0)

# Custom impedance
HYB4 = Hybrid("HYB4", phase=90.0, z0=75.0)
```
"""
mutable struct Hybrid <: AbstractHybridCoupler
    name::String

    n1::Int
    n2::Int
    n3::Int
    n4::Int

    phase::Real
    z0::Real

    function Hybrid(name::AbstractString;
        phase::Real=0.0,
        z0::Real=50.0
    )
        -180 <= phase <= 180 || throw(ArgumentError("Phase must be between -180 and +180 degrees"))
        z0 > 0 || throw(ArgumentError("Impedance must be positive"))
        new(String(name), 0, 0, 0, 0, phase, z0)
    end
end

function to_qucs_netlist(comp::Hybrid)::String
    # Qucsator expects: phi (phase in degrees, required), Zref (reference impedance, optional)
    parts = ["Hybrid:$(comp.name)"]
    push!(parts, "$(qucs_node(comp.n1))")
    push!(parts, "$(qucs_node(comp.n2))")
    push!(parts, "$(qucs_node(comp.n3))")
    push!(parts, "$(qucs_node(comp.n4))")
    push!(parts, "phi=\"$(format_value(comp.phase))\"")
    push!(parts, "Zref=\"$(format_value(comp.z0))\"")
    return join(parts, " ")
end

function _get_node_number(component::Hybrid, pin::Symbol)::Int
    if pin == :n1 || pin == :sum || pin == :port1
        return component.n1
    elseif pin == :n2 || pin == :diff || pin == :isolated || pin == :port2
        return component.n2
    elseif pin == :n3 || pin == :out1 || pin == :port3
        return component.n3
    elseif pin == :n4 || pin == :out2 || pin == :port4
        return component.n4
    else
        error("Invalid pin $pin for Hybrid. Use :n1-:n4 or :sum/:diff/:out1/:out2")
    end
end
