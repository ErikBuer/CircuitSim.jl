"""
    CoaxialLine <: AbstractComponent

Coaxial transmission line with physical parameters.

# Fields

- `name::String`: Component identifier
- `er::Float64`: Relative permittivity (default: 2.3)
- `mur::Float64`: Relative permeability (default: 1.0)
- `length_m::Float64`: Physical length in meters
- `d_mm::Float64`: Inner conductor diameter in mm
- `d_outer_mm::Float64`: Outer conductor diameter in mm
- `n1::Int`: Input port positive node
- `n2::Int`: Input port negative node
- `n3::Int`: Output port positive node
- `n4::Int`: Output port negative node

# Pins

- `:n1`, `:n2`: Input port
- `:n3`, `:n4`: Output port

# Example

```jldoctest
julia> coax = CoaxialLine("COAX1", er=2.3, length_m=0.1, d_mm=0.5, d_outer_mm=3.0)
CoaxialLine("COAX1", 2.3, 1.0, 0.1, 0.5, 3.0, 0.0004, 2.2e-8, 0, 0)
```
"""
mutable struct CoaxialLine <: AbstractTransmissionLine2Port
    name::String
    er::Float64
    mur::Float64
    length_m::Float64
    d_mm::Float64
    d_outer_mm::Float64
    tand::Float64
    rho::Float64
    n1::Int
    n2::Int

    function CoaxialLine(name::AbstractString; er::Real=2.3, mur::Real=1.0, length_m::Real,
        d_mm::Real, d_outer_mm::Real, tand::Real=0.0004, rho::Real=2.2e-8)
        new(String(name), Float64(er), Float64(mur), Float64(length_m),
            Float64(d_mm), Float64(d_outer_mm), Float64(tand), Float64(rho), 0, 0)
    end
end

function to_qucs_netlist(comp::CoaxialLine)::String
    # COAX is 2-terminal, parameters use lowercase: d, D (outer), er, mur, tand, rho, L
    params = "d=\"$(comp.d_mm/1000)\" D=\"$(comp.d_outer_mm/1000)\" L=\"$(comp.length_m)\" er=\"$(comp.er)\" mur=\"$(comp.mur)\" tand=\"$(comp.tand)\" rho=\"$(comp.rho)\""
    return "COAX:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) $params"
end

function to_spice_netlist(comp::CoaxialLine)::String
    "* CoaxialLine $(comp.name) not directly supported in SPICE"
end

function _get_node_number(comp::CoaxialLine, pin::Symbol)
    if pin == :n1
        return comp.n1
    elseif pin == :n2
        return comp.n2
    else
        error("Invalid pin $pin for CoaxialLine. Use :n1 or :n2")
    end
end
