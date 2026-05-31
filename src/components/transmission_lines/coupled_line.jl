"""
    CoupledLine <: AbstractTransmissionLine

4-port coupled transmission line.

# Fields

- `name::String`: Component identifier
- `ze::Float64`: Even-mode characteristic impedance in Ω (default: 50.0, must be > 0)
- `zo::Float64`: Odd-mode characteristic impedance in Ω (default: 50.0, must be > 0)
- `length_m::Float64`: Physical length in meters (default: 1e-3)
- `ere::Float64`: Even-mode effective permittivity (default: 1.0, must be > 0)
- `ero::Float64`: Odd-mode effective permittivity (default: 1.0, must be > 0)
- `ae::Float64`: Even-mode attenuation factor, linear scale (default: 1.0, must be > 0)
- `ao::Float64`: Odd-mode attenuation factor, linear scale (default: 1.0, must be > 0)
- `temp::Float64`: Temperature in °C (default: 26.85)
- `n1::Int`: Port 1 node
- `n2::Int`: Port 2 node
- `n3::Int`: Port 3 node
- `n4::Int`: Port 4 node

# Pins

- `:n1`, `:n2`: First coupled line pair
- `:n3`, `:n4`: Second coupled line pair

# Example

```jldoctest
julia> cl = CoupledLine("CL1", ze=60.0, zo=40.0, length_m=0.02)
CoupledLine("CL1", 0, 0, 0, 0, 60.0, 40.0, 0.02, 1.0, 1.0, 1.0, 1.0, 26.85)
```
"""
mutable struct CoupledLine <: AbstractTransmissionLine
    name::String

    n1::Int
    n2::Int
    n3::Int
    n4::Int

    ze::Float64
    zo::Float64
    length_m::Float64
    ere::Float64
    ero::Float64
    ae::Float64
    ao::Float64
    temp::Float64

    function CoupledLine(name::AbstractString;
        ze::Real=50.0,
        zo::Real=50.0,
        length_m::Real=1e-3,
        ere::Real=1.0,
        ero::Real=1.0,
        ae::Real=1.0,
        ao::Real=1.0,
        temp::Real=26.85
    )
        ze > 0 || error("ze must be > 0 (got $ze)")
        zo > 0 || error("zo must be > 0 (got $zo)")
        ere > 0 || error("ere must be > 0 (got $ere)")
        ero > 0 || error("ero must be > 0 (got $ero)")
        ae > 0 || error("ae must be > 0 (got $ae)")
        ao > 0 || error("ao must be > 0 (got $ao)")
        new(String(name), 0, 0, 0, 0,
            Float64(ze), Float64(zo), Float64(length_m),
            Float64(ere), Float64(ero), Float64(ae), Float64(ao), Float64(temp))
    end
end

function to_qucs_netlist(comp::CoupledLine)::String
    params = "Ze=\"$(comp.ze)\" Zo=\"$(comp.zo)\" L=\"$(comp.length_m)\"" *
             " Ere=\"$(comp.ere)\" Ero=\"$(comp.ero)\"" *
             " Ae=\"$(comp.ae)\" Ao=\"$(comp.ao)\" Temp=\"$(comp.temp)\""
    return "CTLIN:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) $(qucs_node(comp.n3)) $(qucs_node(comp.n4)) $params"
end

function _get_node_number(comp::CoupledLine, pin::Symbol)
    if pin == :n1
        return comp.n1
    elseif pin == :n2
        return comp.n2
    elseif pin == :n3
        return comp.n3
    elseif pin == :n4
        return comp.n4
    else
        error("Invalid pin $pin for CoupledLine. Use :n1, :n2, :n3, or :n4")
    end
end

function _set_node_number!(comp::CoupledLine, pin::Symbol, node::Int)
    if pin == :n1
        comp.n1 = node
    elseif pin == :n2
        comp.n2 = node
    elseif pin == :n3
        comp.n3 = node
    elseif pin == :n4
        comp.n4 = node
    else
        error("Invalid pin $pin for CoupledLine. Use :n1, :n2, :n3, or :n4")
    end
end

function get_pins(comp::CoupledLine)
    return [:n1, :n2, :n3, :n4]
end
