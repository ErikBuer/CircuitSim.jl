module CircuitSim

# Exports

# Core types
export Pin, pin, Circuit, add_component!, connect!, @connect, assign_nodes!

# Components - Basic
export Resistor, Capacitor, Inductor
export CapacitorQ, InductorQ
export Ground, Short, Open

# Sources
export DCVoltageSource, DCCurrentSource
export ACVoltageSource, ACCurrentSource
export ACPowerSource, Pac
export FileVoltageSource, FileCurrentSource
export VoltagePulseSource, CurrentPulseSource
export VoltageRectangularSource, CurrentRectangularSource
export VoltageExponentialSource, CurrentExponentialSource
export VoltageNoiseSource, CurrentNoiseSource
export CurrentControlledCurrentSource, CurrentControlledVoltageSource
export VoltageControlledCurrentSource, VoltageControlledVoltageSource
export VoltageAMSource, VoltagePMSource
export CurrentCurrentNoiseSource, CurrentVoltageNoiseSource, VoltageVoltageNoiseSource

# Probes
export VoltageProbe, CurrentProbe, PowerProbe

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
export OpAmp, Gyrator
export TransmissionLine, CoaxialLine
export IdealTransformer, MutualInductor
export SPfile

# Devices - Nonlinear semiconductors
export Diode, D
export TunnelDiode, RTD
export JFET
export DIAC
export MOSFET
export Thyristor, SCR
export Triac
export BJT
export EquationDefinedDevice, EDD

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
export get_frequency, get_time, get_node_voltage, get_s_matrix_size
export get_component_current, get_pin_current, get_pin_voltage, get_voltage_across, get_component_power

# Utility functions
export s2z, s2z_series


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
include("parser/simulation_result.jl")

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
include("components/short.jl")
include("components/open.jl")

# File I/O utilities
include("io/file_loader.jl")

# Sources
include("sources/dc_voltage_source.jl")
include("sources/dc_current_source.jl")
include("sources/ac_voltage_source.jl")
include("sources/ac_current_source.jl")
include("sources/ac_power_source.jl")
include("sources/file_voltage_source.jl")
include("sources/file_current_source.jl")
include("sources/voltage_pulse_source.jl")
include("sources/current_pulse_source.jl")
include("sources/voltage_rectangular_source.jl")
include("sources/current_rectangular_source.jl")
include("sources/voltage_exponential_source.jl")
include("sources/current_exponential_source.jl")
include("sources/voltage_noise_source.jl")
include("sources/current_noise_source.jl")
include("sources/current_controlled_current_source.jl")
include("sources/current_controlled_voltage_source.jl")
include("sources/voltage_controlled_current_source.jl")
include("sources/voltage_controlled_voltage_source.jl")
include("sources/voltage_am_source.jl")
include("sources/voltage_pm_source.jl")
include("sources/current_current_noise_source.jl")
include("sources/current_voltage_noise_source.jl")
include("sources/voltage_voltage_noise_source.jl")

# Probes
include("probes/voltage_probe.jl")
include("probes/current_probe.jl")
include("probes/power_probe.jl")

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
include("components/opamp.jl")
include("components/gyrator.jl")
include("components/transmission_line.jl")
include("components/coaxial_line.jl")
include("components/ideal_transformer.jl")
include("components/mutual_inductor.jl")
include("components/spfile.jl")

# Nonlinear semiconductor devices
include("devices/diode.jl")
include("devices/tunnel_diode.jl")
include("devices/jfet.jl")
include("devices/diac.jl")
include("devices/mosfet.jl")
include("devices/thyristor.jl")
include("devices/triac.jl")
include("devices/bjt.jl")
include("devices/equation_defined.jl")

end