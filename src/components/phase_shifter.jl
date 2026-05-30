"""
    PhaseShifter <: AbstractPhaseShifter

RF phase shifter.

A phase shifter introduces a specified phase shift to the signal while
maintaining amplitude (ideally).

# Fields

- `name::String`: Component identifier
- `n1::Int`: Input terminal node number
- `n2::Int`: Output terminal node number
- `phase::Real`: Phase shift in degrees (default: 1e-90, essentially 0)
- `z0::Real`: Reference impedance in Ohms, must be positive (default: 50)

# Example

```@example
using CircuitSim
# 90 degree phase shifter
PS1 = PhaseShifter("PS1", phase=90.0)

# 180 degree phase shifter with custom impedance
PS2 = PhaseShifter("PS2", phase=180.0, z0=75.0)
```
"""
mutable struct PhaseShifter <: AbstractPhaseShifter
    name::String

    n1::Int
    n2::Int

    phase::Real  # Phase shift (degrees)
    z0::Real     # Reference impedance (Ohms)

    function PhaseShifter(name::AbstractString;
        phase::Real=1e-90,
        z0::Real=50.0
    )
        z0 > 0 || throw(ArgumentError("Reference impedance must be positive"))
        new(String(name), 0, 0, phase, z0)
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

function _get_node_number(component::PhaseShifter, pin::Symbol)::Int
    if pin == :n1 || pin == :input
        return component.n1
    elseif pin == :n2 || pin == :output
        return component.n2
    else
        error("Invalid pin $pin for PhaseShifter. Use :n1/:input or :n2/:output")
    end
end
