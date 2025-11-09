export AbstractCircuitComponent

# Category roots
export AbstractPassiveComponent, AbstractActiveComponent, AbstractDigitalComponent,
    AbstractNoiseSource, AbstractTransmissionLine, AbstractMicrostripComponent,
    AbstractCoplanarComponent, AbstractExternalInterface

abstract type AbstractCircuitComponent end

abstract type AbstractPassiveComponent <: AbstractCircuitComponent end
abstract type AbstractActiveComponent <: AbstractCircuitComponent end
abstract type AbstractSource <: AbstractCircuitComponent end
abstract type AbstractDigitalComponent <: AbstractCircuitComponent end
abstract type AbstractNoiseSource <: AbstractCircuitComponent end
abstract type AbstractTransmissionLine <: AbstractCircuitComponent end
abstract type AbstractMicrostripComponent <: AbstractTransmissionLine end
abstract type AbstractCoplanarComponent <: AbstractTransmissionLine end
abstract type AbstractExternalInterface <: AbstractCircuitComponent end


# Helper / simple
export AbstractGround, AbstractOpenCircuit, AbstractShortCircuit, AbstractTee, AbstractCrossConnection, AbstractIdealTransformer
abstract type AbstractGround <: AbstractPassiveComponent end
abstract type AbstractOpenCircuit <: AbstractPassiveComponent end
abstract type AbstractShortCircuit <: AbstractPassiveComponent end
abstract type AbstractTee <: AbstractPassiveComponent end
abstract type AbstractCrossConnection <: AbstractPassiveComponent end
abstract type AbstractIdealTransformer <: AbstractPassiveComponent end

# Passive / basic components
export AbstractResistor, AbstractCapacitor, AbstractCapacitorWithQualityFactor, AbstractInductor, AbstractInductorWithQualityFactor
abstract type AbstractResistor <: AbstractPassiveComponent end
abstract type AbstractCapacitor <: AbstractPassiveComponent end
abstract type AbstractCapacitorWithQualityFactor <: AbstractCapacitor end
abstract type AbstractInductor <: AbstractPassiveComponent end
abstract type AbstractInductorWithQualityFactor <: AbstractInductor end

# Mutual inductance variants
export AbstractMutualInductance, AbstractMutualInductance2, AbstractMutualInductanceCross
abstract type AbstractMutualInductance <: AbstractPassiveComponent end
abstract type AbstractMutualInductance2 <: AbstractPassiveComponent end
abstract type AbstractMutualInductanceCross <: AbstractPassiveComponent end

# Controlled / dependent sources
export AbstractVoltageControlledCurrentSource, AbstractCurrentControlledCurrentSource,
    AbstractCurrentControlledVoltageSource, AbstractVoltageControlledVoltageSource
abstract type AbstractVoltageControlledCurrentSource <: AbstractSource end
abstract type AbstractCurrentControlledCurrentSource <: AbstractSource end
abstract type AbstractCurrentControlledVoltageSource <: AbstractSource end
abstract type AbstractVoltageControlledVoltageSource <: AbstractSource end

# Blocks, feeds, biasing and amplifier
export AbstractDCBlock, AbstractDCFeed, AbstractBiasTee, AbstractPowerAmplifier
abstract type AbstractDCBlock <: AbstractPassiveComponent end
abstract type AbstractDCFeed <: AbstractPassiveComponent end
abstract type AbstractBiasTee <: AbstractPassiveComponent end
abstract type AbstractPowerAmplifier <: AbstractActiveComponent end

# Attenuator / isolation / directional devices
export AbstractAttenuator, AbstractCirculator, AbstractIsolator
abstract type AbstractAttenuator <: AbstractPassiveComponent end
abstract type AbstractCirculator <: AbstractPassiveComponent end
abstract type AbstractIsolator <: AbstractPassiveComponent end

# Transformers
export AbstractTransformer, AbstractStrayTransformer
abstract type AbstractTransformer <: AbstractPassiveComponent end
abstract type AbstractStrayTransformer <: AbstractPassiveComponent end

