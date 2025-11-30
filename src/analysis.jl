"""
Analysis types for circuit simulation.

Each analysis type is represented as a struct that can be passed to the simulate function.
The structs are converted to the appropriate netlist format for the target simulator.
"""

# ============================================================================
# Abstract Analysis Type Hierarchy
# ============================================================================

"""
Abstract base type for all circuit analyses.
"""
abstract type AbstractAnalysis end

"""
Abstract type for sweep-based analyses (AC, SP, parameter sweeps).
"""
abstract type AbstractSweepAnalysis <: AbstractAnalysis end

# ============================================================================
# Sweep Type Enum
# ============================================================================

"""
Sweep type for frequency or parameter sweeps.
"""
@enum SweepType begin
    LINEAR      # Linear sweep
    LOGARITHMIC # Logarithmic sweep
    LIST        # List of discrete values
    CONSTANT    # Single constant value
end

# ============================================================================
# DC Analysis
# ============================================================================

"""
    DCAnalysis(; save_ops=true, temp=26.85, save_all=false)

DC operating point analysis.

Computes the DC operating point of the circuit.

# Parameters
- `save_ops::Bool`: Save operating points of nonlinear devices (default: true)
- `temp::Real`: Simulation temperature in °C (default: 26.85)
- `save_all::Bool`: Save all node voltages and branch currents (default: false)
- `name::String`: Analysis name (default: "DC1")

# Example
```julia
analysis = DCAnalysis()
result = simulate(circuit, analysis)
```
"""
struct DCAnalysis <: AbstractAnalysis
    name::String
    save_ops::Bool
    temp::Real
    save_all::Bool

    function DCAnalysis(; name::String="DC1", save_ops::Bool=true, temp::Real=26.85, save_all::Bool=false)
        new(name, save_ops, temp, save_all)
    end
end

# ============================================================================
# AC Analysis  
# ============================================================================

"""
    ACAnalysis(start, stop, points; type=LOGARITHMIC, name="AC1")

AC small-signal frequency sweep analysis.

Computes the small-signal AC response over a frequency range.

# Parameters
- `start::Real`: Start frequency in Hz
- `stop::Real`: Stop frequency in Hz
- `points::Int`: Number of frequency points
- `sweep_type::SweepType`: Type of frequency sweep (LINEAR or LOGARITHMIC, default: LOGARITHMIC)
- `name::String`: Analysis name (default: "AC1")

# Example
```julia
# Logarithmic sweep from 1Hz to 1MHz with 101 points
analysis = ACAnalysis(1.0, 1e6, 101)

# Linear sweep
analysis = ACAnalysis(100.0, 10e3, 100, sweep_type=LINEAR)
```
"""
struct ACAnalysis <: AbstractSweepAnalysis
    name::String
    start::Real
    stop::Real
    points::Int
    sweep_type::SweepType

    function ACAnalysis(start::Real, stop::Real, points::Int;
        sweep_type::SweepType=LOGARITHMIC, name::String="AC1")
        start > 0 || throw(ArgumentError("Start frequency must be positive"))
        stop > start || throw(ArgumentError("Stop frequency must be greater than start"))
        points >= 2 || throw(ArgumentError("Number of points must be at least 2"))
        new(name, start, stop, points, sweep_type)
    end
end

# ============================================================================
# Transient Analysis
# ============================================================================

"""
    TransientAnalysis(stop; start=0.0, points=nothing, step=nothing, name="TR1")

Time-domain transient analysis.

Simulates the circuit behavior over time.

# Parameters
- `stop::Real`: Stop time in seconds
- `start::Real`: Start time in seconds (default: 0.0)
- `points::Int`: Number of time points (specify either points or step)
- `step::Real`: Time step in seconds (specify either points or step)
- `name::String`: Analysis name (default: "TR1")
- `initial_dc::Bool`: Compute initial DC operating point (default: true)

# Example
```julia
# Simulate for 1ms with 1001 points
analysis = TransientAnalysis(1e-3, points=1001)

# Simulate for 10μs with 10ns step
analysis = TransientAnalysis(10e-6, step=10e-9)
```
"""
struct TransientAnalysis <: AbstractAnalysis
    name::String
    start::Real
    stop::Real
    points::Int
    initial_dc::Bool

    function TransientAnalysis(stop::Real; start::Real=0.0,
        points::Union{Int,Nothing}=nothing,
        step::Union{Real,Nothing}=nothing,
        name::String="TR1",
        initial_dc::Bool=true)
        stop > start || throw(ArgumentError("Stop time must be greater than start time"))

        # Calculate points from step or use default
        if points === nothing && step === nothing
            points = 101  # Default
        elseif points === nothing && step !== nothing
            points = ceil(Int, (stop - start) / step) + 1
        elseif points !== nothing
            # Use provided points
        else
            throw(ArgumentError("Specify either points or step, not both"))
        end

        points >= 2 || throw(ArgumentError("Number of points must be at least 2"))
        new(name, start, stop, points, initial_dc)
    end
