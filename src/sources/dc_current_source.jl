"""
    DCCurrentSource <: AbstractDCCurrentSource

DC current source with two terminals.
Current flows from nminus to nplus (into nplus).

# Fields

- `name::String`: Component identifier
- `nplus::Int`: Positive terminal node number
- `nminus::Int`: Negative terminal node number
- `current::Real`: DC current in Amperes

# Example

```julia
I1 = DCCurrentSource("I1", current=0.001)  # 1mA DC source
```
"""
mutable struct DCCurrentSource <: AbstractDCCurrentSource
    name::String

    nplus::Int
    nminus::Int

    current::Real

    DCCurrentSource(name::AbstractString;
        current::Real
    ) = new(String(name), 0, 0, current)
end

function to_qucs_netlist(comp::DCCurrentSource)::String
    "Idc:$(comp.name) $(qucs_node(comp.nplus)) $(qucs_node(comp.nminus)) I=\"$(format_value(comp.current))\""
end

function to_spice_netlist(comp::DCCurrentSource)::String
    "I$(comp.name) $(comp.nplus) $(comp.nminus) DC $(comp.current)"
end

function _get_node_number(component::DCCurrentSource, pin::Symbol)::Int
    if pin == :nplus
        return component.nplus
    elseif pin == :nminus
        return component.nminus
    else
        error("Invalid pin $pin for DCCurrentSource. Use :nplus or :nminus")
    end
end
