"""
    BondWire <: AbstractBondWire

A bond wire connection for chip interconnects.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Node 1 (input)
- `n2::Int`: Node 2 (output)
- `l::Real`: Wire length (m)
- `d::Real`: Wire diameter (m)
- `h::Real`: Wire height above substrate (m)
- `rho::Real`: Specific resistance of the metal (Ω·m)
- `mur::Real`: Relative permeability of the metal
- `model::String`: Model type (FREESPACE, MIRROR, DESCHARLES)
- `substrate::Substrate`: Substrate definition
- `temp::Real`: Simulation temperature (°C)

# Example

```julia
sub = Substrate("Sub1", er=9.8, h=0.635e-3, t=35e-6)
wire = BondWire("BW1", substrate=sub, l=1e-3, d=25e-6, h=0.3e-3)
```

## Qucs Format

`BONDWIRE:Name Node1 Node2 L="length" D="diameter" H="height" rho="resistivity"`
"""
mutable struct BondWire <: AbstractBondWire
    name::String
    n1::Int
    n2::Int
    l::Real         # Wire length (m)
    d::Real         # Wire diameter (m)
    h::Real         # Height above substrate (m)
    rho::Real       # Specific resistance of the metal (Ω·m)
    mur::Real       # Relative permeability of the metal
    model::String   # Model type (FREESPACE, MIRROR, DESCHARLES)
    substrate::Substrate  # Substrate definition
    temp::Real      # Simulation temperature (°C)

    function BondWire(name::AbstractString;
        substrate::Substrate,
        l::Real=3e-3,
        d::Real=50e-6,
        h::Real=2e-3,
        rho::Real=0.022e-6,  # Specific resistance (Ω·m)
        mur::Real=1.0,       # Relative permeability of the metal
        model::String="FREESPACE",
        temp::Real=26.85)    # Temperature (°C)

        if model ∉ ("FREESPACE", "MIRROR", "DESCHARLES")
            throw(ArgumentError("Invalid model type: $model. Must be one of FREESPACE, MIRROR, DESCHARLES"))
        end
        l > 0 || throw(ArgumentError("Wire length must be positive"))
        d > 0 || throw(ArgumentError("Wire diameter must be positive"))
        h >= 0 || throw(ArgumentError("Wire height must be non-negative"))
        mur > 0 || throw(ArgumentError("Relative permeability must be positive"))
        rho > 0 || throw(ArgumentError("Resistivity must be positive"))
        new(String(name), 0, 0, l, d, h, rho, mur, model, substrate, temp)
    end
end

function to_qucs_netlist(bw::BondWire)::String
    parts = ["BOND:$(bw.name)"]
    push!(parts, qucs_node(bw.n1))
    push!(parts, qucs_node(bw.n2))
    push!(parts, "D=\"$(format_value(bw.d))\"")
    push!(parts, "L=\"$(format_value(bw.l))\"")
    push!(parts, "H=\"$(format_value(bw.h))\"")
    push!(parts, "mur=\"$(bw.mur)\"")
    push!(parts, "rho=\"$(bw.rho)\"")
    push!(parts, "Model=\"$(bw.model)\"")
    push!(parts, "Subst=\"$(bw.substrate.name)\"")
    push!(parts, "Temp=\"$(bw.temp)\"")
    return join(parts, " ")
end

function _get_node_number(bw::BondWire, pin::Symbol)::Int
    if pin == :n1
        return bw.n1
    elseif pin == :n2
        return bw.n2
    else
        error("Invalid pin $pin for BondWire. Use :n1 or :n2")
    end
end
