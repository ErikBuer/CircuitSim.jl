"""
    MicrostripLange <: AbstractMicrostripLange

A Lange coupler - an interdigitated microstrip directional coupler providing tight coupling.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Node 1 (input)
- `n2::Int`: Node 2 (through)
- `n3::Int`: Node 3 (coupled)
- `n4::Int`: Node 4 (isolated)
- `w::Real`: Finger width in meters (default: 1e-3)
- `l::Real`: Finger length in meters (default: 10e-3)
- `s::Real`: Finger spacing in meters (default: 1e-3)
- `substrate::String`: Substrate reference name (default: "Subst1")
- `model::String`: Quasi-static model (default: "Kirschning")
- `disp_model::String`: Dispersion model (default: "Kirschning")
- `temp::Real`: Temperature in Celsius (default: 26.85)

# Example

```julia
using CircuitSim
# Default Lange coupler
lange1 = MicrostripLange("LC1", w=0.15e-3, l=10e-3, s=0.1e-3)

# Custom substrate reference
lange2 = MicrostripLange("LC2", substrate="Sub1", 
    w=0.15e-3, l=10e-3, s=0.1e-3)
```

# Qucs Format

`MLANGE:Name Node1 Node2 Node3 Node4 W="width" L="length" S="spacing" Subst="SubstName" Model="..." DispModel="..." Temp="..."`
"""
mutable struct MicrostripLange <: AbstractMicrostripLange
    name::String
    n1::Int
    n2::Int
    n3::Int
    n4::Int

    w::Real         # Finger width (m)
    l::Real         # Finger length (m)
    s::Real         # Finger spacing (m)
    substrate::String  # Substrate reference name
    model::String      # Quasi-static model
    disp_model::String # Dispersion model
    temp::Real         # Temperature (°C)

    function MicrostripLange(name::AbstractString;
        w::Real=1e-3,
        l::Real=10e-3,
        s::Real=1e-3,
        substrate::String="Subst1",
        model::String="Kirschning",
        disp_model::String="Kirschning",
        temp::Real=26.85
    )
        if model ∉ ("Kirschning", "Hammerstad")
            throw(ArgumentError("Invalid model type: $model. Must be one of Kirschning, Hammerstad"))
        end
        if disp_model ∉ ("Kirschning", "Getsinger")
            throw(ArgumentError("Invalid dispersion model type: $disp_model. Must be one of Kirschning, Getsinger"))
        end
        w > 0 || throw(ArgumentError("Finger width must be positive"))
        l > 0 || throw(ArgumentError("Finger length must be positive"))
        s > 0 || throw(ArgumentError("Finger spacing must be positive"))
        temp >= -273.15 || throw(ArgumentError("Temperature must be above absolute zero"))
        new(String(name), 0, 0, 0, 0, w, l, s, substrate, model, disp_model, temp)
    end
end

function to_qucs_netlist(ml::MicrostripLange)::String
    parts = ["MLANGE:$(ml.name)"]
    push!(parts, qucs_node(ml.n1))
    push!(parts, qucs_node(ml.n2))
    push!(parts, qucs_node(ml.n3))
    push!(parts, qucs_node(ml.n4))
    push!(parts, "W=\"$(format_value(ml.w))\"")
    push!(parts, "L=\"$(format_value(ml.l))\"")
    push!(parts, "S=\"$(format_value(ml.s))\"")
    push!(parts, "Subst=\"$(ml.substrate)\"")
    push!(parts, "Model=\"$(ml.model)\"")
    push!(parts, "DispModel=\"$(ml.disp_model)\"")
    push!(parts, "Temp=\"$(format_value(ml.temp))\"")
    return join(parts, " ")
end

function to_spice_netlist(ml::MicrostripLange)::String
    "* Lange coupler $(ml.name) ports $(ml.n1)-$(ml.n2)-$(ml.n3)-$(ml.n4), W=$(ml.w)m, L=$(ml.l)m, S=$(ml.s)m"
end

function _get_node_number(ml::MicrostripLange, terminal::Int)::Int
    terminal == 1 && return ml.n1
    terminal == 2 && return ml.n2
    terminal == 3 && return ml.n3
    terminal == 4 && return ml.n4
    throw(ArgumentError("MicrostripLange has 4 terminals (1, 2, 3, 4), got $terminal"))
end
