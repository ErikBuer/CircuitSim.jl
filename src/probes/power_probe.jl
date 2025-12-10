"""
Power probe for measuring power flow in circuits.

The probe measures power between two differential ports (4 terminals total).
"""
mutable struct PowerProbe <: AbstractWaveProbe
    name::String
    n1::Int
    n2::Int
    n3::Int
    n4::Int

    function PowerProbe(name::AbstractString)
        new(String(name), 0, 0, 0, 0)
    end
end

function to_qucs_netlist(comp::PowerProbe)::String
    # WProbe requires 4 nodes in qucsator
    return "WProbe:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) $(qucs_node(comp.n3)) $(qucs_node(comp.n4))"
end

function to_spice_netlist(comp::PowerProbe)::String
    "* Power probe $(comp.name) not directly supported in SPICE"
end

function _get_node_number(comp::PowerProbe, terminal::Symbol)::Int
    if terminal == :n1
        return comp.n1
    elseif terminal == :n2
        return comp.n2
    elseif terminal == :n3
        return comp.n3
    elseif terminal == :n4
        return comp.n4
    end
    throw(ArgumentError("PowerProbe $(comp.name) has no terminal $terminal. Use :n1, :n2, :n3, or :n4"))
end
