"""
High-level simulation result access interface.

Provides SimulationResult wrapper for easy access to voltages and currents by component.
"""

"""
    SimulationResult

High-level wrapper around QucsDataset that provides easy access to 
voltage and current at component pins.

# Example
```julia
result = simulate_qucsator(c, DCAnalysis())
v = voltage(result, R1, :n1)      # Voltage at R1's n1 pin
i = current(result, V1)           # Current through V1
```
"""
struct SimulationResult
    circuit::Circuit
    dataset::QucsDataset
    node_map::Dict{UInt64,Int}  # pin hash -> node number
end

"""
    SimulationResult(circuit::Circuit, dataset::QucsDataset)

Create a SimulationResult from a circuit and parsed dataset.
The circuit must have been assigned nodes (via assign_nodes!).
"""
function SimulationResult(circuit::Circuit, dataset::QucsDataset)
    # Build node map from circuit's internal state
    node_map = Dict{UInt64,Int}()
    for comp in circuit.components
        if comp isa Resistor || comp isa Capacitor || comp isa Inductor
            # Two-terminal components with n1, n2
            node_map[hash((comp, :n1))] = comp.n1
            node_map[hash((comp, :n2))] = comp.n2
        elseif comp isa DCVoltageSource || comp isa ACVoltageSource ||
               comp isa DCCurrentSource || comp isa ACCurrentSource
            node_map[hash((comp, :nplus))] = comp.nplus
            node_map[hash((comp, :nminus))] = comp.nminus
        elseif comp isa Ground
            node_map[hash((comp, :n))] = comp.n
        end
    end
    return SimulationResult(circuit, dataset, node_map)
end

"""
    node_name(node_num::Int) -> String

Convert internal node number to Qucs node name.
"""
function node_name(node_num::Int)::String
    return node_num == 0 ? "gnd" : "_net$node_num"
end

"""
    voltage(result::SimulationResult, component::AbstractCircuitComponent, pin::Symbol) -> Float64

Get the voltage at a specific pin of a component.

# Arguments
- `result`: The simulation result
- `component`: The component (e.g., R1, C1, V1)
- `pin`: The pin symbol (e.g., :n1, :n2, :nplus, :nminus)

# Returns
- Voltage at the pin (real value for DC, first value for multi-point)

# Example
```julia
v = voltage(result, R1, :n1)  # Voltage at R1's first terminal
```
"""
function voltage(result::SimulationResult, component::AbstractCircuitComponent, pin::Symbol)::Float64
    # Get node number for this pin
    node_num = _get_node_number(component, pin)

    if node_num == 0
        return 0.0  # Ground is always 0V
    end

    # Look up in dataset
    var_name = "_net$(node_num).V"

    if haskey(result.dataset.independent_vars, var_name)
        return real(result.dataset.independent_vars[var_name].values[1])
    elseif haskey(result.dataset.dependent_vars, var_name)
        return real(result.dataset.dependent_vars[var_name].values[1])
    else
        error("Voltage at node $node_num (pin $pin of $(component.name)) not found in results. Available: $(list_vectors(result.dataset))")
    end
end

"""
    voltage_vector(result::SimulationResult, component::AbstractCircuitComponent, pin::Symbol) -> Vector{Float64}

Get all voltage values at a specific pin (for sweeps/transient).
"""
function voltage_vector(result::SimulationResult, component::AbstractCircuitComponent, pin::Symbol)::Vector{Float64}
    node_num = _get_node_number(component, pin)

    if node_num == 0
        # Ground - need to determine size from other vectors
        for (_, dv) in result.dataset.independent_vars
            return zeros(Float64, length(dv.values))
        end
        return [0.0]
    end

    var_name = "_net$(node_num).V"
    return get_real_vector(result.dataset, var_name)
end

"""
    current(result::SimulationResult, component::AbstractDCVoltageSource) -> Float64

Get the current through a voltage source.

# Arguments
- `result`: The simulation result  
- `component`: The voltage source component

# Returns
- Current through the source (positive = into positive terminal)

# Example
```julia
i = current(result, V1)  # Current through voltage source V1
```
"""
function current(result::SimulationResult, component::AbstractDCVoltageSource)::Float64
    var_name = "$(component.name).I"

    if haskey(result.dataset.independent_vars, var_name)
        return real(result.dataset.independent_vars[var_name].values[1])
    elseif haskey(result.dataset.dependent_vars, var_name)
        return real(result.dataset.dependent_vars[var_name].values[1])
    else
        error("Current through $(component.name) not found in results. Available: $(list_vectors(result.dataset))")
    end
end

