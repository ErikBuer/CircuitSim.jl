"""
Power port component for S-parameter analysis (Pac).

Used in Qucsator S-parameter simulations to define measurement ports.
Each Pac defines a port with specified impedance and input power.
"""
mutable struct Pac <: AbstractSource
    name::String
    nplus::Int
    nminus::Int
    port_num::Int
    impedance::Real
    power_dbm::Real

    function Pac(name::AbstractString, port_num::Int=1;
        impedance::Real=50.0, power_dbm::Real=0.0)
        port_num >= 1 || throw(ArgumentError("Port number must be >= 1"))
        impedance > 0 || throw(ArgumentError("Impedance must be positive"))
        new(String(name), 0, 0, port_num, impedance, power_dbm)
    end
end

function to_qucs_netlist(pac::Pac)::String
    return "Pac:$(pac.name) _net$(pac.nplus) _net$(pac.nminus) Num=\"$(pac.port_num)\" Z=\"$(pac.impedance)\" P=\"$(pac.power_dbm) dBm\" f=\"1.0 GHz\""
end

function to_spice_netlist(pac::Pac)::String
    # SPICE doesn't have native S-parameter ports
    # This is a placeholder - S-parameter analysis is Qucsator-specific
    error("Pac component is only supported in Qucsator for S-parameter analysis")
end

function _get_node_number(pac::Pac, terminal::Symbol)::Int
    if terminal == :nplus
        return pac.nplus
    elseif terminal == :nminus
        return pac.nminus
    end
    throw(ArgumentError("Pac $(pac.name) has no terminal $terminal"))
end
