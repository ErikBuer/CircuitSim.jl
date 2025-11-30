"""
Analysis types for circuit simulation.

This module defines the abstract type hierarchy and common types for analysis configurations.
"""

# ============================================================================
# Abstract Analysis Type Hierarchy
# ============================================================================

"""
    AbstractAnalysis

Abstract base type for all circuit analyses.
"""
abstract type AbstractAnalysis end

"""
    AbstractSweepAnalysis <: AbstractAnalysis

Abstract type for sweep-based analyses (AC, SP, parameter sweeps).
"""
abstract type AbstractSweepAnalysis <: AbstractAnalysis end

# ============================================================================
# Sweep Type Enum
# ============================================================================

"""
    SweepType

Sweep type for frequency or parameter sweeps.

Values:
- `LINEAR`: Linear sweep
- `LOGARITHMIC`: Logarithmic sweep
- `LIST`: List of discrete values
- `CONSTANT`: Single constant value
"""
@enum SweepType begin
    LINEAR      # Linear sweep
    LOGARITHMIC # Logarithmic sweep
    LIST        # List of discrete values
    CONSTANT    # Single constant value
end

# ============================================================================
# Dispatch Functions (to be implemented by each analysis type)
# ============================================================================

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
