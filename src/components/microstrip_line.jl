"""
    MicrostripLine <: AbstractMicrostripLine

A microstrip transmission line segment.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Node 1 (input)
- `n2::Int`: Node 2 (output)
- `substrate::Substrate`: Substrate definition reference
- `w::Real`: Line width (m)
- `l::Real`: Line length (m)
- `model::String`: Optional SPICE model name
- `temp::Real`: Temperature (K)

# Example

```julia
sub = Substrate("FR4", er=4.5, h=1.6e-3)
line = MicrostripLine("MS1", sub, w=3.0e-3, l=20e-3)
```

# Qucs Format

`MLIN:Name Node1 Node2 Subst="SubstName" W="width" L="length" Temp="temp"`
"""
mutable struct MicrostripLine <: AbstractMicrostripLine
    name::String
    n1::Int
    n2::Int
    substrate::Substrate
    w::Real         # Width (m)
    l::Real         # Length (m)
    model::String   # SPICE model name
    temp::Real      # Temperature (K)

    function MicrostripLine(name::AbstractString, substrate::Substrate;
        w::Real=1e-3,
        l::Real=10e-3,
        model::String="",
        temp::Real=293.15)
        w > 0 || throw(ArgumentError("Width must be positive"))
        l > 0 || throw(ArgumentError("Length must be positive"))
        temp > 0 || throw(ArgumentError("Temperature must be positive"))
        new(String(name), 0, 0, substrate, w, l, model, temp)
    end
end

function to_qucs_netlist(ms::MicrostripLine)::String
    parts = ["MLIN:$(ms.name)"]
    push!(parts, qucs_node(ms.n1))
    push!(parts, qucs_node(ms.n2))
    push!(parts, "Subst=\"$(ms.substrate.name)\"")
    push!(parts, "W=\"$(format_value(ms.w))\"")
    push!(parts, "L=\"$(format_value(ms.l))\"")
    push!(parts, "Temp=\"$(ms.temp)\"")
    push!(parts, "Model=\"Hammerstad\"")
    push!(parts, "DispModel=\"Kirschning\"")
    return join(parts, " ")
end

function to_spice_netlist(ms::MicrostripLine)::String
    # SPICE approximation using transmission line LTRA or lossy TL
    # Simplified as a 2-port network
    model_ref = isempty(ms.model) ? "MSLINE" : ms.model
    "* Microstrip line $(ms.name) from $(ms.n1) to $(ms.n2), W=$(ms.w)m, L=$(ms.l)m (requires .MODEL $(model_ref))"
end

function _get_node_number(ms::MicrostripLine, terminal::Int)::Int
    terminal == 1 && return ms.n1
    terminal == 2 && return ms.n2
    throw(ArgumentError("MicrostripLine has only 2 terminals (1, 2), got $terminal"))
end
