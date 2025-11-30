"""
DC Voltage Source component.
"""

"""
    DCVoltageSource <: AbstractDCVoltageSource

DC voltage source with two terminals.

# Fields
- `name::String`: Component identifier
- `nplus::Int`: Positive terminal node number
- `nminus::Int`: Negative terminal node number
- `dc::Real`: DC voltage in Volts

# Example
```julia
V1 = DCVoltageSource("V1", 12.0)  # 12V DC source
```
"""
mutable struct DCVoltageSource <: AbstractDCVoltageSource
    name::String
    nplus::Int
    nminus::Int
    dc::Real
    DCVoltageSource(name::AbstractString, dc::Real) = new(String(name), 0, 0, dc)
end

# =============================================================================
# Qucs Netlist Generation
# =============================================================================

function to_qucs_netlist(comp::DCVoltageSource)::String
    "Vdc:$(comp.name) $(qucs_node(comp.nplus)) $(qucs_node(comp.nminus)) U=\"$(format_value(comp.dc))\""
end

# =============================================================================
# SPICE Netlist Generation
# =============================================================================

function to_spice_netlist(comp::DCVoltageSource)::String
    "V$(comp.name) $(comp.nplus) $(comp.nminus) DC $(comp.dc)"
end

# =============================================================================
# Result Access Helpers
# =============================================================================

function _get_node_number(component::DCVoltageSource, pin::Symbol)::Int
    if pin == :nplus
        return component.nplus
    elseif pin == :nminus
        return component.nminus
    else
        error("Invalid pin $pin for DCVoltageSource. Use :nplus or :nminus")
    end
end
