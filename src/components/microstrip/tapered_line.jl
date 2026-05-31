"""
    TaperedLine <: AbstractTransmissionLine

2-port tapered transmission line (TAPEREDLINE).

# Fields

- `name::String`: Component identifier
- `n1::Int`: Port 1 node
- `n2::Int`: Port 2 node
- `z1::Float64`: Port 1 impedance in Ohm (default: 50.0, must be > 0)
- `z2::Float64`: Port 2 impedance in Ohm (default: 100.0, must be > 0)
- `length_m::Float64`: Physical length in meters (default: 75e-3)
- `weighting::String`: Profile weighting ("Exponential", "Linear", "Triangular", "Klopfenstein")
- `gamma_max::Float64`: Maximum ripple for Klopfenstein profile (default: 0.1, must be > 0)
- `alpha::Float64`: Loss coefficient in linear scale (default: 1.0, must be > 0)
- `temp::Float64`: Temperature in °C (default: 26.85)

# Pins

- `:n1`: Port 1
- `:n2`: Port 2

# Example

```jldoctest
julia> tl = TaperedLine("TP1")
TaperedLine("TP1", 0, 0, 50.0, 100.0, 0.075, "Exponential", 0.1, 1.0, 26.85)
```
"""
mutable struct TaperedLine <: AbstractTransmissionLine
    name::String

    n1::Int
    n2::Int

    z1::Float64
    z2::Float64
    length_m::Float64
    weighting::String
    gamma_max::Float64
    alpha::Float64
    temp::Float64

    function TaperedLine(name::AbstractString;
        z1::Real=50.0,
        z2::Real=100.0,
        length_m::Real=75e-3,
        weighting::String="Exponential",
        gamma_max::Real=0.1,
        alpha::Real=1.0,
        temp::Real=26.85
    )
        z1 > 0 || error("z1 must be > 0 (got $z1)")
        z2 > 0 || error("z2 must be > 0 (got $z2)")
        weighting in ["Exponential", "Linear", "Triangular", "Klopfenstein"] ||
            error("weighting must be one of: Exponential, Linear, Triangular, Klopfenstein")
        gamma_max > 0 || error("gamma_max must be > 0 (got $gamma_max)")
        alpha > 0 || error("alpha must be > 0 (got $alpha)")
        temp >= -273.15 || error("temp must be >= -273.15 (got $temp)")

        new(String(name), 0, 0,
            Float64(z1), Float64(z2), Float64(length_m),
            weighting, Float64(gamma_max), Float64(alpha), Float64(temp))
    end
end

function to_qucs_netlist(comp::TaperedLine)::String
    params = "Z1=\"$(comp.z1)\" Z2=\"$(comp.z2)\" L=\"$(comp.length_m)\"" *
             " Weighting=\"$(comp.weighting)\" Gamma_max=\"$(comp.gamma_max)\"" *
             " Alpha=\"$(comp.alpha)\" Temp=\"$(comp.temp)\""
    return "TAPEREDLINE:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) $params"
end

function _get_node_number(comp::TaperedLine, pin::Symbol)
    if pin == :n1
        return comp.n1
    elseif pin == :n2
        return comp.n2
    else
        error("Invalid pin $pin for TaperedLine. Use :n1 or :n2")
    end
end

function _set_node_number!(comp::TaperedLine, pin::Symbol, node::Int)
    if pin == :n1
        comp.n1 = node
    elseif pin == :n2
        comp.n2 = node
    else
        error("Invalid pin $pin for TaperedLine. Use :n1 or :n2")
    end
end

function get_pins(::TaperedLine)
    return [:n1, :n2]
end