"""
    current(result::SimulationResult, component::AbstractDCCurrentSource) -> Float64

Get the current through a DC current source. For ideal current sources,
this returns the specified source current.

# Arguments
- `result`: The simulation result  
- `component`: The DC current source component

# Returns
- Current through the source (positive = into positive terminal)
"""
function current(result::SimulationResult, component::AbstractDCCurrentSource)::Float64
    var_name = "$(component.name).I"

    if haskey(result.dataset.independent_vars, var_name)
        return real(result.dataset.independent_vars[var_name].values[1])
    elseif haskey(result.dataset.dependent_vars, var_name)
        return real(result.dataset.dependent_vars[var_name].values[1])
    else
        # For ideal current sources, the current is simply the source value
        # (if not explicitly saved in results)
        return component.dc
    end
end

"""
    current(result::SimulationResult, component::AbstractACVoltageSource) -> ComplexF64

Get the current through an AC voltage source.
"""
function current(result::SimulationResult, component::AbstractACVoltageSource)::ComplexF64
    var_name = "$(component.name).I"

    if haskey(result.dataset.independent_vars, var_name)
        return result.dataset.independent_vars[var_name].values[1]
    elseif haskey(result.dataset.dependent_vars, var_name)
        return result.dataset.dependent_vars[var_name].values[1]
    else
        error("Current through $(component.name) not found in results. Available: $(list_vectors(result.dataset))")
    end
end

"""
    current(result::SimulationResult, component::AbstractACCurrentSource) -> ComplexF64

Get the current through an AC current source.
"""
function current(result::SimulationResult, component::AbstractACCurrentSource)::ComplexF64
    var_name = "$(component.name).I"

    if haskey(result.dataset.independent_vars, var_name)
        return result.dataset.independent_vars[var_name].values[1]
    elseif haskey(result.dataset.dependent_vars, var_name)
        return result.dataset.dependent_vars[var_name].values[1]
    else
        # For ideal current sources, return magnitude at 0 phase if not in results
        return complex(component.ac_mag * cosd(component.ac_phase), component.ac_mag * sind(component.ac_phase))
    end
end

"""
    current_vector(result::SimulationResult, component::AbstractDCVoltageSource) -> Vector{Float64}

Get all current values through a voltage source (for sweeps/transient).
"""
function current_vector(result::SimulationResult, component::AbstractDCVoltageSource)::Vector{Float64}
    var_name = "$(component.name).I"
    return get_real_vector(result.dataset, var_name)
end

"""
    current_vector(result::SimulationResult, component::AbstractDCCurrentSource) -> Vector{Float64}

Get all current values through a DC current source (for sweeps/transient).
"""
function current_vector(result::SimulationResult, component::AbstractDCCurrentSource)::Vector{Float64}
    var_name = "$(component.name).I"
    return get_real_vector(result.dataset, var_name)
end

"""
    voltage_between(result::SimulationResult, pin1::Pin, pin2::Pin) -> Float64

Get the voltage difference between two pins: V(pin1) - V(pin2).

This is the most flexible way to measure voltage - you can measure between
any two pins of any components.

# Example
```julia
# Voltage across R1 (from n1 to n2)
v_r1 = voltage_between(result, Pin(R1, :n1), Pin(R2, :n2))

# Voltage from V1+ to ground
v_supply = voltage_between(result, Pin(V1, :nplus), Pin(G, :n))

# Voltage between two different components
v_diff = voltage_between(result, Pin(R1, :n2), Pin(C1, :n1))
```
"""
function voltage_between(result::SimulationResult, pin1::Pin, pin2::Pin)::Float64
    v1 = voltage(result, pin1)
    v2 = voltage(result, pin2)
    return v1 - v2
end

"""
    voltage(result::SimulationResult, p::Pin) -> Float64

Get the voltage at a Pin.

# Example
```julia
v = voltage(result, Pin(R1, :n1))
```
"""
function voltage(result::SimulationResult, p::Pin)::Float64
    return voltage(result, p.comp, p.field)
end

"""
    voltage_vector(result::SimulationResult, p::Pin) -> Vector{Float64}

Get all voltage values at a Pin (for sweeps/transient).
"""
function voltage_vector(result::SimulationResult, p::Pin)::Vector{Float64}
    return voltage_vector(result, p.comp, p.field)
end

"""
    _get_node_number(component::AbstractCircuitComponent, pin::Symbol) -> Int

Get the node number for a component pin.
Must be implemented for each component type in the component's file.
"""
function _get_node_number end

# Fallback for unknown types
function _get_node_number(component::AbstractCircuitComponent, pin::Symbol)::Int
    error("Unknown component type: $(typeof(component))")
end

"""
    has_errors(result::SimulationResult) -> Bool

Check if the simulation had any errors.
"""
function has_errors(result::SimulationResult)::Bool
    return has_errors(result.dataset)
end

"""
    print_summary(result::SimulationResult)

Print a summary of the simulation result.
"""
function print_summary(result::SimulationResult)
    print_summary(result.dataset)
end
