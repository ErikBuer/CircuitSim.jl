"""
    CurrentCurrentNoiseSource(name::String; i1::Real=1e-6, i2::Real=1e-6, c_corr::Real=0.0, a::Real=0.0, c::Real=1.0, e::Real=0.0)

Create correlated current-current noise sources with 4-port configuration.

# Arguments

- `name::String`: Component identifier
- `i1::Real`: RMS current of first source in A (default 1e-6)
- `i2::Real`: RMS current of second source in A (default 1e-6)
- `c_corr::Real`: Correlation coefficient -1 to 1 (default 0.0)
- `a::Real`: Flicker noise exponent (default 0.0)
- `c::Real`: Flicker noise coefficient (default 1.0)
- `e::Real`: Flicker noise frequency exponent (default 0.0)

# Fields

- `i1plus::Int`: Positive node of first current source
- `i1minus::Int`: Negative node of first current source
- `i2plus::Int`: Positive node of second current source
- `i2minus::Int`: Negative node of second current source
"""
mutable struct CurrentCurrentNoiseSource <: AbstractNoiseSource
    name::String
    i1plus::Int   # Positive node of first current source
    i1minus::Int  # Negative node of first current source
    i2plus::Int   # Positive node of second current source
    i2minus::Int  # Negative node of second current source
    i1::Real      # RMS current of first source in A
    i2::Real      # RMS current of second source in A
    c_corr::Real  # Correlation coefficient (-1 to 1)
    a::Real       # Flicker noise exponent
    c::Real       # Flicker noise coefficient
    e::Real       # Flicker noise frequency exponent

    function CurrentCurrentNoiseSource(name::String; i1::Real=1e-6, i2::Real=1e-6, c_corr::Real=0.0,
        a::Real=0.0, c::Real=1.0, e::Real=0.0)
        i1 >= 0 || throw(ArgumentError("Current i1 must be non-negative, got $i1"))
        i2 >= 0 || throw(ArgumentError("Current i2 must be non-negative, got $i2"))
        -1 <= c_corr <= 1 || throw(ArgumentError("Correlation coefficient c_corr must be between -1 and 1, got $c_corr"))
        new(name, -1, -1, -1, -1, i1, i2, c_corr, a, c, e)
    end
end

# Qucsator netlist format: iinoise:Name Node1+ Node1- Node2+ Node2- i1="..." i2="..." C="..." a="..." c="..." e="..."
function to_qucs_netlist(c::CurrentCurrentNoiseSource)
    params = "i1=\"$(c.i1)\" i2=\"$(c.i2)\" C=\"$(c.c_corr)\" a=\"$(c.a)\" c=\"$(c.c)\" e=\"$(c.e)\""
    return "iinoise:$(c.name) $(c.i1plus) $(c.i1minus) $(c.i2plus) $(c.i2minus) $params"
end

# SPICE does not have native correlated noise sources
function to_spice_netlist(c::CurrentCurrentNoiseSource)
    @warn "SPICE does not support correlated noise sources like iinoise $(c.name)"
    return "* Correlated noise source $(c.name) not supported in SPICE"
end

function _get_node_number(c::CurrentCurrentNoiseSource, pin::Symbol)
    pin == :i1plus && return c.i1plus
    pin == :i1minus && return c.i1minus
    pin == :i2plus && return c.i2plus
    pin == :i2minus && return c.i2minus
    error("Unknown pin $pin for CurrentCurrentNoiseSource")
end
