"""
    SpiralInductor <: AbstractSpiralInductor

A planar spiral inductor on a substrate.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Node 1 (outer terminal)
- `n2::Int`: Node 2 (inner terminal)
- `substrate::Substrate`: Substrate definition reference
- `geometry::String`: Inductor geometry ("Circular", "Square", "Hexagonal", "Octogonal")
- `w::Real`: Track width (m)
- `s::Real`: Track spacing (m)
- `di::Real`: Inner diameter (m)
- `turns::Real`: Number of turns

# Example

```julia
sub = Substrate("FR4", er=4.5, h=1.6e-3)
spiral = SpiralInductor("L1", sub, geometry="Circular", w=0.2e-3, s=0.15e-3, di=1e-3, turns=5.5)
```
"""
mutable struct SpiralInductor <: AbstractSpiralInductor
    name::String
    n1::Int
    n2::Int
    substrate::Substrate
    geometry::String    # Inductor geometry
    w::Real         # Track width (m)
    s::Real         # Track spacing (m)
    di::Real        # Inner diameter (m)
    turns::Real     # Number of turns

    function SpiralInductor(name::AbstractString, substrate::Substrate;
        geometry::AbstractString="Circular",
        w::Real=0.2e-3,
        s::Real=0.15e-3,
        di::Real=1e-3,
        turns::Real=5.0)
        valid_geometries = ["Circular", "Square", "Hexagonal", "Octogonal"]
        geometry in valid_geometries || throw(ArgumentError("Geometry must be one of: $(join(valid_geometries, ", "))"))
        w > 0 || throw(ArgumentError("Track width must be positive"))
        s > 0 || throw(ArgumentError("Track spacing must be positive"))
        di > 0 || throw(ArgumentError("Inner diameter must be positive"))
        turns > 0 || throw(ArgumentError("Number of turns must be positive"))
        new(String(name), 0, 0, substrate, String(geometry), w, s, di, turns)
    end
end

function to_qucs_netlist(sp::SpiralInductor)::String
    parts = ["SPIRALIND:$(sp.name)"]
    push!(parts, qucs_node(sp.n1))
    push!(parts, qucs_node(sp.n2))
    push!(parts, "Subst=\"$(sp.substrate.name)\"")
    push!(parts, "Geometry=\"$(sp.geometry)\"")
    push!(parts, "W=\"$(format_value(sp.w))\"")
    push!(parts, "S=\"$(format_value(sp.s))\"")
    push!(parts, "Di=\"$(format_value(sp.di))\"")
    push!(parts, "N=\"$(sp.turns)\"")
    return join(parts, " ")
end

function to_spice_netlist(sp::SpiralInductor)::String
    # Approximate spiral inductance using Wheeler's formula (simplified)
    # L ≈ n² * d_avg / (1 + 2.75 * fill_ratio)
    davg = sp.di + sp.turns * (sp.w + sp.s)
    fill = (sp.turns * (sp.w + sp.s)) / (davg / 2)
    l_approx = sp.turns^2 * davg * 1e9 / (1 + 2.75 * fill)  # nH approx
    "L$(sp.name) $(sp.n1) $(sp.n2) $(l_approx)n  ; Spiral inductor approx"
end

function _get_node_number(sp::SpiralInductor, pin::Symbol)::Int
    if pin == :n1
        return sp.n1
    elseif pin == :n2
        return sp.n2
    else
        error("Invalid pin $pin for SpiralInductor. Use :n1 or :n2")
    end
end
