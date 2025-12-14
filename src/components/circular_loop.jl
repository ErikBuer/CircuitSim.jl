"""
    CircularLoop <: AbstractCircularLoop

A single-turn circular loop inductor.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Node 1
- `n2::Int`: Node 2
- `r::Real`: Loop radius (m)
- `w::Real`: Wire/trace width (m)

# Example

```julia
loop = CircularLoop("CL1", r=5e-3, w=0.5e-3)
```

# Qucs Format

Approximated using standard inductor with calculated value
"""
mutable struct CircularLoop <: AbstractCircularLoop
    name::String
    n1::Int
    n2::Int
    r::Real         # Loop radius (m)
    w::Real         # Wire/trace width (m)

    function CircularLoop(name::AbstractString;
        r::Real=5e-3,
        w::Real=0.5e-3)
        r > 0 || throw(ArgumentError("Loop radius must be positive"))
        w > 0 || throw(ArgumentError("Wire width must be positive"))
        r > w / 2 || throw(ArgumentError("Loop radius must be greater than half wire width"))
        new(String(name), 0, 0, r, w)
    end
end

function to_qucs_netlist(cl::CircularLoop)::String
    # Calculate inductance using formula: L = μ₀ * r * (ln(8r/a) - 2) for thin wire
    # where a is wire radius, r is loop radius
    μ0 = 4π * 1e-7  # H/m
    a = cl.w / 2    # wire radius
    l_value = μ0 * cl.r * (log(8 * cl.r / a) - 2)

    parts = ["L:$(cl.name)"]
    push!(parts, qucs_node(cl.n1))
    push!(parts, qucs_node(cl.n2))
    push!(parts, "L=\"$(format_value(l_value))\"")
    return join(parts, " ")
end

function to_spice_netlist(cl::CircularLoop)::String
    # Calculate inductance
    μ0 = 4π * 1e-7
    a = cl.w / 2
    l_value = μ0 * cl.r * (log(8 * cl.r / a) - 2)
    "L$(cl.name) $(cl.n1) $(cl.n2) $(l_value)  ; Circular loop inductor"
end

function _get_node_number(cl::CircularLoop, terminal::Int)::Int
    terminal == 1 && return cl.n1
    terminal == 2 && return cl.n2
    throw(ArgumentError("CircularLoop has only 2 terminals (1, 2), got $terminal"))
end
