"""
    VoltageNoiseSource <: AbstractVoltageSource

Voltage noise source for noise analysis with frequency-dependent PSD.

# Fields
- `name::String`: Component identifier
- `n1::Int`: Positive terminal node number
- `n2::Int`: Negative terminal node number
- `u::Real`: Noise power spectral density (V²/Hz)
- `a::Real`: Frequency offset parameter (optional, default 0)
- `c::Real`: Frequency coefficient (optional, default 1)
- `e::Real`: Frequency exponent (optional, default 0)

Noise PSD formula: PSD(f) = u / (a + c * f^e)

# Example
```julia
vsrc = VoltageNoiseSource("Vnoise1", u=1e-6, e=0)  # White noise
```
"""
mutable struct VoltageNoiseSource <: AbstractVoltageNoiseSource
    name::String

    n1::Int
    n2::Int

    u::Real
    a::Real
    c::Real
    e::Real

    function VoltageNoiseSource(name::AbstractString;
        u::Real=1e-6,
        a::Real=0.0,
        c::Real=1.0,
        e::Real=0.0
    )
        u > 0 || throw(ArgumentError("Noise PSD must be positive"))
        a >= 0 || throw(ArgumentError("Frequency offset must be non-negative"))
        c > 0 || throw(ArgumentError("Frequency coefficient must be positive"))
        new(String(name), 0, 0, u, a, c, e)
    end
end

function to_qucs_netlist(src::VoltageNoiseSource)::String
    parts = ["Vnoise:$(src.name)"]
    push!(parts, qucs_node(src.n1))
    push!(parts, qucs_node(src.n2))
    push!(parts, "u=\"$(format_value(src.u))\"")
    push!(parts, "a=\"$(format_value(src.a))\"")
    push!(parts, "c=\"$(format_value(src.c))\"")
    push!(parts, "e=\"$(format_value(src.e))\"")
    return join(parts, " ")
end

function to_spice_netlist(src::VoltageNoiseSource)::String
    "V$(src.name) $(src.n1) $(src.n2) DC 0  ; Noise source (SPICE approximation)"
end

function _get_node_number(src::VoltageNoiseSource, pin::Symbol)::Int
    if pin == :nplus || pin == :n1
        return src.n1
    elseif pin == :nminus || pin == :n2
        return src.n2
    else
        error("Invalid pin $pin for VoltageNoiseSource. Use :nplus/:n1 or :nminus/:n2")
    end
end
