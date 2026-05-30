"""
    MutualInductor <: AbstractComponent

Two coupled inductors with mutual inductance.

# Fields

- `name::String`: Component identifier
- `n1::Int`: First inductor node 1
- `n2::Int`: First inductor node 2
- `n3::Int`: Second inductor node 1
- `n4::Int`: Second inductor node 2
- `l1::Float64`: Inductance of first coil in H (default: 1e-3)
- `l2::Float64`: Inductance of second coil in H (default: 1e-3)
- `k::Float64`: Coupling coefficient, range -1 < k < 1 (default: 0.9)

# Pins

- `:n1`, `:n2`: First inductor
- `:n3`, `:n4`: Second inductor

# Example

```jldoctest
julia> mut = MutualInductor("MUT1", l1=1e-6, l2=1e-6, k=0.95)
MutualInductor("MUT1", 0, 0, 0, 0, 1.0e-6, 1.0e-6, 0.95)
```
"""
mutable struct MutualInductor <: AbstractMutualInductance
    name::String

    n1::Int
    n2::Int
    n3::Int
    n4::Int

    l1::Float64
    l2::Float64
    k::Float64

    function MutualInductor(name::AbstractString;
        l1::Real=1e-3,
        l2::Real=1e-3,
        k::Real=0.9
    )
        l1 > 0 || throw(ArgumentError("L1 must be positive"))
        l2 > 0 || throw(ArgumentError("L2 must be positive"))
        -1 < k < 1 || throw(ArgumentError("Coupling coefficient k must be in range (-1, 1)"))
        new(String(name), 0, 0, 0, 0, Float64(l1), Float64(l2), Float64(k))
    end
end

function to_qucs_netlist(comp::MutualInductor)::String
    params = "L1=\"$(comp.l1)\" L2=\"$(comp.l2)\" k=\"$(comp.k)\""
    return "MUT:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) $(qucs_node(comp.n3)) $(qucs_node(comp.n4)) $params"
end

function _get_node_number(comp::MutualInductor, pin::Symbol)
    if pin == :n1
        return comp.n1
    elseif pin == :n2
        return comp.n2
    elseif pin == :n3
        return comp.n3
    elseif pin == :n4
        return comp.n4
    else
        error("Invalid pin $pin for MutualInductor. Use :n1, :n2, :n3, or :n4")
    end
end
