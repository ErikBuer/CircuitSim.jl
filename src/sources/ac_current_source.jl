"""
    ACCurrentSource <: AbstractACCurrentSource

AC current source with two terminals.
Current flows from nminus to nplus (into nplus).

For AC analysis, provides a sinusoidal current source.
- `ac_magnitude`: AC magnitude for small-signal analysis
- `ac_phase`: AC phase in degrees (default 0)
- `theta`: Exponential damping factor (default 0)
- `freq`: Frequency in Hz (default 1e9)

# Fields

- `name::String`: Component identifier
- `nplus::Int`: Positive terminal node number
- `nminus::Int`: Negative terminal node number
- `ac_magnitude::Real`: AC magnitude in Amperes
- `ac_phase::Real`: AC phase in degrees
- `theta::Real`: Exponential damping factor
- `freq::Real`: Frequency in Hz

# Example

```julia
# 1mA AC source at 1kHz
I1 = ACCurrentSource("I1", ac_magnitude=0.001, freq=1e3)

# 10mA AC with damping
I2 = ACCurrentSource("I2", ac_magnitude=0.01, ac_phase=30.0, theta=1e6, freq=50.0)
```
"""
mutable struct ACCurrentSource <: AbstractACCurrentSource
    name::String

    nplus::Int
    nminus::Int

    ac_magnitude::Real
    ac_phase::Real  # degrees
    theta::Real
    freq::Real      # Hz, for transient

    function ACCurrentSource(name::AbstractString;
        ac_magnitude::Union{Nothing,Real}=nothing,
        ac_phase::Real=0.0,
        theta::Real=0.0,
        freq::Real=1e9,
        # Compatibility aliases
        ac_mag::Union{Nothing,Real}=nothing,
        dc::Union{Nothing,Real}=nothing,
    )
        if ac_magnitude === nothing && ac_mag === nothing
            throw(ArgumentError("Provide either ac_magnitude or ac_mag"))
        elseif ac_magnitude !== nothing && ac_mag !== nothing
            throw(ArgumentError("Use either ac_magnitude or ac_mag, not both"))
        elseif ac_magnitude === nothing
            ac_magnitude = ac_mag
        end
        ac_magnitude_value = ac_magnitude::Real
        ac_magnitude_value >= 0 || throw(ArgumentError("ac_magnitude must be non-negative"))
        -360 <= ac_phase <= 360 || throw(ArgumentError("ac_phase must be in range [-360, 360]"))
        theta >= 0 || throw(ArgumentError("theta must be non-negative"))
        freq > 0 || throw(ArgumentError("freq must be positive"))
        if dc !== nothing && dc != 0
            @warn "ACCurrentSource ignores dc in qucsator Iac; use DCCurrentSource for DC injection"
        end
        new(String(name), 0, 0, ac_magnitude_value, ac_phase, theta, freq)
    end
end

function to_qucs_netlist(comp::ACCurrentSource)::String
    parts = ["Iac:$(comp.name)"]
    push!(parts, qucs_node(comp.nplus))
    push!(parts, qucs_node(comp.nminus))
    push!(parts, "I=\"$(format_value(comp.ac_magnitude))\"")
    push!(parts, "f=\"$(format_value(comp.freq))\"")
    push!(parts, "Phase=\"$(comp.ac_phase)\"")
    if comp.theta != 0
        push!(parts, "Theta=\"$(format_value(comp.theta))\"")
    end
    return join(parts, " ")
end

function to_spice_netlist(comp::ACCurrentSource)::String
    "I$(comp.name) $(comp.nplus) $(comp.nminus) AC $(comp.ac_magnitude) $(comp.ac_phase) SIN(0 $(comp.ac_magnitude) $(comp.freq) 0 $(comp.theta) $(comp.ac_phase))"
end

function _get_node_number(component::ACCurrentSource, pin::Symbol)::Int
    if pin == :nplus
        return component.nplus
    elseif pin == :nminus
        return component.nminus
    else
        error("Invalid pin $pin for ACCurrentSource. Use :nplus or :nminus")
    end
end
