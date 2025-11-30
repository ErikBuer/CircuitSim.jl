"""
Microstrip gap (series capacitance) component.
"""

"""
    MicrostripGap <: AbstractMicrostripGap

A microstrip series gap discontinuity providing capacitive coupling.

# Fields
- `name::String`: Component identifier
- `n1::Int`: Node 1 (input)
- `n2::Int`: Node 2 (output)
- `substrate::Substrate`: Substrate definition reference
- `w1::Real`: Width at port 1 (m)
- `w2::Real`: Width at port 2 (m)
- `s::Real`: Gap spacing (m)

# Example
```julia
sub = Substrate("FR4", er=4.5, h=1.6e-3)
gap = MicrostripGap("MG1", sub, w1=3.0e-3, w2=3.0e-3, s=0.2e-3)
```

# Qucs Format
`MGAP:Name Node1 Node2 Subst="SubstName" W1="width1" W2="width2" S="spacing"`
"""
mutable struct MicrostripGap <: AbstractMicrostripGap
    name::String
    n1::Int
    n2::Int
    substrate::Substrate
    w1::Real        # Width at port 1 (m)
    w2::Real        # Width at port 2 (m)
    s::Real         # Gap spacing (m)

    function MicrostripGap(name::AbstractString, substrate::Substrate;
        w1::Real=1e-3,
        w2::Real=1e-3,
        s::Real=0.1e-3)
        w1 > 0 || throw(ArgumentError("Width 1 must be positive"))
        w2 > 0 || throw(ArgumentError("Width 2 must be positive"))
        s > 0 || throw(ArgumentError("Gap spacing must be positive"))
        new(String(name), 0, 0, substrate, w1, w2, s)
    end
end

function to_qucs_netlist(mg::MicrostripGap)::String
    parts = ["MGAP:$(mg.name)"]
    push!(parts, qucs_node(mg.n1))
    push!(parts, qucs_node(mg.n2))
    push!(parts, "Subst=\"$(mg.substrate.name)\"")
    push!(parts, "W1=\"$(format_value(mg.w1))\"")
    push!(parts, "W2=\"$(format_value(mg.w2))\"")
    push!(parts, "S=\"$(format_value(mg.s))\"")
    return join(parts, " ")
end

function to_spice_netlist(mg::MicrostripGap)::String
    "* Microstrip gap $(mg.name) from $(mg.n1) to $(mg.n2), W1=$(mg.w1)m, W2=$(mg.w2)m, S=$(mg.s)m"
end

function _get_node_number(mg::MicrostripGap, terminal::Int)::Int
    terminal == 1 && return mg.n1
    terminal == 2 && return mg.n2
    throw(ArgumentError("MicrostripGap has only 2 terminals (1, 2), got $terminal"))
end
