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
- `z1::Real`: Port 1 impedance in Ohms (default: 50)
- `z2::Real`: Port 2 impedance in Ohms (default: 50)
- `temp::Real`: Temperature in Celsius (default: 26.85)

# Example

```julia
using CircuitSim
# Standard isolator with 50Ω ports
ISO1 = Isolator("ISO1")

# Isolator with custom port impedances
ISO2 = Isolator("ISO2", z1=50.0, z2=75.0)

# Isolator at specific temperature
ISO3 = Isolator("ISO3", temp=85.0)
```
"""
mutable struct Isolator <: AbstractIsolator
    name::String

    n1::Int
    n2::Int

    z1::Real
    z2::Real
    temp::Real

    function Isolator(name::AbstractString;
        z1::Real=50.0,
        z2::Real=50.0,
        temp::Real=26.85
    )
        z1 > 0 || throw(ArgumentError("Z1 impedance must be positive"))
        z2 > 0 || throw(ArgumentError("Z2 impedance must be positive"))
        temp >= -273.15 || throw(ArgumentError("Temperature must be above absolute zero"))
        new(String(name), 0, 0, z1, z2, temp)
    end
end

function to_qucs_netlist(comp::Isolator)::String
    parts = ["Isolator:$(comp.name)"]
    push!(parts, "$(qucs_node(comp.n1))")
    push!(parts, "$(qucs_node(comp.n2))")
    push!(parts, "Z1=\"$(format_value(comp.z1))\"")
    push!(parts, "Z2=\"$(format_value(comp.z2))\"")
    push!(parts, "Temp=\"$(format_value(comp.temp))\"")
    return join(parts, " ")
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
