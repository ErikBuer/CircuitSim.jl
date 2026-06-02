"""
    CurrentVoltageNoiseSource(name::AbstractString; i1::Real=1e-6, v2::Real=1e-6, c_corr::Real=0.5, a::Real=0.0, c::Real=1.0, e::Real=0.0)

Create correlated current-voltage noise sources with 4-port configuration.

# Arguments

- `name::AbstractString`: Component identifier
- `i1::Real`: RMS current in A (default 1e-6)
- `v2::Real`: RMS voltage in V (default 1e-6)
- `c_corr::Real`: Correlation coefficient -1 to 1 (default 0.5)
- `a::Real`: Flicker noise exponent (default 0.0)
- `c::Real`: Flicker noise coefficient (default 1.0)
- `e::Real`: Flicker noise frequency exponent (default 0.0)

# Fields

- `i1plus::Int`: Positive node of current source
- `i1minus::Int`: Negative node of current source
- `v2plus::Int`: Positive node of voltage source
- `v2minus::Int`: Negative node of voltage source
"""
mutable struct CurrentVoltageNoiseSource <: AbstractNoiseSource
    name::String

    i1plus::Int   # Positive node of current source
    i1minus::Int  # Negative node of current source
    v2plus::Int   # Positive node of voltage source
    v2minus::Int  # Negative node of voltage source

    i1::Real      # RMS current in A
    v2::Real      # RMS voltage in V
    c_corr::Real  # Correlation coefficient (-1 to 1)
    a::Real       # Flicker noise exponent
    c::Real       # Flicker noise coefficient
    e::Real       # Flicker noise frequency exponent

    function CurrentVoltageNoiseSource(name::AbstractString;
        i1::Real=1e-6,
        v2::Real=1e-6,
        c_corr::Real=0.5,
        a::Real=0.0,
        c::Real=1.0,
        e::Real=0.0
    )
        i1 >= 0 || throw(ArgumentError("Current i1 must be non-negative, got $i1"))
        v2 >= 0 || throw(ArgumentError("Voltage v2 must be non-negative, got $v2"))
        -1 <= c_corr <= 1 || throw(ArgumentError("Correlation coefficient c_corr must be between -1 and 1, got $c_corr"))
        a >= 0 || throw(ArgumentError("Flicker exponent a must be non-negative, got $a"))
        c >= 0 || throw(ArgumentError("Flicker coefficient c must be non-negative, got $c"))
        e >= 0 || throw(ArgumentError("Flicker frequency exponent e must be non-negative, got $e"))
        new(String(name), -1, -1, -1, -1, i1, v2, c_corr, a, c, e)
    end
end

# Qucsator netlist format: IVnoise:Name I1+ V2+ V2- I1- i1="..." v2="..." C="..." a="..." c="..." e="..."
function to_qucs_netlist(c::CurrentVoltageNoiseSource)
    params = "i1=\"$(format_value(c.i1))\" v2=\"$(format_value(c.v2))\" C=\"$(format_value(c.c_corr))\" a=\"$(format_value(c.a))\" c=\"$(format_value(c.c))\" e=\"$(format_value(c.e))\""
    # qucs IVnoise pin order is I1+, V2+, V2-, I1-
    return "IVnoise:$(c.name) $(qucs_node(c.i1plus)) $(qucs_node(c.v2plus)) $(qucs_node(c.v2minus)) $(qucs_node(c.i1minus)) $params"
end

function _get_node_number(c::CurrentVoltageNoiseSource, pin::Symbol)
    pin == :i1plus && return c.i1plus
    pin == :i1minus && return c.i1minus
    pin == :v2plus && return c.v2plus
    pin == :v2minus && return c.v2minus
    error("Unknown pin $pin for CurrentVoltageNoiseSource")
end
