#!/usr/bin/env julia
"""
Microstrip component demo - demonstrates microstrip components for RF/microwave design.

This creates a simple microstrip lowpass filter using stepped impedance sections.
"""

using CircuitTypes

println("="^60)
println("Microstrip Components Demo")
println("="^60)

# Define substrate - FR4 for demonstration
println("\n1. Substrate Definition")
println("-"^40)

fr4 = Substrate("FR4",
    er=4.5,      # Relative permittivity
    h=1.6e-3,    # 1.6mm height
    t=35e-6,     # 35µm copper
    tand=0.02    # Loss tangent
)
println("FR4 Substrate: ", to_qucs_netlist(fr4))

# Higher performance Rogers substrate
ro4003c = Substrate("RO4003C",
    er=3.55,
    h=0.508e-3,  # 20 mil
    t=17e-6,     # 0.5 oz copper
    tand=0.0027
)
println("RO4003C Substrate: ", to_qucs_netlist(ro4003c))

# =============================================================================
# Basic Microstrip Components
# =============================================================================

println("\n2. Microstrip Line Segments")
println("-"^40)

# Standard 50Ω line (width depends on substrate)
line_50ohm = MicrostripLine("TL1", fr4, w=3.0e-3, l=25e-3)
println("50Ω Line: ", to_qucs_netlist(line_50ohm))

# High impedance line (narrower)
line_hi_z = MicrostripLine("TL_HI", fr4, w=0.5e-3, l=10e-3)
println("Hi-Z Line: ", to_qucs_netlist(line_hi_z))

# Low impedance line (wider)
line_lo_z = MicrostripLine("TL_LO", fr4, w=8.0e-3, l=10e-3)
println("Lo-Z Line: ", to_qucs_netlist(line_lo_z))

# =============================================================================
# Discontinuities
# =============================================================================

println("\n3. Microstrip Discontinuities")
println("-"^40)

# Width step between high and low impedance
step1 = MicrostripStep("STEP1", fr4, w1=0.5e-3, w2=8.0e-3)
println("Step: ", to_qucs_netlist(step1))

# Corner bend
corner = MicrostripCorner("CORN1", fr4, w=3.0e-3)
println("Corner: ", to_qucs_netlist(corner))

# Mitered bend (better performance than corner)
mitered = MicrostripMiteredBend("BEND1", fr4, w=3.0e-3)
println("Mitered Bend: ", to_qucs_netlist(mitered))

# Series gap (capacitive coupling)
gap = MicrostripGap("GAP1", fr4, w1=3.0e-3, w2=3.0e-3, s=0.1e-3)
println("Gap: ", to_qucs_netlist(gap))

# Open stub end
open_end = MicrostripOpen("OPEN1", fr4, w=3.0e-3)
println("Open End: ", to_qucs_netlist(open_end))

# =============================================================================
# Junctions
# =============================================================================

println("\n4. Microstrip Junctions")
println("-"^40)

# T-junction (for power dividers, stubs)
tee = MicrostripTee("TEE1", fr4, w1=3.0e-3, w2=3.0e-3, w3=3.0e-3)
println("T-Junction: ", to_qucs_netlist(tee))

# Cross junction
cross = MicrostripCross("CROSS1", fr4, w1=3.0e-3, w2=3.0e-3, w3=3.0e-3, w4=3.0e-3)
println("Cross: ", to_qucs_netlist(cross))

# =============================================================================
# Coupled Lines and Couplers
# =============================================================================

println("\n5. Coupled Structures")
println("-"^40)

# Coupled microstrip lines (for filters, couplers)
coupled = MicrostripCoupled("CPL1", fr4, w=1.0e-3, l=20e-3, s=0.2e-3)
println("Coupled Lines: ", to_qucs_netlist(coupled))

# Lange coupler (tight coupling)
lange = MicrostripLange("LANGE1", ro4003c, w=0.15e-3, l=10e-3, s=0.1e-3, n=4)
println("Lange Coupler: ", to_qucs_netlist(lange))

# =============================================================================
# Via and Special Structures
# =============================================================================

println("\n6. Vias and Stubs")
println("-"^40)

# Via to ground
via = MicrostripVia("VIA1", fr4, d=0.3e-3)
println("Via: ", to_qucs_netlist(via))

# Radial stub
radial = MicrostripRadialStub("RSTUB1", fr4, ri=0.5e-3, ro=5.0e-3, alpha=60.0)
println("Radial Stub: ", to_qucs_netlist(radial))

