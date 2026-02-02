"""
    CurrentExponentialSource <: AbstractCurrentSource

Exponential rise/fall current source for transient analysis.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Positive terminal node number
- `n2::Int`: Negative terminal node number
- `i1::Real`: Initial current level (A)
- `i2::Real`: Final current level (A)
- `t1::Real`: Rise delay time (s)
- `t2::Real`: Fall delay time (s)
- `tr::Real`: Rise time constant (s, optional, default 1ns)
- `tf::Real`: Fall time constant (s, optional, default 1ns)

# Example

```julia
isrc = CurrentExponentialSource("Iexp1", i1=0.0, i2=10e-3, t1=1e-9, t2=10e-9)
```
"""
mutable struct CurrentExponentialSource <: AbstractSource
    name::String

    n1::Int
    n2::Int

    i1::Real
    i2::Real
    t1::Real
    t2::Real
    tr::Real
    tf::Real

    function CurrentExponentialSource(name::AbstractString;
        i1::Real=0.0,
        i2::Real=1e-3,
        t1::Real=0.0,
        t2::Real=1e-3,
        tr::Real=1e-9,
        tf::Real=1e-9
    )
        t1 >= 0 || throw(ArgumentError("Rise delay must be non-negative"))
        t2 > t1 || throw(ArgumentError("Fall delay must be greater than rise delay"))
        tr > 0 || throw(ArgumentError("Rise time constant must be positive"))
        tf > 0 || throw(ArgumentError("Fall time constant must be positive"))
        new(String(name), 0, 0, i1, i2, t1, t2, tr, tf)
    end
end

function to_qucs_netlist(src::CurrentExponentialSource)::String
    parts = ["Iexp:$(src.name)"]
    push!(parts, qucs_node(src.n1))
    push!(parts, qucs_node(src.n2))
    push!(parts, "I1=\"$(format_value(src.i1))\"")
    push!(parts, "I2=\"$(format_value(src.i2))\"")
    push!(parts, "T1=\"$(format_value(src.t1))\"")
    push!(parts, "T2=\"$(format_value(src.t2))\"")
    push!(parts, "Tr=\"$(format_value(src.tr))\"")
    push!(parts, "Tf=\"$(format_value(src.tf))\"")
    return join(parts, " ")
end

function to_spice_netlist(src::CurrentExponentialSource)::String
    "I$(src.name) $(src.n1) $(src.n2) EXP($(src.i1) $(src.i2) $(src.t1) $(src.tr) $(src.t2) $(src.tf))"
end

function _get_node_number(src::CurrentExponentialSource, pin::Symbol)::Int
    if pin == :nplus || pin == :n1
        return src.n1
    elseif pin == :nminus || pin == :n2
        return src.n2
    else
        error("Invalid pin $pin for CurrentExponentialSource. Use :nplus/:n1 or :nminus/:n2")
    end
end
