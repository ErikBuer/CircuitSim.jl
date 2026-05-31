"""
    MicrostripLine <: AbstractMicrostripLine

A microstrip transmission line segment.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Node 1 (input)
- `n2::Int`: Node 2 (output)
- `w::Real`: Line width in meters (default: 1e-3)
- `l::Real`: Line length in meters (default: 10e-3)
- `substrate::String`: Substrate reference name (default: "Subst1")
- `disp_model::String`: Dispersion model (default: "Kirschning")
- `model::String`: Quasi-static model (default: "Hammerstad")
- `temp::Real`: Temperature in Celsius (default: 26.85)

# Example

```julia
using CircuitSim
# Default microstrip line
line1 = MicrostripLine("MS1", w=3.0e-3, l=20e-3)

# Custom substrate reference
line2 = MicrostripLine("MS2", substrate="Sub1", w=3.0e-3, l=20e-3)
```

# Qucs Format

`MLIN:Name Node1 Node2 W="width" L="length" Subst="SubstName" DispModel="..." Model="..." Temp="..."`
"""
mutable struct MicrostripLine <: AbstractMicrostripLine
    name::String

    n1::Int
    n2::Int

    w::Real            # Width (m)
    l::Real            # Length (m)
    substrate::String  # Substrate reference name
    disp_model::String # Dispersion model
    model::String      # Quasi-static model
    temp::Real         # Temperature (°C)

    function MicrostripLine(name::AbstractString;
        w::Real=1e-3,
        l::Real=10e-3,
        substrate::String="Subst1",
        disp_model::String="Kirschning",
        model::String="Hammerstad",
        temp::Real=26.85
    )
        if model ∉ ("Wheeler", "Schneider", "Hammerstad")
            throw(ArgumentError("Invalid model type: $model. Must be one of Wheeler, Schneider, Hammerstad"))
        end
        if disp_model ∉ ("Getsinger", "Schneider", "Yamashita", "Kobayashi", "Pramanick", "Hammerstad", "Kirschning")
            throw(ArgumentError("Invalid dispersion model type: $disp_model. Must be one of Getsinger, Schneider, Yamashita, Kobayashi, Pramanick, Hammerstad, Kirschning"))
        end
        w > 0 || throw(ArgumentError("Width must be positive"))
        l > 0 || throw(ArgumentError("Length must be positive"))
        temp >= -273.15 || throw(ArgumentError("Temperature must be above absolute zero"))
        new(String(name), 0, 0, w, l, substrate, disp_model, model, temp)
    end
end

function to_qucs_netlist(ms::MicrostripLine)::String
    parts = ["MLIN:$(ms.name)"]
    push!(parts, qucs_node(ms.n1))
    push!(parts, qucs_node(ms.n2))
    push!(parts, "W=\"$(format_value(ms.w))\"")
    push!(parts, "L=\"$(format_value(ms.l))\"")
    push!(parts, "Subst=\"$(ms.substrate)\"")
    push!(parts, "DispModel=\"$(ms.disp_model)\"")
    push!(parts, "Model=\"$(ms.model)\"")
    push!(parts, "Temp=\"$(format_value(ms.temp))\"")
    return join(parts, " ")
end

function _get_node_number(ms::MicrostripLine, terminal::Int)::Int
    terminal == 1 && return ms.n1
    terminal == 2 && return ms.n2
    throw(ArgumentError("MicrostripLine has only 2 terminals (1, 2), got $terminal"))
end
