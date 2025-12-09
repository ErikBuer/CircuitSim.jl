"""
Rectangular pulse voltage source for transient analysis.
"""

"""
    VoltageRectangularSource <: AbstractVoltageSource

Periodic rectangular pulse voltage source for transient analysis.

# Fields
- `name::String`: Component identifier
- `n1::Int`: Positive terminal node number
- `n2::Int`: Negative terminal node number
- `u::Real`: Pulse voltage level (V)
- `th::Real`: High time duration (s)
- `tl::Real`: Low time duration (s)
- `tr::Real`: Rise time (s, optional, default 1ns)
- `tf::Real`: Fall time (s, optional, default 1ns)
- `td::Real`: Delay time (s, optional, default 0)

# Example
```julia
vsrc = VoltageRectangularSource("Vrect1", u=5.0, th=1e-6, tl=1e-6)
```

# Qucs Format
`Vrect:Name Node+ Node- U="u" TH="th" TL="tl" Tr="tr" Tf="tf" Td="td"`
"""
mutable struct VoltageRectangularSource <: AbstractVoltageRectifiedSource
    name::String
    n1::Int
    n2::Int
    u::Real
    th::Real
    tl::Real
    tr::Real
    tf::Real
    td::Real

    function VoltageRectangularSource(name::AbstractString;
        u::Real=1.0, th::Real=1e-3, tl::Real=1e-3,
        tr::Real=1e-9, tf::Real=1e-9, td::Real=0.0)
        th > 0 || throw(ArgumentError("High time must be positive"))
        tl > 0 || throw(ArgumentError("Low time must be positive"))
        tr > 0 || throw(ArgumentError("Rise time must be positive"))
        tf > 0 || throw(ArgumentError("Fall time must be positive"))
        td >= 0 || throw(ArgumentError("Delay time must be non-negative"))
        new(String(name), 0, 0, u, th, tl, tr, tf, td)
    end
end

function to_qucs_netlist(src::VoltageRectangularSource)::String
    parts = ["Vrect:$(src.name)"]
    push!(parts, qucs_node(src.n1))
    push!(parts, qucs_node(src.n2))
    push!(parts, "U=\"$(format_value(src.u))\"")
    push!(parts, "TH=\"$(format_value(src.th))\"")
    push!(parts, "TL=\"$(format_value(src.tl))\"")
    push!(parts, "Tr=\"$(format_value(src.tr))\"")
    push!(parts, "Tf=\"$(format_value(src.tf))\"")
    push!(parts, "Td=\"$(format_value(src.td))\"")
    return join(parts, " ")
end

function to_spice_netlist(src::VoltageRectangularSource)::String
    per = src.th + src.tl
    "V$(src.name) $(src.n1) $(src.n2) PULSE(0 $(src.u) $(src.td) $(src.tr) $(src.tf) $(src.th) $(per))"
end

function _get_node_number(src::VoltageRectangularSource, pin::Symbol)::Int
    if pin == :nplus || pin == :n1
        return src.n1
    elseif pin == :nminus || pin == :n2
        return src.n2
    else
        error("Invalid pin $pin for VoltageRectangularSource. Use :nplus/:n1 or :nminus/:n2")
    end
end
