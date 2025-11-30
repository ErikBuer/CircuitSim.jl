"""
Bond wire component.
"""

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
- `rho::Real`: Resistivity relative to copper

# Example
```julia
wire = BondWire("BW1", l=1e-3, d=25e-6, h=0.3e-3)
```

# Qucs Format
`BONDWIRE:Name Node1 Node2 L="length" D="diameter" H="height" rho="resistivity"`
"""
mutable struct BondWire <: AbstractBondWire
    name::String
    n1::Int
    n2::Int
    l::Real         # Wire length (m)
    d::Real         # Wire diameter (m)
    h::Real         # Height above substrate (m)
    rho::Real       # Resistivity (relative to copper)
    model::String   # Model type

    function BondWire(name::AbstractString;
        l::Real=1e-3,
        d::Real=25e-6,
        h::Real=0.3e-3,
        rho::Real=1.0,      # 1.0 = gold, 0.6 = copper relative
        model::String="FREESPACE")
        l > 0 || throw(ArgumentError("Wire length must be positive"))
        d > 0 || throw(ArgumentError("Wire diameter must be positive"))
        h >= 0 || throw(ArgumentError("Wire height must be non-negative"))
        rho > 0 || throw(ArgumentError("Resistivity must be positive"))
        new(String(name), 0, 0, l, d, h, rho, model)
    end
end

function to_qucs_netlist(bw::BondWire)::String
    parts = ["BONDWIRE:$(bw.name)"]
    push!(parts, qucs_node(bw.n1))
    push!(parts, qucs_node(bw.n2))
    push!(parts, "L=\"$(format_value(bw.l))\"")
    push!(parts, "D=\"$(format_value(bw.d))\"")
    push!(parts, "H=\"$(format_value(bw.h))\"")
    push!(parts, "rho=\"$(bw.rho)\"")
    push!(parts, "Model=\"$(bw.model)\"")
    push!(parts, "Subst=\"\"")
    push!(parts, "mur=\"1\"")
    return join(parts, " ")
end

function to_spice_netlist(bw::BondWire)::String
    # Approximate bond wire as an inductor
    # Simple formula: L ≈ 2*l*(ln(4*l/d) - 1) nH for l in mm, d in mm
    l_mm = bw.l * 1000
    d_mm = bw.d * 1000
    l_nh = 2 * l_mm * (log(4 * l_mm / d_mm) - 1)
    "L$(bw.name) $(bw.n1) $(bw.n2) $(l_nh)n  ; Bond wire approx"
end

function _get_node_number(bw::BondWire, terminal::Int)::Int
    terminal == 1 && return bw.n1
    terminal == 2 && return bw.n2
    throw(ArgumentError("BondWire has only 2 terminals (1, 2), got $terminal"))
end
