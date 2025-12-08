"""
    get_node_voltage(result, node_name::String)

Get voltage at a specific node from simulation results.

# Arguments

- `result`: DCResult, ACResult, or TransientResult
- `node_name::String`: Node name (e.g., "_net1", "_net2")

# Returns

- For DC: Float64 voltage
- For AC: Vector{ComplexF64} voltage vs frequency
- For Transient: Vector{Float64} voltage vs time

# Example

```julia
dc = simulate_qucsator(circ, DCAnalysis())
v_out = get_node_voltage(dc, "_net1")
```
"""
function get_node_voltage(result::Union{DCResult,ACResult,TransientResult}, node_name::String)
    if !haskey(result.voltages, node_name)
        available = sort(collect(keys(result.voltages)))
        error("Node '$node_name' not found. Available nodes: $available")
    end
    return result.voltages[node_name]
end

"""
    get_component_current(result, component_name::String)

Get current through a component from simulation results.

Note: Current direction follows passive sign convention - positive current flows
from the first pin (e.g., nplus, n1) to the second pin (e.g., nminus, n2) internally.

# Arguments

- `result`: DCResult, ACResult, or TransientResult
- `component_name::String`: Component name (e.g., "V1", "R1")

# Returns

- For DC: Float64 current
- For AC: Vector{ComplexF64} current vs frequency
- For Transient: Vector{Float64} current vs time

# Example

```julia
dc = simulate_qucsator(circ, DCAnalysis())
i_source = get_component_current(dc, "V1")
```
"""
function get_component_current(result::Union{DCResult,ACResult,TransientResult}, component_name::String)
    if !haskey(result.currents, component_name)
        available = sort(collect(keys(result.currents)))
        error("Component '$component_name' not found. Available components: $available")
    end
    return result.currents[component_name]
end

"""
    get_pin_current(result, component, pin::Symbol)

Get current flowing INTO a specific pin of a component from the external circuit.

Current direction convention:
- Positive current = current flowing INTO the pin (from external circuit)
- Negative current = current flowing OUT of the pin (to external circuit)

For a voltage source delivering power:
- Current OUT of nplus (to circuit) → get_pin_current returns NEGATIVE
- Current INTO nminus (from circuit) → get_pin_current returns POSITIVE

This follows standard node current convention where currents entering a node are positive.

# Arguments

- `result`: DCResult, ACResult, or TransientResult
- `component`: Component instance (must be a voltage or current source)
- `pin::Symbol`: Pin name (e.g., :nplus, :nminus, :n1, :n2)

# Returns

- For DC: Float64 current (in amperes)
- For AC: Vector{ComplexF64} current vs frequency
- For Transient: Vector{Float64} current vs time

# Example

```julia
V = DCVoltageSource("V1", 10.0)
R = Resistor("R", 100.0)
# ... build circuit: V.nplus -> R -> GND, V.nminus -> GND ...
dc = simulate_qucsator(circ, DCAnalysis())

# For a source delivering 100mA:
i_nplus = get_pin_current(dc, V, :nplus)   # -100mA (current OUT of source)
i_nminus = get_pin_current(dc, V, :nminus) # +100mA (current INTO source)

# Kirchhoff's current law: i_nplus + i_nminus = 0
```

# Note
Only voltage and current sources report currents in qucsator. For other components,
current can be calculated using Ohm's law with voltage and component parameters.
"""
function get_pin_current(result::Union{DCResult,ACResult,TransientResult}, component, pin::Symbol)
    if !haskey(result.currents, component.name)
        error("Current not available for component $(component.name). Only sources report currents in qucsator.")
    end

    # Get the component current (passive sign convention: internal flow from first to second pin)
    i_component = result.currents[component.name]

    # Determine current INTO pin from external circuit
    # Component current is internal: from nplus/n1 to nminus/n2
    # External current INTO pin = opposite of internal current AT that pin

    if hasfield(typeof(component), :nplus) && hasfield(typeof(component), :nminus)
        # Voltage/current sources: nplus and nminus
        if pin == :nplus
            # External current INTO nplus = -internal current OUT of nplus
            # Internal current OUT of nplus = -i_component
            # Therefore: current INTO nplus = -(-i_component) = i_component
            return i_component
        elseif pin == :nminus
            # External current INTO nminus = internal current INTO nminus
            # Internal current INTO nminus = i_component
            # Therefore: current INTO nminus = i_component (but entering from outside)
            # Actually: external INTO nminus = -internal OUT of nminus = -(i_component) 
            return -i_component
        else
            error("Pin $pin not valid for component $(component.name). Use :nplus or :nminus")
        end
    elseif hasfield(typeof(component), :n1) && hasfield(typeof(component), :n2)
        # General two-terminal: n1 and n2
        if pin == :n1
            return i_component
        elseif pin == :n2
            return -i_component
        else
            error("Pin $pin not valid for component $(component.name). Use :n1 or :n2")
        end
    else
        error("Component $(component.name) does not have recognized pin structure")
    end
end

