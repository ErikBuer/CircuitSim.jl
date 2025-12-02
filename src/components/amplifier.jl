"""
    Amplifier <: AbstractPowerAmplifier

RF/microwave amplifier with gain and noise figure.

This is a simplified amplifier model suitable for system-level simulations.

# Fields
- `name::String`: Component identifier
- `n1::Int`: Input terminal node number
- `n2::Int`: Output terminal node number
- `gain::Real`: Power gain in dB
- `nf::Real`: Noise figure in dB (default: 0 for noiseless)
- `z_in::Real`: Input impedance in Ohms (default: 50)
- `z_out::Real`: Output impedance in Ohms (default: 50)
- `p1db::Real`: 1-dB compression point in dBm (default: 20 dBm)

# Example
```@example
using CircuitTypes
# Low noise amplifier: 20 dB gain, 1.5 dB NF
LNA = Amplifier("LNA", 20.0, 1.5)

# Power amplifier: 30 dB gain, 5 dB NF, +30 dBm P1dB
PA = Amplifier("PA", 30.0, 5.0, p1db=30.0)
```
"""
mutable struct Amplifier <: AbstractPowerAmplifier
    name::String
    n1::Int
    n2::Int
    gain::Real
    nf::Real
    z_in::Real
    z_out::Real
    p1db::Real

    function Amplifier(name::AbstractString, gain::Real, nf::Real=0.0;
        z_in::Real=50.0, z_out::Real=50.0, p1db::Real=20.0)
        z_in > 0 || throw(ArgumentError("Input impedance must be positive"))
        z_out > 0 || throw(ArgumentError("Output impedance must be positive"))
        new(String(name), 0, 0, gain, nf, z_in, z_out, p1db)
    end
end

function to_qucs_netlist(comp::Amplifier)::String
    # Qucs amplifier model
    parts = ["Amp:$(comp.name)"]
    push!(parts, "$(qucs_node(comp.n1))")
    push!(parts, "$(qucs_node(comp.n2))")
    push!(parts, "G=\"$(format_value(comp.gain)) dB\"")
    if comp.nf > 0
        push!(parts, "NF=\"$(format_value(comp.nf)) dB\"")
    end
    push!(parts, "Z1=\"$(format_value(comp.z_in))\"")
    push!(parts, "Z2=\"$(format_value(comp.z_out))\"")
    return join(parts, " ")
end

function to_spice_netlist(comp::Amplifier)::String
    # SPICE model using voltage-controlled voltage source with impedances
    # Voltage gain from power gain: Gv = sqrt(Gp * Zout/Zin)
    gp = 10^(comp.gain / 10)  # Power gain (linear)
    gv = sqrt(gp * comp.z_out / comp.z_in)  # Voltage gain

    lines = String[]
    push!(lines, "* Amplifier $(comp.name): Gain=$(comp.gain)dB, NF=$(comp.nf)dB")
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
