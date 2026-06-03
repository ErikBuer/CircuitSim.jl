"""
    ACVoltageSource <: AbstractACVoltageSource

AC voltage source with two terminals.

For AC analysis, provides a sinusoidal voltage source.
- `ac_magnitude`: AC magnitude for small-signal analysis
- `ac_phase`: AC phase in degrees (default 0)
- `theta`: Exponential damping factor (default 0)
- `freq`: Frequency in Hz (default 1e9)

Qucs `Vac` has no DC term. Use `DCVoltageSource` for DC injection.

# Fields

- `name::String`: Component identifier
- `nplus::Int`: Positive terminal node number
- `nminus::Int`: Negative terminal node number
- `ac_magnitude::Real`: AC magnitude in Volts
- `ac_phase::Real`: AC phase in degrees
- `theta::Real`: Exponential damping factor
- `freq::Real`: Frequency in Hz

# Example

```julia
# 1V AC source at 1kHz
V1 = ACVoltageSource("V1", ac_magnitude=1.0, freq=1e3)

# 5V AC with damping
V2 = ACVoltageSource("V2", ac_magnitude=5.0, ac_phase=15.0, theta=1e6, freq=1e6)
```
"""
mutable struct ACVoltageSource <: AbstractACVoltageSource
    name::String

    nplus::Int
    nminus::Int

    ac_magnitude::Real
    ac_phase::Real  # degrees
    theta::Real
    freq::Real      # Hz, for transient

    function ACVoltageSource(name::AbstractString;
        ac_magnitude::Union{Nothing,Real}=nothing,
        ac_phase::Real=0.0,
        theta::Real=0.0,
        freq::Real=1e9,
        # Compatibility aliases
        ac_mag::Union{Nothing,Real}=nothing,
        dc::Union{Nothing,Real}=nothing,
        dc_voltage::Union{Nothing,Real}=nothing,
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

        dc_effective = if dc !== nothing
            dc
        else
            dc_voltage
        end
        if dc_effective !== nothing && dc_effective != 0
            @warn "ACVoltageSource ignores dc in qucsator Vac; use DCVoltageSource for DC injection"
        end

        new(String(name), 0, 0, ac_magnitude_value, ac_phase, theta, freq)
    end
end

function to_qucs_netlist(comp::ACVoltageSource)::String
    parts = ["Vac:$(comp.name)"]
    push!(parts, qucs_node(comp.nplus))
    push!(parts, qucs_node(comp.nminus))
    push!(parts, "U=\"$(format_value(comp.ac_magnitude))\"")
    push!(parts, "f=\"$(format_value(comp.freq))\"")
    push!(parts, "Phase=\"$(comp.ac_phase)\"")
    if comp.theta != 0
        push!(parts, "Theta=\"$(format_value(comp.theta))\"")
    end
    return join(parts, " ")
end

function to_spice_netlist(comp::ACVoltageSource)::String
    "V$(comp.name) $(comp.nplus) $(comp.nminus) AC $(comp.ac_magnitude) $(comp.ac_phase) SIN(0 $(comp.ac_magnitude) $(comp.freq) 0 $(comp.theta) $(comp.ac_phase))"
end

function _get_node_number(component::ACVoltageSource, pin::Symbol)::Int
    if pin == :nplus
        return component.nplus
    elseif pin == :nminus
        return component.nminus
    else
        error("Invalid pin $pin for ACVoltageSource. Use :nplus or :nminus")
    end
end