# Sources
export AbstractDCVoltageSource, AbstractDCCurrentSource, AbstractACVoltageSource, AbstractACCurrentSource,
    AbstractVoltagePulseSource, AbstractCurrentPulseSource, AbstractVoltageFileSource, AbstractCurrentFileSource,
    AbstractVoltageRectifiedSource, AbstractCurrentRectifiedSource
abstract type AbstractDCVoltageSource <: AbstractSource end
abstract type AbstractDCCurrentSource <: AbstractSource end
abstract type AbstractACVoltageSource <: AbstractSource end
abstract type AbstractACCurrentSource <: AbstractSource end
abstract type AbstractVoltagePulseSource <: AbstractSource end
abstract type AbstractCurrentPulseSource <: AbstractSource end
abstract type AbstractVoltageFileSource <: AbstractSource end
abstract type AbstractCurrentFileSource <: AbstractSource end
abstract type AbstractVoltageRectifiedSource <: AbstractSource end
abstract type AbstractCurrentRectifiedSource <: AbstractSource end

# Voltage / current measurement probes and S-parameter file types
export AbstractCurrentProbe, AbstractWaveProbe, AbstractVoltageProbe, AbstractSParameterFile, AbstractSParameterDataFile
abstract type AbstractCurrentProbe <: AbstractPassiveComponent end
abstract type AbstractWaveProbe <: AbstractPassiveComponent end
abstract type AbstractVoltageProbe <: AbstractPassiveComponent end
abstract type AbstractSParameterFile <: AbstractExternalInterface end
abstract type AbstractSParameterDataFile <: AbstractExternalInterface end

# Phase shifter, gyrator, switches, relais
export AbstractPhaseShifter, AbstractGyrator, AbstractTwoStateSwitch, AbstractRelay
abstract type AbstractPhaseShifter <: AbstractPassiveComponent end
abstract type AbstractGyrator <: AbstractPassiveComponent end
abstract type AbstractTwoStateSwitch <: AbstractPassiveComponent end
abstract type AbstractRelay <: AbstractPassiveComponent end

# Transmission lines, waveguides and related
export AbstractTransmissionLine2Port, AbstractCoupledTransmissionLine, AbstractTaperedTransmissionLine,
    AbstractCoaxialLine, AbstractRectangularWaveguide, AbstractCircularWaveguide,
    AbstractTwistedPairCable, AbstractFourPortTransmissionLine, AbstractRLCGLine
abstract type AbstractTransmissionLine2Port <: AbstractTransmissionLine end
abstract type AbstractCoupledTransmissionLine <: AbstractTransmissionLine end
abstract type AbstractTaperedTransmissionLine <: AbstractTransmissionLine end
abstract type AbstractCoaxialLine <: AbstractTransmissionLine end
abstract type AbstractRectangularWaveguide <: AbstractTransmissionLine end
abstract type AbstractCircularWaveguide <: AbstractTransmissionLine end
abstract type AbstractTwistedPairCable <: AbstractTransmissionLine end
abstract type AbstractFourPortTransmissionLine <: AbstractTransmissionLine end
abstract type AbstractRLCGLine <: AbstractTransmissionLine end

# RF building blocks
export AbstractCoupler, AbstractHybridCoupler, AbstractRFEMDDevice
abstract type AbstractCoupler <: AbstractPassiveComponent end
abstract type AbstractHybridCoupler <: AbstractPassiveComponent end
abstract type AbstractRFEMDDevice <: AbstractPassiveComponent end

# Noise sources
export AbstractVoltageNoiseSource, AbstractCurrentNoiseSource, AbstractCurrentInDependentNoiseSource,
    AbstractIVNoiseSource, AbstractVoltageVoltageNoiseSource
abstract type AbstractVoltageNoiseSource <: AbstractNoiseSource end
abstract type AbstractCurrentNoiseSource <: AbstractNoiseSource end
abstract type AbstractCurrentInDependentNoiseSource <: AbstractNoiseSource end
abstract type AbstractIVNoiseSource <: AbstractNoiseSource end
abstract type AbstractVoltageVoltageNoiseSource <: AbstractNoiseSource end

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

