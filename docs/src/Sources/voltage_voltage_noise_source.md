# Correlated Voltage-Voltage Noise Source

Two voltage noise sources with adjustable correlation coefficient.

## Example

```@example voltage_voltage_noise
using CircuitSim

# Correlated noise source (correlation = 0.8)
vnoise = VoltageVoltageNoiseSource("VVN1", v1=1e-6, v2=1e-6, c_corr=0.8)

# Load resistors to observe noise voltage
r1 = Resistor("R1", resistance=50.0)
r2 = Resistor("R2", resistance=50.0)
GND = Ground("GND")

circ = Circuit()
add_component!(circ, vnoise)
add_component!(circ, r1)
add_component!(circ, r2)
add_component!(circ, GND)

# Connect first noise source
@connect circ vnoise.v1plus r1.n1
@connect circ vnoise.v1minus GND
@connect circ r1.n2 GND
# Connect second noise source
@connect circ vnoise.v2plus r2.n1
@connect circ vnoise.v2minus GND
@connect circ r2.n2 GND

# In qucsator, noise is enabled on AC/SP analysis
ac_noise = ACAnalysis(start=1.0, stop=1e6, points=100, sweep_type="log", noise=true)
println(to_qucs_analysis(ac_noise))
```
