module CircuitTypes

# =============================================================================
# Exports
# =============================================================================

# Core types
export Pin, pin, Circuit, add_component!, connect!, @connect, assign_nodes!

# Components
export Resistor, Capacitor, Inductor
export DCVoltageSource, DCCurrentSource
export ACVoltageSource, ACCurrentSource
export Ground

# Netlist generation
export netlist_qucs, netlist_ngspice
export to_qucs_netlist, to_spice_netlist

# Backend functions
export check_qucsator, run_qucsator, simulate_qucsator, simulate
export check_ngspice, run_ngspice

# Analysis types
export AbstractAnalysis, AbstractSweepAnalysis
export SweepType, LINEAR, LOGARITHMIC, LIST, CONSTANT
export DCAnalysis, ACAnalysis, TransientAnalysis
export SParameterAnalysis, ParameterSweep
export HarmonicBalanceAnalysis, NoiseAnalysis
export to_qucs_analysis, to_spice_analysis

# Parser exports
export SimulationStatus, SIM_SUCCESS, SIM_ERROR, SIM_PARSE_ERROR, SIM_NOT_RUN
export DataVector, QucsDataset
export parse_qucs_value, parse_qucs_dataset
export get_real_vector, get_imag_vector, get_complex_vector
export list_vectors, has_errors, print_summary

# High-level result access exports
export SimulationResult
export voltage, voltage_vector, voltage_between
export current, current_vector

# =============================================================================
# Abstract Types (must be loaded first)
# =============================================================================

include("abstract_types.jl")

# =============================================================================
# Utilities
# =============================================================================

include("utilities.jl")

# =============================================================================
# Analysis Types (abstracts must be loaded before concrete types)
# =============================================================================

include("analysis/analysis_types.jl")
include("analysis/dc_analysis.jl")
include("analysis/ac_analysis.jl")
include("analysis/transient_analysis.jl")
include("analysis/s_parameter_analysis.jl")
include("analysis/parameter_sweep.jl")
include("analysis/harmonic_balance_analysis.jl")
include("analysis/noise_analysis.jl")

# =============================================================================
# Core Infrastructure
# =============================================================================

include("pin.jl")
include("union_find.jl")
include("circuit.jl")

# =============================================================================
# Parser (must be loaded before backends that use QucsDataset)
# =============================================================================

include("parser/qucs_dataset.jl")
include("parser/simulation_result.jl")

# =============================================================================
# Backends (declares dispatch function stubs)
# =============================================================================

include("backends/qucsator.jl")
include("backends/ngspice.jl")

# =============================================================================
# Components (implements dispatch methods for each component)
# =============================================================================

include("components/resistor.jl")
include("components/capacitor.jl")
include("components/inductor.jl")
include("components/ground.jl")
include("components/dc_voltage_source.jl")
include("components/dc_current_source.jl")
include("components/ac_voltage_source.jl")
include("components/ac_current_source.jl")

end