end

# ============================================================================
# S-Parameter Analysis
# ============================================================================

"""
    SParameterAnalysis(start, stop, points; type=LOGARITHMIC, name="SP1", z0=50.0)

S-parameter frequency sweep analysis.

Computes S-parameters over a frequency range.

# Parameters
- `start::Real`: Start frequency in Hz
- `stop::Real`: Stop frequency in Hz
- `points::Int`: Number of frequency points
- `sweep_type::SweepType`: Type of frequency sweep (LINEAR or LOGARITHMIC, default: LOGARITHMIC)
- `z0::Real`: Reference impedance in Ohms (default: 50.0)
- `name::String`: Analysis name (default: "SP1")

# Example
```julia
# S-parameter analysis from 1MHz to 1GHz
analysis = SParameterAnalysis(1e6, 1e9, 201)
```
"""
struct SParameterAnalysis <: AbstractSweepAnalysis
    name::String
    start::Real
    stop::Real
    points::Int
    sweep_type::SweepType
    z0::Real

    function SParameterAnalysis(start::Real, stop::Real, points::Int;
        sweep_type::SweepType=LOGARITHMIC,
        z0::Real=50.0,
        name::String="SP1")
        start > 0 || throw(ArgumentError("Start frequency must be positive"))
        stop > start || throw(ArgumentError("Stop frequency must be greater than start"))
        points >= 2 || throw(ArgumentError("Number of points must be at least 2"))
        z0 > 0 || throw(ArgumentError("Reference impedance must be positive"))
        new(name, start, stop, points, sweep_type, z0)
    end
end

# ============================================================================
# Parameter Sweep Analysis
# ============================================================================

"""
    ParameterSweep(param, start, stop, points, inner_analysis; type=LINEAR, name="SW1")

Parameter sweep analysis.

Sweeps a component parameter and runs an inner analysis at each point.

# Parameters
- `param::String`: Parameter name to sweep (e.g., "R1.R" for resistor R1's resistance)
- `start::Real`: Start value
- `stop::Real`: Stop value  
- `points::Int`: Number of sweep points
- `inner_analysis::AbstractAnalysis`: Analysis to run at each sweep point
- `sweep_type::SweepType`: Type of sweep (LINEAR or LOGARITHMIC, default: LINEAR)
- `name::String`: Analysis name (default: "SW1")

# Example
```julia
# Sweep R1 from 1kOhm to 10kOhm and run DC analysis at each point
dc = DCAnalysis()
sweep = ParameterSweep("R1.R", 1e3, 10e3, 10, dc)
result = simulate(circuit, sweep)
```
"""
struct ParameterSweep <: AbstractSweepAnalysis
    name::String
    param::String
    start::Real
    stop::Real
    points::Int
    sweep_type::SweepType
    inner_analysis::AbstractAnalysis

    function ParameterSweep(param::String, start::Real, stop::Real, points::Int,
        inner_analysis::AbstractAnalysis;
        sweep_type::SweepType=LINEAR,
        name::String="SW1")
        points >= 2 || throw(ArgumentError("Number of points must be at least 2"))
        new(name, param, start, stop, points, sweep_type, inner_analysis)
    end
end

# ============================================================================
# Harmonic Balance Analysis
# ============================================================================

