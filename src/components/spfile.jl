"""
S-parameter file (Touchstone) component.
"""

"""
    SPfile <: AbstractSParameterFile

S-parameter file (Touchstone format) component.

Loads S-parameters from a Touchstone file (.s2p) 
and uses them as a black-box 2-port frequency-domain model.

# Fields
- `name::String`: Component identifier
- `n1::Int`: Port 1 terminal
- `n2::Int`: Port 2 terminal  
- `file::String`: Path to Touchstone file
- `data_format::String`: Data format ("rectangular" or "polar")
- `interpolator::String`: Interpolation method ("linear" or "cubic")
- `temp::Real`: Temperature in Kelvin (default 293.15K = 20°C)
- `during_dc::String`: DC behavior ("open", "short", or "unspecified")

# Example
```julia
# Load a 2-port S-parameter file
amp = SPfile("AMP1", "amplifier.s2p")

# Custom options
filter_sp = SPfile("FILT1", "filter.s2p", 
    data_format="polar",
    interpolator="cubic",
    temp=298.15)
```

# Qucs Format
`SPfile:Name Node1 Node2 File="filename" Data="rectangular" Interpolator="linear" Temp="293.15" duringDC="open"`

# Notes
- File path can be absolute or relative to netlist location
- Supports Touchstone v1.0, v1.1, v2.0 formats (.s2p files)
- Currently supports 2-port networks only
"""
mutable struct SPfile <: AbstractSParameterFile
    name::String
    n1::Int
    n2::Int
    file::String
    data_format::String
    interpolator::String
    temp::Real
    during_dc::String

    function SPfile(name::AbstractString, file::AbstractString;
        data_format::String="rectangular",
        interpolator::String="linear",
        temp::Real=293.15,
        during_dc::String="open")

        data_format in ["rectangular", "polar"] || throw(ArgumentError("data_format must be 'rectangular' or 'polar'"))
        interpolator in ["linear", "cubic"] || throw(ArgumentError("interpolator must be 'linear' or 'cubic'"))
        during_dc in ["open", "short", "unspecified"] || throw(ArgumentError("during_dc must be 'open', 'short', or 'unspecified'"))

        new(String(name), 0, 0, file, data_format, interpolator, temp, during_dc)
    end
end

function to_qucs_netlist(spf::SPfile)::String
    parts = ["SPfile:$(spf.name)"]
    push!(parts, qucs_node(spf.n1))
    push!(parts, qucs_node(spf.n2))
    push!(parts, "File=\"$(spf.file)\"")
    push!(parts, "Data=\"$(spf.data_format)\"")
    push!(parts, "Interpolator=\"$(spf.interpolator)\"")
    push!(parts, "Temp=\"$(spf.temp)\"")
    push!(parts, "duringDC=\"$(spf.during_dc)\"")
    return join(parts, " ")
end

function to_spice_netlist(spf::SPfile)::String
    "* S-parameter file $(spf.name) from $(spf.file)"
end

function _get_node_number(spf::SPfile, terminal::Int)::Int
    terminal == 1 && return spf.n1
    terminal == 2 && return spf.n2
    throw(ArgumentError("SPfile $(spf.name) is 2-port, terminal must be 1 or 2, got $terminal"))
end
