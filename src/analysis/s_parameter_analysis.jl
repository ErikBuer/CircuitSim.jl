"""
    SParameterAnalysis(; start, stop, points, sweep_type=LOGARITHMIC, name="SP1", z0=50.0, noise=false)
    SParameterAnalysis(; values, sweep_type=LIST, name="SP1", z0=50.0, noise=false)

S-parameter frequency sweep analysis.

Computes S-parameters over a frequency range. Optionally compute noise parameters.

## Parameters

For LINEAR or LOGARITHMIC sweeps:
- `start::Real`: Start frequency in Hz
- `stop::Real`: Stop frequency in Hz
- `points::Int`: Number of frequency points
- `sweep_type::String`: "lin"/"linear" or "log"/"logarithmic" (default: "log")

For LIST sweeps:
- `values::Vector{<:Real}`: List of frequency points in Hz
- `sweep_type::String`: Must be "list"

For CONSTANT sweeps:
- `values::Real`: Single frequency value in Hz
- `sweep_type::String`: Must be "const" or "constant"

Common parameters:
- `name::String`: Analysis name (default: "SP1")
- `z0::Real`: Reference impedance in Ohms (default: 50.0)
- `noise::Bool`: Enable noise parameter calculation (default: false)
- `noise_input_port::Int`: Input port for noise parameters (default: 1)
- `noise_output_port::Int`: Output port for noise parameters (default: 2)

## Example

```julia
# S-parameter analysis from 1MHz to 1GHz
analysis = SParameterAnalysis(start=1e6, stop=1e9, points=201)

# With 75Ω reference impedance
analysis = SParameterAnalysis(start=1e6, stop=1e9, points=201, z0=75.0)

# With noise parameters (F, Fmin, Sopt, Rn)
analysis = SParameterAnalysis(start=1e6, stop=1e9, points=201, noise=true)

# List of specific frequencies
analysis = SParameterAnalysis(values=[1e6, 10e6, 100e6, 1e9], sweep_type="list")
```
"""
mutable struct SParameterAnalysis <: AbstractSweepAnalysis
    name::String
    start::Union{Nothing,Real}
    stop::Union{Nothing,Real}
    points::Union{Nothing,Int}
    values::Union{Nothing,Vector{<:Real},Real}
    sweep_type::String
    z0::Real
    noise::Bool
    noise_input_port::Int
    noise_output_port::Int
end

# Main constructor
function SParameterAnalysis(;
    name::String="SP1",
    start::Real=1e6,
    stop::Real=100e6,
    points::Int=101,
    values::Union{Vector{<:Real},Real}=1e6,
    sweep_type::String="log",
    z0::Real=50.0,
    noise::Bool=false,
    noise_input_port::Int=1,
    noise_output_port::Int=2
)
    sweep_lower = lowercase(sweep_type)

    # Validate parameters based on sweep type
    if !(sweep_lower in ("lin", "linear", "log", "logarithmic", "list"))
        throw(ArgumentError("Invalid sweep_type: \"$sweep_type\". Must be 'log'/'logarithmic', 'lin'/'linear', or 'list'"))
    end

    z0 > 0 || throw(ArgumentError("Reference impedance must be positive"))
    noise_input_port >= 1 || throw(ArgumentError("Noise input port must be >= 1"))
    noise_output_port >= 1 || throw(ArgumentError("Noise output port must be >= 1"))

    SParameterAnalysis(name, start, stop, points, values, sweep_lower, z0, noise, noise_input_port, noise_output_port)
end

function to_qucs_analysis(a::SParameterAnalysis)::String
    noise_str = a.noise ? "yes" : "no"
    parts = [".SP:$(a.name)"]
    sweep_lower = lowercase(a.sweep_type)

    if sweep_lower in ("lin", "linear")
        push!(parts, "Type=\"lin\"")
        push!(parts, "Start=\"$(format_value(a.start))\"")
        push!(parts, "Stop=\"$(format_value(a.stop))\"")
        push!(parts, "Points=\"$(a.points)\"")
    elseif sweep_lower in ("log", "logarithmic")
        push!(parts, "Type=\"log\"")
        push!(parts, "Start=\"$(format_value(a.start))\"")
        push!(parts, "Stop=\"$(format_value(a.stop))\"")
        push!(parts, "Points=\"$(a.points)\"")
    elseif sweep_lower == "list"
        push!(parts, "Type=\"list\"")
        values_str = "[" * join(format_value.(a.values), ";") * "]"
        push!(parts, "Values=\"$values_str\"")
    end

    push!(parts, "Z0=\"$(format_value(a.z0))\"")
    push!(parts, "Noise=\"$noise_str\"")
    push!(parts, "NoiseIP=\"$(a.noise_input_port)\"")
    push!(parts, "NoiseOP=\"$(a.noise_output_port)\"")
    return join(parts, " ")
end
