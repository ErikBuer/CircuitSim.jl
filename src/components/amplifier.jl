"""
    Amplifier <: AbstractPowerAmplifier

RF/microwave amplifier with gain and noise figure.

This is a simplified amplifier model suitable for system-level simulations.

# Fields
- `name::String`: Component identifier
- `n1::Int`: Input terminal node number
- `n2::Int`: Output terminal node number
- `gain::Real`: Linear voltage gain. For 20 dB gain, use gain=10.0
- `nf::Real`: Noise figure (linear). For 3 dB NF, use nf=2.0. Default: 1.0 (noiseless)
- `z_in::Real`: Input impedance in Ohms (default: 50)
- `z_out::Real`: Output impedance in Ohms (default: 50)
- `p1db::Real`: 1-dB compression point in dBm (default: 20 dBm)

"""
mutable struct Amplifier <: AbstractPowerAmplifier
    name::String
    n1::Int
    n2::Int
    gain::Real
    nf::Real
    z_in::Real
    z_out::Real
    p1db::Real          # TODO. Is this implemented in backends?

    function Amplifier(name::AbstractString, gain::Real, nf::Real=1.0;
        z_in::Real=50.0, z_out::Real=50.0, p1db::Real=20.0)
        z_in > 0 || throw(ArgumentError("Input impedance must be positive"))
        z_out > 0 || throw(ArgumentError("Output impedance must be positive"))
        gain >= 1 || throw(ArgumentError("Gain must be >= 1 (linear)"))
        nf >= 1 || throw(ArgumentError("Noise figure must be >= 1 (linear)"))
        new(String(name), 0, 0, gain, nf, z_in, z_out, p1db)
    end
end

function to_qucs_netlist(comp::Amplifier)::String
    # Qucs amplifier model - G and NF are linear values, NOT dB
    parts = ["Amp:$(comp.name)"]
    push!(parts, "$(qucs_node(comp.n1))")
    push!(parts, "$(qucs_node(comp.n2))")
    push!(parts, "G=\"$(format_value(comp.gain))\"")
    if comp.nf > 1
        push!(parts, "NF=\"$(format_value(comp.nf))\"")
    end
    push!(parts, "Z1=\"$(format_value(comp.z_in))\"")
    push!(parts, "Z2=\"$(format_value(comp.z_out))\"")
    return join(parts, " ")
end

function to_spice_netlist(comp::Amplifier)::String
    # SPICE model using voltage-controlled voltage source with impedances
    # comp.gain is already linear voltage gain
    gv = comp.gain  # Use gain directly as it's already linear

    lines = String[]
    push!(lines, "* Amplifier $(comp.name): Gain=$(comp.gain) (linear), NF=$(comp.nf) (linear)")
    push!(lines, "R$(comp.name)_in $(comp.n1) 0 $(comp.z_in)")
    push!(lines, "E$(comp.name) $(comp.n1)_int 0 $(comp.n1) 0 $(gv)")
    push!(lines, "R$(comp.name)_out $(comp.n1)_int $(comp.n2) $(comp.z_out)")
    return join(lines, "\n")
end

function _get_node_number(component::Amplifier, pin::Symbol)::Int
    if pin == :n1 || pin == :input
        return component.n1
    elseif pin == :n2 || pin == :output
        return component.n2
    else
        error("Invalid pin $pin for Amplifier. Use :n1/:input or :n2/:output")
    end
end
