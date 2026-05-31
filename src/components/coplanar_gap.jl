"""
    CoplanarGap <: AbstractMicrostripComponent

A coplanar waveguide gap discontinuity (CGAP).

# Fields

- `name::String`: Component identifier
- `n1::Int`: Port 1 node
- `n2::Int`: Port 2 node
- `w::Float64`: Center conductor width in meters (default: 1e-3, must be > 0)
- `g::Float64`: Gap length in meters (default: 5e-4, must be > 0)
- `substrate::String`: Substrate reference name (default: "Subst1")
- `s::Float64`: Slot width in meters (default: 1e-3, optional in qucs, must be > 0)

# Pins

- `:n1`: Port 1
- `:n2`: Port 2

# Example

```jldoctest
julia> cp = CoplanarGap("CG1")
CoplanarGap("CG1", 0, 0, 0.001, 0.0005, "Subst1", 0.001)
```
"""
mutable struct CoplanarGap <: AbstractMicrostripComponent
    name::String

    n1::Int
    n2::Int

    w::Float64
    g::Float64
    substrate::String
    s::Float64

    function CoplanarGap(name::AbstractString;
        w::Real=1e-3,
        g::Real=5e-4,
        substrate::String="Subst1",
        s::Real=1e-3
    )
        w > 0 || error("w must be > 0 (got $w)")
        g > 0 || error("g must be > 0 (got $g)")
        s > 0 || error("s must be > 0 (got $s)")

        new(String(name), 0, 0, Float64(w), Float64(g), substrate, Float64(s))
    end
end

function CoplanarGap(name::AbstractString;
    w::Real=1e-3,
    g::Real=5e-4,
    substrate::Substrate,
    s::Real=1e-3
)
    return CoplanarGap(name;
        w=w,
        g=g,
        substrate=substrate.name,
        s=s
    )
end

function to_qucs_netlist(comp::CoplanarGap)::String
    parts = ["CGAP:$(comp.name)"]
    push!(parts, qucs_node(comp.n1))
    push!(parts, qucs_node(comp.n2))
    push!(parts, "W=\"$(comp.w)\"")
    push!(parts, "G=\"$(comp.g)\"")
    push!(parts, "Subst=\"$(comp.substrate)\"")
    push!(parts, "S=\"$(comp.s)\"")
    return join(parts, " ")
end

function _get_node_number(comp::CoplanarGap, pin::Symbol)
    if pin == :n1
        return comp.n1
    elseif pin == :n2
        return comp.n2
    else
        error("Invalid pin $pin for CoplanarGap. Use :n1 or :n2")
    end
end

function _set_node_number!(comp::CoplanarGap, pin::Symbol, node::Int)
    if pin == :n1
        comp.n1 = node
    elseif pin == :n2
        comp.n2 = node
    else
        error("Invalid pin $pin for CoplanarGap. Use :n1 or :n2")
    end
end

function get_pins(::CoplanarGap)
    return [:n1, :n2]
end

const CGAP = CoplanarGap
