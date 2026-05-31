# Correlated Current-Voltage Noise Source

Correlated current and voltage noise sources with adjustable correlation coefficient.

## Example

```@example current_voltage_noise
using CircuitSim

# Correlated noise source (correlation = 0.7)
ivnoise = CurrentVoltageNoiseSource("IVN1", i1=1e-9, v2=1e-6, c_corr=0.7)

# Load resistors
r1 = Resistor("R1", resistance=1000.0)
r2 = Resistor("R2", resistance=50.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, ivnoise)
add_component!(circ, r1)
add_component!(circ, r2)
add_component!(circ, GND)

# Connect current noise source
@connect circ ivnoise.i1plus r1.n1
@connect circ ivnoise.i1minus GND
@connect circ r1.n2 GND
# Connect voltage noise source
@connect circ ivnoise.v2plus r2.n1
@connect circ ivnoise.v2minus GND
@connect circ r2.n2 GND

# In qucsator, noise is enabled on AC/SP analysis
ac_noise = ACAnalysis(start=1.0, stop=1e6, points=100, sweep_type="log", noise=true)
println(to_qucs_analysis(ac_noise))
```
