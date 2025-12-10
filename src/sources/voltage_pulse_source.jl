"""
    VoltagePulseSource <: AbstractVoltageSource

Voltage source with pulse waveform for transient analysis.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Positive terminal node number
- `n2::Int`: Negative terminal node number
- `u1::Real`: Initial voltage level (V)
- `u2::Real`: Pulsed voltage level (V)
- `t1::Real`: Start time of pulse (s)
- `t2::Real`: End time of pulse (s)
- `tr::Real`: Rise time (s, optional, default 1ns)
- `tf::Real`: Fall time (s, optional, default 1ns)

# Example

```julia
vsrc = VoltagePulseSource("Vpulse1", u1=0.0, u2=5.0, t1=1e-9, t2=10e-9, tr=1e-10, tf=1e-10)
```
"""
mutable struct VoltagePulseSource <: AbstractVoltagePulseSource
    name::String
    n1::Int
    n2::Int
    u1::Real
    u2::Real
    t1::Real
    t2::Real
    tr::Real
    tf::Real

    function VoltagePulseSource(name::AbstractString;
        u1::Real=0.0, u2::Real=1.0, t1::Real=0.0, t2::Real=1e-3,
        tr::Real=1e-9, tf::Real=1e-9)
        t1 >= 0 || throw(ArgumentError("Start time must be non-negative"))
        t2 > t1 || throw(ArgumentError("End time must be greater than start time"))
        tr > 0 || throw(ArgumentError("Rise time must be positive"))
        tf > 0 || throw(ArgumentError("Fall time must be positive"))
        new(String(name), 0, 0, u1, u2, t1, t2, tr, tf)
    end
end

function to_qucs_netlist(src::VoltagePulseSource)::String
    parts = ["Vpulse:$(src.name)"]
    push!(parts, qucs_node(src.n1))
    push!(parts, qucs_node(src.n2))
    push!(parts, "U1=\"$(format_value(src.u1))\"")
    push!(parts, "U2=\"$(format_value(src.u2))\"")
    push!(parts, "T1=\"$(format_value(src.t1))\"")
    push!(parts, "T2=\"$(format_value(src.t2))\"")
    push!(parts, "Tr=\"$(format_value(src.tr))\"")
    push!(parts, "Tf=\"$(format_value(src.tf))\"")
    return join(parts, " ")
end

function to_spice_netlist(src::VoltagePulseSource)::String
    "V$(src.name) $(src.n1) $(src.n2) PULSE($(src.u1) $(src.u2) $(src.t1) $(src.tr) $(src.tf) $(src.t2-src.t1-src.tr))"
end

function _get_node_number(src::VoltagePulseSource, pin::Symbol)::Int
    if pin == :nplus || pin == :n1
        return src.n1
    elseif pin == :nminus || pin == :n2
        return src.n2
    else
        error("Invalid pin $pin for VoltagePulseSource. Use :nplus/:n1 or :nminus/:n2")
    end
end
