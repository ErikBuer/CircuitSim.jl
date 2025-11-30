"""
Ideal Resistor
"""
mutable struct Resistor <: AbstractResistor
    name::String
    n1::Int
    n2::Int
    value::Real
    Resistor(name::AbstractString, value::Real) = new(String(name), 0, 0, value)
end

"""
Ideal Capacitor
"""
mutable struct Capacitor <: AbstractCapacitor
    name::String
    n1::Int
    n2::Int
    value::Real
    Capacitor(name::AbstractString, value::Real) = new(String(name), 0, 0, value)
end

"""
Ideal Inductor
"""
mutable struct Inductor <: AbstractInductor
    name::String
    n1::Int
    n2::Int
    value::Real
    Inductor(name::AbstractString, value::Real) = new(String(name), 0, 0, value)
end

"""
DC Voltage source (two-pin)
"""
mutable struct DCVoltageSource <: AbstractDCVoltageSource
    name::String
    nplus::Int
    nminus::Int
    dc::Real
    DCVoltageSource(name::AbstractString, dc::Real) = new(String(name), 0, 0, dc)
end

"""
DC Current source (two-pin)

Current flows from nminus to nplus (into nplus).
"""
mutable struct DCCurrentSource <: AbstractDCCurrentSource
    name::String
    nplus::Int
    nminus::Int
    dc::Real
    DCCurrentSource(name::AbstractString, dc::Real) = new(String(name), 0, 0, dc)
end

"""
AC Voltage source (two-pin)

For AC analysis, provides a sinusoidal voltage source.
- `dc`: DC offset (default 0)
- `ac_mag`: AC magnitude for small-signal analysis
- `ac_phase`: AC phase in degrees (default 0)
- `freq`: Frequency in Hz (for transient analysis)

Note: For AC analysis (.AC), only ac_mag and ac_phase are used.
For transient analysis, all parameters define a sinusoid: V(t) = dc + ac_mag * sin(2π*freq*t + ac_phase)
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

"""
AC Current source (two-pin)

For AC analysis, provides a sinusoidal current source.
Current flows from nminus to nplus (into nplus).
- `dc`: DC offset (default 0)
- `ac_mag`: AC magnitude for small-signal analysis  
- `ac_phase`: AC phase in degrees (default 0)
- `freq`: Frequency in Hz (for transient analysis)
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

"""
Ground (single pin). We'll map Ground's pin to node 0.
"""
mutable struct Ground <: AbstractGround
    name::String
    n::Int
    Ground(name::AbstractString="GND") = new(String(name), 0)
end