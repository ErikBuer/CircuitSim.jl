"""
    MicrostripRadialStub <: AbstractMicrostripRadialStub

A microstrip radial (butterfly) stub for wideband matching.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Node (connection point)
- `substrate::Substrate`: Substrate definition reference
- `ri::Real`: Inner radius (m)
- `ro::Real`: Outer radius (m)
- `wf::Real`: Feedline width (m)
- `alpha::Real`: Stub angle (degrees)

# Example

```julia
sub = Substrate("FR4", er=4.5, h=1.6e-3)
stub = MicrostripRadialStub("RS1", sub, ri=0.5e-3, ro=5.0e-3, wf=1.0e-3, alpha=60.0)
```

# Qucs Format

`MRSTUB:Name Node1 Subst="SubstName" ri="inner" ro="outer" Wf="width" alpha="angle" EffDimens="OldQucsNoCorrection" Model="OldQucsModel"`
"""
mutable struct MicrostripRadialStub <: AbstractMicrostripRadialStub
    name::String

    n1::Int

    substrate::Substrate
    ri::Real        # Inner radius (m)
    ro::Real        # Outer radius (m)
    wf::Real        # Feedline width (m)
    alpha::Real     # Stub angle (degrees)

    function MicrostripRadialStub(name::AbstractString;
        substrate::Substrate,
        ri::Real=0.5e-3,
        ro::Real=5e-3,
        wf::Real=1e-3,
        alpha::Real=60.0
    )
        ri > 0 || throw(ArgumentError("Inner radius must be positive"))
        ro > ri || throw(ArgumentError("Outer radius must be greater than inner radius"))
        wf > 0 || throw(ArgumentError("Feedline width must be positive"))
        0 < alpha <= 180 || throw(ArgumentError("Angle must be between 0 and 180 degrees"))
        new(String(name), 0, substrate, ri, ro, wf, alpha)
    end
end

function to_qucs_netlist(rs::MicrostripRadialStub)::String
    parts = ["MRSTUB:$(rs.name)"]
    push!(parts, qucs_node(rs.n1))
    push!(parts, "Subst=\"$(rs.substrate.name)\"")
    push!(parts, "ri=\"$(format_value(rs.ri))\"")
    push!(parts, "ro=\"$(format_value(rs.ro))\"")
    push!(parts, "Wf=\"$(format_value(rs.wf))\"")
    push!(parts, "alpha=\"$(rs.alpha)\"")
    push!(parts, "EffDimens=\"OldQucsNoCorrection\"")
    push!(parts, "Model=\"OldQucsModel\"")
    return join(parts, " ")
end

function to_spice_netlist(rs::MicrostripRadialStub)::String
    "* Microstrip radial stub $(rs.name) at node $(rs.n1), Ri=$(rs.ri)m, Ro=$(rs.ro)m, Wf=$(rs.wf)m, Alpha=$(rs.alpha)°"
end

function _get_node_number(rs::MicrostripRadialStub, terminal::Int)::Int
    terminal == 1 && return rs.n1
    throw(ArgumentError("MicrostripRadialStub has only 1 terminal (1), got $terminal"))
end
