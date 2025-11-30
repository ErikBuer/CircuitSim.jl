module CircuitTypes

export Pin, pin, Circuit, add_component!, connect!, @connect, assign_nodes!
export netlist_qucs, netlist_ngspice, to_qucs_netlist, to_spice_netlist
export check_qucsator, run_qucsator, simulate_qucsator, simulate, check_ngspice, run_ngspice
export Resistor, Capacitor, Inductor
export DCVoltageSource, DCCurrentSource
export ACVoltageSource, ACCurrentSource
export Ground

# Analysis types exports
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

include("abstract_types.jl")
include("components.jl")
include("pin.jl")
include("union_find.jl")
include("circuit.jl")

include("utilities.jl")

# Analysis types
include("analysis.jl")

# Supported backends
include("qucsator.jl")
include("ngspice.jl")

# Output parsers
include("qucs_parser.jl")

end