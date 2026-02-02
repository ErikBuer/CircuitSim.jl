# Phase Modulated Voltage Source

A voltage source with phase modulation (PM) based on a control signal.

## Example

```@example voltage_pm
using CircuitSim

# Modulation signal (1 kHz sine wave, 0.5V amplitude)
vmod = ACVoltageSource("Vmod", ac_magnitude=0.5, freq=1e3)

# PM source (1 MHz carrier, phase modulated by node 1)
vpm = VoltagePMSource("PM1", u=1.0, f=1e6, m=1.0)

# Load resistor
rload = Resistor("Rload", resistance=50.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, vmod)
add_component!(circ, vpm)
add_component!(circ, rload)
add_component!(circ, GND)

# Connect modulation source to PM modulation input
@connect circ vmod.nplus vpm.nmod
@connect circ vmod.nminus GND
# Connect PM output to load
@connect circ vpm.nplus rload.nplus
@connect circ vpm.nminus rload.nminus
@connect circ rload.nminus GND

# PM sources require transient analysis with appropriate time resolution
println("PM source configured: carrier=", vpm.f/1e6, " MHz, phase modulation=", vpm.f/1e3, " kHz")
println("For simulation, use TransientAnalysis with sufficient points to capture phase variation")
```
