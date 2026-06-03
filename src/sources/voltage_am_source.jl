"""
    VoltageAMSource(name::String; u::Real=1.0, f::Real=1e9, m::Real=1.0, phase::Real=0.0)

Create an amplitude modulated voltage source with 3-port configuration.

# Arguments

- `name::String`: Component identifier
- `u::Real`: Carrier amplitude in Volts (default 1.0)
- `f::Real`: Carrier frequency in Hz (default 1e9)
- `m::Real`: Modulation index 0 to 1 (default 1.0)
- `phase::Real`: Phase in degrees -360 to 360 (default 0.0)

# Fields 
 
- `nplus::Int`: Positive output node
- `nminus::Int`: Negative output node
- `nmod::Int`: Modulation input node
"""
mutable struct VoltageAMSource <: AbstractSource
    name::String

    nplus::Int   # Positive output node
    nminus::Int  # Negative output node
    nmod::Int    # Modulation input node

    u::Real      # Carrier amplitude in Volts
    f::Real      # Carrier frequency in Hz
    m::Real      # Modulation index (0 to 1)
    phase::Real  # Phase in degrees (-360 to 360)

    function VoltageAMSource(name::AbstractString;
        u::Real=1.0,
        f::Real=1e9,
        m::Real=1.0,
        phase::Real=0.0
    )
        f > 0 || throw(ArgumentError("Frequency f must be positive, got $f"))
        0 <= m <= 1 || throw(ArgumentError("Modulation index m must be between 0 and 1, got $m"))
        -360 <= phase <= 360 || throw(ArgumentError("Phase must be between -360 and 360 degrees, got $phase"))
        new(String(name), -1, -1, -1, u, f, m, phase)
    end
end

# Qucsator netlist format: AM_Mod:Name Node+ Node- ModNode U="..." f="..." m="..." Phase="..."
function to_qucs_netlist(c::VoltageAMSource)
    params = "U=\"$(format_value(c.u))\" f=\"$(format_value(c.f))\" m=\"$(format_value(c.m))\" Phase=\"$(format_value(c.phase))\""
    return "AM_Mod:$(c.name) $(qucs_node(c.nplus)) $(qucs_node(c.nminus)) $(qucs_node(c.nmod)) $params"
end


function _get_node_number(c::VoltageAMSource, pin::Symbol)
    pin == :nplus && return c.nplus
    pin == :nminus && return c.nminus
    pin == :nmod && return c.nmod
    error("Unknown pin $pin for VoltageAMSource")
end
