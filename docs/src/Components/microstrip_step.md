# Microstrip Step

Microstrip width step/discontinuity.

## Parameters

- `w1`: Width at port 1 in meters, default: 1e-3
- `w2`: Width at port 2 in meters, default: 1e-3
- `substrate`: Substrate reference name, default: "Subst1"
- `ms_disp_model`: Dispersion model, default: "Kirschning" (options: "Getsinger", "Schneider", "Yamashita", "Kobayashi", "Pramanick", "Hammerstad", "Kirschning")
- `ms_model`: Quasi-static model, default: "Hammerstad" (options: "Wheeler", "Schneider", "Hammerstad")

## Example

```@example microstrip_step
using CircuitSim

circ = Circuit()

sub = Substrate("Sub1", er=4.5, h=1.6e-3, t=35e-6)
add_component!(circ, sub)

port1 = ACPowerSource("P1", port_num=1, impedance=50.0)
port2 = ACPowerSource("P2", port_num=2, impedance=50.0)
add_component!(circ, port1)
add_component!(circ, port2)

STEP = MicrostripStep("STEP1", substrate="Sub1", w1=1e-3, w2=2e-3)
add_component!(circ, STEP)

gnd = Ground("GND")
add_component!(circ, gnd)

@connect circ port1.nplus STEP.n1
@connect circ STEP.n2 port2.nplus
@connect circ port1.nminus gnd
@connect circ port2.nminus gnd

sparam = SParameterAnalysis(start=1e9, stop=10e9, points=100,
    sweep_type="linear",
    z0=50.0
)

result = simulate_qucsator(circ, sparam)
```