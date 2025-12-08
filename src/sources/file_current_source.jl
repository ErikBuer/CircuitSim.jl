"""
    FileCurrentSource <: AbstractSource

File-based current source for transient analysis.

This component can operate in two modes:
1. **File mode**: Reads current vs. time data from an external file
2. **Vector mode**: Accepts Julia vectors and automatically creates temporary file

The data consists of time-current pairs that are interpolated during simulation.

# Fields
- `name::String`: Component identifier
- `nplus::Int`: Positive terminal node number (current flows from nplus to nminus)
- `nminus::Int`: Negative terminal node number
- `file::Union{String,Nothing}`: Path to data file (nothing for vector mode)
- `time_vector::Union{AbstractVector,Nothing}`: Time values for vector mode
- `current_vector::Union{AbstractVector,Nothing}`: Current values for vector mode
- `interpolator::String`: Interpolation method ("linear", "cubic", or "hold")
- `repeat::Bool`: Whether to repeat the waveform
- `gain::Real`: Gain factor (multiplier for current values)
- `delay::Real`: Time delay in seconds
- `format::Symbol`: File format (:csv or :qucs_dataset, default :csv)

# Supported File Formats

## CSV Format (default, recommended)
Two columns: time, current (comma or semicolon separated)
Optional header row with column names

Example:
```
time,current
0.0,0.0
1e-9,0.001
2e-9,0.001
```

## Qucs Dataset Format
Native qucsator format with indep/dep blocks

Example:
```
<Qucs Dataset 1.0.0>
<indep time 3>
  0.0
  1e-9
  2e-9
</indep>
<dep I1 3>
  0.0
  0.001
  0.001
</dep>
```

# Example
```@example
using CircuitSim

# Vector mode - automatic file handling (CSV format)
time = [0.0, 1e-9, 2e-9, 3e-9, 4e-9]
current = [0.0, 0.001, 0.001, 0.0, 0.0]
I1 = FileCurrentSource("I1", time, current)

# Vector mode with Qucs Dataset format
I2 = FileCurrentSource("I2", time, current, format=:qucs_dataset)

# File mode - read from existing file
I3 = FileCurrentSource("I3", "my_current.csv")

# With cubic interpolation and repeating waveform
I4 = FileCurrentSource("I4", time, current, interpolator="cubic", repeat=true)
```
"""
mutable struct FileCurrentSource <: AbstractSource
    name::String
    nplus::Int
    nminus::Int
    file::Union{String,Nothing}
    time_vector::Union{AbstractVector,Nothing}
    current_vector::Union{AbstractVector,Nothing}
    interpolator::String
    repeat::Bool
    gain::Real
    delay::Real
    format::Symbol

    function FileCurrentSource(
        name::AbstractString,
        file::AbstractString;
        interpolator::AbstractString="linear",
        repeat::Bool=false,
        gain::Real=1.0,
        delay::Real=0.0
    )
        @assert interpolator in ["linear", "cubic", "hold"] "interpolator must be 'linear', 'cubic', or 'hold'"
        new(String(name), 0, 0, String(file), nothing, nothing, String(interpolator), repeat, gain, delay, :auto)
    end

    function FileCurrentSource(
        name::AbstractString,
        time_vec::AbstractVector,
        current_vec::AbstractVector;
        interpolator::AbstractString="linear",
        repeat::Bool=false,
        gain::Real=1.0,
        delay::Real=0.0,
        format::Symbol=:csv
    )
        @assert length(time_vec) == length(current_vec) "time and current vectors must have same length"
        @assert length(time_vec) >= 2 "must have at least 2 data points"
        @assert interpolator in ["linear", "cubic", "hold"] "interpolator must be 'linear', 'cubic', or 'hold'"
        @assert format in [:csv, :qucs_dataset] "format must be :csv or :qucs_dataset"
        new(String(name), 0, 0, nothing, time_vec, current_vec, String(interpolator), repeat, gain, delay, format)
    end
end

function to_qucs_netlist(comp::FileCurrentSource)::String
    actual_file = if comp.file !== nothing
        basename(comp.file)
    else
        # Choose file extension based on format
        ext = comp.format == :csv ? ".csv" : ".dat"
        temp_file = "/tmp/ifile_$(comp.name)_data$(ext)"

        if comp.format == :csv
            write_csv(temp_file, comp.time_vector, comp.current_vector,
                time_name="time", var_name="I.$(comp.name)")
        elseif comp.format == :qucs_dataset
            write_qucs_dataset(temp_file, comp.time_vector, comp.current_vector,
                time_name="time", var_name="I.$(comp.name)")
        else
            error("Unsupported format: $(comp.format)")
        end

        basename(temp_file)
    end

    repeat_str = comp.repeat ? "yes" : "no"

    return "Ifile:$(comp.name) $(qucs_node(comp.nplus)) $(qucs_node(comp.nminus)) File=\"$(actual_file)\" Interpolator=\"$(comp.interpolator)\" Repeat=\"$(repeat_str)\" G=\"$(comp.gain)\" T=\"$(comp.delay)\""
end

function to_spice_netlist(comp::FileCurrentSource)::String
    error("FileCurrentSource is not yet supported in SPICE backend")
end

num_pins(::Type{FileCurrentSource}) = 2
