"""
    FourTerminalTransmissionLine <: AbstractTransmissionLine2Port

4-port differential transmission line (TLIN4P).

# Fields

- `name::String`: Component identifier
- `z0::Float64`: Characteristic impedance in Ω (default: 50.0)
- `length_m::Float64`: Physical length in meters (default: 1e-3)
- `alpha::Float64`: Attenuation factor (linear scale, default: 1.0, must be > 0)
- `temp::Float64`: Temperature in °C (default: 26.85)
- `n1::Int`: First differential pair, node 1
- `n2::Int`: First differential pair, node 2
- `n3::Int`: Second differential pair, node 1
- `n4::Int`: Second differential pair, node 2

# Pins

- `:n1`, `:n2`: First differential port
- `:n3`, `:n4`: Second differential port

# Example

```jldoctest
julia> tline = FourTerminalTransmissionLine("TL1", z0=75.0, length_m=0.1)
FourTerminalTransmissionLine("TL1", 0, 0, 0, 0, 75.0, 0.1, 1.0, 26.85)
```
"""
mutable struct FourTerminalTransmissionLine <: AbstractTransmissionLine2Port
    name::String

    n1::Int
    n2::Int
    n3::Int
    n4::Int

    z0::Float64
    length_m::Float64
    alpha::Float64
    temp::Float64

    function FourTerminalTransmissionLine(name::AbstractString;
        z0::Real=50.0,
        length_m::Real=1e-3,
        alpha::Real=1.0,
        temp::Real=26.85
    )
        alpha > 0 || error("alpha must be > 0 (got $alpha)")
        new(String(name), 0, 0, 0, 0, Float64(z0), Float64(length_m), Float64(alpha), Float64(temp))
    end
end

function to_qucs_netlist(comp::FourTerminalTransmissionLine)::String
    params = "Z=\"$(comp.z0)\" L=\"$(comp.length_m)\" Alpha=\"$(comp.alpha)\" Temp=\"$(comp.temp)\""
    return "TLIN4P:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) $(qucs_node(comp.n3)) $(qucs_node(comp.n4)) $params"
end

function _get_node_number(comp::FourTerminalTransmissionLine, pin::Symbol)
    if pin == :n1
        return comp.n1
    elseif pin == :n2
        return comp.n2
    elseif pin == :n3
        return comp.n3
    elseif pin == :n4
        return comp.n4
    else
        error("Invalid pin $pin for FourTerminalTransmissionLine. Use :n1, :n2, :n3, or :n4")
    end
end
