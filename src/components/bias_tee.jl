"""
    BiasTee <: AbstractBiasTee

Bias tee for combining DC bias and RF signals.

A bias tee has three ports:
- RF port: AC coupled (passes RF, blocks DC)
- DC port: DC coupled (passes DC, blocks RF) 
- Combined port: Both DC and RF

# Fields
- `name::String`: Component identifier
- `n_rf::Int`: RF input port node number
- `n_dc::Int`: DC input port node number
- `n_out::Int`: Combined output port node number
- `c_block::Real`: DC blocking capacitance (default: 1 μF)
- `l_choke::Real`: RF choke inductance (default: 1 mH)

# Example
```@example
using CircuitSim
# Standard bias tee
BT1 = BiasTee("BT1")

# Custom component values
BT2 = BiasTee("BT2", c_block=10e-6, l_choke=10e-3)
```
"""
mutable struct BiasTee <: AbstractBiasTee
    name::String
    n_rf::Int
    n_dc::Int
    n_out::Int
    c_block::Real
    l_choke::Real

    function BiasTee(name::AbstractString; c_block::Real=1e-6, l_choke::Real=1e-3)
        c_block > 0 || throw(ArgumentError("Blocking capacitance must be positive"))
        l_choke > 0 || throw(ArgumentError("Choke inductance must be positive"))
        new(String(name), 0, 0, 0, c_block, l_choke)
    end
end

function to_qucs_netlist(comp::BiasTee)::String
    parts = ["BiasT:$(comp.name)"]
    push!(parts, "$(qucs_node(comp.n_rf))")
    push!(parts, "$(qucs_node(comp.n_dc))")
    push!(parts, "$(qucs_node(comp.n_out))")
    push!(parts, "C=\"$(format_value(comp.c_block))\"")
    push!(parts, "L=\"$(format_value(comp.l_choke))\"")
    return join(parts, " ")
end

function to_spice_netlist(comp::BiasTee)::String
    lines = String[]
    push!(lines, "* Bias Tee $(comp.name)")
    push!(lines, "C$(comp.name)_block $(comp.n_rf) $(comp.n_out) $(comp.c_block)")
    push!(lines, "L$(comp.name)_choke $(comp.n_dc) $(comp.n_out) $(comp.l_choke)")
    return join(lines, "\n")
end

function _get_node_number(component::BiasTee, pin::Symbol)::Int
    if pin == :n_rf || pin == :rf
        return component.n_rf
    elseif pin == :n_dc || pin == :dc
        return component.n_dc
    elseif pin == :n_out || pin == :output
        return component.n_out
    else
        error("Invalid pin $pin for BiasTee. Use :n_rf/:rf, :n_dc/:dc, or :n_out/:output")
    end
end
