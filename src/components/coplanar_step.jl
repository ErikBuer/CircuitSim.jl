"""
    CoplanarStep <: AbstractMicrostripComponent

A coplanar waveguide step discontinuity (CSTEP).

# Fields

- `name::String`: Component identifier
- `n1::Int`: Port 1 node
- `n2::Int`: Port 2 node
- `w1::Float64`: Conductor width at port 1 in meters (default: 1e-3, must be > 0)
- `w2::Float64`: Conductor width at port 2 in meters (default: 2e-3, must be > 0)
- `s::Float64`: Groundplane gap in meters (default: 4e-3, must be > 0)
- `substrate::String`: Substrate reference name (default: "Subst1")
- `backside::String`: Backside condition ("Metal" or "Air", default: "Metal")

# Pins

- `:n1`: Port 1
- `:n2`: Port 2

# Example

```jldoctest
julia> cp = CoplanarStep("CST1")
CoplanarStep("CST1", 0, 0, 0.001, 0.002, 0.004, "Subst1", "Metal")
```
"""
mutable struct CoplanarStep <: AbstractMicrostripComponent
    name::String

    n1::Int
    n2::Int

    w1::Float64
    w2::Float64
    s::Float64
    substrate::String
    backside::String

    function CoplanarStep(name::AbstractString;
        w1::Real=1e-3,
        w2::Real=2e-3,
        s::Real=4e-3,
        substrate::String="Subst1",
        backside::String="Metal"
    )
        w1 > 0 || error("w1 must be > 0 (got $w1)")
        w2 > 0 || error("w2 must be > 0 (got $w2)")
        s > 0 || error("s must be > 0 (got $s)")
        w1 != w2 || error("w1 and w2 must differ for a step discontinuity")
        w1 < s || error("w1 must be < s (got w1=$w1, s=$s)")
        w2 < s || error("w2 must be < s (got w2=$w2, s=$s)")
        backside in ["Metal", "Air"] || error("backside must be one of: Metal, Air")

        new(String(name), 0, 0, Float64(w1), Float64(w2), Float64(s), substrate, backside)
    end
end

function CoplanarStep(name::AbstractString;
    w1::Real=1e-3,
    w2::Real=2e-3,
    s::Real=4e-3,
    substrate::Substrate,
    backside::String="Metal"
)
    return CoplanarStep(name;
        w1=w1,
        w2=w2,
        s=s,
        substrate=substrate.name,
        backside=backside
    )
end

function to_qucs_netlist(comp::CoplanarStep)::String
    parts = ["CSTEP:$(comp.name)"]
    push!(parts, qucs_node(comp.n1))
    push!(parts, qucs_node(comp.n2))
    push!(parts, "W1=\"$(comp.w1)\"")
    push!(parts, "W2=\"$(comp.w2)\"")
    push!(parts, "S=\"$(comp.s)\"")
    push!(parts, "Subst=\"$(comp.substrate)\"")
    push!(parts, "Backside=\"$(comp.backside)\"")
    return join(parts, " ")
end

function _get_node_number(comp::CoplanarStep, pin::Symbol)
    if pin == :n1
        return comp.n1
    elseif pin == :n2
        return comp.n2
    else
        error("Invalid pin $pin for CoplanarStep. Use :n1 or :n2")
    end
end

function _set_node_number!(comp::CoplanarStep, pin::Symbol, node::Int)
    if pin == :n1
        comp.n1 = node
    elseif pin == :n2
        comp.n2 = node
    else
        error("Invalid pin $pin for CoplanarStep. Use :n1 or :n2")
    end
end

function get_pins(::CoplanarStep)
    return [:n1, :n2]
end

const CSTEP = CoplanarStep
