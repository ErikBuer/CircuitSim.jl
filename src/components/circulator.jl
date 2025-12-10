"""
    Circulator <: AbstractCirculator

3-port RF circulator.

A circulator routes signals in one direction: port 1→2, 2→3, 3→1.
Commonly used for isolating transmitter and receiver sharing an antenna.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Port 1 node number
- `n2::Int`: Port 2 node number
- `n3::Int`: Port 3 node number
- `insertion_loss::Real`: Loss through forward path (dB) (default: 0.5)
- `isolation::Real`: Isolation to reverse path (dB) (default: 20)
- `z0::Real`: Reference impedance in Ohms (default: 50)

# Example

```julia
using CircuitSim
# Standard circulator
CIRC1 = Circulator("CIRC1")

# Custom circulator with better isolation
CIRC2 = Circulator("CIRC2", isolation=30.0)
```
"""
mutable struct Circulator <: AbstractCirculator
    name::String
    n1::Int
    n2::Int
    n3::Int
    insertion_loss::Real
    isolation::Real
    z0::Real

    function Circulator(name::AbstractString;
        insertion_loss::Real=0.5,
        isolation::Real=20.0,
        z0::Real=50.0)
        insertion_loss >= 0 || throw(ArgumentError("Insertion loss must be non-negative"))
        isolation >= 0 || throw(ArgumentError("Isolation must be non-negative"))
        z0 > 0 || throw(ArgumentError("Impedance must be positive"))
        new(String(name), 0, 0, 0, insertion_loss, isolation, z0)
    end
end

function to_qucs_netlist(comp::Circulator)::String
    parts = ["Circulator:$(comp.name)"]
    push!(parts, "$(qucs_node(comp.n1))")
    push!(parts, "$(qucs_node(comp.n2))")
    push!(parts, "$(qucs_node(comp.n3))")
    push!(parts, "Z=\"$(format_value(comp.z0))\"")
    push!(parts, "IL=\"$(format_value(comp.insertion_loss)) dB\"")
    push!(parts, "Iso=\"$(format_value(comp.isolation)) dB\"")
    return join(parts, " ")
end

function to_spice_netlist(comp::Circulator)::String
    # SPICE approximation using S-parameters or behavioral model
    # Simplified model: controlled sources for each forward path
    g_fwd = 10^(-comp.insertion_loss / 20)
    g_iso = 10^(-comp.isolation / 20)

    lines = String[]
    push!(lines, "* Circulator $(comp.name): IL=$(comp.insertion_loss)dB, Iso=$(comp.isolation)dB")
    push!(lines, "B$(comp.name)_12 $(comp.n2) 0 V=V($(comp.n1))*$(g_fwd)")
    push!(lines, "B$(comp.name)_23 $(comp.n3) 0 V=V($(comp.n2))*$(g_fwd)")
    push!(lines, "B$(comp.name)_31 $(comp.n1) 0 V=V($(comp.n3))*$(g_fwd)")
    push!(lines, "R$(comp.name)_1 $(comp.n1) 0 $(comp.z0)")
    push!(lines, "R$(comp.name)_2 $(comp.n2) 0 $(comp.z0)")
    push!(lines, "R$(comp.name)_3 $(comp.n3) 0 $(comp.z0)")
    return join(lines, "\n")
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