# Coplanar waveguide and coplanar items
export AbstractCoplanarWaveguideLine, AbstractCoplanarOpen, AbstractCoplanarShort, AbstractCoplanarGap, AbstractCoplanarStep
abstract type AbstractCoplanarWaveguideLine <: AbstractCoplanarComponent end
abstract type AbstractCoplanarOpen <: AbstractCoplanarComponent end
abstract type AbstractCoplanarShort <: AbstractCoplanarComponent end
abstract type AbstractCoplanarGap <: AbstractCoplanarComponent end
abstract type AbstractCoplanarStep <: AbstractCoplanarComponent end

# Non-linear / semiconductor / other active devices
export AbstractOperationalAmplifier, AbstractDiode, AbstractJFET, AbstractBipolarJunctionTransistor,
    AbstractMOSFET, AbstractEquationDefinedDevice, AbstractDIAC, AbstractTRIAC, AbstractThyristor,
    AbstractTunnelDiode
abstract type AbstractOperationalAmplifier <: AbstractActiveComponent end
abstract type AbstractDiode <: AbstractActiveComponent end
abstract type AbstractJFET <: AbstractActiveComponent end
abstract type AbstractBipolarJunctionTransistor <: AbstractActiveComponent end
abstract type AbstractMOSFET <: AbstractActiveComponent end
abstract type AbstractEquationDefinedDevice <: AbstractActiveComponent end
abstract type AbstractDIAC <: AbstractActiveComponent end
abstract type AbstractTRIAC <: AbstractActiveComponent end
abstract type AbstractThyristor <: AbstractActiveComponent end
abstract type AbstractTunnelDiode <: AbstractActiveComponent end

# Digital components
export AbstractInverter, AbstractNORGate, AbstractORGate, AbstractNANDGate, AbstractANDGate,
    AbstractXNORGate, AbstractXORGate, AbstractDigitalSource, AbstractBuffer
abstract type AbstractInverter <: AbstractDigitalComponent end
abstract type AbstractNORGate <: AbstractDigitalComponent end
abstract type AbstractORGate <: AbstractDigitalComponent end
abstract type AbstractNANDGate <: AbstractDigitalComponent end
abstract type AbstractANDGate <: AbstractDigitalComponent end
abstract type AbstractXNORGate <: AbstractDigitalComponent end
abstract type AbstractXORGate <: AbstractDigitalComponent end
abstract type AbstractDigitalSource <: AbstractDigitalComponent end
abstract type AbstractBuffer <: AbstractDigitalComponent end

# Verilog / external device placeholders
export AbstractVerilogDevice, AbstractModelAmplifier, AbstractLogarithmicAmplifier, AbstractPotentiometer,
    AbstractMESFETDevice, AbstractEKV26MOSDevice, AbstractPhotodiodeDevice, AbstractPhototransistorDevice,
    AbstractNIGBTDevice
abstract type AbstractVerilogDevice <: AbstractCircuitComponent end
abstract type AbstractModelAmplifier <: AbstractVerilogDevice end
abstract type AbstractLogarithmicAmplifier <: AbstractVerilogDevice end
abstract type AbstractPotentiometer <: AbstractVerilogDevice end
abstract type AbstractMESFETDevice <: AbstractVerilogDevice end
abstract type AbstractEKV26MOSDevice <: AbstractVerilogDevice end
abstract type AbstractPhotodiodeDevice <: AbstractVerilogDevice end
abstract type AbstractPhototransistorDevice <: AbstractVerilogDevice end
abstract type AbstractNIGBTDevice <: AbstractVerilogDevice end

# Digital verilog / state machine placeholder types
export AbstractDFlipFlopSR, AbstractTFlipFlopSR, AbstractJKFlipFlopSR, AbstractGatedDLatch,
    AbstractLogicOne, AbstractLogicZero, AbstractMux2to1, AbstractMux4to1, AbstractMux8to1,
    AbstractDigitalSelectorNto1, AbstractDigitalSelector1toN,
    AbstractAndOr4x2, AbstractAndOr4x3, AbstractAndOr4x4,
    AbstractDigitalDemux2to4, AbstractDigitalDemux3to8, AbstractDigitalDemux4to16,
    AbstractHalfAdder1Bit, AbstractFullAdder1Bit, AbstractFullAdder2Bit,
    AbstractPad2Bit, AbstractPad3Bit, AbstractPad4Bit,
    AbstractBinaryToGrey4Bit, AbstractGreyToBinary4Bit,
    AbstractComparator1Bit, AbstractComparator2Bit, AbstractComparator4Bit,
    AbstractHighPriorityBinary4Bit