# =============================================================================
# Inductors and Interconnects
# =============================================================================

println("\n7. Inductors and Interconnects")
println("-"^40)

# Spiral inductor
spiral = SpiralInductor("SP1", fr4, w=0.2e-3, s=0.15e-3, di=2e-3, turns=4.5)
println("Spiral Inductor: ", to_qucs_netlist(spiral))

# Bond wire
wire = BondWire("BW1", l=1e-3, d=25e-6, h=0.3e-3)
println("Bond Wire: ", to_qucs_netlist(wire))

# Circular loop
loop = CircularLoop("LOOP1", r=5e-3, w=0.5e-3)
println("Circular Loop: ", to_qucs_netlist(loop))

# =============================================================================
# Build a Simple Stepped Impedance Lowpass Filter
# =============================================================================

println("\n" * "="^60)
println("Building a Stepped Impedance Lowpass Filter")
println("="^60)

# Create circuit
circ = Circuit()

# Define substrate (must be first in netlist)
substrate = Substrate("Sub1", er=4.5, h=1.6e-3, t=35e-6, tand=0.02)

# Port 1 (input power source)
port1 = PowerSource("P1", 1, z0=50.0, power=-30.0, freq=1e9)
add_component!(circ, port1)

# Input 50Ω line
tl_in = MicrostripLine("TL_IN", substrate, w=3.0e-3, l=5e-3)
add_component!(circ, tl_in)

# High-Z section (series inductance)
hi_z_1 = MicrostripLine("HI_Z1", substrate, w=0.5e-3, l=8e-3)
add_component!(circ, hi_z_1)

# Low-Z section (shunt capacitance)
lo_z_1 = MicrostripLine("LO_Z1", substrate, w=10e-3, l=8e-3)
add_component!(circ, lo_z_1)

# High-Z section
hi_z_2 = MicrostripLine("HI_Z2", substrate, w=0.5e-3, l=8e-3)
add_component!(circ, hi_z_2)

# Output 50Ω line
tl_out = MicrostripLine("TL_OUT", substrate, w=3.0e-3, l=5e-3)
add_component!(circ, tl_out)

# Port 2 (output)
port2 = PowerSource("P2", 2, z0=50.0, power=-30.0, freq=1e9)
add_component!(circ, port2)

# Ground
gnd = Ground("GND")
add_component!(circ, gnd)

# Connect: P1 → TL_IN → HI_Z1 → LO_Z1 → HI_Z2 → TL_OUT → P2
connect!(circ, pin(port1, :nplus), pin(tl_in, :n1))
connect!(circ, pin(tl_in, :n2), pin(hi_z_1, :n1))
connect!(circ, pin(hi_z_1, :n2), pin(lo_z_1, :n1))
connect!(circ, pin(lo_z_1, :n2), pin(hi_z_2, :n1))
connect!(circ, pin(hi_z_2, :n2), pin(tl_out, :n1))
connect!(circ, pin(tl_out, :n2), pin(port2, :nplus))

# Ground connections
connect!(circ, pin(port1, :nminus), pin(gnd, :n))
connect!(circ, pin(port2, :nminus), pin(gnd, :n))

# Assign node numbers
assign_nodes!(circ)

# Print netlist
println("\nQucs Netlist:")
println("-"^40)
# Print substrate definition first
println(to_qucs_netlist(substrate))
# Print component netlist
println(netlist_qucs(circ))

println("\n✓ Demo complete!")
println("\nImplemented microstrip components:")
println("  • MicrostripLine - transmission line segment")
println("  • MicrostripCorner - 90° corner")
println("  • MicrostripMiteredBend - mitered 90° bend")
println("  • MicrostripStep - width discontinuity")
println("  • MicrostripOpen - open circuit termination")
println("  • MicrostripGap - series gap")
println("  • MicrostripCoupled - coupled lines (4-port)")
println("  • MicrostripTee - T-junction (3-port)")
println("  • MicrostripCross - cross junction (4-port)")
println("  • MicrostripVia - via to ground")
println("  • MicrostripRadialStub - radial/butterfly stub")
println("  • MicrostripLange - Lange coupler")
println("  • SpiralInductor - planar spiral inductor")
println("  • BondWire - bond wire interconnect")
println("  • CircularLoop - circular loop inductor")
