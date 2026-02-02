# Amplitude Modulated Voltage Source

A voltage source with amplitude modulation (AM) based on a control signal.

## Example

```@example voltage_am
using CircuitSim

# Modulation signal (1 kHz sine wave, 0.5V amplitude)
vmod = ACVoltageSource("Vmod", ac_magnitude=0.5, freq=1e3)

# AM source (1 MHz carrier, modulated by node 1)
vam = VoltageAMSource("AM1", u=1.0, f=1e6, m=1.0)

# Load resistor
rload = Resistor("Rload", resistance=50.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, vmod)
add_component!(circ, vam)
add_component!(circ, rload)
add_component!(circ, GND)

# Connect modulation source to AM modulation input
@connect circ vmod.nplus vam.nmod
@connect circ vmod.nminus GND
# Connect AM output to load
@connect circ vam.nplus rload.nplus
@connect circ vam.nminus rload.nminus
@connect circ rload.nminus GND

# AM sources require transient analysis with appropriate time resolution
println("AM source configured: carrier=", vam.f/1e6, " MHz, modulation=", vam.f/1e3, " kHz")
println("For simulation, use TransientAnalysis with sufficient points to capture modulation")
```
