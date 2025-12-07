"""
S-parameter frequency sweep analysis.
"""

"""
    SParameterAnalysis(start, stop, points; type=LOGARITHMIC, name="SP1", z0=50.0, noise=false, noise_input_port=1, noise_output_port=2)

S-parameter frequency sweep analysis.

Computes S-parameters over a frequency range. Optionally compute noise parameters.

# Parameters
- `start::Real`: Start frequency in Hz
- `stop::Real`: Stop frequency in Hz
- `points::Int`: Number of frequency points
- `sweep_type::SweepType`: Type of frequency sweep (LINEAR or LOGARITHMIC, default: LOGARITHMIC)
- `z0::Real`: Reference impedance in Ohms (default: 50.0)
- `noise::Bool`: Enable noise parameter calculation (default: false)
- `noise_input_port::Int`: Input port for noise parameters (default: 1)
- `noise_output_port::Int`: Output port for noise parameters (default: 2)
- `name::String`: Analysis name (default: "SP1")

# Example
```julia
# S-parameter analysis from 1MHz to 1GHz
analysis = SParameterAnalysis(1e6, 1e9, 201)

# With 75Ω reference impedance
analysis = SParameterAnalysis(1e6, 1e9, 201, z0=75.0)

# With noise parameters (F, Fmin, Sopt, Rn)
analysis = SParameterAnalysis(1e6, 1e9, 201, noise=true)
```
"""
struct SParameterAnalysis <: AbstractSweepAnalysis
    name::String
    start::Real
    stop::Real
    points::Int
    sweep_type::SweepType
    z0::Real
    noise::Bool
    noise_input_port::Int
    noise_output_port::Int

    function SParameterAnalysis(start::Real, stop::Real, points::Int;
        sweep_type::SweepType=LOGARITHMIC,
        z0::Real=50.0,
        noise::Bool=false,
        noise_input_port::Int=1,
        noise_output_port::Int=2,
        name::String="SP1")
        start > 0 || throw(ArgumentError("Start frequency must be positive"))
        stop > start || throw(ArgumentError("Stop frequency must be greater than start"))
        points >= 2 || throw(ArgumentError("Number of points must be at least 2"))
        z0 > 0 || throw(ArgumentError("Reference impedance must be positive"))
        noise_input_port >= 1 || throw(ArgumentError("Noise input port must be >= 1"))
        noise_output_port >= 1 || throw(ArgumentError("Noise output port must be >= 1"))
        new(name, start, stop, points, sweep_type, z0, noise, noise_input_port, noise_output_port)
    end
end


function to_qucs_analysis(a::SParameterAnalysis)::String
    type_str = a.sweep_type == LOGARITHMIC ? "log" : "lin"
    noise_str = a.noise ? "yes" : "no"
    parts = [".SP:$(a.name)"]
    push!(parts, "Type=\"$type_str\"")
    push!(parts, "Start=\"$(format_value(a.start))\"")
    push!(parts, "Stop=\"$(format_value(a.stop))\"")
    push!(parts, "Points=\"$(a.points)\"")
    push!(parts, "Z0=\"$(format_value(a.z0))\"")
    push!(parts, "Noise=\"$noise_str\"")
    push!(parts, "NoiseIP=\"$(a.noise_input_port)\"")
    push!(parts, "NoiseOP=\"$(a.noise_output_port)\"")
    return join(parts, " ")
end
