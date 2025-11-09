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
Ground (single pin). We'll map Ground's pin to node 0.
"""
mutable struct Ground <: AbstractGround
    name::String
    n::Int
    Ground(name::AbstractString="GND") = new(String(name), 0)
end