"""
    HarmonicBalanceAnalysis(frequency; harmonics=5, name="HB1")

Harmonic balance analysis for steady-state analysis of nonlinear circuits
with periodic excitation.

# Parameters
- `frequency::Real`: Fundamental frequency in Hz
- `harmonics::Int`: Number of harmonics to include (default: 5)
- `name::String`: Analysis name (default: "HB1")

# Example
```julia
# Harmonic balance at 1GHz with 7 harmonics
analysis = HarmonicBalanceAnalysis(1e9, harmonics=7)
```
"""
struct HarmonicBalanceAnalysis <: AbstractAnalysis
    name::String
    frequency::Real
    harmonics::Int

    function HarmonicBalanceAnalysis(frequency::Real; harmonics::Int=5, name::String="HB1")
        frequency > 0 || throw(ArgumentError("Frequency must be positive"))
        harmonics >= 1 || throw(ArgumentError("Number of harmonics must be at least 1"))
        new(name, frequency, harmonics)
    end
end

# ============================================================================
# Noise Analysis
# ============================================================================

"""
    NoiseAnalysis(start, stop, points, output_node, source; type=LOGARITHMIC, name="Noise1")

Noise analysis over a frequency range.

Computes noise contributions from all noise sources in the circuit.

# Parameters
- `start::Real`: Start frequency in Hz
- `stop::Real`: Stop frequency in Hz
- `points::Int`: Number of frequency points
- `output_node::String`: Output node name for noise measurement
- `source::String`: Input source name for noise reference
- `sweep_type::SweepType`: Type of frequency sweep (default: LOGARITHMIC)
- `name::String`: Analysis name (default: "Noise1")

# Example
```julia
analysis = NoiseAnalysis(10.0, 100e3, 101, "_net1", "V1")
```
"""
struct NoiseAnalysis <: AbstractSweepAnalysis
    name::String
    start::Real
    stop::Real
    points::Int
    output_node::String
    source::String
    sweep_type::SweepType

    function NoiseAnalysis(start::Real, stop::Real, points::Int,
        output_node::String, source::String;
        sweep_type::SweepType=LOGARITHMIC,
        name::String="Noise1")
        start > 0 || throw(ArgumentError("Start frequency must be positive"))
        stop > start || throw(ArgumentError("Stop frequency must be greater than start"))
        points >= 2 || throw(ArgumentError("Number of points must be at least 2"))
        new(name, start, stop, points, output_node, source, sweep_type)
    end
end

# ============================================================================
# Conversion to Qucs Netlist Format
# ============================================================================

"""
    to_qucs_analysis(analysis::AbstractAnalysis) -> String

Convert an analysis struct to a Qucs netlist analysis command string.
"""
function to_qucs_analysis end

function to_qucs_analysis(a::DCAnalysis)::String
    parts = [".DC:$(a.name)"]
    push!(parts, "saveOPs=\"$(a.save_ops ? "yes" : "no")\"")
    push!(parts, "Temp=\"$(a.temp)\"")
    push!(parts, "saveAll=\"$(a.save_all ? "yes" : "no")\"")
    return join(parts, " ")
end

function to_qucs_analysis(a::ACAnalysis)::String
    type_str = a.sweep_type == LOGARITHMIC ? "log" : "lin"
    parts = [".AC:$(a.name)"]
    push!(parts, "Type=\"$type_str\"")
    push!(parts, "Start=\"$(format_value(a.start))\"")
    push!(parts, "Stop=\"$(format_value(a.stop))\"")
    push!(parts, "Points=\"$(a.points)\"")
    return join(parts, " ")
end

function to_qucs_analysis(a::TransientAnalysis)::String
    parts = [".TR:$(a.name)"]
    push!(parts, "Type=\"lin\"")
    push!(parts, "Start=\"$(format_value(a.start))\"")
    push!(parts, "Stop=\"$(format_value(a.stop))\"")
    push!(parts, "Points=\"$(a.points)\"")
    push!(parts, "IntegrationMethod=\"Trapezoidal\"")
    return join(parts, " ")
end

