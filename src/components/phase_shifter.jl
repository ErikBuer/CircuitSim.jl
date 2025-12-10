"""
    PhaseShifter <: AbstractPhaseShifter

RF phase shifter.

A phase shifter introduces a specified phase shift to the signal while
maintaining amplitude (ideally).

# Fields

- `name::String`: Component identifier
- `n1::Int`: Input terminal node number
- `n2::Int`: Output terminal node number
- `phase::Real`: Phase shift in degrees
- `z0::Real`: Reference impedance in Ohms (default: 50)
- `insertion_loss::Real`: Insertion loss in dB (default: 0 for ideal)

# Example

```@example
using CircuitSim
# 90 degree phase shifter
PS1 = PhaseShifter("PS1", 90.0)

# 180 degree phase shifter with 0.5 dB loss
PS2 = PhaseShifter("PS2", 180.0, insertion_loss=0.5)
```
"""
mutable struct PhaseShifter <: AbstractPhaseShifter
    name::String
    n1::Int
    n2::Int
    phase::Real
    z0::Real
    insertion_loss::Real

    function PhaseShifter(name::AbstractString, phase::Real;
        z0::Real=50.0, insertion_loss::Real=0.0)
        z0 > 0 || throw(ArgumentError("Impedance must be positive"))
        insertion_loss >= 0 || throw(ArgumentError("Insertion loss must be non-negative"))
        new(String(name), 0, 0, phase, z0, insertion_loss)
    end
end

function to_qucs_netlist(comp::PhaseShifter)::String
    # Qucsator expects: phi (phase in degrees, required), Zref (reference impedance, optional)
    # Component name in qucsator is "PShift"
    parts = ["PShift:$(comp.name)"]
    push!(parts, "$(qucs_node(comp.n1))")
    push!(parts, "$(qucs_node(comp.n2))")
    push!(parts, "phi=\"$(format_value(comp.phase))\"")
    push!(parts, "Zref=\"$(format_value(comp.z0))\"")
    return join(parts, " ")
end

function to_spice_netlist(comp::PhaseShifter)::String
    # SPICE model using transmission line with electrical length
    # Or behavioral source with phase shift
    phase_rad = deg2rad(comp.phase)
    mag = 10^(-comp.insertion_loss / 20)

    lines = String[]
    push!(lines, "* Phase Shifter $(comp.name): $(comp.phase)° shift, $(comp.insertion_loss)dB loss")
    push!(lines, "* Using ideal transmission line model")
    push!(lines, "T$(comp.name) $(comp.n1) 0 $(comp.n2) 0 Z0=$(comp.z0) TD=0 F=1G NL=$(comp.phase/360)")
    return join(lines, "\n")
end

function _get_node_number(component::PhaseShifter, pin::Symbol)::Int
    if pin == :n1 || pin == :input
        return component.n1
    elseif pin == :n2 || pin == :output
        return component.n2
    else
        error("Invalid pin $pin for PhaseShifter. Use :n1/:input or :n2/:output")
    end
end
