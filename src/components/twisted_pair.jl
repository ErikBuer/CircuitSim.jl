"""
    TwistedPair <: AbstractTransmissionLine

4-port twisted pair transmission line (TWIST).

# Fields

- `name::String`: Component identifier
- `d::Float64`: Wire diameter in m (default: 0.5e-3, must be > 0)
- `D::Float64`: Distance between wire centers in m (default: 0.8e-3, must be > 0)
- `length_m::Float64`: Cable length in m (default: 1500e-3)
- `turns_per_m::Float64`: Twist turns per meter (default: 100, must be > 0)
- `er::Float64`: Relative permittivity (default: 4.0, range: 1 to 100)
- `mur::Float64`: Relative permeability (default: 1.0, range: 1 to 100)
- `tand::Float64`: Dielectric loss tangent (default: 4e-4, must be > 0)
- `rho::Float64`: Conductor resistivity in Ohm*m (default: 0.022e-6, must be > 0)
- `temp::Float64`: Temperature in °C (default: 26.85)
- `n1::Int`: Port 1 node
- `n2::Int`: Port 2 node
- `n3::Int`: Port 3 node
- `n4::Int`: Port 4 node

# Pins

- `:n1`, `:n2`: First conductor pair
- `:n3`, `:n4`: Second conductor pair

# Example

```jldoctest
julia> tp = TwistedPair("TP1")
TwistedPair("TP1", 0, 0, 0, 0, 0.0005, 0.0008, 1.5, 100.0, 4.0, 1.0, 0.0004, 2.2e-8, 26.85)
```
"""
mutable struct TwistedPair <: AbstractTransmissionLine
    name::String

    n1::Int
    n2::Int
    n3::Int
    n4::Int

    d::Float64
    D::Float64
    length_m::Float64
    turns_per_m::Float64
    er::Float64
    mur::Float64
    tand::Float64
    rho::Float64
    temp::Float64

    function TwistedPair(name::AbstractString;
        d::Real=0.5e-3,
        D::Real=0.8e-3,
        length_m::Real=1500e-3,
        turns_per_m::Real=100,
        er::Real=4.0,
        mur::Real=1.0,
        tand::Real=4e-4,
        rho::Real=0.022e-6,
        temp::Real=26.85
    )
        d > 0 || error("d must be > 0 (got $d)")
        D > 0 || error("D must be > 0 (got $D)")
        turns_per_m > 0 || error("turns_per_m must be > 0 (got $turns_per_m)")
        1 <= er <= 100 || error("er must be in [1, 100] (got $er)")
        1 <= mur <= 100 || error("mur must be in [1, 100] (got $mur)")
        tand > 0 || error("tand must be > 0 (got $tand)")
        rho > 0 || error("rho must be > 0 (got $rho)")
        temp >= -273.15 || error("temp must be >= -273.15 (got $temp)")

        new(String(name), 0, 0, 0, 0,
            Float64(d), Float64(D), Float64(length_m), Float64(turns_per_m),
            Float64(er), Float64(mur), Float64(tand), Float64(rho), Float64(temp))
    end
end

function to_qucs_netlist(comp::TwistedPair)::String
    params = "d=\"$(comp.d)\" D=\"$(comp.D)\" L=\"$(comp.length_m)\"" *
             " T=\"$(comp.turns_per_m)\" er=\"$(comp.er)\" mur=\"$(comp.mur)\"" *
             " tand=\"$(comp.tand)\" rho=\"$(comp.rho)\" Temp=\"$(comp.temp)\""
    return "TWIST:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) $(qucs_node(comp.n3)) $(qucs_node(comp.n4)) $params"
end

function _get_node_number(comp::TwistedPair, pin::Symbol)
    if pin == :n1
        return comp.n1
    elseif pin == :n2
        return comp.n2
    elseif pin == :n3
        return comp.n3
    elseif pin == :n4
        return comp.n4
    else
        error("Invalid pin $pin for TwistedPair. Use :n1, :n2, :n3, or :n4")
    end
end

function _set_node_number!(comp::TwistedPair, pin::Symbol, node::Int)
    if pin == :n1
        comp.n1 = node
    elseif pin == :n2
        comp.n2 = node
    elseif pin == :n3
        comp.n3 = node
    elseif pin == :n4
        comp.n4 = node
    else
        error("Invalid pin $pin for TwistedPair. Use :n1, :n2, :n3, or :n4")
    end
end

function get_pins(comp::TwistedPair)
    return [:n1, :n2, :n3, :n4]
end
