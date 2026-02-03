"""
    CapacitorQ <: AbstractCapacitor

Capacitor with quality factor for RF simulations.

# Fields

- `name::String`: Component identifier
- `n1::Int`: First terminal node number
- `n2::Int`: Second terminal node number
- `capacitance::Real`: Capacitance in Farads
- `q::Real`: Quality factor (Q) at the specified frequency
- `frequency::Real`: frequency in Hz where Q is specified (default: 1 GHz)
- `mode::String`: Q frequency dependency mode - "Linear", "SquareRoot", or "Constant" (default: "Linear")
- `temp::Real`: Temperature in Celsius for noise calculations (default: 26.85°C)

# Example

```julia
using CircuitSim
C1 = CapacitorQ("C1", capacitance=10e-12, q=50.0)  # 10pF capacitor with Q=50
C2 = CapacitorQ("C2", capacitance=100e-12, q=100.0, frequency=2.4e9, mode="SquareRoot")  # 100pF, Q=100 at 2.4 GHz
```
"""
mutable struct CapacitorQ <: AbstractCapacitor
    name::String

    n1::Int
    n2::Int

    capacitance::Real
    q::Real
    frequency::Real
    mode::String
    temp::Real

    function CapacitorQ(name::AbstractString;
        capacitance::Real,
        q::Real,
        frequency::Real=1e9,
        mode::String="Linear",
        temp::Real=26.85
    )
        capacitance > 0 || throw(ArgumentError("Capacitance must be positive"))
        q > 0 || throw(ArgumentError("Quality factor must be positive"))
        frequency > 0 || throw(ArgumentError("Frequency must be positive"))
        mode in ["Linear", "SquareRoot", "Constant"] || throw(ArgumentError("Mode must be one of: Linear, SquareRoot, Constant"))
        new(String(name), 0, 0, capacitance, q, frequency, mode, temp)
    end
end

function to_qucs_netlist(comp::CapacitorQ)::String
    # Qucsator-RF uses CAPQ component with properties C, Q, f, Mode, Temp
    # CAPQ:name n1 n2 C="capacitance" Q="q" f="frequency" Mode="mode" Temp="temp"
    parts = ["CAPQ:$(comp.name)"]
    push!(parts, "$(qucs_node(comp.n1))")
    push!(parts, "$(qucs_node(comp.n2))")
    push!(parts, "C=\"$(format_capacitance(comp.capacitance))\"")
    push!(parts, "Q=\"$(format_value(comp.q))\"")
    push!(parts, "f=\"$(format_value(comp.frequency))\"")
    push!(parts, "Mode=\"$(comp.mode)\"")
    if comp.temp != 26.85
        push!(parts, "Temp=\"$(comp.temp)\"")
    end
    return join(parts, " ")
end

function to_spice_netlist(comp::CapacitorQ)::String
    # SPICE models Q factor using series resistance
    # ESR = 1 / (2*pi*f*C*Q)
    esr = 1 / (2 * π * comp.frequency * comp.capacitance * comp.q)

    lines = String[]
    push!(lines, "* Capacitor with Q=$(comp.q) at $(comp.frequency) Hz")
    push!(lines, "C$(comp.name) $(comp.n1) $(comp.n1)_int $(comp.capacitance)")
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
