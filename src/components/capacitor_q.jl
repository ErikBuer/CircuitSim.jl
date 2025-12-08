"""
    CapacitorQ <: AbstractCapacitorWithQualityFactor

Capacitor with quality factor for RF simulations.

# Fields
- `name::String`: Component identifier
- `n1::Int`: First terminal node number
- `n2::Int`: Second terminal node number
- `value::Real`: Capacitance in Farads
- `q::Real`: Quality factor (Q) at the specified frequency
- `freq::Real`: Frequency in Hz where Q is specified (default: 1 GHz)

# Example
```@example
using CircuitSim
C1 = CapacitorQ("C1", 10e-12, 50.0)  # 10pF capacitor with Q=50
C2 = CapacitorQ("C2", 100e-12, 100.0, freq=2.4e9)  # 100pF, Q=100 at 2.4 GHz
```
"""
mutable struct CapacitorQ <: AbstractCapacitorWithQualityFactor
    name::String
    n1::Int
    n2::Int
    value::Real
    q::Real
    freq::Real

    function CapacitorQ(name::AbstractString, value::Real, q::Real; freq::Real=1e9)
        value > 0 || throw(ArgumentError("Capacitance must be positive"))
        q > 0 || throw(ArgumentError("Quality factor must be positive"))
        freq > 0 || throw(ArgumentError("Frequency must be positive"))
        new(String(name), 0, 0, value, q, freq)
    end
end

function to_qucs_netlist(comp::CapacitorQ)::String
    # Qucsator-RF uses CAPQ component with properties C, Q, f, Mode
    # CAPQ:name n1 n2 C="value" Q="q" f="freq" Mode="Constant"
    parts = ["CAPQ:$(comp.name)"]
    push!(parts, "$(qucs_node(comp.n1))")
    push!(parts, "$(qucs_node(comp.n2))")
    push!(parts, "C=\"$(format_value(comp.value))\"")
    push!(parts, "Q=\"$(format_value(comp.q))\"")
    push!(parts, "f=\"$(format_value(comp.freq))\"")
    push!(parts, "Mode=\"Constant\"")
    return join(parts, " ")
end

function to_spice_netlist(comp::CapacitorQ)::String
    # SPICE models Q factor using series resistance
    # ESR = 1 / (2*pi*f*C*Q)
    esr = 1 / (2 * π * comp.freq * comp.value * comp.q)

    lines = String[]
    push!(lines, "* Capacitor with Q=$(comp.q) at $(comp.freq) Hz")
    push!(lines, "C$(comp.name) $(comp.n1) $(comp.n1)_int $(comp.value)")
    push!(lines, "R$(comp.name)_esr $(comp.n1)_int $(comp.n2) $(esr)")
    return join(lines, "\n")
end

function _get_node_number(component::CapacitorQ, pin::Symbol)::Int
    if pin == :n1
        return component.n1
    elseif pin == :n2
        return component.n2
    else
        error("Invalid pin $pin for CapacitorQ. Use :n1 or :n2")
    end
end
