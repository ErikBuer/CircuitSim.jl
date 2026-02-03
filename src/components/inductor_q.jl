"""
    InductorQ <: AbstractInductor

Inductor with quality factor for RF simulations.

# Fields

- `name::String`: Component identifier
- `n1::Int`: First terminal node number
- `n2::Int`: Second terminal node number
- `inductance::Real`: Inductance in Henries
- `q::Real`: Quality factor (Q) at the specified frequency
- `freq::Real`: Frequency in Hz where Q is specified (default: 1 GHz)
- `mode::String`: Q frequency dependency mode - "Linear", "SquareRoot", or "Constant" (default: "Linear")
- `temp::Real`: Temperature in Celsius for noise calculations (default: 26.85°C)

# Example

```julia
using CircuitSim
L1 = InductorQ("L1", inductance=10e-9, q=30.0)  # 10nH inductor with Q=30
L2 = InductorQ("L2", inductance=100e-9, q=50.0, freq=2.4e9, mode="SquareRoot")  # 100nH, Q=50 at 2.4 GHz
```
"""
mutable struct InductorQ <: AbstractInductor
    name::String

    n1::Int
    n2::Int

    inductance::Real
    q::Real
    freq::Real
    mode::String
    temp::Real

    function InductorQ(name::AbstractString;
        inductance::Real,
        q::Real,
        freq::Real=1e9,
        mode::String="Linear",
        temp::Real=26.85
    )
        inductance > 0 || throw(ArgumentError("Inductance must be positive"))
        q > 0 || throw(ArgumentError("Quality factor must be positive"))
        freq > 0 || throw(ArgumentError("Frequency must be positive"))
        mode in ["Linear", "SquareRoot", "Constant"] || throw(ArgumentError("Mode must be one of: Linear, SquareRoot, Constant"))
        new(String(name), 0, 0, inductance, q, freq, mode, temp)
    end
end

function to_qucs_netlist(comp::InductorQ)::String
    # Qucsator-RF uses INDQ component with properties L, Q, f, Mode, Temp
    # INDQ:name n1 n2 L="inductance" Q="q" f="freq" Mode="mode" Temp="temp"
    parts = ["INDQ:$(comp.name)"]
    push!(parts, "$(qucs_node(comp.n1))")
    push!(parts, "$(qucs_node(comp.n2))")
    push!(parts, "L=\"$(format_inductance(comp.inductance))\"")
    push!(parts, "Q=\"$(format_value(comp.q))\"")
    push!(parts, "f=\"$(format_value(comp.freq))\"")
    push!(parts, "Mode=\"$(comp.mode)\"")
    if comp.temp != 26.85
        push!(parts, "Temp=\"$(comp.temp)\"")
    end
    return join(parts, " ")
end

function to_spice_netlist(comp::InductorQ)::String
    # SPICE models Q factor using series resistance
    # ESR = 2*pi*f*L / Q
    esr = 2 * π * comp.freq * comp.inductance / comp.q

    lines = String[]
    push!(lines, "* Inductor with Q=$(comp.q) at $(comp.freq) Hz")
    push!(lines, "L$(comp.name) $(comp.n1) $(comp.n1)_int $(comp.inductance)")
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
