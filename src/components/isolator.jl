"""
    Isolator <: AbstractIsolator

RF isolator (unidirectional component).

An isolator allows signals to pass in one direction (forward) while 
blocking signals in the reverse direction. Commonly used to protect 
sources from reflections.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Input terminal node number
- `n2::Int`: Output terminal node number
- `forward_loss::Real`: Insertion loss in forward direction (dB) (default: 0.5)
- `reverse_loss::Real`: Isolation in reverse direction (dB) (default: 20)
- `z0::Real`: Reference impedance in Ohms (default: 50)

# Example

```julia
using CircuitSim
# Standard isolator: 0.5 dB forward loss, 20 dB isolation
ISO1 = Isolator("ISO1")

# Custom isolator: 1 dB forward loss, 30 dB isolation
ISO2 = Isolator("ISO2", forward_loss=1.0, reverse_loss=30.0)
```
"""
mutable struct Isolator <: AbstractIsolator
    name::String
    n1::Int
    n2::Int
    forward_loss::Real
    reverse_loss::Real
    z0::Real

    function Isolator(name::AbstractString;
        forward_loss::Real=0.5,
        reverse_loss::Real=20.0,
        z0::Real=50.0)
        forward_loss >= 0 || throw(ArgumentError("Forward loss must be non-negative"))
        reverse_loss >= 0 || throw(ArgumentError("Reverse loss must be non-negative"))
        z0 > 0 || throw(ArgumentError("Impedance must be positive"))
        new(String(name), 0, 0, forward_loss, reverse_loss, z0)
    end
end

function to_qucs_netlist(comp::Isolator)::String
    parts = ["Isolator:$(comp.name)"]
    push!(parts, "$(qucs_node(comp.n1))")
    push!(parts, "$(qucs_node(comp.n2))")
    push!(parts, "L1=\"$(format_value(comp.forward_loss)) dB\"")
    push!(parts, "L2=\"$(format_value(comp.reverse_loss)) dB\"")
    push!(parts, "Z=\"$(format_value(comp.z0))\"")
    return join(parts, " ")
end

function to_spice_netlist(comp::Isolator)::String
    # SPICE approximation using voltage-controlled sources
    # Forward path: attenuator
    # Reverse path: high attenuation
    g_forward = 10^(-comp.forward_loss / 20)
    g_reverse = 10^(-comp.reverse_loss / 20)

    lines = String[]
    push!(lines, "* Isolator $(comp.name): Forward=$(comp.forward_loss)dB, Reverse=$(comp.reverse_loss)dB")
    push!(lines, "B$(comp.name)_fwd $(comp.n2) 0 V=V($(comp.n1))*$(g_forward)")
    push!(lines, "R$(comp.name)_load $(comp.n2) 0 $(comp.z0)")
    return join(lines, "\n")
end

function _get_node_number(component::Isolator, pin::Symbol)::Int
    if pin == :n1 || pin == :input
        return component.n1
    elseif pin == :n2 || pin == :output
        return component.n2
    else
        error("Invalid pin $pin for Isolator. Use :n1/:input or :n2/:output")
    end
end
