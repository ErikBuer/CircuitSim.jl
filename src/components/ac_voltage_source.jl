"""
AC Voltage Source component.
"""

"""
    ACVoltageSource <: AbstractACVoltageSource

AC voltage source with two terminals.

For AC analysis, provides a sinusoidal voltage source.
- `dc`: DC offset (default 0)
- `ac_mag`: AC magnitude for small-signal analysis
- `ac_phase`: AC phase in degrees (default 0)
- `freq`: Frequency in Hz (for transient analysis)

Note: For AC analysis (.AC), only ac_mag and ac_phase are used.
For transient analysis, all parameters define a sinusoid: 
V(t) = dc + ac_mag * sin(2π*freq*t + ac_phase)

# Fields
- `name::String`: Component identifier
- `nplus::Int`: Positive terminal node number
- `nminus::Int`: Negative terminal node number
- `dc::Real`: DC offset voltage
- `ac_mag::Real`: AC magnitude in Volts
- `ac_phase::Real`: AC phase in degrees
- `freq::Real`: Frequency in Hz

# Example
```julia
# 1V AC source at 1kHz
V1 = ACVoltageSource("V1", 1.0, freq=1e3)

# 5V AC with 2V DC offset
V2 = ACVoltageSource("V2", 5.0, dc=2.0, freq=1e6)
```
"""
mutable struct ACVoltageSource <: AbstractACVoltageSource
    name::String
    nplus::Int
    nminus::Int
    dc::Real
    ac_mag::Real
    ac_phase::Real  # degrees
    freq::Real      # Hz, for transient
    ACVoltageSource(name::AbstractString, ac_mag::Real; dc::Real=0.0, ac_phase::Real=0.0, freq::Real=1e6) =
        new(String(name), 0, 0, dc, ac_mag, ac_phase, freq)
end

function to_qucs_netlist(comp::ACVoltageSource)::String
    "Vac:$(comp.name) $(qucs_node(comp.nplus)) $(qucs_node(comp.nminus)) U=\"$(format_value(comp.ac_mag))\" f=\"$(format_value(comp.freq))\" Phase=\"$(comp.ac_phase)\""
end

function to_spice_netlist(comp::ACVoltageSource)::String
    if comp.dc != 0.0
        "V$(comp.name) $(comp.nplus) $(comp.nminus) DC $(comp.dc) AC $(comp.ac_mag) $(comp.ac_phase) SIN($(comp.dc) $(comp.ac_mag) $(comp.freq) 0 0 $(comp.ac_phase))"
    else
        "V$(comp.name) $(comp.nplus) $(comp.nminus) AC $(comp.ac_mag) $(comp.ac_phase) SIN(0 $(comp.ac_mag) $(comp.freq) 0 0 $(comp.ac_phase))"
    end
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
