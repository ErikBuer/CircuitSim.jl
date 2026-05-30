"""
    TransmissionLine <: AbstractTransmissionLine

2-port ideal transmission line (TLIN).

# Fields

- `name::String`: Component identifier
- `z0::Float64`: Characteristic impedance in Ω (default: 50.0, must be > 0)
- `length_m::Float64`: Physical length in meters (default: 1e-3)
- `alpha::Float64`: Attenuation factor, linear scale (default: 1.0, must be > 0)
- `temp::Float64`: Temperature in °C (default: 26.85)
- `n1::Int`: Port 1 node
- `n2::Int`: Port 2 node

# Pins

- `:n1`: Port 1
- `:n2`: Port 2

# Example

```jldoctest
julia> tline = TransmissionLine("TL1", z0=75.0, length_m=0.1)
TransmissionLine("TL1", 0, 0, 75.0, 0.1, 1.0, 26.85)
```
"""
mutable struct TransmissionLine <: AbstractTransmissionLine
    name::String

    n1::Int
    n2::Int

    z0::Float64
    length_m::Float64
    alpha::Float64
    temp::Float64

    function TransmissionLine(name::AbstractString;
        z0::Real=50.0,
        length_m::Real=1e-3,
        alpha::Real=1.0,
        temp::Real=26.85
    )
        z0 > 0 || error("z0 must be > 0 (got $z0)")
        alpha > 0 || error("alpha must be > 0 (got $alpha)")
        new(String(name), 0, 0, Float64(z0), Float64(length_m), Float64(alpha), Float64(temp))
    end
end

function to_qucs_netlist(comp::TransmissionLine)::String
    params = "Z=\"$(comp.z0)\" L=\"$(comp.length_m)\" Alpha=\"$(comp.alpha)\" Temp=\"$(comp.temp)\""
    return "TLIN:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) $params"
end

function _get_node_number(comp::TransmissionLine, pin::Symbol)
    if pin == :n1
        return comp.n1
    elseif pin == :n2
        return comp.n2
    else
        error("Invalid pin $pin for TransmissionLine. Use :n1 or :n2")
    end
end

function _set_node_number!(comp::TransmissionLine, pin::Symbol, node::Int)
    if pin == :n1
        comp.n1 = node
    elseif pin == :n2
        comp.n2 = node
    else
        error("Invalid pin $pin for TransmissionLine. Use :n1 or :n2")
    end
end

function get_pins(::TransmissionLine)
    return [:n1, :n2]
end
