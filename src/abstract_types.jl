# Abstract types. There are way to many levels and types. Should be cleaned up a bit.
# We only need types that are useful for dispatching methods on.

export AbstractCircuitComponent

# Core category types
export AbstractPassiveComponent, AbstractActiveComponent, AbstractSource, AbstractNoiseSource,
    AbstractTransmissionLine, AbstractMicrostripComponent, AbstractExternalInterface

abstract type AbstractCircuitComponent end
abstract type AbstractPassiveComponent <: AbstractCircuitComponent end
abstract type AbstractActiveComponent <: AbstractCircuitComponent end
abstract type AbstractSource <: AbstractCircuitComponent end
abstract type AbstractNoiseSource <: AbstractCircuitComponent end
abstract type AbstractTransmissionLine <: AbstractCircuitComponent end
abstract type AbstractMicrostripComponent <: AbstractTransmissionLine end
abstract type AbstractExternalInterface <: AbstractCircuitComponent end

# Simple helper components
export AbstractGround, AbstractOpenCircuit, AbstractShortCircuit, AbstractIdealTransformer
abstract type AbstractGround <: AbstractPassiveComponent end
abstract type AbstractOpenCircuit <: AbstractPassiveComponent end
abstract type AbstractShortCircuit <: AbstractPassiveComponent end
abstract type AbstractIdealTransformer <: AbstractPassiveComponent end

# Passive components
export AbstractResistor, AbstractCapacitor,
    AbstractInductor, AbstractMutualInductance
abstract type AbstractResistor <: AbstractPassiveComponent end
abstract type AbstractCapacitor <: AbstractPassiveComponent end
abstract type AbstractInductor <: AbstractPassiveComponent end
abstract type AbstractMutualInductance <: AbstractPassiveComponent end

# RF building blocks
export AbstractDCBlock, AbstractDCFeed, AbstractBiasTee, AbstractPowerAmplifier,
    AbstractAttenuator, AbstractCirculator, AbstractIsolator, AbstractPhaseShifter,
    AbstractGyrator, AbstractCoupler, AbstractHybridCoupler
abstract type AbstractDCBlock <: AbstractPassiveComponent end
abstract type AbstractDCFeed <: AbstractPassiveComponent end
abstract type AbstractBiasTee <: AbstractPassiveComponent end
abstract type AbstractPowerAmplifier <: AbstractActiveComponent end
abstract type AbstractAttenuator <: AbstractPassiveComponent end
abstract type AbstractCirculator <: AbstractPassiveComponent end
abstract type AbstractIsolator <: AbstractPassiveComponent end
abstract type AbstractPhaseShifter <: AbstractPassiveComponent end
abstract type AbstractGyrator <: AbstractPassiveComponent end
abstract type AbstractCoupler <: AbstractPassiveComponent end
abstract type AbstractHybridCoupler <: AbstractPassiveComponent end

# Sources
export AbstractDCVoltageSource, AbstractDCCurrentSource, AbstractACVoltageSource, AbstractACCurrentSource,
    AbstractVoltagePulseSource, AbstractVoltageRectifiedSource, AbstractCurrentRectifiedSource
abstract type AbstractDCVoltageSource <: AbstractSource end
abstract type AbstractDCCurrentSource <: AbstractSource end
abstract type AbstractACVoltageSource <: AbstractSource end
abstract type AbstractACCurrentSource <: AbstractSource end
abstract type AbstractVoltagePulseSource <: AbstractSource end
abstract type AbstractVoltageRectifiedSource <: AbstractSource end
abstract type AbstractCurrentRectifiedSource <: AbstractSource end

# Probes
export AbstractCurrentProbe, AbstractWaveProbe, AbstractVoltageProbe
abstract type AbstractCurrentProbe <: AbstractPassiveComponent end
abstract type AbstractWaveProbe <: AbstractPassiveComponent end
abstract type AbstractVoltageProbe <: AbstractPassiveComponent end

# S-parameter file
export AbstractSParameterFile
abstract type AbstractSParameterFile <: AbstractExternalInterface end

# Transmission lines
export AbstractTransmissionLine2Port
abstract type AbstractTransmissionLine2Port <: AbstractTransmissionLine end

# Noise sources
export AbstractVoltageNoiseSource, AbstractCurrentNoiseSource
abstract type AbstractVoltageNoiseSource <: AbstractNoiseSource end
abstract type AbstractCurrentNoiseSource <: AbstractNoiseSource end

# Microstrip components
export AbstractMicrostripLine, AbstractMicrostripCorner, AbstractMicrostripMiteredBend,
    AbstractMicrostripStep, AbstractMicrostripOpen, AbstractMicrostripGap, AbstractMicrostripCoupled,
    AbstractMicrostripLange, AbstractMicrostripTee, AbstractMicrostripCross, AbstractMicrostripVia,
    AbstractMicrostripRadialStub, AbstractBondWire, AbstractSpiralInductor, AbstractCircularLoop
abstract type AbstractMicrostripLine <: AbstractMicrostripComponent end
abstract type AbstractMicrostripCorner <: AbstractMicrostripComponent end
abstract type AbstractMicrostripMiteredBend <: AbstractMicrostripComponent end
abstract type AbstractMicrostripStep <: AbstractMicrostripComponent end
abstract type AbstractMicrostripOpen <: AbstractMicrostripComponent end
abstract type AbstractMicrostripGap <: AbstractMicrostripComponent end
abstract type AbstractMicrostripCoupled <: AbstractMicrostripComponent end
abstract type AbstractMicrostripLange <: AbstractMicrostripComponent end
abstract type AbstractMicrostripTee <: AbstractMicrostripComponent end
abstract type AbstractMicrostripCross <: AbstractMicrostripComponent end
abstract type AbstractMicrostripVia <: AbstractMicrostripComponent end
abstract type AbstractMicrostripRadialStub <: AbstractMicrostripComponent end
abstract type AbstractBondWire <: AbstractMicrostripComponent end
abstract type AbstractSpiralInductor <: AbstractMicrostripComponent end
abstract type AbstractCircularLoop <: AbstractMicrostripComponent end

# Active devices
export AbstractDiode, AbstractJFET, AbstractBipolarJunctionTransistor, AbstractMOSFET,
    AbstractEquationDefinedDevice, AbstractTRIAC, AbstractThyristor, AbstractTunnelDiode
export AbstractTriac  # Alias
abstract type AbstractDiode <: AbstractActiveComponent end
abstract type AbstractJFET <: AbstractActiveComponent end
abstract type AbstractBipolarJunctionTransistor <: AbstractActiveComponent end
abstract type AbstractMOSFET <: AbstractActiveComponent end
abstract type AbstractEquationDefinedDevice <: AbstractActiveComponent end
abstract type AbstractTRIAC <: AbstractActiveComponent end
abstract type AbstractThyristor <: AbstractActiveComponent end
abstract type AbstractTunnelDiode <: AbstractActiveComponent end
const AbstractTriac = AbstractTRIAC