# BJT (Bipolar Junction Transistor)

A bipolar junction transistor is a three-terminal semiconductor device that can amplify current or switch signals. It consists of two PN junctions forming either an NPN or PNP structure.

## Terminals

- `base` - Control terminal
- `collector` - High-current terminal
- `emitter` - Low-current terminal (reference)
- `substrate` - Substrate/bulk connection

## Parameters

### Essential Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `name` | String | required | Component identifier |
| `Type` | String | "npn" | Transistor type: "npn" or "pnp" |
| `Is` | Real | 1e-15 | Transport saturation current (A) |
| `Bf` | Real | 100 | Ideal maximum forward beta |
| `Nf` | Real | 1.0 | Forward emission coefficient |
| `Nr` | Real | 1.0 | Reverse emission coefficient |
| `Br` | Real | 1.0 | Ideal maximum reverse beta |

### Forward/Reverse Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Ikf` | Real | 0 | Forward beta high current roll-off knee current (A) |
| `Ikr` | Real | 0 | Reverse beta high current roll-off knee current (A) |
| `Vaf` | Real | 0 | Forward Early voltage (V) |
| `Var` | Real | 0 | Reverse Early voltage (V) |
| `Ise` | Real | 0 | Base-emitter leakage saturation current (A) |
| `Ne` | Real | 1.5 | Base-emitter leakage emission coefficient |
| `Isc` | Real | 0 | Base-collector leakage saturation current (A) |
| `Nc` | Real | 2.0 | Base-collector leakage emission coefficient |

### Resistance Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Rb` | Real | 0 | Zero bias base resistance (Ω) |
| `Rbm` | Real | 0 | Minimum base resistance (Ω) |
| `Irb` | Real | 0 | Current at which Rb falls to half of Rbm (A) |
| `Rc` | Real | 0 | Collector ohmic resistance (Ω) |
| `Re` | Real | 0 | Emitter ohmic resistance (Ω) |

### Junction Capacitance Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Cje` | Real | 0 | Base-emitter zero-bias depletion capacitance (F) |
| `Vje` | Real | 0.75 | Base-emitter built-in potential (V) |
| `Mje` | Real | 0.33 | Base-emitter junction grading coefficient |
| `Cjc` | Real | 0 | Base-collector zero-bias depletion capacitance (F) |
| `Vjc` | Real | 0.75 | Base-collector built-in potential (V) |
| `Mjc` | Real | 0.33 | Base-collector junction grading coefficient |
| `Xcjc` | Real | 1.0 | Fraction of Cjc connected internal to Rb |
| `Cjs` | Real | 0 | Substrate zero-bias depletion capacitance (F) |
| `Vjs` | Real | 0.75 | Substrate built-in potential (V) |
| `Mjs` | Real | 0.0 | Substrate junction grading coefficient |
| `Fc` | Real | 0.5 | Forward bias depletion capacitance coefficient |

### Transit Time Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Tf` | Real | 0 | Ideal forward transit time (s) |
| `Xtf` | Real | 0 | Coefficient for bias dependence of Tf |
| `Vtf` | Real | 0 | Voltage describing Vbc dependence of Tf (V) |
| `Itf` | Real | 0 | High current parameter for Tf (A) |
| `Tr` | Real | 0 | Ideal reverse transit time (s) |
| `Ptf` | Real | 0 | Excess phase at 1/(2π·Tf) Hz (deg) |

### Noise Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Kf` | Real | 0 | Flicker noise coefficient |
| `Af` | Real | 1.0 | Flicker noise exponent |
| `Ffe` | Real | 1.0 | Flicker noise frequency exponent |
| `Kb` | Real | 0 | Burst noise coefficient |
| `Ab` | Real | 1.0 | Burst noise exponent |
| `Fb` | Real | 1.0 | Burst noise frequency exponent |

### Temperature Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Temp` | Real | 26.85 | Device temperature (°C) |
| `Tnom` | Real | 26.85 | Nominal temperature (°C) |
| `Xtb` | Real | 0 | Forward/reverse beta temperature coefficient |
| `Xti` | Real | 3.0 | Is temperature effect exponent |
| `Eg` | Real | 1.11 | Energy gap (eV) |

### Geometry

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Area` | Real | 1.0 | Area scaling factor |

## Example

```@example
using CircuitSim

circ = Circuit()

q1 = BJT("q1", Type="npn", Bf=100, Is=1e-15)
vcc = DCVoltageSource("vcc", 12.0)
vb = DCVoltageSource("vb", 0.7)
rc = Resistor("rc", 1000.0)
rb = Resistor("rb", 10000.0)
gnd = Ground("gnd")

add_component!(circ, q1)
add_component!(circ, vcc)
add_component!(circ, vb)
add_component!(circ, rc)
add_component!(circ, rb)
add_component!(circ, gnd)

@connect circ vcc.nplus rc.n1
@connect circ rc.n2 q1.collector
@connect circ q1.emitter gnd.n
@connect circ q1.substrate gnd.n
@connect circ vb.nplus rb.n1
@connect circ rb.n2 q1.base
@connect circ vb.nminus gnd.n
@connect circ vcc.nminus gnd.n

println("Circuit netlist:")
println(netlist_qucs(circ))
```

This common-emitter configuration demonstrates basic BJT amplification. With VBE ≈ 0.7V, the transistor should be in active mode with collector current IC = β·IB flowing through RC.
