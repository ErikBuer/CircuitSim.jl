"""
Microstrip step (width discontinuity) component.
"""

"""
    MicrostripStep <: AbstractMicrostripStep

A microstrip width step/discontinuity.

# Fields
- `name::String`: Component identifier
- `n1::Int`: Node 1 (input, wider/narrower side)
- `n2::Int`: Node 2 (output, other side)
- `substrate::Substrate`: Substrate definition reference
- `w1::Real`: Width at port 1 (m)
- `w2::Real`: Width at port 2 (m)

# Example
```julia
sub = Substrate("FR4", er=4.5, h=1.6e-3)
step = MicrostripStep("MSTEP1", sub, w1=3.0e-3, w2=1.5e-3)
```

# Qucs Format
`MSTEP:Name Node1 Node2 Subst="SubstName" W1="width1" W2="width2"`
"""
mutable struct MicrostripStep <: AbstractMicrostripStep
    name::String
    n1::Int
    n2::Int
    substrate::Substrate
    w1::Real        # Width at port 1 (m)
    w2::Real        # Width at port 2 (m)

    function MicrostripStep(name::AbstractString, substrate::Substrate;
        w1::Real=2e-3,
        w2::Real=1e-3)
        w1 > 0 || throw(ArgumentError("Width 1 must be positive"))
        w2 > 0 || throw(ArgumentError("Width 2 must be positive"))
        new(String(name), 0, 0, substrate, w1, w2)
    end
end

function to_qucs_netlist(ms::MicrostripStep)::String
    parts = ["MSTEP:$(ms.name)"]
    push!(parts, qucs_node(ms.n1))
    push!(parts, qucs_node(ms.n2))
    push!(parts, "Subst=\"$(ms.substrate.name)\"")
    push!(parts, "W1=\"$(format_value(ms.w1))\"")
    push!(parts, "W2=\"$(format_value(ms.w2))\"")
    return join(parts, " ")
end

function to_spice_netlist(ms::MicrostripStep)::String
    "* Microstrip step $(ms.name) from $(ms.n1) to $(ms.n2), W1=$(ms.w1)m, W2=$(ms.w2)m"
end

function _get_node_number(ms::MicrostripStep, terminal::Int)::Int
    terminal == 1 && return ms.n1
    terminal == 2 && return ms.n2
    throw(ArgumentError("MicrostripStep has only 2 terminals (1, 2), got $terminal"))
end
