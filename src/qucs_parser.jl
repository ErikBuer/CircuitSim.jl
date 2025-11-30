# Parser for Qucs dataset output format
# Format: <Qucs Dataset VERSION>
#         <indep name size> ... values ... </indep>
#         <dep name dep1 dep2 ...> ... values ... </dep>

"""
Result status from a simulation run
"""
@enum SimulationStatus begin
    SIM_SUCCESS = 0
    SIM_ERROR = 1
    SIM_PARSE_ERROR = 2
    SIM_NOT_RUN = 3
end

"""
Represents a data vector from simulation output
"""
struct DataVector
    name::String
    values::Vector{ComplexF64}
    dependencies::Vector{String}
    is_independent::Bool
end

"""
Parsed simulation result containing all vectors and metadata
"""
struct QucsDataset
    status::SimulationStatus
    version::String
    independent_vars::Dict{String,DataVector}
    dependent_vars::Dict{String,DataVector}
    errors::Vector{String}
    warnings::Vector{String}
    raw_output::String
end

"""
    parse_qucs_value(s::AbstractString) -> ComplexF64

Parse a single value from Qucs dataset format.
Handles real values like `+1.234e+00` and complex values like `+1.234e+00+j5.678e-01`
"""
function parse_qucs_value(s::AbstractString)::ComplexF64
    s = strip(s)
    isempty(s) && return ComplexF64(0.0, 0.0)

    # Check for complex number with 'j' notation
    # Format: +1.234e+00+j5.678e-01 or +1.234e+00-j5.678e-01
    j_pos = findfirst(r"[+-]j", s)

    if j_pos !== nothing
        # Complex number
        real_part_str = s[1:first(j_pos)-1]
        imag_part_str = s[first(j_pos):end]

        # Remove the 'j' from imaginary part
        imag_part_str = replace(imag_part_str, "j" => "")

        real_part = parse(Float64, real_part_str)
        imag_part = parse(Float64, imag_part_str)

        return ComplexF64(real_part, imag_part)
    else
        # Real number only
        return ComplexF64(parse(Float64, s), 0.0)
    end
end

