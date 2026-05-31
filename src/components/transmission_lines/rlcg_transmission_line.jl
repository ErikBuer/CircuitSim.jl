"""
    RLCGTransmissionLine <: AbstractTransmissionLine

2-port distributed RLCG transmission line (RLCG).

# Fields

- `name::String`: Component identifier
- `n1::Int`: Port 1 node
- `n2::Int`: Port 2 node
- `r_ohm_per_m::Float64`: Series resistance per meter in Ohm/m (default: 0.0, must be >= 0)
- `l_H_per_m::Float64`: Series inductance per meter in H/m (default: 0.6e-6, must be > 0)
- `c_F_per_m::Float64`: Shunt capacitance per meter in F/m (default: 240e-12, must be > 0)
- `g_S_per_m::Float64`: Shunt conductance per meter in S/m (default: 0.0, must be >= 0)
- `length_m::Float64`: Physical length in meters (default: 1e-3)
- `temp::Float64`: Temperature in °C (default: 26.85)

# Pins

- `:n1`: Port 1
- `:n2`: Port 2

# Example

```jldoctest
julia> rl = RLCGTransmissionLine("RL1")
RLCGTransmissionLine("RL1", 0, 0, 0.0, 6.0e-7, 2.4e-10, 0.0, 0.001, 26.85)
```
"""
mutable struct RLCGTransmissionLine <: AbstractTransmissionLine
    name::String

    n1::Int
    n2::Int

    r_ohm_per_m::Float64
    l_H_per_m::Float64
    c_F_per_m::Float64
    g_S_per_m::Float64
    length_m::Float64
    temp::Float64

    function RLCGTransmissionLine(name::AbstractString;
        r_ohm_per_m::Real=0.0,
        l_H_per_m::Real=0.6e-6,
        c_F_per_m::Real=240e-12,
        g_S_per_m::Real=0.0,
        length_m::Real=1e-3,
        temp::Real=26.85
    )
        r_ohm_per_m >= 0 || error("r_ohm_per_m must be >= 0 (got $r_ohm_per_m)")
        l_H_per_m > 0 || error("l_H_per_m must be > 0 (got $l_H_per_m)")
        c_F_per_m > 0 || error("c_F_per_m must be > 0 (got $c_F_per_m)")
        g_S_per_m >= 0 || error("g_S_per_m must be >= 0 (got $g_S_per_m)")
        temp >= -273.15 || error("temp must be >= -273.15 (got $temp)")

        new(String(name), 0, 0,
            Float64(r_ohm_per_m), Float64(l_H_per_m), Float64(c_F_per_m),
            Float64(g_S_per_m), Float64(length_m), Float64(temp))
    end
end

function to_qucs_netlist(comp::RLCGTransmissionLine)::String
    params = "R=\"$(comp.r_ohm_per_m)\" L=\"$(comp.l_H_per_m)\" C=\"$(comp.c_F_per_m)\"" *
             " G=\"$(comp.g_S_per_m)\" Length=\"$(comp.length_m)\" Temp=\"$(comp.temp)\""
    return "RLCG:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) $params"
end

function _get_node_number(comp::RLCGTransmissionLine, pin::Symbol)
    if pin == :n1
        return comp.n1
    elseif pin == :n2
        return comp.n2
    else
        error("Invalid pin $pin for RLCGTransmissionLine. Use :n1 or :n2")
    end
end

function _set_node_number!(comp::RLCGTransmissionLine, pin::Symbol, node::Int)
    if pin == :n1
        comp.n1 = node
    elseif pin == :n2
        comp.n2 = node
    else
        error("Invalid pin $pin for RLCGTransmissionLine. Use :n1 or :n2")
    end
end

function get_pins(::RLCGTransmissionLine)
    return [:n1, :n2]
end
