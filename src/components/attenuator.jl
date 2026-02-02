"""
    Attenuator <: AbstractAttenuator

RF attenuator for signal level control.

An attenuator reduces signal power by a specified amount while maintaining
impedance matching.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Input terminal node number
- `n2::Int`: Output terminal node number
- `attenuation::Real`: Attenuation in linear scale
- `z0::Real`: Reference impedance in Ohms (default: 50)
- `temp::Real`: Temperature in Celsius (default: 26.85)

"""
mutable struct Attenuator <: AbstractAttenuator
    name::String

    n1::Int
    n2::Int

    attenuation::Real
    z0::Real
    temp::Real

    function Attenuator(name::AbstractString;
        attenuation::Real=1.0,
        z0::Real=50.0,
        temp::Real=26.85
    )
        attenuation >= 0 || throw(ArgumentError("Attenuation must be non-negative"))
        z0 > 0 || throw(ArgumentError("Impedance must be positive"))
        new(String(name), 0, 0, attenuation, z0, temp)
    end
end

function to_qucs_netlist(comp::Attenuator)::String
    parts = ["Attenuator:$(comp.name)"]
    push!(parts, "$(qucs_node(comp.n1))")
    push!(parts, "$(qucs_node(comp.n2))")
    push!(parts, "L=\"$(format_value(comp.attenuation))\"")
    push!(parts, "Zref=\"$(format_value(comp.z0))\"")
    push!(parts, "Temp=\"$(format_value(comp.temp))\"")
    return join(parts, " ")
end

function to_spice_netlist(comp::Attenuator)::String
    # SPICE doesn't have a direct attenuator component - output warning
    return ""
end

function _get_node_number(component::Attenuator, pin::Symbol)::Int
    if pin == :n1 || pin == :input
        return component.n1
    elseif pin == :n2 || pin == :output
        return component.n2
    else
        error("Invalid pin $pin for Attenuator. Use :n1/:input or :n2/:output")
    end
end
