"""
    Circulator <: AbstractCirculator

3-port ideal RF circulator.

A circulator routes signals in one direction: port 1→2, 2→3, 3→1.
Commonly used for isolating transmitter and receiver sharing an antenna.

The circulator is defined by the impedances at each port. S-parameters 
are calculated from these port impedances.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Port 1 node number
- `n2::Int`: Port 2 node number
- `n3::Int`: Port 3 node number
- `z1::Real`: Port 1 impedance (Ω) (default: 50)
- `z2::Real`: Port 2 impedance (Ω) (default: 50)
- `z3::Real`: Port 3 impedance (Ω) (default: 50)

# Example

```julia
using CircuitSim
# Standard 50Ω circulator
CIRC1 = Circulator("CIRC1")

# Custom circulator with different port impedances
CIRC2 = Circulator("CIRC2", z1=50.0, z2=75.0, z3=50.0)
```
"""
mutable struct Circulator <: AbstractCirculator
    name::String

    n1::Int
    n2::Int
    n3::Int

    z1::Real  # Port 1 impedance (Ω)
    z2::Real  # Port 2 impedance (Ω)
    z3::Real  # Port 3 impedance (Ω)

    function Circulator(name::AbstractString;
        z1::Real=50.0,
        z2::Real=50.0,
        z3::Real=50.0
    )
        z1 > 0 || throw(ArgumentError("Port 1 impedance must be positive"))
        z2 > 0 || throw(ArgumentError("Port 2 impedance must be positive"))
        z3 > 0 || throw(ArgumentError("Port 3 impedance must be positive"))
        new(String(name), 0, 0, 0, z1, z2, z3)
    end
end

function to_qucs_netlist(comp::Circulator)::String
    parts = ["Circulator:$(comp.name)"]
    push!(parts, qucs_node(comp.n1))
    push!(parts, qucs_node(comp.n2))
    push!(parts, qucs_node(comp.n3))
    push!(parts, "Z1=\"$(format_value(comp.z1))\"")
    push!(parts, "Z2=\"$(format_value(comp.z2))\"")
    push!(parts, "Z3=\"$(format_value(comp.z3))\"")
    return join(parts, " ")
end


function _get_node_number(component::Circulator, pin::Symbol)::Int
    if pin == :n1 || pin == :port1
        return component.n1
    elseif pin == :n2 || pin == :port2
        return component.n2
    elseif pin == :n3 || pin == :port3
        return component.n3
    else
        error("Invalid pin $pin for Circulator. Use :n1/:port1, :n2/:port2, or :n3/:port3")
    end
end