abstract type AbstractDFlipFlopSR <: AbstractDigitalComponent end
abstract type AbstractTFlipFlopSR <: AbstractDigitalComponent end
abstract type AbstractJKFlipFlopSR <: AbstractDigitalComponent end
abstract type AbstractGatedDLatch <: AbstractDigitalComponent end
abstract type AbstractLogicOne <: AbstractDigitalComponent end
abstract type AbstractLogicZero <: AbstractDigitalComponent end
abstract type AbstractMux2to1 <: AbstractDigitalComponent end
abstract type AbstractMux4to1 <: AbstractDigitalComponent end
abstract type AbstractMux8to1 <: AbstractDigitalComponent end
abstract type AbstractDigitalSelectorNto1 <: AbstractDigitalComponent end
abstract type AbstractDigitalSelector1toN <: AbstractDigitalComponent end
abstract type AbstractAndOr4x2 <: AbstractDigitalComponent end
abstract type AbstractAndOr4x3 <: AbstractDigitalComponent end
abstract type AbstractAndOr4x4 <: AbstractDigitalComponent end
abstract type AbstractDigitalDemux2to4 <: AbstractDigitalComponent end
abstract type AbstractDigitalDemux3to8 <: AbstractDigitalComponent end
abstract type AbstractDigitalDemux4to16 <: AbstractDigitalComponent end
abstract type AbstractHalfAdder1Bit <: AbstractDigitalComponent end
abstract type AbstractFullAdder1Bit <: AbstractDigitalComponent end
abstract type AbstractFullAdder2Bit <: AbstractDigitalComponent end
abstract type AbstractPad2Bit <: AbstractDigitalComponent end
abstract type AbstractPad3Bit <: AbstractDigitalComponent end
abstract type AbstractPad4Bit <: AbstractDigitalComponent end
abstract type AbstractBinaryToGrey4Bit <: AbstractDigitalComponent end
abstract type AbstractGreyToBinary4Bit <: AbstractDigitalComponent end
abstract type AbstractComparator1Bit <: AbstractDigitalComponent end
abstract type AbstractComparator2Bit <: AbstractDigitalComponent end
abstract type AbstractComparator4Bit <: AbstractDigitalComponent end
abstract type AbstractHighPriorityBinary4Bit <: AbstractDigitalComponent end

# External interface
export AbstractExternalControlledVoltageSource
abstract type AbstractExternalControlledVoltageSource <: AbstractExternalInterface end


# SPICE-specific abstract kinds

abstract type AbstractBehavioralSource <: ::AbstractActiveComponent end
abstract type AbstractBehavioralVoltageSource <: AbstractBehavioralSource end
abstract type AbstractBehavioralCurrentSource <: AbstractBehavioralSource end

abstract type AbstractSubcircuitInstance <: ::AbstractComponent end
abstract type AbstractSubcircuitDeclaration <: ::AbstractComponent end
abstract type AbstractModelDeclaration <: ::AbstractComponent end

abstract type AbstractIncludeDirective <: ::AbstractComponent end
abstract type AbstractParameterDirective <: ::AbstractComponent end
abstract type AbstractOptionDirective <: ::AbstractComponent end

abstract type AbstractMOSFETModel <: ::AbstractActiveComponent end
abstract type AbstractMOSFETLevel <: AbstractMOSFETModel end
abstract type AbstractBSIMModel <: AbstractMOSFETLevel end
abstract type AbstractEKVModel <: AbstractMOSFETLevel end

abstract type AbstractMutualCouplingByK <: ::AbstractPassiveComponent end

abstract type AbstractVoltageControlledSwitch <: ::AbstractActiveComponent end
abstract type AbstractCurrentControlledSwitch <: ::AbstractActiveComponent end

abstract type AbstractTransmissionLineSPICE <: ::AbstractTransmissionLine end