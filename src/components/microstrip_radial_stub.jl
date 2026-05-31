"""
    MicrostripRadialStub <: AbstractMicrostripRadialStub

A microstrip radial (butterfly) stub for wideband matching.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Node (connection point)
- `ri::Real`: Inner radius in meters (default: 1e-3)
- `ro::Real`: Outer radius in meters (default: 10e-3)
- `wf::Real`: Feedline width in meters (default: 1e-3)
- `alpha::Real`: Stub angle in degrees (default: 90.0)
- `substrate::String`: Substrate reference name (default: "Subst1")
- `eff_dimens::String`: Effective dimensions model (default: "OldQucsNoCorrection")
- `model::String`: Analysis model (default: "OldQucsModel")

# Example

```julia
using CircuitSim
# Default radial stub
stub1 = MicrostripRadialStub("RS1", ri=1e-3, ro=10e-3, wf=1.0e-3, alpha=90.0)

# Custom substrate and model
stub2 = MicrostripRadialStub("RS2", substrate="Sub1", 
    ri=0.5e-3, ro=5.0e-3, wf=1.0e-3, alpha=60.0,
    eff_dimens="Giannini", model="March")
```

# Qucs Format

`MRSTUB:Name Node1 ri="inner" ro="outer" Wf="width" alpha="angle" Subst="SubstName" EffDimens="..." Model="..."`
"""
mutable struct MicrostripRadialStub <: AbstractMicrostripRadialStub
    name::String

    n1::Int

    ri::Real           # Inner radius (m)
    ro::Real           # Outer radius (m)
    wf::Real           # Feedline width (m)
    alpha::Real        # Stub angle (degrees)
    substrate::String  # Substrate reference name
    eff_dimens::String # Effective dimensions model
    model::String      # Analysis model

    function MicrostripRadialStub(name::AbstractString;
        ri::Real=1e-3,
        ro::Real=10e-3,
        wf::Real=1e-3,
        alpha::Real=90.0,
        substrate::String="Subst1",
        eff_dimens::String="OldQucsNoCorrection",
        model::String="OldQucsModel"
    )
        if eff_dimens ∉ ("OldQucsNoCorrection", "Chew_Kong", "Giannini")
            throw(ArgumentError("Invalid effective dimensions model: $eff_dimens. Must be one of OldQucsNoCorrection, Chew_Kong, Giannini"))
        end
        if model ∉ ("OldQucsModel", "March", "Giannini")
            throw(ArgumentError("Invalid model: $model. Must be one of OldQucsModel, March, Giannini"))
        end
        ri > 0 || throw(ArgumentError("Inner radius must be positive"))
        ro > ri || throw(ArgumentError("Outer radius must be greater than inner radius"))
        wf > 0 || throw(ArgumentError("Feedline width must be positive"))
        0 < alpha <= 180 || throw(ArgumentError("Angle must be between 0 and 180 degrees"))
        new(String(name), 0, ri, ro, wf, alpha, substrate, eff_dimens, model)
    end
end

function to_qucs_netlist(rs::MicrostripRadialStub)::String
    parts = ["MRSTUB:$(rs.name)"]
    push!(parts, qucs_node(rs.n1))
    push!(parts, "ri=\"$(format_value(rs.ri))\"")
    push!(parts, "ro=\"$(format_value(rs.ro))\"")
    push!(parts, "Wf=\"$(format_value(rs.wf))\"")
    push!(parts, "alpha=\"$(rs.alpha)\"")
    push!(parts, "Subst=\"$(rs.substrate)\"")
    push!(parts, "EffDimens=\"$(rs.eff_dimens)\"")
    push!(parts, "Model=\"$(rs.model)\"")
    return join(parts, " ")
end

function _get_node_number(rs::MicrostripRadialStub, terminal::Int)::Int
    terminal == 1 && return rs.n1
    throw(ArgumentError("MicrostripRadialStub has only 1 terminal (1), got $terminal"))
end
