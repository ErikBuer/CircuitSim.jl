"""
    MicrostripVia <: AbstractMicrostripVia

A microstrip via hole connecting to ground plane.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Node (top connection)
- `d::Real`: Via hole diameter in meters (default: 100e-6)
- `substrate::String`: Substrate reference name (default: "Subst1")
- `temp::Real`: Temperature in Celsius (default: 26.85)

# Example

```julia
using CircuitSim
# Default via
via1 = MicrostripVia("VIA1", d=0.3e-3)

# Custom substrate reference
via2 = MicrostripVia("VIA2", substrate="Sub1", d=0.3e-3)
```
"""
mutable struct MicrostripVia <: AbstractMicrostripVia
    name::String

    n1::Int

    d::Real            # Via diameter (m)
    substrate::String  # Substrate reference name
    temp::Real         # Temperature (°C)

    function MicrostripVia(name::AbstractString;
        d::Real=100e-6,
        substrate::String="Subst1",
        temp::Real=26.85
    )
        d > 0 || throw(ArgumentError("Via diameter must be positive"))
        temp >= -273.15 || throw(ArgumentError("Temperature must be above absolute zero"))
        new(String(name), 0, d, substrate, temp)
    end
end

function to_qucs_netlist(mv::MicrostripVia)::String
    parts = ["MVIA:$(mv.name)"]
    push!(parts, qucs_node(mv.n1))
    push!(parts, "gnd")  # Vias connect to ground
    push!(parts, "D=\"$(format_value(mv.d))\"")
    push!(parts, "Subst=\"$(mv.substrate)\"")
    push!(parts, "Temp=\"$(format_value(mv.temp))\"")
    return join(parts, " ")
end


function _get_node_number(mv::MicrostripVia, terminal::Int)::Int
    terminal == 1 && return mv.n1
    terminal == 2 && return 0  # Ground
    throw(ArgumentError("MicrostripVia has only 1 signal terminal (1) plus ground (2), got $terminal"))
end
