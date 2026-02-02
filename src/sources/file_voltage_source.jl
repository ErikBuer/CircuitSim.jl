"""
    FileVoltageSource <: AbstractSource

File-based voltage source for transient analysis.

This component can operate in two modes:
1. **File mode**: Reads voltage vs. time data from an external file
2. **Vector mode**: Accepts Julia vectors and automatically creates temporary file

The data consists of time-voltage pairs that are interpolated during simulation.

# Fields

- `name::String`: Component identifier
- `nplus::Int`: Positive terminal node number  
- `nminus::Int`: Negative terminal node number
- `file::Union{String,Nothing}`: Path to data file (nothing for vector mode)
- `time_vector::Union{AbstractVector,Nothing}`: Time values for vector mode
- `voltage_vector::Union{AbstractVector,Nothing}`: Voltage values for vector mode
- `interpolator::String`: Interpolation method ("linear", "cubic", or "hold")
- `repeat::Bool`: Whether to repeat the waveform
- `gain::Real`: Gain factor (multiplier for voltage values)
- `delay::Real`: Time delay in seconds
- `format::Symbol`: File format (:csv or :qucs_dataset, default :csv)

# Supported File Formats

## CSV Format (default, recommended)
Two columns: time, voltage (comma or semicolon separated)
Optional header row with column names

Example:
```
time,voltage
0.0,0.0
1e-9,1.0
2e-9,0.5
```

## Qucs Dataset Format
Native qucsator format with indep/dep blocks

Example:
```
<Qucs Dataset 1.0.0>
<indep time 4>
  0.0
  1e-9
  2e-9
  3e-9
</indep>
<dep V1 4>
  0.0
  1.0
  0.5
  0.0
</dep>
```

# Example

```julia
using CircuitSim

# Vector mode - creates a temporary csv file and passes to qucsator.
time = [0.0, 1e-9, 2e-9, 3e-9]
voltage = [0.0, 1.0, 1.0, 0.0]
V1 = FileVoltageSource("V1", time, voltage)

# Vector mode with Qucs Dataset format
V2 = FileVoltageSource("V2", time, voltage, format=:qucs_dataset)

# File mode - read from existing file
V3 = FileVoltageSource("V3", "my_waveform.csv")

# With interpolation and gain
V4 = FileVoltageSource("V4", time, voltage, interpolator="cubic", gain=2.0)
```
"""
mutable struct FileVoltageSource <: AbstractSource
    name::String

    nplus::Int
    nminus::Int

    file::Union{String,Nothing}
    time_vector::Union{AbstractVector,Nothing}
    voltage_vector::Union{AbstractVector,Nothing}
    interpolator::String
    repeat::Bool
    gain::Real
    delay::Real
    format::Symbol

    function FileVoltageSource(name::AbstractString;
        file::AbstractString,
        interpolator::AbstractString="linear",
        repeat::Bool=false,
        gain::Real=1.0,
        delay::Real=0.0
    )
        @assert interpolator in ["linear", "cubic", "hold"] "interpolator must be 'linear', 'cubic', or 'hold'"
        new(String(name), 0, 0, String(file), nothing, nothing, String(interpolator), repeat, gain, delay, :auto)
    end

    function FileVoltageSource(
        name::AbstractString,
        time_vec::AbstractVector,
        voltage_vec::AbstractVector;
        interpolator::AbstractString="linear",
        repeat::Bool=false,
        gain::Real=1.0,
        delay::Real=0.0,
        format::Symbol=:csv
    )
        @assert length(time_vec) == length(voltage_vec) "time and voltage vectors must have same length"
        @assert length(time_vec) >= 2 "must have at least 2 data points"
        @assert interpolator in ["linear", "cubic", "hold"] "interpolator must be 'linear', 'cubic', or 'hold'"
        @assert format in [:csv, :qucs_dataset] "format must be :csv or :qucs_dataset"
        new(String(name), 0, 0, nothing, time_vec, voltage_vec, String(interpolator), repeat, gain, delay, format)
    end
end

"""
    prepare_external_files!(comp::FileVoltageSource, netlist_dir::String)

Create data file for FileVoltageSource in the netlist directory when using vector mode.
Called by the backend before running qucsator.
"""
function prepare_external_files!(comp::FileVoltageSource, netlist_dir::String)
    # Only create file if in vector mode (file === nothing)
    if comp.file === nothing
        ext = comp.format == :csv ? ".csv" : ".dat"
        data_file = joinpath(netlist_dir, "vfile_$(comp.name)_data$(ext)")

        if comp.format == :csv
            write_csv(data_file, comp.time_vector, comp.voltage_vector,
                time_name="time", var_name="V.$(comp.name)")
        elseif comp.format == :qucs_dataset
            write_qucs_dataset(data_file, comp.time_vector, comp.voltage_vector,
                time_name="time", var_name="V.$(comp.name)")
        end
    end
    return nothing
end

function to_qucs_netlist(comp::FileVoltageSource)::String
    actual_file = if comp.file !== nothing
        comp.file
    else
        # Choose file extension based on format
        ext = comp.format == :csv ? ".csv" : ".dat"
        temp_file = "/tmp/vfile_$(comp.name)_data$(ext)"

        if comp.format == :csv
            write_csv(temp_file, comp.time_vector, comp.voltage_vector,
                time_name="time", var_name="V.$(comp.name)")
        elseif comp.format == :qucs_dataset
            write_qucs_dataset(temp_file, comp.time_vector, comp.voltage_vector,
                time_name="time", var_name="V.$(comp.name)")
        else
            error("Unsupported format: $(comp.format)")
        end

        basename(temp_file)
    end

    repeat_str = comp.repeat ? "yes" : "no"

    return "Vfile:$(comp.name) $(qucs_node(comp.nplus)) $(qucs_node(comp.nminus)) File=\"$(actual_file)\" Interpolator=\"$(comp.interpolator)\" Repeat=\"$(repeat_str)\" G=\"$(comp.gain)\" T=\"$(comp.delay)\""
end

function to_spice_netlist(comp::FileVoltageSource)::String
    error("FileVoltageSource is not yet supported in SPICE backend")
end

num_pins(::Type{FileVoltageSource}) = 2
