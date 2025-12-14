# Tunnel Diode

## Example

DC analysis of tunnel diode with series resistor.

```@example tunnel_diode
using CircuitSim

# Create circuit
circ = Circuit()

# DC voltage source
vin = DCVoltageSource("VIN", 0.5)
rtd = TunnelDiode("RTD1", Ip=4e-3, Iv=0.6e-3, Vv=0.8)
rs = Resistor("RS", 100)  # Series resistor
gnd = Ground("GND")

add_component!(circ, vin)
add_component!(circ, rtd)
add_component!(circ, rs)
add_component!(circ, gnd)

# Connect: vin+ -> RS -> RTD anode, RTD cathode -> gnd
@connect circ vin.nplus rs.n1
@connect circ rs.n2 rtd.anode
@connect circ rtd.cathode gnd.n
@connect circ vin.nminus gnd.n

# Run DC analysis
analysis = DCAnalysis()
result = simulate_qucsator(circ, analysis)

# Get voltages (node names are assigned by circuit analysis)
v_anode = get_node_voltage(result, "_net2")  # RTD anode connected to RS.n2
v_drop = v_anode  # Cathode at ground = 0V

println("Tunnel diode DC operating point:")
println("  Anode voltage: $(round(v_anode, digits=3)) V")
println("  Voltage drop: $(round(v_drop, digits=3)) V")
```
