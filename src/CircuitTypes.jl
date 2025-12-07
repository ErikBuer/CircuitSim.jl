module CircuitTypes

# Exports

# Core types
export Pin, pin, Circuit, add_component!, connect!, @connect, assign_nodes!

# Components - Basic
export Resistor, Capacitor, Inductor
export CapacitorQ, InductorQ
export Ground

# Sources
export DCVoltageSource, DCCurrentSource
export ACVoltageSource, ACCurrentSource
export ACPowerSource, Pac

# Probes
export VoltageProbe, CurrentProbe

# Components - Substrate
export Substrate

# Components - Microstrip
export MicrostripLine, MicrostripCorner, MicrostripMiteredBend
export MicrostripStep, MicrostripOpen, MicrostripGap
export MicrostripCoupled, MicrostripTee, MicrostripCross
export MicrostripVia, MicrostripRadialStub, MicrostripLange

# Components - Other RF
export BondWire, SpiralInductor, CircularLoop

# Components - RF Building Blocks
export DCBlock, DCFeed, BiasTee
export Amplifier, Isolator, Attenuator
export Circulator, PhaseShifter
export Coupler, Hybrid

# Netlist generation
export netlist_qucs, netlist_ngspice
export to_qucs_netlist, to_spice_netlist

# Backend functions
export check_qucsator, run_qucsator, simulate_qucsator
export check_ngspice, run_ngspice

# Analysis types
export AbstractAnalysis, AbstractSweepAnalysis
export SweepType, LINEAR, LOGARITHMIC, LIST, CONSTANT
export DCAnalysis, ACAnalysis, TransientAnalysis
export SParameterAnalysis, ParameterSweep
export HarmonicBalanceAnalysis, NoiseAnalysis
export to_qucs_analysis, to_spice_analysis

# Parser exports - Base types
export SimulationStatus, SIM_SUCCESS, SIM_ERROR, SIM_PARSE_ERROR, SIM_NOT_RUN
export DataVector, QucsDataset
export parse_qucs_value, parse_qucs_dataset
export get_real_vector, get_imag_vector, get_complex_vector
export list_vectors, has_errors, print_summary

# Parser exports - Typed result structures (Qucsator-specific)
export DCResult, ACResult, TransientResult, SParameterResult, MultiAnalysisResult
export extract_dc_result, extract_ac_result, extract_transient_result, extract_sparameter_result

# Parser exports - Analysis-specific convenience methods
export get_frequency, get_time, get_sparameter, get_node_voltage, get_s_matrix_size


# Abstract Types (must be loaded first)

include("abstract_types.jl")

include("utilities.jl")

# Analysis Types (abstracts must be loaded before concrete types)

include("analysis/analysis_types.jl")
include("analysis/dc_analysis.jl")
include("analysis/ac_analysis.jl")
include("analysis/transient_analysis.jl")
include("analysis/s_parameter_analysis.jl")
include("analysis/parameter_sweep.jl")
include("analysis/harmonic_balance_analysis.jl")
include("analysis/noise_analysis.jl")

# Core Infrastructure

include("pin.jl")
include("union_find.jl")
include("circuit.jl")

# Parser (must be loaded before backends that use QucsDataset)

include("parser/qucs_dataset.jl")

# Backends (declares dispatch function stubs)

include("backends/qucsator.jl")
include("backends/ngspice.jl")

# Components (implements dispatch methods for each component)

include("components/resistor.jl")
include("components/capacitor.jl")
include("components/inductor.jl")
include("components/capacitor_q.jl")
include("components/inductor_q.jl")
include("components/ground.jl")

# Sources
include("sources/dc_voltage_source.jl")
include("sources/dc_current_source.jl")
include("sources/ac_voltage_source.jl")
include("sources/ac_current_source.jl")
include("sources/ac_power_source.jl")

# Probes
include("probes/voltage_probe.jl")
include("probes/current_probe.jl")

# Substrate (needed by microstrip components)
include("components/substrate.jl")

# Microstrip components
include("components/microstrip_line.jl")
include("components/microstrip_corner.jl")
include("components/microstrip_mitered_bend.jl")
include("components/microstrip_step.jl")
include("components/microstrip_open.jl")
include("components/microstrip_gap.jl")
include("components/microstrip_coupled.jl")
include("components/microstrip_tee.jl")
include("components/microstrip_cross.jl")
include("components/microstrip_via.jl")
include("components/microstrip_radial_stub.jl")
include("components/microstrip_lange.jl")

# Other RF components
include("components/bond_wire.jl")
include("components/spiral_inductor.jl")
include("components/circular_loop.jl")

# RF building blocks
include("components/dc_block.jl")
include("components/dc_feed.jl")
include("components/bias_tee.jl")
include("components/amplifier.jl")
include("components/isolator.jl")
include("components/attenuator.jl")
include("components/circulator.jl")
include("components/phase_shifter.jl")
include("components/coupler.jl")
include("components/hybrid.jl")

end