"""
    parse_qucs_dataset(output::AbstractString) -> QucsDataset

Parse the Qucs dataset format output from qucsator_rf.
Returns a QucsDataset containing all parsed vectors and status information.
"""
function parse_qucs_dataset(output::AbstractString)::QucsDataset
    lines = split(output, '\n')

    independent_vars = Dict{String,DataVector}()
    dependent_vars = Dict{String,DataVector}()
    errors = String[]
    warnings = String[]
    version = ""
    status = SIM_SUCCESS

    # Check for empty output
    if isempty(strip(output))
        return QucsDataset(SIM_PARSE_ERROR, "", independent_vars, dependent_vars,
            ["Empty output received"], warnings, output)
    end

    # State machine for parsing
    current_vector_name = ""
    current_vector_values = ComplexF64[]
    current_dependencies = String[]
    in_indep_block = false
    in_dep_block = false
    expected_size = 0

    for (line_num, line) in enumerate(lines)
        stripped = strip(line)
        isempty(stripped) && continue

        # Check for version header
        version_match = match(r"<Qucs Dataset ([^>]+)>", stripped)
        if version_match !== nothing
            version = version_match.captures[1]
            continue
        end

        # Check for error messages (stderr output mixed in)
        if startswith(lowercase(stripped), "error") ||
           startswith(lowercase(stripped), "fatal") ||
           occursin("error:", lowercase(stripped))
            push!(errors, stripped)
            status = SIM_ERROR
            continue
        end

        # Check for warning messages
        if startswith(lowercase(stripped), "warning") ||
           occursin("warning:", lowercase(stripped))
            push!(warnings, stripped)
            continue
        end

        # Check for independent variable block start: <indep name size>
        indep_match = match(r"<indep\s+(\S+)\s+(\d+)>", stripped)
        if indep_match !== nothing
            current_vector_name = indep_match.captures[1]
            expected_size = parse(Int, indep_match.captures[2])
            current_vector_values = ComplexF64[]
            current_dependencies = String[]
            in_indep_block = true
            in_dep_block = false
            continue
        end

        # Check for dependent variable block start: <dep name dep1 dep2 ...>
        dep_match = match(r"<dep\s+(\S+)(.*)>", stripped)
        if dep_match !== nothing
            current_vector_name = dep_match.captures[1]
            deps_str = strip(dep_match.captures[2])
            current_dependencies = isempty(deps_str) ? String[] : split(deps_str)
            current_vector_values = ComplexF64[]
            in_dep_block = true
            in_indep_block = false
            continue
        end

        # Check for block end tags
        if stripped == "</indep>"
            if in_indep_block && !isempty(current_vector_name)
                dv = DataVector(current_vector_name, copy(current_vector_values),
                    String[], true)
                independent_vars[current_vector_name] = dv

                # Validate size
                if length(current_vector_values) != expected_size
                    push!(warnings, "Vector '$current_vector_name' has $(length(current_vector_values)) values, expected $expected_size")
                end
            end
            in_indep_block = false
            current_vector_name = ""
            current_vector_values = ComplexF64[]
            continue
        end

        if stripped == "</dep>"
            if in_dep_block && !isempty(current_vector_name)
                dv = DataVector(current_vector_name, copy(current_vector_values),
                    copy(current_dependencies), false)
                dependent_vars[current_vector_name] = dv
            end
            in_dep_block = false
            current_vector_name = ""
            current_vector_values = ComplexF64[]
            current_dependencies = String[]
            continue
        end

        # Parse data values inside blocks
        if (in_indep_block || in_dep_block) && !startswith(stripped, "<")
            try
                val = parse_qucs_value(stripped)
                push!(current_vector_values, val)
            catch e
                push!(warnings, "Failed to parse value at line $line_num: '$stripped'")
            end
        end
    end

    # If we found no version and no data, something went wrong
    if isempty(version) && isempty(independent_vars) && isempty(dependent_vars)
        if isempty(errors)
            push!(errors, "No valid Qucs dataset found in output")
        end
        status = SIM_PARSE_ERROR
    end

    return QucsDataset(status, version, independent_vars, dependent_vars,
        errors, warnings, output)
end

"""
    get_real_vector(dataset::QucsDataset, name::String) -> Vector{Float64}

Extract real parts of a named vector from the dataset.
"""
function get_real_vector(dataset::QucsDataset, name::String)::Vector{Float64}
    if haskey(dataset.independent_vars, name)
        return real.(dataset.independent_vars[name].values)
    elseif haskey(dataset.dependent_vars, name)
        return real.(dataset.dependent_vars[name].values)
    else
        error("Vector '$name' not found in dataset")
    end
end

"""
    get_imag_vector(dataset::QucsDataset, name::String) -> Vector{Float64}

Extract imaginary parts of a named vector from the dataset.
"""
function get_imag_vector(dataset::QucsDataset, name::String)::Vector{Float64}
    if haskey(dataset.independent_vars, name)
        return imag.(dataset.independent_vars[name].values)
    elseif haskey(dataset.dependent_vars, name)
        return imag.(dataset.dependent_vars[name].values)
    else
        error("Vector '$name' not found in dataset")
    end
end

"""
    get_complex_vector(dataset::QucsDataset, name::String) -> Vector{ComplexF64}

Get the complex values of a named vector from the dataset.
"""
function get_complex_vector(dataset::QucsDataset, name::String)::Vector{ComplexF64}
    if haskey(dataset.independent_vars, name)
        return dataset.independent_vars[name].values
    elseif haskey(dataset.dependent_vars, name)
        return dataset.dependent_vars[name].values
    else
        error("Vector '$name' not found in dataset")
    end
end

"""
    list_vectors(dataset::QucsDataset) -> Vector{String}

List all vector names in the dataset.
"""
function list_vectors(dataset::QucsDataset)::Vector{String}
    return vcat(collect(keys(dataset.independent_vars)),
        collect(keys(dataset.dependent_vars)))
