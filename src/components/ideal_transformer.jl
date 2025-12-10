"""
    IdealTransformer <: AbstractComponent

Ideal transformer with specified turns ratio.

# Fields

- `name::String`: Component identifier
- `t::Float64`: Turns ratio N2/N1 (default: 1.0)
- `n1::Int`: Primary winding positive node
- `n2::Int`: Primary winding negative node
- `n3::Int`: Secondary winding positive node
- `n4::Int`: Secondary winding negative node

# Pins

- `:n1`, `:n2`: Primary winding
- `:n3`, `:n4`: Secondary winding

# Example

```jldoctest
julia> trafo = IdealTransformer("TR1", t=2.0)
IdealTransformer("TR1", 2.0, 0, 0, 0, 0)
```
"""
mutable struct IdealTransformer <: AbstractIdealTransformer
    name::String
    t::Float64
    n1::Int
    n2::Int
    n3::Int
    n4::Int

    function IdealTransformer(name::AbstractString; t::Real=1.0)
        new(String(name), Float64(t), 0, 0, 0, 0)
    end
end

function to_qucs_netlist(comp::IdealTransformer)::String
    params = "T=\"$(comp.t)\""
    return "Tr:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) $(qucs_node(comp.n3)) $(qucs_node(comp.n4)) $params"
end

function to_spice_netlist(comp::IdealTransformer)::String
    "K$(comp.name) L1_$(comp.name) L2_$(comp.name) $(comp.t)"
end

function _get_node_number(comp::IdealTransformer, pin::Symbol)
    if pin == :n1
        return comp.n1
    elseif pin == :n2
        return comp.n2
    elseif pin == :n3
        return comp.n3
    elseif pin == :n4
        return comp.n4
    else
        error("Invalid pin $pin for IdealTransformer. Use :n1, :n2, :n3, or :n4")
    end
end
