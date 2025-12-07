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

    function ACPowerSource(name::AbstractString, port_num::Int=1;
        impedance::Real=50.0, power_dbm::Real=0.0, frequency::Real=1e9)
        port_num >= 1 || throw(ArgumentError("Port number must be >= 1"))
        impedance > 0 || throw(ArgumentError("Impedance must be positive"))
        frequency > 0 || throw(ArgumentError("Frequency must be positive"))
        new(String(name), 0, 0, port_num, impedance, power_dbm, frequency)
    end
end

# Alias for convenience
const Pac = ACPowerSource

function to_qucs_netlist(ps::ACPowerSource)::String
    # Generates Qucsator "Pac" component
    # Note: f parameter required by qucsator but overridden during sweep analysis
    return "Pac:$(ps.name) $(qucs_node(ps.nplus)) $(qucs_node(ps.nminus)) Num=\"$(ps.port_num)\" Z=\"$(ps.impedance)\" P=\"$(ps.power_dbm) dBm\" f=\"$(ps.frequency) Hz\""
end

function to_spice_netlist(ps::ACPowerSource)::String
    # SPICE doesn't have a direct equivalent - use voltage source with internal resistance
    # V = sqrt(8 * Z0 * P) where P is in Watts
    # For S-parameter analysis in ngspice, typically use .PORT directive
    power_watts = 10^((ps.power_dbm - 30) / 10)  # Convert dBm to Watts
    v_rms = sqrt(ps.impedance * power_watts)  # RMS voltage for matched load

    # Create a Thevenin equivalent: voltage source in series with impedance
    lines = String[]
    push!(lines, "* AC Power Source $(ps.name) - Port $(ps.port_num)")
    push!(lines, "V$(ps.name) $(ps.nplus)_int $(ps.nminus) AC $(2*v_rms) 0")
    push!(lines, "R$(ps.name)_z0 $(ps.nplus)_int $(ps.nplus) $(ps.impedance)")
    return join(lines, "\n")
end

function _get_node_number(ps::ACPowerSource, terminal::Symbol)::Int
    if terminal == :nplus
        return ps.nplus
    elseif terminal == :nminus
        return ps.nminus
    end
    throw(ArgumentError("ACPowerSource $(ps.name) has no terminal $terminal"))
end
