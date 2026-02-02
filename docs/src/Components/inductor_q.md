# Inductor with Quality Factor

This example demonstrates the `InductorQ` component, which models an inductor with frequency-dependent losses characterized by a quality factor Q.

```@example indq
using CircuitSim
using GLMakie

# Create circuit for S-parameter analysis
circ = Circuit()

# Two-port configuration: Port1 -> InductorQ -> Port2
port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
port2 = ACPowerSource("P2", port_num=2, impedance=50.0)
add_component!(circ, port1)
add_component!(circ, port2)

ind_q = InductorQ("L1", inductance=100e-9, q=100.0, freq=100e6)
add_component!(circ, ind_q)

# Ground
gnd = Ground("GND")
add_component!(circ, gnd)
```

Connect the inductor in series between the two ports.

```@example indq
# Series connection: Port1 -> Inductor -> Port2
@connect circ port1.nplus ind_q.n1
@connect circ ind_q.n2 port2.nplus

# Ground connections
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd
```

## S-Parameter Analysis

Run S-parameter analysis from 1 MHz to 1000 MHz to characterize the inductor's frequency response.

```@example indq
# S-parameter analysis
sparam = SParameterAnalysis(1e6, 1000e6, 1000,
    sweep_type=LINEAR,
    z0=50.0
)

# Run simulation
sp_result = simulate_qucsator(circ, sparam)
```