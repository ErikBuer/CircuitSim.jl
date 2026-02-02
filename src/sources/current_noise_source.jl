"""
    CurrentNoiseSource <: AbstractCurrentSource

Current noise source for noise analysis with frequency-dependent PSD.

# Fields
- `name::String`: Component identifier
- `n1::Int`: Positive terminal node number
- `n2::Int`: Negative terminal node number
- `i::Real`: Noise power spectral density (A²/Hz)
- `a::Real`: Frequency offset parameter (optional, default 0)
- `c::Real`: Frequency coefficient (optional, default 1)
- `e::Real`: Frequency exponent (optional, default 0)

Noise PSD formula: PSD(f) = i / (a + c * f^e)

# Example
```julia
isrc = CurrentNoiseSource("Inoise1", i=1e-12, e=0)  # White noise
```
"""
mutable struct CurrentNoiseSource <: AbstractCurrentNoiseSource
    name::String

    n1::Int
    n2::Int

    i::Real
    a::Real
    c::Real
    e::Real

    function CurrentNoiseSource(name::AbstractString;
        i::Real=1e-6,
        a::Real=0.0,
        c::Real=1.0,
        e::Real=0.0
    )
        i > 0 || throw(ArgumentError("Noise PSD must be positive"))
        a >= 0 || throw(ArgumentError("Frequency offset must be non-negative"))
        c > 0 || throw(ArgumentError("Frequency coefficient must be positive"))
        new(String(name), 0, 0, i, a, c, e)
    end
end

function to_qucs_netlist(src::CurrentNoiseSource)::String
    parts = ["Inoise:$(src.name)"]
    push!(parts, qucs_node(src.n1))
    push!(parts, qucs_node(src.n2))
    push!(parts, "i=\"$(format_value(src.i))\"")
    push!(parts, "a=\"$(format_value(src.a))\"")
    push!(parts, "c=\"$(format_value(src.c))\"")
    push!(parts, "e=\"$(format_value(src.e))\"")
    return join(parts, " ")
end

function to_spice_netlist(src::CurrentNoiseSource)::String
    "I$(src.name) $(src.n1) $(src.n2) DC 0  ; Noise source (SPICE approximation)"
end

function _get_node_number(src::CurrentNoiseSource, pin::Symbol)::Int
    if pin == :nplus || pin == :n1
        return src.n1
    elseif pin == :nminus || pin == :n2
        return src.n2
    else
        error("Invalid pin $pin for CurrentNoiseSource. Use :nplus/:n1 or :nminus/:n2")
    end
end
