"""
    AbstractAnalysis

Abstract base type for all circuit analysis.
"""
abstract type AbstractAnalysis <: AbstractCircuitSimulationElement end

"""
    AbstractSweepAnalysis <: AbstractAnalysis

Abstract type for sweep-based analyses (AC, SP, parameter sweeps).
"""
abstract type AbstractSweepAnalysis <: AbstractAnalysis end

"""
    to_qucs_analysis(analysis::AbstractAnalysis) -> String

Convert an analysis struct to a Qucs netlist analysis command string.
Must be implemented for each concrete analysis type.
"""
function to_qucs_analysis end

"""
    to_spice_analysis(analysis::AbstractAnalysis) -> String

Convert an analysis struct to a SPICE netlist analysis command string.
Must be implemented for each concrete analysis type.
"""
function to_spice_analysis end

# Fallback for unsupported analysis types in SPICE
function to_spice_analysis(a::AbstractAnalysis)::String
    error("Analysis type $(typeof(a)) is not supported by ngspice")
end
