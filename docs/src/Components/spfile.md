# S-Parameter File

Load S-parameters from a Touchstone file (.s2p) for black-box modeling.

```julia #TODO make actual example with sp file
using CircuitSim

circ = Circuit()

# Components
port1 = ACPowerSource("P1", 1, impedance=50.0)
port2 = ACPowerSource("P2", 2, impedance=50.0)

# Load S-parameters from file
# Note: Replace with actual path to your .s2p file
spf = SPfile("DUT1", "device.s2p", data_format="rectangular", interpolator="linear")

gnd = Ground("GND")

add_component!(circ, port1)
add_component!(circ, port2)
add_component!(circ, spf)
add_component!(circ, gnd)

# Connect S-parameter file between ports
@connect circ port1.nplus spf.n1
@connect circ spf.n2 port2.nplus
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd

# Note: This example requires an actual .s2p file to run
# The SPfile component allows you to:
# - Load measured or simulated S-parameters
# - Use "rectangular" or "polar" data format
# - Choose "linear" or "cubic" interpolation
# - Set operating temperature
# - Specify DC behavior ("open", "short", "unspecified")

println("SPfile component created: ", spf.name)
println("  File: ", spf.file)
println("  Data format: ", spf.data_format)
println("  Interpolation: ", spf.interpolator)
println("  Temperature: ", spf.temp, " K")
```
