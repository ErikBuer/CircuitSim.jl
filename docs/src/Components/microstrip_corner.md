# Microstrip Corner

90° microstrip bend.

## Parameters

- `w`: Line width in meters, default: 1e-3
- `substrate`: Substrate reference name, default: "Subst1"

## Model Validity

- 0.2 ≤ W/h ≤ 6.0
- 2.36 ≤ εᵣ ≤ 10.4
- freq·h ≤ 12 MHz

## Example

```@example microstrip_corner
using CircuitSim

# Default substrate reference
corner1 = MicrostripCorner("CORNER1", w=1e-3)

# Custom substrate reference
corner2 = MicrostripCorner("CORNER2", w=2.5e-3, substrate="Sub1")
```