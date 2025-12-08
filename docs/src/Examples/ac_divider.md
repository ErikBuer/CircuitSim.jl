# AC Analysis - Capacitor Divider

```@example ac_divider
using CircuitSim
using Printf

# 1V AC source with capacitor divider (1nF and 2nF)
V = ACVoltageSource("V1", 1.0)
C1 = Capacitor("C1", 1e-9)   # 1 nF
C2 = Capacitor("C2", 2e-9)   # 2 nF
GND = Ground("GND")

circ = Circuit()
add_component!(circ, V)
add_component!(circ, C1)
add_component!(circ, C2)
add_component!(circ, GND)

@connect circ V.nplus C1.n1
@connect circ C1.n2 C2.n1
@connect circ C2.n2 GND
@connect circ V.nminus GND

# AC sweep from 1 MHz to 100 MHz
result = simulate_qucsator(circ, ACAnalysis(1e6, 100e6, 10))

# Read voltages across components
v_c1 = get_voltage_across(result, C1, :n1, :n2)
v_c2 = get_voltage_across(result, C2, :n1, :n2)
freqs = result.frequencies_Hz

println("Capacitor Divider (1V AC, C1=1nF, C2=2nF):")
println("Frequency (MHz) | |V_C1| (V) | |V_C2| (V) | Ratio")
println("-" * "="^50)
for i in [1, 5, 10]
    f_MHz = freqs[i] / 1e6
    mag_c1 = abs(v_c1[i])
    mag_c2 = abs(v_c2[i])
    ratio = mag_c2 / (mag_c1 + mag_c2)
    println(@sprintf("%14.2f | %10.4f | %10.4f | %.3f", f_MHz, mag_c1, mag_c2, ratio))
end
println("\nExpected ratio C1/(C1+C2) = ", round(1e-9/(1e-9+2e-9), digits=3))
```