function to_qucs_analysis(a::SParameterAnalysis)::String
    type_str = a.sweep_type == LOGARITHMIC ? "log" : "lin"
    parts = [".SP:$(a.name)"]
    push!(parts, "Type=\"$type_str\"")
    push!(parts, "Start=\"$(format_value(a.start))\"")
    push!(parts, "Stop=\"$(format_value(a.stop))\"")
    push!(parts, "Points=\"$(a.points)\"")
    push!(parts, "Z0=\"$(format_value(a.z0))\"")
    return join(parts, " ")
end

function to_qucs_analysis(a::ParameterSweep)::String
    type_str = a.sweep_type == LOGARITHMIC ? "log" : "lin"
    inner_str = to_qucs_analysis(a.inner_analysis)

    # The inner analysis command
    lines = [inner_str]

    # The parameter sweep command
    parts = [".SW:$(a.name)"]
    push!(parts, "Type=\"$type_str\"")
    push!(parts, "Param=\"$(a.param)\"")
    push!(parts, "Start=\"$(format_value(a.start))\"")
    push!(parts, "Stop=\"$(format_value(a.stop))\"")
    push!(parts, "Points=\"$(a.points)\"")
    push!(parts, "Sim=\"$(a.inner_analysis.name)\"")

    push!(lines, join(parts, " "))
    return join(lines, "\n")
end

function to_qucs_analysis(a::HarmonicBalanceAnalysis)::String
    parts = [".HB:$(a.name)"]
    push!(parts, "n=\"$(a.harmonics)\"")
    push!(parts, "f=\"$(format_value(a.frequency))\"")
    return join(parts, " ")
end

function to_qucs_analysis(a::NoiseAnalysis)::String
    type_str = a.sweep_type == LOGARITHMIC ? "log" : "lin"
    parts = [".Noise:$(a.name)"]
    push!(parts, "Type=\"$type_str\"")
    push!(parts, "Start=\"$(format_value(a.start))\"")
    push!(parts, "Stop=\"$(format_value(a.stop))\"")
    push!(parts, "Points=\"$(a.points)\"")
    push!(parts, "Output=\"$(a.output_node)\"")
    push!(parts, "Src=\"$(a.source)\"")
    return join(parts, " ")
end

# ============================================================================
# Conversion to SPICE Netlist Format (for ngspice)
# ============================================================================

"""
    to_spice_analysis(analysis::AbstractAnalysis) -> String

Convert an analysis struct to a SPICE netlist analysis command string.
"""
function to_spice_analysis end

function to_spice_analysis(a::DCAnalysis)::String
    ".op"
end

function to_spice_analysis(a::ACAnalysis)::String
    type_str = a.sweep_type == LOGARITHMIC ? "dec" : "lin"
    # SPICE uses decades for log sweep, so we need to calculate points per decade
    if a.sweep_type == LOGARITHMIC
        decades = log10(a.stop / a.start)
        points_per_decade = ceil(Int, a.points / decades)
        ".ac $type_str $points_per_decade $(a.start) $(a.stop)"
    else
        ".ac $type_str $(a.points) $(a.start) $(a.stop)"
    end
end

function to_spice_analysis(a::TransientAnalysis)::String
    step = (a.stop - a.start) / (a.points - 1)
    ".tran $(step) $(a.stop)"
end

function to_spice_analysis(a::ParameterSweep)::String
    # SPICE parameter sweep is more complex, using .step
    inner_str = to_spice_analysis(a.inner_analysis)
    type_str = a.sweep_type == LOGARITHMIC ? "dec" : "lin"
    "$inner_str\n.step param $(a.param) $(a.start) $(a.stop) $(a.points)"
end

function to_spice_analysis(a::NoiseAnalysis)::String
    type_str = a.sweep_type == LOGARITHMIC ? "dec" : "lin"
    if a.sweep_type == LOGARITHMIC
        decades = log10(a.stop / a.start)
        points_per_decade = ceil(Int, a.points / decades)
        ".noise v($(a.output_node)) $(a.source) $type_str $points_per_decade $(a.start) $(a.stop)"
    else
        ".noise v($(a.output_node)) $(a.source) $type_str $(a.points) $(a.start) $(a.stop)"
    end
end

# Fallback for unsupported analysis types in SPICE
function to_spice_analysis(a::AbstractAnalysis)::String
    error("Analysis type $(typeof(a)) is not supported by ngspice")
end
