"""
    SpiralInductor <: AbstractSpiralInductor

A planar spiral inductor on a substrate.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Node 1 (outer terminal)
- `n2::Int`: Node 2 (inner terminal)
- `geometry::String`: Inductor geometry ("Circular", "Square", "Hexagonal", "Octogonal")
- `w::Real`: Track width in meters (default: 25e-6)
- `di::Real`: Inner diameter in meters (default: 200e-6)
- `s::Real`: Track spacing in meters (default: 25e-6)
- `turns::Real`: Number of turns (default: 3)
- `substrate::String`: Substrate reference name (default: "Subst1")
- `temp::Real`: Temperature in Celsius (default: 26.85)

# Example

```julia
using CircuitSim
spiral = SpiralInductor("L1", geometry="Circular", w=25e-6, di=200e-6, s=25e-6, turns=3, substrate="Sub1")
```
"""
mutable struct SpiralInductor <: AbstractSpiralInductor
    name::String

    n1::Int
    n2::Int

    geometry::String    # Inductor geometry
    w::Real             # Track width (m)
    di::Real            # Inner diameter (m)
    s::Real             # Track spacing (m)
    turns::Real         # Number of turns
    substrate::String   # Substrate reference name
    temp::Real          # Temperature (°C)

    function SpiralInductor(name::AbstractString;
        geometry::AbstractString="Circular",
        w::Real=25e-6,
        di::Real=200e-6,
        s::Real=25e-6,
        turns::Real=3,
        substrate::String="Subst1",
        temp::Real=26.85
    )
        valid_geometries = ["Circular", "Square", "Hexagonal", "Octogonal"]
        geometry in valid_geometries || throw(ArgumentError("Geometry must be one of: $(join(valid_geometries, ", "))"))
        w > 0 || throw(ArgumentError("Track width must be positive"))
        di > 0 || throw(ArgumentError("Inner diameter must be positive"))
        s >= 0 || throw(ArgumentError("Track spacing must be non-negative"))
        turns > 0 || throw(ArgumentError("Number of turns must be positive"))
        temp >= -273.15 || throw(ArgumentError("Temperature must be above absolute zero"))
        new(String(name), 0, 0, String(geometry), w, di, s, turns, substrate, temp)
    end
end

function to_qucs_netlist(sp::SpiralInductor)::String
    parts = ["SPIRALIND:$(sp.name)"]
    push!(parts, qucs_node(sp.n1))
    push!(parts, qucs_node(sp.n2))
    push!(parts, "Geometry=\"$(sp.geometry)\"")
    push!(parts, "W=\"$(format_value(sp.w))\"")
    push!(parts, "Di=\"$(format_value(sp.di))\"")
    push!(parts, "S=\"$(format_value(sp.s))\"")
    push!(parts, "N=\"$(sp.turns)\"")
    push!(parts, "Subst=\"$(sp.substrate)\"")
    push!(parts, "Temp=\"$(format_value(sp.temp))\"")
    return join(parts, " ")
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
