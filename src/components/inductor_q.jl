"""
    InductorQ <: AbstractInductorWithQualityFactor

Inductor with quality factor for RF simulations.

# Fields
- `name::String`: Component identifier
- `n1::Int`: First terminal node number
- `n2::Int`: Second terminal node number
- `value::Real`: Inductance in Henries
- `q::Real`: Quality factor (Q) at the specified frequency
- `freq::Real`: Frequency in Hz where Q is specified (default: 1 GHz)

# Example
```@example
using CircuitTypes
L1 = InductorQ("L1", 10e-9, 30.0)  # 10nH inductor with Q=30
L2 = InductorQ("L2", 100e-9, 50.0, freq=2.4e9)  # 100nH, Q=50 at 2.4 GHz
```
"""
mutable struct InductorQ <: AbstractInductorWithQualityFactor
    name::String
    n1::Int
    n2::Int
    value::Real
    q::Real
    freq::Real

    function InductorQ(name::AbstractString, value::Real, q::Real; freq::Real=1e9)
        value > 0 || throw(ArgumentError("Inductance must be positive"))
        q > 0 || throw(ArgumentError("Quality factor must be positive"))
        freq > 0 || throw(ArgumentError("Frequency must be positive"))
        new(String(name), 0, 0, value, q, freq)
    end
end

function to_qucs_netlist(comp::InductorQ)::String
    # Qucs uses the syntax L:name n1 n2 L="value" Q="q" F="freq"
    parts = ["L:$(comp.name)"]
    push!(parts, "$(qucs_node(comp.n1))")
    push!(parts, "$(qucs_node(comp.n2))")
    push!(parts, "L=\"$(format_value(comp.value))\"")
    push!(parts, "Q=\"$(format_value(comp.q))\"")
    push!(parts, "F=\"$(format_value(comp.freq))\"")
    return join(parts, " ")
end

function to_spice_netlist(comp::InductorQ)::String
    # SPICE models Q factor using series resistance
    # ESR = 2*pi*f*L / Q
    esr = 2 * π * comp.freq * comp.value / comp.q

    lines = String[]
    push!(lines, "* Inductor with Q=$(comp.q) at $(comp.freq) Hz")
    push!(lines, "L$(comp.name) $(comp.n1) $(comp.n1)_int $(comp.value)")
    push!(lines, "R$(comp.name)_esr $(comp.n1)_int $(comp.n2) $(esr)")
    return join(lines, "\n")
end

function _get_node_number(component::InductorQ, pin::Symbol)::Int
    if pin == :n1
        return component.n1
    elseif pin == :n2
        return component.n2
    else
        error("Invalid pin $pin for InductorQ. Use :n1 or :n2")
    end
end
