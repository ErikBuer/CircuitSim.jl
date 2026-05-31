"""
    Substrate

Defines the substrate properties for microstrip and planar components.

# Fields

- `name::String`: Substrate identifier
- `er::Real`: Relative permittivity (dielectric constant, default: 9.8)
- `h::Real`: Substrate height/thickness in meters (default: 1e-3)
- `t::Real`: Metal thickness in meters (default: 35e-6)
- `tand::Real`: Loss tangent (tan δ, default: 1e-3)
- `rho::Real`: Metal resistivity in Ω·m (Copper ≈ 0.022e-6)
- `rough::Real`: Surface roughness in meters (default: 0.15e-6)

# Example

```julia
# Standard FR4 substrate
fr4 = Substrate("FR4", er=4.5, h=1.6e-3, t=35e-6, tand=0.02)

# Rogers RO4003C
ro4003c = Substrate("RO4003C", er=3.55, h=0.508e-3, t=17e-6, tand=0.0027)

# Low-loss Rogers RT/duroid
duroid = Substrate("Duroid", er=2.2, h=0.787e-3, t=35e-6, tand=0.0009)
```
"""
mutable struct Substrate <: AbstractCircuitComponent
    name::String
    er::Real        # Relative permittivity
    h::Real         # Substrate height (m)
    t::Real         # Metal thickness (m)
    tand::Real      # Loss tangent
    rho::Real       # Resistivity in Ω·m
    rough::Real     # Surface roughness (m)

    function Substrate(name::AbstractString;
        er::Real=9.8,
        h::Real=1e-3,
        t::Real=35e-6,
        tand::Real=1e-3,
        rho::Real=0.022e-6,
        rough::Real=0.15e-6
    )
        1 <= er <= 100 || throw(ArgumentError("Relative permittivity must be in range [1, 100]"))
        h > 0 || throw(ArgumentError("Substrate height must be positive"))
        t > 0 || throw(ArgumentError("Metal thickness must be positive"))
        tand > 0 || throw(ArgumentError("Loss tangent must be positive"))
        rho > 0 || throw(ArgumentError("Resistivity must be positive"))
        rough > 0 || throw(ArgumentError("Surface roughness must be positive"))
        new(String(name), er, h, t, tand, rho, rough)
    end
end

# Qucs substrate definition - produces a SUBST line
function to_qucs_netlist(sub::Substrate)::String
    parts = ["SUBST:$(sub.name)"]
    push!(parts, "er=\"$(sub.er)\"")
    push!(parts, "h=\"$(format_value(sub.h))\"")
    push!(parts, "t=\"$(format_value(sub.t))\"")
    push!(parts, "tand=\"$(sub.tand)\"")
    push!(parts, "rho=\"$(format_value(sub.rho))\"")
    push!(parts, "D=\"$(format_value(sub.rough))\"")
    return join(parts, " ")
end

# Substrate doesn't have pins/nodes - it's a parameter definition
_is_node_field(::Substrate, ::Symbol) = false

function _register_pins_in_uf!(::Substrate, ::UnionFind)
    # Substrate has no pins to register
    nothing
end

function _collect_roots!(::Vector{Int}, ::Substrate, ::UnionFind)
    # Substrate has no roots to collect
    nothing
end

function _write_node_numbers!(::Substrate, ::Dict{Int,Int})
    # Substrate has no node numbers to write
    nothing
end
