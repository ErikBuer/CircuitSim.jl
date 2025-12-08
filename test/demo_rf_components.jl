"""
Demo script showing usage of RF components in CircuitSim.jl

This demonstrates:
- Quality factor components (CapacitorQ, InductorQ)
- RF building blocks (DCBlock, DCFeed, BiasTee)
- Active components (Amplifier)
- Directional components (Isolator, Circulator)
- Power control (Attenuator, PhaseShifter)
- Power dividers/combiners (Coupler, Hybrid)
"""

using CircuitSim

println("="^70)
println("RF Components Demo")
println("="^70)

# Quality Factor Components

println("\n--- Quality Factor Components ---")

# High-Q capacitor for RF matching
C1 = CapacitorQ("C1", 10e-12, 50.0)  # 10pF, Q=50 at 1 GHz
println("High-Q Capacitor: $(C1.value*1e12) pF, Q=$(C1.q) @ $(C1.freq/1e9) GHz")

# High-Q inductor for RF matching
L1 = InductorQ("L1", 10e-9, 30.0, freq=2.4e9)  # 10nH, Q=30 at 2.4 GHz  
println("High-Q Inductor: $(L1.value*1e9) nH, Q=$(L1.q) @ $(L1.freq/1e9) GHz")

# DC Blocking and Feed

println("\n--- DC Blocking and Feed Components ---")

# DC block for AC coupling between stages
DCB1 = DCBlock("DCB1")
println("DC Block: $(DCB1.value*1e6) μF (blocks DC, passes RF)")

# DC feed for bias insertion
DCF1 = DCFeed("DCF1")
println("DC Feed: $(DCF1.value*1e3) mH (passes DC, blocks RF)")

# Bias Tee for combining DC and RF
BT1 = BiasTee("BT1")
println("Bias Tee: C=$(BT1.c_block*1e6)μF, L=$(BT1.l_choke*1e3)mH")

# Amplifiers

println("\n--- Amplifier Components ---")

# Low noise amplifier
LNA = Amplifier("LNA", 20.0, 1.5)
println("LNA: Gain=$(LNA.gain)dB, NF=$(LNA.nf)dB, Zin=$(LNA.z_in)Ω")

# Power amplifier  
PA = Amplifier("PA", 30.0, 5.0, p1db=30.0)
println("PA: Gain=$(PA.gain)dB, NF=$(PA.nf)dB, P1dB=$(PA.p1db)dBm")

# Directional Components

println("\n--- Directional Components ---")

# Isolator for source protection
ISO1 = Isolator("ISO1")
println("Isolator: Forward Loss=$(ISO1.forward_loss)dB, Isolation=$(ISO1.reverse_loss)dB")

# 3-port circulator
CIRC1 = Circulator("CIRC1", isolation=30.0)
println("Circulator: IL=$(CIRC1.insertion_loss)dB, Isolation=$(CIRC1.isolation)dB")

# Power Control

println("\n--- Power Control Components ---")

# Fixed attenuator
ATT1 = Attenuator("ATT1", 10.0)
println("Attenuator: $(ATT1.attenuation)dB @ $(ATT1.z0)Ω")

# Phase shifter
PS1 = PhaseShifter("PS1", 90.0)
println("Phase Shifter: $(PS1.phase)° shift, IL=$(PS1.insertion_loss)dB")

# Power Dividers/Combiners

println("\n--- Power Dividers/Combiners ---")

# 3dB directional coupler (50/50 split)
DC1 = Coupler("DC1", 3.0)
println("3dB Coupler: $(DC1.coupling)dB coupling, Isolation=$(DC1.isolation)dB")

# 10dB directional coupler (90/10 split)
DC2 = Coupler("DC2", 10.0)
println("10dB Coupler: $(DC2.coupling)dB coupling, Isolation=$(DC2.isolation)dB")

# 90 degree hybrid (quadrature coupler)
HYB1 = Hybrid("HYB1")
println("Quadrature Hybrid: $(HYB1.phase)° phase, IL=$(HYB1.insertion_loss)dB")

# 180 degree hybrid (rat-race)
HYB2 = Hybrid("HYB2", phase=180.0)
println("Rat-Race Hybrid: $(HYB2.phase)° phase, IL=$(HYB2.insertion_loss)dB")

# Simple RF Chain Example

println("\n--- Simple RF Receiver Chain Example ---")

circuit = Circuit()

# Create components
gnd = Ground("GND")
p1 = PowerSource("P1", 1, z0=50.0, power=0.0)  # 0 dBm input
iso = Isolator("ISO")  # Protect source
lna = Amplifier("LNA", 20.0, 1.5)  # 20dB gain, 1.5dB NF
att = Attenuator("ATT", 6.0)  # 6dB pad
p2 = PowerSource("P2", 2, z0=50.0)  # Output port

# Add to circuit
add_component!(circuit, gnd)
add_component!(circuit, p1)
add_component!(circuit, iso)
add_component!(circuit, lna)
add_component!(circuit, att)
add_component!(circuit, p2)

# Connect: Input -> Isolator -> LNA -> Attenuator -> Output
connect!(circuit, pin(p1, :nplus), pin(iso, :n1))
connect!(circuit, pin(iso, :n2), pin(lna, :n1))
connect!(circuit, pin(lna, :n2), pin(att, :n1))
connect!(circuit, pin(att, :n2), pin(p2, :nplus))

# Ground connections
connect!(circuit, pin(p1, :nminus), pin(gnd, :node))
connect!(circuit, pin(p2, :nminus), pin(gnd, :node))

println("\nRF Chain: Input -> Isolator -> LNA(20dB) -> Pad(6dB) -> Output")
println("Expected gain: $(20-6)dB (not including isolator loss)")

# Netlist generation
println("\n--- Qucs Netlist Preview ---")
assign_nodes!(circuit)
netlist = netlist_qucs(circuit)
println(netlist[1:min(500, length(netlist))] * "...")

println("\n" * "="^70)
println("RF Components Demo Complete!")
println("="^70)
