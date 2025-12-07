"""
Current probe for measuring current in AC, DC, and transient analyses.

The probe is inserted in series with a circuit element and measures current.
It acts as a short circuit (zero impedance).
"""
mutable struct CurrentProbe <: AbstractCurrentProbe
    name::String
    n1::Int  # Input terminal
    n2::Int  # Output terminal

    function CurrentProbe(name::AbstractString)
        new(String(name), 0, 0)
    end
end

function to_qucs_netlist(ip::CurrentProbe)::String
    # IProbe component measures current through it
    # It is a short circuit (zero impedance voltage source)
    return "IProbe:$(ip.name) $(qucs_node(ip.n1)) $(qucs_node(ip.n2))"
end

function to_spice_netlist(ip::CurrentProbe)::String
    # SPICE uses zero-voltage source for current measurement
    return "V$(ip.name) $(ip.n1) $(ip.n2) DC 0"
end

function _get_node_number(ip::CurrentProbe, terminal::Symbol)::Int
    if terminal == :n1
        return ip.n1
    elseif terminal == :n2
        return ip.n2
    end
    throw(ArgumentError("CurrentProbe $(ip.name) has no terminal $terminal. Use :n1 or :n2"))
end