end

"""
    has_errors(dataset::QucsDataset) -> Bool

Check if the simulation had any errors.
"""
function has_errors(dataset::QucsDataset)::Bool
    return dataset.status != SIM_SUCCESS || !isempty(dataset.errors)
end

"""
    print_summary(dataset::QucsDataset)

Print a summary of the dataset contents.
"""
function print_summary(dataset::QucsDataset)
    println("Qucs Dataset Summary")
    println("="^40)
    println("Status: $(dataset.status)")
    println("Version: $(dataset.version)")
    println()

    if !isempty(dataset.errors)
        println("Errors:")
        for err in dataset.errors
            println("  ✗ $err")
        end
        println()
    end

    if !isempty(dataset.warnings)
        println("Warnings:")
        for warn in dataset.warnings
            println("  ⚠ $warn")
        end
        println()
    end

    println("Independent Variables ($(length(dataset.independent_vars))):")
    for (name, dv) in dataset.independent_vars
        println("  • $name: $(length(dv.values)) points")
    end
    println()

    println("Dependent Variables ($(length(dataset.dependent_vars))):")
    for (name, dv) in dataset.dependent_vars
        deps_str = isempty(dv.dependencies) ? "" : " [deps: $(join(dv.dependencies, ", "))]"
        println("  • $name: $(length(dv.values)) points$deps_str")
    end
end

# =============================================================================
# SimulationResult - High-level interface for accessing results by component
# =============================================================================

"""
    SimulationResult

High-level wrapper around QucsDataset that provides easy access to 
voltage and current at component pins.

# Example
```julia
result = simulate(c, [".DC:DC1 saveOPs=\"yes\""])
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
        elseif comp isa DCVoltageSource
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

# Helper function to get node number from component and pin
# Uses multiple dispatch for type-safe pin access
function _get_node_number(component::Resistor, pin::Symbol)::Int
    if pin == :n1
        return component.n1
    elseif pin == :n2
        return component.n2
    else
        error("Invalid pin $pin for Resistor. Use :n1 or :n2")
    end
end

function _get_node_number(component::Capacitor, pin::Symbol)::Int
    if pin == :n1
        return component.n1
    elseif pin == :n2
        return component.n2
    else
        error("Invalid pin $pin for Capacitor. Use :n1 or :n2")
    end
end

function _get_node_number(component::Inductor, pin::Symbol)::Int
    if pin == :n1
        return component.n1
    elseif pin == :n2
        return component.n2
    else
        error("Invalid pin $pin for Inductor. Use :n1 or :n2")
    end
end

function _get_node_number(component::DCVoltageSource, pin::Symbol)::Int
    if pin == :nplus
        return component.nplus
    elseif pin == :nminus
        return component.nminus
    else
        error("Invalid pin $pin for DCVoltageSource. Use :nplus or :nminus")
    end
end

function _get_node_number(component::ACVoltageSource, pin::Symbol)::Int
    if pin == :nplus
        return component.nplus
    elseif pin == :nminus
        return component.nminus
    else
        error("Invalid pin $pin for ACVoltageSource. Use :nplus or :nminus")
    end
end

function _get_node_number(component::DCCurrentSource, pin::Symbol)::Int
    if pin == :nplus
        return component.nplus
    elseif pin == :nminus
        return component.nminus
    else
        error("Invalid pin $pin for DCCurrentSource. Use :nplus or :nminus")
    end
end

function _get_node_number(component::ACCurrentSource, pin::Symbol)::Int
    if pin == :nplus
        return component.nplus
    elseif pin == :nminus
        return component.nminus
    else
        error("Invalid pin $pin for ACCurrentSource. Use :nplus or :nminus")
    end
end

function _get_node_number(component::Ground, pin::Symbol)::Int
    if pin == :n
        return component.n
    else
        error("Invalid pin $pin for Ground. Use :n")
    end
end

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
