"""
AC Current Source component.
"""

"""
    ACCurrentSource <: AbstractACCurrentSource

AC current source with two terminals.
Current flows from nminus to nplus (into nplus).

For AC analysis, provides a sinusoidal current source.
- `dc`: DC offset (default 0)
- `ac_mag`: AC magnitude for small-signal analysis  
- `ac_phase`: AC phase in degrees (default 0)
- `freq`: Frequency in Hz (for transient analysis)

# Fields
- `name::String`: Component identifier
- `nplus::Int`: Positive terminal node number
- `nminus::Int`: Negative terminal node number
- `dc::Real`: DC offset current
- `ac_mag::Real`: AC magnitude in Amperes
- `ac_phase::Real`: AC phase in degrees
- `freq::Real`: Frequency in Hz

# Example
```julia
# 1mA AC source at 1kHz
I1 = ACCurrentSource("I1", 0.001, freq=1e3)

# 10mA AC with 5mA DC offset
I2 = ACCurrentSource("I2", 0.01, dc=0.005, freq=50.0)
```
"""
mutable struct ACCurrentSource <: AbstractACCurrentSource
    name::String
    nplus::Int
    nminus::Int
    dc::Real
    ac_mag::Real
    ac_phase::Real  # degrees
    freq::Real      # Hz, for transient
    ACCurrentSource(name::AbstractString, ac_mag::Real; dc::Real=0.0, ac_phase::Real=0.0, freq::Real=1e6) =
        new(String(name), 0, 0, dc, ac_mag, ac_phase, freq)
end

function to_qucs_netlist(comp::ACCurrentSource)::String
    "Iac:$(comp.name) $(qucs_node(comp.nplus)) $(qucs_node(comp.nminus)) I=\"$(format_value(comp.ac_mag))\" f=\"$(format_value(comp.freq))\" Phase=\"$(comp.ac_phase)\""
end

function to_spice_netlist(comp::ACCurrentSource)::String
    if comp.dc != 0.0
        "I$(comp.name) $(comp.nplus) $(comp.nminus) DC $(comp.dc) AC $(comp.ac_mag) $(comp.ac_phase) SIN($(comp.dc) $(comp.ac_mag) $(comp.freq) 0 0 $(comp.ac_phase))"
    else
        "I$(comp.name) $(comp.nplus) $(comp.nminus) AC $(comp.ac_mag) $(comp.ac_phase) SIN(0 $(comp.ac_mag) $(comp.freq) 0 0 $(comp.ac_phase))"
    end
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
