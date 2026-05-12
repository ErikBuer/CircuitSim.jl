"""
    CoaxialLine <: AbstractComponent

Coaxial transmission line with physical parameters.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Port 1 node
- `n2::Int`: Port 2 node
- `D::Real`: Outer conductor diameter (m) (default: 2.95e-3)
- `d::Real`: Inner conductor diameter (m) (default: 0.9e-3)
- `L::Real`: Physical length (m) (default: 1.5)
- `er::Real`: Relative permittivity (default: 2.29)
- `mur::Real`: Relative permeability (default: 1.0)
- `tand::Real`: Loss tangent (default: 4e-4)
- `rho::Real`: Conductor resistivity (Ω·m) (default: 0.022e-6)
- `temp::Real`: Temperature (°C) (default: 26.85)

# Example

```julia
coax = CoaxialLine("COAX1", D=2.95e-3, d=0.9e-3, L=0.1)
```
"""
mutable struct CoaxialLine <: AbstractTransmissionLine2Port
    name::String

    n1::Int
    n2::Int

    D::Real      # Outer conductor diameter (m)
    d::Real      # Inner conductor diameter (m)
    L::Real      # Length (m)
    er::Real     # Relative permittivity
    mur::Real    # Relative permeability
    tand::Real   # Loss tangent
    rho::Real    # Resistivity (Ω·m)
    temp::Real   # Temperature (°C)

    function CoaxialLine(name::AbstractString;
        D::Real=2.95e-3,
        d::Real=0.9e-3,
        L::Real=1.5,
        er::Real=2.29,
        mur::Real=1.0,
        tand::Real=4e-4,
        rho::Real=0.022e-6,
        temp::Real=26.85
    )
        D > 0 || throw(ArgumentError("Outer diameter must be positive"))
        d > 0 || throw(ArgumentError("Inner diameter must be positive"))
        d < D || throw(ArgumentError("Inner diameter must be less than outer diameter"))
        er >= 1 || throw(ArgumentError("Relative permittivity must be >= 1"))
        mur >= 1 || throw(ArgumentError("Relative permeability must be >= 1"))
        new(String(name), 0, 0, D, d, L, er, mur, tand, rho, temp)
    end
end

function to_qucs_netlist(comp::CoaxialLine)::String
    parts = ["COAX:$(comp.name)"]
    push!(parts, qucs_node(comp.n1))
    push!(parts, qucs_node(comp.n2))
    push!(parts, "D=\"$(format_value(comp.D))\"")
    push!(parts, "d=\"$(format_value(comp.d))\"")
    push!(parts, "L=\"$(format_value(comp.L))\"")
    push!(parts, "er=\"$(comp.er)\"")
    push!(parts, "mur=\"$(comp.mur)\"")
    push!(parts, "tand=\"$(comp.tand)\"")
    push!(parts, "rho=\"$(comp.rho)\"")
    push!(parts, "Temp=\"$(comp.temp)\"")
    return join(parts, " ")
end

function to_spice_netlist(comp::CoaxialLine)::String
    "* CoaxialLine $(comp.name) not directly supported in SPICE"
end

function _get_node_number(comp::CoaxialLine, pin::Symbol)
    if pin == :n1
        return comp.n1
    elseif pin == :n2
        return comp.n2
    else
        error("Invalid pin $pin for CoaxialLine. Use :n1 or :n2")
    end
end
