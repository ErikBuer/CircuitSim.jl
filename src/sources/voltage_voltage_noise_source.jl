"""
    VoltageVoltageNoiseSource(name::String; v1::Real=1e-6, v2::Real=1e-6, c_corr::Real=0.0, a::Real=0.0, c::Real=1.0, e::Real=0.0)

Create correlated voltage-voltage noise sources with 4-port configuration.

# Arguments

- `name::String`: Component identifier
- `v1::Real`: RMS voltage of first source in V (default 1e-6)
- `v2::Real`: RMS voltage of second source in V (default 1e-6)
- `c_corr::Real`: Correlation coefficient -1 to 1 (default 0.0)
- `a::Real`: Flicker noise exponent (default 0.0)
- `c::Real`: Flicker noise coefficient (default 1.0)
- `e::Real`: Flicker noise frequency exponent (default 0.0)

# Fields

- `v1plus::Int`: Positive node of first voltage source
- `v1minus::Int`: Negative node of first voltage source
- `v2plus::Int`: Positive node of second voltage source
- `v2minus::Int`: Negative node of second voltage source
"""
mutable struct VoltageVoltageNoiseSource <: AbstractNoiseSource
    name::String

    v1plus::Int   # Positive node of first voltage source
    v1minus::Int  # Negative node of first voltage source
    v2plus::Int   # Positive node of second voltage source
    v2minus::Int  # Negative node of second voltage source

    v1::Real      # RMS voltage of first source in V
    v2::Real      # RMS voltage of second source in V
    c_corr::Real  # Correlation coefficient (-1 to 1)
    a::Real       # Flicker noise exponent
    c::Real       # Flicker noise coefficient
    e::Real       # Flicker noise frequency exponent

    function VoltageVoltageNoiseSource(name::AbstractString;
        v1::Real=1e-6,
        v2::Real=1e-6,
        c_corr::Real=0.5,
        a::Real=0.0,
        c::Real=1.0,
        e::Real=0.0
    )

        v1 >= 0 || throw(ArgumentError("Voltage v1 must be non-negative, got $v1"))
        v2 >= 0 || throw(ArgumentError("Voltage v2 must be non-negative, got $v2"))
        -1 <= c_corr <= 1 || throw(ArgumentError("Correlation coefficient c_corr must be between -1 and 1, got $c_corr"))
        a >= 0 || throw(ArgumentError("Flicker noise exponent a must be non-negative, got $a"))
        c >= 0 || throw(ArgumentError("Flicker noise coefficient c must be non-negative, got $c"))
        e >= 0 || throw(ArgumentError("Flicker noise frequency exponent e must be non-negative, got $e"))
        new(String(name), -1, -1, -1, -1, v1, v2, c_corr, a, c, e)
    end
end

# Qucsator netlist format: VVnoise:Name V1+ V2+ V2- V1- v1="..." v2="..." C="..." a="..." c="..." e="..."
function to_qucs_netlist(c::VoltageVoltageNoiseSource)
    params = "v1=\"$(format_value(c.v1))\" v2=\"$(format_value(c.v2))\" C=\"$(format_value(c.c_corr))\" a=\"$(format_value(c.a))\" c=\"$(format_value(c.c))\" e=\"$(format_value(c.e))\""
    return "VVnoise:$(c.name) $(qucs_node(c.v1plus)) $(qucs_node(c.v2plus)) $(qucs_node(c.v2minus)) $(qucs_node(c.v1minus)) $params"
end

function _get_node_number(c::VoltageVoltageNoiseSource, pin::Symbol)
    pin == :v1plus && return c.v1plus
    pin == :v1minus && return c.v1minus
    pin == :v2plus && return c.v2plus
    pin == :v2minus && return c.v2minus
    error("Unknown pin $pin for VoltageVoltageNoiseSource")
end
