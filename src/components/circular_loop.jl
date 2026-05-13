"""
    CircularLoop <: AbstractCircularLoop

A single-turn circular loop inductor.

Reference: I. Bahl, Fundamentals of RF and Microwave Transistor Amplifiers, 
           John Wiley and Sons, 2009

# Fields

- `name::String`: Component identifier
- `n1::Int`: Node 1
- `n2::Int`: Node 2
- `a::Real`: Loop radius (m)
- `w::Real`: Wire/trace width (m)
- `substrate::String`: Substrate reference name (default: "Subst1")
- `temp::Real`: Simulation temperature (°C)

# Example

```julia
loop = CircularLoop("CL1", substrate="Sub1", a=200e-6, w=25e-6)
```
"""
mutable struct CircularLoop <: AbstractCircularLoop
    name::String

    n1::Int
    n2::Int

    a::Real         # Loop radius (m)
    w::Real         # Wire/trace width (m)
    substrate::String  # Substrate reference name
    temp::Real      # Simulation temperature (°C)

    function CircularLoop(name::AbstractString;
        substrate::String="Subst1",
        a::Real=200e-6,
        w::Real=25e-6,
        temp::Real=26.85
    )
        a > 0 || throw(ArgumentError("Loop radius must be positive"))
        w > 0 || throw(ArgumentError("Wire width must be positive"))
        a > w / 2 || throw(ArgumentError("Loop radius must be greater than half wire width"))
        new(String(name), 0, 0, a, w, substrate, temp)
    end
end

function to_qucs_netlist(cl::CircularLoop)::String
    parts = ["CIRCULARLOOP:$(cl.name)"]
    push!(parts, qucs_node(cl.n1))
    push!(parts, qucs_node(cl.n2))
    push!(parts, "Subst=\"$(cl.substrate)\"")
    push!(parts, "W=\"$(format_value(cl.w))\"")
    push!(parts, "a=\"$(format_value(cl.a))\"")
    push!(parts, "Temp=\"$(cl.temp)\"")
    return join(parts, " ")
end

function _get_node_number(cl::CircularLoop, pin::Symbol)::Int
    if pin == :n1
        return cl.n1
    elseif pin == :n2
        return cl.n2
    else
        error("Invalid pin $pin for CircularLoop. Use :n1 or :n2")
    end
end
