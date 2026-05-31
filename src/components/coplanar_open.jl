"""
    CoplanarOpen <: AbstractMicrostripComponent

A coplanar waveguide open-end termination (COPEN).

# Fields

- `name::String`: Component identifier
- `n1::Int`: Port node
- `w::Float64`: Center conductor width in meters (default: 1e-3, must be > 0)
- `s::Float64`: Slot width in meters (default: 1e-3, must be > 0)
- `g::Float64`: Ground width in meters (default: 5e-3, must be > 0)
- `substrate::String`: Substrate reference name (default: "Subst1")
- `backside::String`: Backside condition ("Metal" or "Air", default: "Metal")

# Pins

- `:n1`: Port node

# Example

```jldoctest
julia> cp = CoplanarOpen("CP1")
CoplanarOpen("CP1", 0, 0.001, 0.001, 0.005, "Subst1", "Metal")
```
"""
mutable struct CoplanarOpen <: AbstractMicrostripComponent
    name::String

    n1::Int

    w::Float64
    s::Float64
    g::Float64
    substrate::String
    backside::String

    function CoplanarOpen(name::AbstractString;
        w::Real=1e-3,
        s::Real=1e-3,
        g::Real=5e-3,
        substrate::String="Subst1",
        backside::String="Metal"
    )
        w > 0 || error("w must be > 0 (got $w)")
        s > 0 || error("s must be > 0 (got $s)")
        g > 0 || error("g must be > 0 (got $g)")
        backside in ["Metal", "Air"] || error("backside must be one of: Metal, Air")

        new(String(name), 0, Float64(w), Float64(s), Float64(g), substrate, backside)
    end
end

function CoplanarOpen(name::AbstractString;
    w::Real=1e-3,
    s::Real=1e-3,
    g::Real=5e-3,
    substrate::Substrate,
    backside::String="Metal"
)
    return CoplanarOpen(name;
        w=w,
        s=s,
        g=g,
        substrate=substrate.name,
        backside=backside
    )
end

function to_qucs_netlist(comp::CoplanarOpen)::String
    parts = ["COPEN:$(comp.name)"]
    push!(parts, qucs_node(comp.n1))
    push!(parts, "W=\"$(comp.w)\"")
    push!(parts, "S=\"$(comp.s)\"")
    push!(parts, "G=\"$(comp.g)\"")
    push!(parts, "Subst=\"$(comp.substrate)\"")
    push!(parts, "Backside=\"$(comp.backside)\"")
    return join(parts, " ")
end

function _get_node_number(comp::CoplanarOpen, pin::Symbol)
    if pin == :n1
        return comp.n1
    else
        error("Invalid pin $pin for CoplanarOpen. Use :n1")
    end
end

function _set_node_number!(comp::CoplanarOpen, pin::Symbol, node::Int)
    if pin == :n1
        comp.n1 = node
    else
        error("Invalid pin $pin for CoplanarOpen. Use :n1")
    end
end

function get_pins(::CoplanarOpen)
    return [:n1]
end

const COPEN = CoplanarOpen
