# Triac

A triac (triode for alternating current) is a bidirectional thyristor that can conduct current in either direction when triggered. It's widely used for AC power control applications.

## Terminals

- `t1` - Terminal 1 (bidirectional)
- `gate` - Control terminal
- `t2` - Terminal 2 (bidirectional)

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `name` | String | required | Component identifier |
| `Vbo` | Real | 30 | Breakover voltage (V) |
| `Cj0` | Real | 1e-11 | Zero-bias junction capacitance (F) |
| `Is` | Real | 1e-10 | Saturation current (A) |
| `N` | Real | 2 | Emission coefficient |
| `Ri` | Real | 10 | Intrinsic region resistance (Ω) |
| `Rg` | Real | 5 | Gate resistance (Ω) |
| `Temp` | Real | 26.85 | Temperature (°C) |

## Example

```@example
using CircuitSim

circ = Circuit()

triac = Triac("triac1", Vbo=30)
vt = DCVoltageSource("vt", 20.0)
vg = DCVoltageSource("vg", 0.15)
rg = Resistor("rg", 1000.0)
gnd = Ground("gnd")

add_component!(circ, triac)
add_component!(circ, vt)
add_component!(circ, vg)
add_component!(circ, rg)
add_component!(circ, gnd)

@connect circ vt.nplus triac.t1
@connect circ triac.t2 gnd.n
@connect circ vg.nplus rg.n1
@connect circ rg.n2 triac.gate
@connect circ vg.nminus gnd.n
@connect circ vt.nminus gnd.n

println(netlist_qucs(circ))
```

The triac conducts when triggered by the gate signal, allowing bidirectional current flow. Unlike a thyristor, it can be triggered in either polarity.
