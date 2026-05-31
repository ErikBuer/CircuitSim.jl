"""
    MicrostripCoupled <: AbstractMicrostripCoupled

A pair of microstrip coupled transmission lines (4-port).

# Fields

- `name::String`: Component identifier
- `n1::Int`: Node 1 (line 1 input)
- `n2::Int`: Node 2 (line 1 output)
- `n3::Int`: Node 3 (line 2 input)
- `n4::Int`: Node 4 (line 2 output)
- `w::Real`: Line width in meters (default: 1e-3)
- `l::Real`: Line length in meters (default: 10e-3)
- `s::Real`: Line spacing in meters (default: 1e-3)
- `substrate::String`: Substrate reference name (default: "Subst1")
- `model::String`: Quasi-static model ("Kirschning" or "Hammerstad", default: "Kirschning")
- `disp_model::String`: Dispersion model ("Kirschning" or "Getsinger", default: "Kirschning")
- `temp::Real`: Temperature in Celsius (default: 26.85)

# Example

```julia
using CircuitSim
# Default with Kirschning model
coupled1 = MicrostripCoupled("MCPL1", w=1.0e-3, l=20e-3, s=0.2e-3)

# Custom substrate and Hammerstad model
coupled2 = MicrostripCoupled("MCPL2", substrate="MySub", 
    w=1.0e-3, l=20e-3, s=0.2e-3, model="Hammerstad")

# With Getsinger dispersion model
coupled3 = MicrostripCoupled("MCPL3", w=1.0e-3, l=20e-3, s=0.2e-3,
    disp_model="Getsinger")
```
"""
mutable struct MicrostripCoupled <: AbstractMicrostripCoupled
    name::String

    n1::Int
    n2::Int
    n3::Int
    n4::Int

    w::Real         # Line width (m)
    l::Real         # Line length (m)
    s::Real         # Line spacing (m)
    substrate::String  # Substrate reference name
    model::String   # Quasi-static model
    disp_model::String  # Dispersion model
    temp::Real      # Temperature (°C)

    function MicrostripCoupled(name::AbstractString;
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
        w > 0 || throw(ArgumentError("Width must be positive"))
        l > 0 || throw(ArgumentError("Length must be positive"))
        s > 0 || throw(ArgumentError("Spacing must be positive"))
        temp >= -273.15 || throw(ArgumentError("Temperature must be above absolute zero"))
        new(String(name), 0, 0, 0, 0, w, l, s, substrate, model, disp_model, temp)
    end
end

function to_qucs_netlist(mc::MicrostripCoupled)::String
    parts = ["MCOUPLED:$(mc.name)"]
    push!(parts, qucs_node(mc.n1))
    push!(parts, qucs_node(mc.n2))
    push!(parts, qucs_node(mc.n3))
    push!(parts, qucs_node(mc.n4))
    push!(parts, "W=\"$(format_value(mc.w))\"")
    push!(parts, "L=\"$(format_value(mc.l))\"")
    push!(parts, "S=\"$(format_value(mc.s))\"")
    push!(parts, "Subst=\"$(mc.substrate)\"")
    push!(parts, "Model=\"$(mc.model)\"")
    push!(parts, "DispModel=\"$(mc.disp_model)\"")
    push!(parts, "Temp=\"$(format_value(mc.temp))\"")
    return join(parts, " ")
end

function _get_node_number(mc::MicrostripCoupled, terminal::Int)::Int
    terminal == 1 && return mc.n1
    terminal == 2 && return mc.n2
    terminal == 3 && return mc.n3
    terminal == 4 && return mc.n4
    throw(ArgumentError("MicrostripCoupled has 4 terminals (1, 2, 3, 4), got $terminal"))
end
