# Correlated Current-Voltage Noise Source

Correlated current and voltage noise sources with adjustable correlation coefficient.

## Example

```@example current_voltage_noise
using CircuitSim

# Correlated noise source (correlation = 0.7)
ivnoise = CurrentVoltageNoiseSource("IVN1", i1=1e-9, v2=1e-6, c_corr=0.7)

# Load resistors
r1 = Resistor("R1", 1000.0)
r2 = Resistor("R2", 50.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, ivnoise)
add_component!(circ, r1)
add_component!(circ, r2)
add_component!(circ, GND)

# Connect current noise source
@connect circ ivnoise.i1plus r1.nplus
@connect circ ivnoise.i1minus GND
@connect circ r1.nminus GND
# Connect voltage noise source
@connect circ ivnoise.v2plus r2.nplus
@connect circ ivnoise.v2minus GND
@connect circ r2.nminus GND

assign_nodes!(circ)

# Noise analysis
noise_analysis = NoiseAnalysis(1.0, 1e6, 100, "_net1", "IVN1")
result = simulate_qucsator(circ, noise_analysis)

println("Correlated current-voltage noise with correlation = 0.7")
```
