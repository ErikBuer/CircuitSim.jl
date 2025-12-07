"""
Voltage probe for measuring voltages in AC, DC, and transient analyses.

The probe connects between two nodes and measures the voltage difference.
It has infinite input impedance (does not affect the circuit).
"""
mutable struct VoltageProbe <: AbstractVoltageProbe
    name::String
    n1::Int  # Positive terminal
    n2::Int  # Negative terminal (can be ground)

    function VoltageProbe(name::AbstractString)
        new(String(name), 0, 0)
    end
end

function to_qucs_netlist(vp::VoltageProbe)::String
    # VProbe component measures voltage between two nodes
    # It is an open circuit (infinite impedance)
    return "VProbe:$(vp.name) $(qucs_node(vp.n1)) $(qucs_node(vp.n2))"
end

function to_spice_netlist(vp::VoltageProbe)::String
    # SPICE doesn't need explicit voltage probes
    # Voltages are always available at nodes
    # Return empty string or comment
    return "* Voltage probe $(vp.name) between nodes $(vp.n1) and $(vp.n2)"
end

function _get_node_number(vp::VoltageProbe, terminal::Symbol)::Int
    if terminal == :n1
        return vp.n1
    elseif terminal == :n2
        return vp.n2
    end
    throw(ArgumentError("VoltageProbe $(vp.name) has no terminal $terminal. Use :n1 or :n2"))
end
