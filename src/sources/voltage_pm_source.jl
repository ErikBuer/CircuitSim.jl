"""
    VoltagePMSource(name::String; u::Real=1.0, f::Real=1e9, m::Real=1.0, phase::Real=0.0)

Create a phase modulated voltage source with 3-port configuration.

# Arguments

- `name::String`: Component identifier
- `u::Real`: Carrier amplitude in Volts (default 1.0)
- `f::Real`: Carrier frequency in Hz (default 1e9)
- `m::Real`: Modulation index 0 to 1 (default 1.0)
- `phase::Real`: Base phase in degrees -360 to 360 (default 0.0)

# Fields

- `nplus::Int`: Positive output node
- `nminus::Int`: Negative output node
- `nmod::Int`: Modulation input node
"""
mutable struct VoltagePMSource <: AbstractSource
    name::String
    nplus::Int   # Positive output node
    nminus::Int  # Negative output node
    nmod::Int    # Modulation input node
    u::Real      # Carrier amplitude in Volts
    f::Real      # Carrier frequency in Hz
    m::Real      # Modulation index (0 to 1)
    phase::Real  # Base phase in degrees (-360 to 360)

    function VoltagePMSource(name::String; u::Real=1.0, f::Real=1e9, m::Real=1.0, phase::Real=0.0)
        f > 0 || throw(ArgumentError("Frequency f must be positive, got $f"))
        0 <= m <= 1 || throw(ArgumentError("Modulation index m must be between 0 and 1, got $m"))
        -360 <= phase <= 360 || throw(ArgumentError("Phase must be between -360 and 360 degrees, got $phase"))
        new(name, -1, -1, -1, u, f, m, phase)
    end
end

# Qucsator netlist format: PM_Mod:Name Node+ Node- ModNode U="..." f="..." M="..." Phase="..."
function to_qucs_netlist(c::VoltagePMSource)
    params = "U=\"$(c.u)\" f=\"$(c.f)\" M=\"$(c.m)\" Phase=\"$(c.phase)\""
    return "PM_Mod:$(c.name) $(c.nplus) $(c.nminus) $(c.nmod) $params"
end

# SPICE does not have native PM sources - use behavioral source
function to_spice_netlist(c::VoltagePMSource)
    # B-source with PM modulation formula
    # V = U * sin(2*pi*f*t + phase + m*V(modnode))
    phase_rad = c.phase * π / 180
    return "B$(c.name) $(c.nplus) $(c.nminus) V=$(c.u)*sin(2*pi*$(c.f)*time+$(phase_rad)+$(c.m)*V($(c.nmod)))"
end

function _get_node_number(c::VoltagePMSource, pin::Symbol)
    pin == :nplus && return c.nplus
    pin == :nminus && return c.nminus
    pin == :nmod && return c.nmod
    error("Unknown pin $pin for VoltagePMSource")
end
