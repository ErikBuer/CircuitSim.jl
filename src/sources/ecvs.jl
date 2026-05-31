"""
    ExternallyControlledVoltageSource <: AbstractSource

Externally controlled voltage source (ECVS).

This is a two-terminal source whose output voltage is controlled externally
through the `U` property and advanced in time with `Tnext`.

# Fields

- `name::String`: Component identifier
- `n1::Int`: Positive terminal node number
- `n2::Int`: Negative terminal node number
- `u::Real`: Control voltage in Volts
- `interpolator::String`: Interpolation method (`"hold"`, `"linear"`, `"cubic"`)
- `tnext::Real`: Next control time in seconds

# Example

```julia
e = ExternallyControlledVoltageSource("E1", u=1.2, interpolator="linear", tnext=1e-9)
```
"""
mutable struct ExternallyControlledVoltageSource <: AbstractSource
    name::String

    n1::Int
    n2::Int

    u::Real
    interpolator::String
    tnext::Real

    function ExternallyControlledVoltageSource(name::AbstractString;
        u::Real=0.0,
        interpolator::String="linear",
        tnext::Real=0.0
    )
        interpolator in ["hold", "linear", "cubic"] ||
            error("interpolator must be one of: hold, linear, cubic")
        tnext >= 0 || error("tnext must be >= 0 (got $tnext)")
        new(String(name), 0, 0, Float64(u), interpolator, Float64(tnext))
    end
end

function to_qucs_netlist(comp::ExternallyControlledVoltageSource)::String
    params = "U=\"$(format_value(comp.u))\" Interpolator=\"$(comp.interpolator)\" Tnext=\"$(format_value(comp.tnext))\""
    return "ECVS:$(comp.name) $(qucs_node(comp.n1)) $(qucs_node(comp.n2)) $params"
end

function _get_node_number(comp::ExternallyControlledVoltageSource, pin::Symbol)::Int
    if pin == :n1 || pin == :nplus
        return comp.n1
    elseif pin == :n2 || pin == :nminus
        return comp.n2
    else
        error("Invalid pin $pin for ExternallyControlledVoltageSource. Use :n1 or :n2")
    end
end

function num_pins(::Type{ExternallyControlledVoltageSource})
    return 2
end
