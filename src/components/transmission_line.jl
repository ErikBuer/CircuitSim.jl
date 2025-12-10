"""
    TransmissionLine <: AbstractComponent

Simple lossless transmission line.

# Fields

- `name::String`: Component identifier
- `z0::Float64`: Characteristic impedance in Ω (default: 50.0)
- `length_m::Float64`: Physical length in meters
- `alpha::Float64`: Attenuation constant in 1/m (default: 0.0)
- `n1::Int`: Input port positive node
- `n2::Int`: Input port negative node
- `n3::Int`: Output port positive node
- `n4::Int`: Output port negative node

# Pins

- `:n1`, `:n2`: Input port
- `:n3`, `:n4`: Output port

# Example

```jldoctest
julia> tline = TransmissionLine("TL1", z0=75.0, length_m=0.1)
TransmissionLine("TL1", 75.0, 0.1, 0.0, 0, 0, 0, 0)
```
"""
mutable struct TransmissionLine <: AbstractTransmissionLine2Port
    name::String
    z0::Float64
    length_m::Float64
    alpha::Float64
    n1::Int
    n2::Int
    n3::Int
    n4::Int

    function TransmissionLine(name::AbstractString; z0::Real=50.0, length_m::Real, alpha::Real=0.0)
        new(String(name), Float64(z0), Float64(length_m), Float64(alpha), 0, 0, 0, 0)
    end
end

function to_qucs_netlist(comp::TransmissionLine)::String
    # TLIN4P requires Alpha > 0, use small value if 0
    alpha_val = comp.alpha > 0 ? comp.alpha : 1e-10
    params = "Z=\"$(comp.z0)\" L=\"$(comp.length_m)\" Alpha=\"$alpha_val\""
    return "TLIN4P:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) $(qucs_node(comp.n3)) $(qucs_node(comp.n4)) $params"
end

function to_spice_netlist(comp::TransmissionLine)::String
    "T$(comp.name) $(comp.n1) $(comp.n2) $(comp.n3) $(comp.n4) Z0=$(comp.z0) TD=0"
end

function _get_node_number(comp::TransmissionLine, pin::Symbol)
    if pin == :n1
        return comp.n1
    elseif pin == :n2
        return comp.n2
    elseif pin == :n3
        return comp.n3
    elseif pin == :n4
        return comp.n4
    else
        error("Invalid pin $pin for TransmissionLine. Use :n1, :n2, :n3, or :n4")
    end
end
