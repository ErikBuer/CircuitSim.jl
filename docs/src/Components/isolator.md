# Isolator

Ideal RF isolator with unidirectional transmission.

## Parameters

- `z1`: Port 1 impedance, default: 50 Ω
- `z2`: Port 2 impedance, default: 50 Ω
- `temp`: Temperature in Celsius, default: 26.85°C

## Example

```@example isolator
using CircuitSim

# Standard 50Ω isolator
iso1 = Isolator("ISO1")

# Isolator with custom port impedances
iso2 = Isolator("ISO2", z1=50.0, z2=75.0)

# Isolator at elevated temperature
iso3 = Isolator("ISO3", temp=85.0)
```