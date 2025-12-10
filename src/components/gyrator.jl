"""
    Gyrator <: AbstractComponent

Gyrator converts impedance (e.g., capacitor ↔ inductor).

# Fields

- `name::String`: Component identifier
- `r::Float64`: Gyration resistance in Ω (default: 50.0)
- `zref::Float64`: Reference impedance in Ω (default: 50.0)
- `n1::Int`: Port 1 positive node
- `n2::Int`: Port 1 negative node
- `n3::Int`: Port 2 positive node
- `n4::Int`: Port 2 negative node

# Pins

- `:n1`, `:n2`: Port 1
- `:n3`, `:n4`: Port 2

# Example

```jldoctest
julia> gyr = Gyrator("GYR1", r=100.0)
Gyrator("GYR1", 100.0, 50.0, 0, 0, 0, 0)
```
"""
mutable struct Gyrator <: AbstractGyrator
    name::String
    r::Float64
    zref::Float64
    n1::Int
    n2::Int
    n3::Int
    n4::Int

    function Gyrator(name::AbstractString; r::Real=50.0, zref::Real=50.0)
        new(String(name), Float64(r), Float64(zref), 0, 0, 0, 0)
    end
end

function to_qucs_netlist(comp::Gyrator)::String
    params = "R=\"$(comp.r)\" Zref=\"$(comp.zref)\""
    return "Gyrator:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) $(qucs_node(comp.n3)) $(qucs_node(comp.n4)) $params"
end

function to_spice_netlist(comp::Gyrator)::String
    "* Gyrator $(comp.name) not directly supported in SPICE"
end

function _get_node_number(comp::Gyrator, pin::Symbol)
    if pin == :n1
        return comp.n1
    elseif pin == :n2
        return comp.n2
    elseif pin == :n3
        return comp.n3
    elseif pin == :n4
        return comp.n4
    else
        error("Invalid pin $pin for Gyrator. Use :n1, :n2, :n3, or :n4")
    end
end
