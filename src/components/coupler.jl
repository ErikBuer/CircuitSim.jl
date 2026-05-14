"""
    Coupler <: AbstractCoupler

Directional coupler (4-port device).

A directional coupler splits power with specified coupling factor.
Ports: 1=input, 2=through, 3=coupled, 4=isolated

# Fields

- `name::String`: Component identifier
- `n1::Int`: Port 1 (input) node number
- `n2::Int`: Port 2 (through) node number
- `n3::Int`: Port 3 (coupled) node number
- `n4::Int`: Port 4 (isolated) node number
- `coupling::Real`: Coupling factor (linear, 0 to 1), default: √(1/2) ≈ 0.7071 (≈ 3 dB)
- `phase::Real`: Phase in degrees (default: 0, range: -180 to +180)
- `z0::Real`: Reference impedance in Ohms (default: 50)

# Example

```julia
using CircuitSim
# 3 dB (50/50) directional coupler - default coupling = √(1/2)
DC1 = Coupler("DC1")

# 10 dB directional coupler: coupling = 10^(-10/20) ≈ 0.316
DC2 = Coupler("DC2", coupling=0.316)

# 90° hybrid coupler (3 dB with 90° phase shift)
DC3 = Coupler("DC3", phase=90.0)
```
"""
mutable struct Coupler <: AbstractCoupler
    name::String

    n1::Int
    n2::Int
    n3::Int
    n4::Int

    coupling::Real
    phase::Real
    z0::Real

    function Coupler(name::AbstractString;
        coupling::Real=sqrt(1 / 2),
        phase::Real=0.0,
        z0::Real=50.0
    )
        0 <= coupling <= 1 || throw(ArgumentError("Coupling factor must be between 0 and 1"))
        -180 <= phase <= 180 || throw(ArgumentError("Phase must be between -180 and +180 degrees"))
        z0 > 0 || throw(ArgumentError("Impedance must be positive"))
        new(String(name), 0, 0, 0, 0, coupling, phase, z0)
    end
end

function to_qucs_netlist(comp::Coupler)::String
    parts = ["Coupler:$(comp.name)"]
    push!(parts, "$(qucs_node(comp.n1))")
    push!(parts, "$(qucs_node(comp.n2))")
    push!(parts, "$(qucs_node(comp.n3))")
    push!(parts, "$(qucs_node(comp.n4))")
    push!(parts, "k=\"$(format_value(comp.coupling))\"")
    push!(parts, "phi=\"$(format_value(comp.phase))\"")
    push!(parts, "Z=\"$(format_value(comp.z0))\"")
    return join(parts, " ")
end

function _get_node_number(component::Coupler, pin::Symbol)::Int
    if pin == :n1 || pin == :input || pin == :port1
        return component.n1
    elseif pin == :n2 || pin == :through || pin == :port2
        return component.n2
    elseif pin == :n3 || pin == :coupled || pin == :port3
        return component.n3
    elseif pin == :n4 || pin == :isolated || pin == :port4
        return component.n4
    else
        error("Invalid pin $pin for Coupler. Use :n1-:n4 or :input/:through/:coupled/:isolated")
    end
end