"""
    get_pin_voltage(result, component, pin::Symbol)

Get voltage at a specific pin of a component.

# Arguments

- `result`: DCResult, ACResult, or TransientResult
- `component`: Component instance (e.g., R1, C1)
- `pin::Symbol`: Pin name (e.g., :n1, :n2, :nplus, :nminus)

# Returns

- For DC: Float64 voltage
- For AC: Vector{ComplexF64} voltage
- For Transient: Vector{Float64} voltage vs time

# Example

```julia
R1 = Resistor("R1", 100.0)
# ... build and simulate circuit ...
dc = simulate_qucsator(circ, DCAnalysis())
v_r1_input = get_pin_voltage(dc, R1, :n1)
v_r1_output = get_pin_voltage(dc, R1, :n2)
v_across_r1 = v_r1_input - v_r1_output
```
"""
function get_pin_voltage(result::Union{DCResult,ACResult,TransientResult}, component, pin::Symbol)
    node_num = _get_node_number(component, pin)
    if node_num == 0
        error("Pin $pin of component $(component.name) is not connected")
    end
    node_name = "_net$node_num"
    return get_node_voltage(result, node_name)
end

"""
    get_voltage_across(result, component, pin_pos::Symbol, pin_neg::Symbol)

Get voltage difference across a component (V_pos - V_neg).

# Arguments

- `result`: DCResult, ACResult, or TransientResult
- `component`: Component instance
- `pin_pos::Symbol`: Positive pin name
- `pin_neg::Symbol`: Negative pin name

# Returns

- For DC: Float64 voltage difference
- For AC: Vector{ComplexF64} voltage
- For Transient: Vector{Float64} voltage difference vs time

# Example

```julia
R1 = Resistor("R1", 100.0)
# ... build and simulate circuit ...
dc = simulate_qucsator(circ, DCAnalysis())
v_across_r1 = get_voltage_across(dc, R1, :n1, :n2)
```
"""
function get_voltage_across(result::Union{DCResult,ACResult,TransientResult}, component, pin_pos::Symbol, pin_neg::Symbol)
    v_pos = get_pin_voltage(result, component, pin_pos)
    v_neg = get_pin_voltage(result, component, pin_neg)
    return v_pos .- v_neg
end

"""
    get_component_power(result::DCResult, component, pin_pos::Symbol, pin_neg::Symbol)

Calculate power dissipated in a component for DC analysis (P = V × I).

# Arguments

- `result::DCResult`: DC analysis result
- `component`: Component instance
- `pin_pos::Symbol`: Positive pin name
- `pin_neg::Symbol`: Negative pin name

# Returns

- Float64: Power in watts (positive = dissipated, negative = generated)

# Example

```julia
R1 = Resistor("R1", 100.0)
# ... build and simulate circuit ...
dc = simulate_qucsator(circ, DCAnalysis())
power = get_component_power(dc, R1, :n1, :n2)
```
"""
function get_component_power(result::DCResult, component, pin_pos::Symbol, pin_neg::Symbol)
    v = get_voltage_across(result, component, pin_pos, pin_neg)
    if haskey(result.currents, component.name)
        i = result.currents[component.name]
        return v * i
    else
        error("Current not available for component $(component.name)")
    end
end

"""
    get_probe_voltage(result, probe)

Get voltage measured by a VoltageProbe.

# Arguments

- `result`: DCResult, ACResult, or TransientResult
- `probe`: VoltageProbe instance or probe name as String

# Returns

- For DC: Float64 voltage
- For AC: Vector{ComplexF64} voltage vs frequency
- For Transient: Vector{Float64} voltage vs time

# Example

```julia
VP = VoltageProbe("VP1")
# ... build circuit with probe ...
dc = simulate_qucsator(circ, DCAnalysis())
v_measured = get_probe_voltage(dc, VP)
```
"""
function get_probe_voltage(result::Union{DCResult,ACResult,TransientResult}, probe)
    probe_name = isa(probe, String) ? probe : probe.name
    if !haskey(result.voltages, probe_name)
        available = sort(collect(keys(result.voltages)))
        error("Voltage probe '$probe_name' not found. Available voltages: $available")
    end
    return result.voltages[probe_name]
end

"""
    get_probe_current(result, probe)

Get current measured by a CurrentProbe.

# Arguments

- `result`: DCResult, ACResult, or TransientResult
- `probe`: CurrentProbe instance or probe name as String

# Returns

- For DC: Float64 current
- For AC: Vector{ComplexF64} current vs frequency
- For Transient: Vector{Float64} current vs time

# Example

```julia
IP = CurrentProbe("IP1")
# ... build circuit with probe ...
dc = simulate_qucsator(circ, DCAnalysis())
i_measured = get_probe_current(dc, IP)
```
"""
function get_probe_current(result::Union{DCResult,ACResult,TransientResult}, probe)
    probe_name = isa(probe, String) ? probe : probe.name
    if !haskey(result.currents, probe_name)
        available = sort(collect(keys(result.currents)))
        error("Current probe '$probe_name' not found. Available currents: $available")
    end
    return result.currents[probe_name]
end
