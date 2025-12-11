# Thyristor (SCR)

A silicon-controlled rectifier (SCR) or thyristor is a four-layer, three-terminal semiconductor device that acts as a latching switch. Once triggered by a gate current, it conducts from anode to cathode and remains on until the current drops below the holding current.

## Terminals

- `anode` - Positive terminal
- `gate` - Control terminal
- `cathode` - Negative terminal

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `name` | String | required | Component identifier |
| `Igt` | Real | 50e-6 | Gate trigger current (A) |
| `Vbo` | Real | 30 | Breakover voltage (V) |
| `Cj0` | Real | 1e-11 | Zero-bias junction capacitance (F) |
| `Is` | Real | 1e-10 | Saturation current (A) |
| `N` | Real | 2 | Emission coefficient |
| `Ri` | Real | 10 | Intrinsic region resistance (Ω) |
| `Rg` | Real | 5 | Gate resistance (Ω) |
| `Temp` | Real | 26.85 | Temperature (°C) |

## Aliases

`SCR` is available as an alias for `Thyristor`.

## Example

```@example
using CircuitSim

circ = Circuit()

scr = Thyristor("scr1", Igt=50e-6, Vbo=30)
vak = DCVoltageSource("vak", 20.0)
vg = DCVoltageSource("vg", 0.15)
rg = Resistor("rg", 1000.0)
gnd = Ground("gnd")

add_component!(circ, scr)
add_component!(circ, vak)
add_component!(circ, vg)
add_component!(circ, rg)
add_component!(circ, gnd)

@connect circ vak.nplus scr.anode
@connect circ scr.cathode gnd.n
@connect circ vg.nplus rg.n1
@connect circ rg.n2 scr.gate
@connect circ vg.nminus gnd.n
@connect circ vak.nminus gnd.n

println(netlist_qucs(circ))
```

The thyristor conducts when the gate current exceeds Igt, clamping the anode-cathode voltage to a low value determined by the device's on-state characteristics.
