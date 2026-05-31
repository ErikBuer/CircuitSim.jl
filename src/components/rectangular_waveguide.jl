"""
    RectangularWaveguide <: AbstractTransmissionLine

2-port rectangular waveguide in TE10 mode (RECTLINE).

# Fields

- `name::String`: Component identifier
- `n1::Int`: Port 1 node
- `n2::Int`: Port 2 node
- `a::Float64`: Wider dimension in meters (default: 2.86e-2, must be > 0)
- `b::Float64`: Narrower dimension in meters (default: 1.016e-2, must be > 0)
- `length_m::Float64`: Physical length in meters (default: 1500e-3)
- `er::Float64`: Relative permittivity (default: 1.0, range [1, 100])
- `mur::Float64`: Relative permeability (default: 1.0, range [1, 100])
- `tand::Float64`: Loss tangent (default: 4e-4, must be > 0)
- `rho::Float64`: Resistivity in Ohm·m (default: 0.022e-6, must be > 0)
- `temp::Float64`: Temperature in °C (default: 26.85)
- `material::String`: Wall material ("unspecified", "Copper", "StainlessSteel", "Gold")

# Pins

- `:n1`: Port 1
- `:n2`: Port 2

# Example

```jldoctest
julia> wg = RectangularWaveguide("WG1")
RectangularWaveguide("WG1", 0, 0, 0.0286, 0.010160000000000001, 1.5, 1.0, 1.0, 0.0004, 2.2e-8, 26.85, "unspecified")
```
"""
mutable struct RectangularWaveguide <: AbstractTransmissionLine
    name::String

    n1::Int
    n2::Int

    a::Float64
    b::Float64
    length_m::Float64
    er::Float64
    mur::Float64
    tand::Float64
    rho::Float64
    temp::Float64
    material::String

    function RectangularWaveguide(name::AbstractString;
        a::Real=2.86e-2,
        b::Real=1.016e-2,
        length_m::Real=1500e-3,
        er::Real=1.0,
        mur::Real=1.0,
        tand::Real=4e-4,
        rho::Real=0.022e-6,
        temp::Real=26.85,
        material::String="unspecified"
    )
        a > 0 || error("a must be > 0 (got $a)")
        b > 0 || error("b must be > 0 (got $b)")
        1 <= er <= 100 || error("er must be in [1, 100] (got $er)")
        1 <= mur <= 100 || error("mur must be in [1, 100] (got $mur)")
        tand > 0 || error("tand must be > 0 (got $tand)")
        rho > 0 || error("rho must be > 0 (got $rho)")
        temp >= -273.15 || error("temp must be >= -273.15 (got $temp)")
        material in ["unspecified", "Copper", "StainlessSteel", "Gold"] ||
            error("material must be one of: unspecified, Copper, StainlessSteel, Gold")

        new(String(name), 0, 0,
            Float64(a), Float64(b), Float64(length_m),
            Float64(er), Float64(mur), Float64(tand), Float64(rho),
            Float64(temp), material)
    end
end

function to_qucs_netlist(comp::RectangularWaveguide)::String
    params = "a=\"$(comp.a)\" b=\"$(comp.b)\" L=\"$(comp.length_m)\"" *
             " er=\"$(comp.er)\" mur=\"$(comp.mur)\"" *
             " tand=\"$(comp.tand)\" rho=\"$(comp.rho)\"" *
             " Temp=\"$(comp.temp)\" Material=\"$(comp.material)\""
    return "RECTLINE:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) $params"
end

function _get_node_number(comp::RectangularWaveguide, pin::Symbol)
    if pin == :n1
        return comp.n1
    elseif pin == :n2
        return comp.n2
    else
        error("Invalid pin $pin for RectangularWaveguide. Use :n1 or :n2")
    end
end

function _set_node_number!(comp::RectangularWaveguide, pin::Symbol, node::Int)
    if pin == :n1
        comp.n1 = node
    elseif pin == :n2
        comp.n2 = node
    else
        error("Invalid pin $pin for RectangularWaveguide. Use :n1 or :n2")
    end
end

function get_pins(::RectangularWaveguide)
    return [:n1, :n2]
end
