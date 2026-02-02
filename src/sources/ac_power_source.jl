"""
AC Power Source component for S-parameter and frequency-domain analysis.

This is a generic power source with specified impedance, used as a port
for S-parameter, AC, and harmonic balance analyses. In Qucsator netlists,
this becomes a "Pac" component.
"""
mutable struct ACPowerSource <: AbstractSource
    name::String

    nplus::Int
    nminus::Int

    port_num::Int
    impedance::Real
    power_dbm::Real
    frequency::Real  # Required by qucsator but overridden by sweep
    temp::Real       # Operating temperature in Degrees Celsius

    function ACPowerSource(name::AbstractString;
        port_num::Int=1,
        impedance::Real=50.0,
        power_dbm::Real=0.0,
        frequency::Real=1e9,
        temp::Real=26.85
    )
        port_num >= 1 || throw(ArgumentError("Port number must be >= 1"))
        impedance > 0 || throw(ArgumentError("Impedance must be positive"))
        frequency > 0 || throw(ArgumentError("Frequency must be positive"))
        new(String(name), 0, 0, port_num, impedance, power_dbm, frequency, temp)
    end
end

# Alias for convenience
const Pac = ACPowerSource

function to_qucs_netlist(ps::ACPowerSource)::String
    # Generates Qucsator "Pac" component
    # Note: f parameter required by qucsator but overridden during sweep analysis
    netlist = "Pac:$(ps.name) $(qucs_node(ps.nplus)) $(qucs_node(ps.nminus)) Num=\"$(ps.port_num)\" Z=\"$(ps.impedance)Ohm\" P=\"$(ps.power_dbm)dBm\" f=\"$(ps.frequency)Hz\""
    if ps.temp != 26.85
        netlist *= " Temp=\"$(ps.temp)\""
    end
    return netlist
end

function to_spice_netlist(ps::ACPowerSource)::String
    # SPICE doesn't have a direct equivalent
    return ""
end

function _get_node_number(ps::ACPowerSource, terminal::Symbol)::Int
    if terminal == :nplus
        return ps.nplus
    elseif terminal == :nminus
        return ps.nminus
    end
    throw(ArgumentError("ACPowerSource $(ps.name) has no terminal $terminal"))
end
