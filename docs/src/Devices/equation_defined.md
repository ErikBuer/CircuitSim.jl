# Equation Defined Device (EDD)

An equation-defined device allows you to create custom circuit components by specifying current (I) and charge (Q) equations for each branch. This powerful feature enables modeling of arbitrary nonlinear and dynamic circuit elements.

## Overview

The EDD is a variable-terminal device that can have 1 to 20 branches (2 to 40 nodes). Each branch requires:
- **Current equation (I)**: Defines the branch current as a function of voltages
- **Charge equation (Q)**: Defines the stored charge for dynamic behavior

The simulator automatically computes conductances (dI/dV) and capacitances (dQ/dV) through symbolic differentiation.

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | String | Yes | Component identifier |
| `num_branches` | Int | Yes | Number of branches (1-20) |
| `I_equations` | Dict{Int, String} | Yes | Current equations for each branch |
| `Q_equations` | Dict{Int, String} | Yes | Charge equations for each branch |

## Equation Variables

In your equations, you can reference:
- `V1`, `V2`, ..., `Vn` - Branch voltages
- `I1`, `I2`, ..., `In` - Branch currents (in current equations only)
- Mathematical functions: `sin`, `cos`, `exp`, `log`, `sqrt`, etc.
- Arithmetic operators: `+`, `-`, `*`, `/`, `^`

## Aliases

`EDD` is available as an alias for `EquationDefinedDevice`.

## Examples

### Simple Resistor

```@example
using CircuitSim

I_eqs = Dict{Int, String}(
    1 => "V1 / 1000"  # I = V/R, R=1kΩ
)
Q_eqs = Dict{Int, String}(
    1 => "0"  # No charge storage
)

edd = EquationDefinedDevice("resistor_edd", num_branches=1, 
                           I_equations=I_eqs, 
                           Q_equations=Q_eqs)

edd.nodes[1] = 1
edd.nodes[2] = 0

println(to_qucs_netlist(edd))
```

### Nonlinear Capacitor

```@example
using CircuitSim

I_eqs = Dict{Int, String}(
    1 => "0"  # No DC current
)
Q_eqs = Dict{Int, String}(
    1 => "1e-12 * V1 * (1 + 0.5 * V1)"  # Q = C0*V*(1 + α*V)
)

edd = EquationDefinedDevice("varactor", num_branches=1,
                           I_equations=I_eqs,
                           Q_equations=Q_eqs)

edd.nodes[1] = 1
edd.nodes[2] = 0

println(to_qucs_netlist(edd))
```

### Two-Branch Device

```@example
using CircuitSim

I_eqs = Dict{Int, String}(
    1 => "V1 / 100",      # Branch 1: 100Ω
    2 => "V2 / 200"       # Branch 2: 200Ω
)
Q_eqs = Dict{Int, String}(
    1 => "1e-9 * V1",     # Branch 1: 1nF
    2 => "2e-9 * V2"      # Branch 2: 2nF
)

edd = EquationDefinedDevice("coupled", num_branches=2,
                           I_equations=I_eqs,
                           Q_equations=Q_eqs)

edd.nodes[1] = 1
edd.nodes[2] = 0
edd.nodes[3] = 2
edd.nodes[4] = 0

println(to_qucs_netlist(edd))
```

## Notes

- The EDD uses automatic differentiation to compute Jacobian matrices
- Both I and Q equations must be provided for each branch
- Equation syntax follows standard mathematical notation
- For DC-only devices, set Q equations to "0"
- For purely capacitive elements, set I equations to "0"
- Node numbering: each branch uses 2 consecutive nodes (branch i uses nodes 2i-1 and 2i)
