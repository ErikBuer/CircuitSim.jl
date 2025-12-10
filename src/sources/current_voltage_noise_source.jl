"""
    CurrentVoltageNoiseSource(name::String; i1::Real=1e-6, v2::Real=1e-6, c_corr::Real=0.0, a::Real=0.0, c::Real=1.0, e::Real=0.0)

Create correlated current-voltage noise sources with 4-port configuration.

# Arguments

- `name::String`: Component identifier
- `i1::Real`: RMS current in A (default 1e-6)
- `v2::Real`: RMS voltage in V (default 1e-6)
- `c_corr::Real`: Correlation coefficient -1 to 1 (default 0.0)
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

    function CurrentVoltageNoiseSource(name::String; i1::Real=1e-6, v2::Real=1e-6, c_corr::Real=0.0,
        a::Real=0.0, c::Real=1.0, e::Real=0.0)
        i1 >= 0 || throw(ArgumentError("Current i1 must be non-negative, got $i1"))
        v2 >= 0 || throw(ArgumentError("Voltage v2 must be non-negative, got $v2"))
        -1 <= c_corr <= 1 || throw(ArgumentError("Correlation coefficient c_corr must be between -1 and 1, got $c_corr"))
        new(name, -1, -1, -1, -1, i1, v2, c_corr, a, c, e)
    end
end

# Qucsator netlist format: ivnoise:Name NodeI+ NodeI- NodeV+ NodeV- i1="..." v2="..." C="..." a="..." c="..." e="..."
function to_qucs_netlist(c::CurrentVoltageNoiseSource)
    params = "i1=\"$(c.i1)\" v2=\"$(c.v2)\" C=\"$(c.c_corr)\" a=\"$(c.a)\" c=\"$(c.c)\" e=\"$(c.e)\""
    return "ivnoise:$(c.name) $(c.i1plus) $(c.i1minus) $(c.v2plus) $(c.v2minus) $params"
end

# SPICE does not have native correlated noise sources
function to_spice_netlist(c::CurrentVoltageNoiseSource)
    @warn "SPICE does not support correlated noise sources like ivnoise $(c.name)"
    return "* Correlated noise source $(c.name) not supported in SPICE"
end

function _get_node_number(c::CurrentVoltageNoiseSource, pin::Symbol)
    pin == :i1plus && return c.i1plus
    pin == :i1minus && return c.i1minus
    pin == :v2plus && return c.v2plus
    pin == :v2minus && return c.v2minus
    error("Unknown pin $pin for CurrentVoltageNoiseSource")
end
