# Correlated Current-Current Noise Source

Two current noise sources with adjustable correlation coefficient.

## Example

```@example current_current_noise
using CircuitSim

# Correlated noise source (correlation = 0.5)
inoise = CurrentCurrentNoiseSource("IIN1", i1=1e-9, i2=1e-9, c_corr=0.5)

# Load resistors to convert current noise to voltage
r1 = Resistor("R1", 1000.0)
r2 = Resistor("R2", 1000.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, inoise)
add_component!(circ, r1)
add_component!(circ, r2)
add_component!(circ, GND)

# Connect first noise source
@connect circ inoise.i1plus r1.nplus
@connect circ inoise.i1minus GND
@connect circ r1.nminus GND
# Connect second noise source
@connect circ inoise.i2plus r2.nplus
@connect circ inoise.i2minus GND
@connect circ r2.nminus GND

# Noise analysis
noise_analysis = NoiseAnalysis(1.0, 1e6, 100, "_net1", "IIN1")
result = simulate_qucsator(circ, noise_analysis)

println("Correlated current noise sources with correlation = 0.5")
```
