"""
Parser for Qucs dataset output format.

Format: 
```
<Qucs Dataset VERSION>
<indep name size> ... values ... </indep>
<dep name dep1 dep2 ...> ... values ... </dep>
```
"""

"""
    SimulationStatus

Result status from a simulation run.

Values:
- `SIM_SUCCESS`: Simulation completed successfully
- `SIM_ERROR`: Simulation encountered an error
- `SIM_PARSE_ERROR`: Output parsing failed
- `SIM_NOT_RUN`: Simulation has not been run
"""
@enum SimulationStatus begin
    SIM_SUCCESS = 0
    SIM_ERROR = 1
    SIM_PARSE_ERROR = 2
    SIM_NOT_RUN = 3
end

"""
    DataVector

Represents a data vector from simulation output.

# Fields
- `name::String`: Vector name
- `values::Vector{ComplexF64}`: Data values
- `dependencies::Vector{String}`: Names of independent variables this depends on
- `is_independent::Bool`: Whether this is an independent variable
"""
struct DataVector
    name::String
    values::Vector{ComplexF64}
    dependencies::Vector{String}
    is_independent::Bool
end

"""
    QucsDataset

Parsed simulation result containing all vectors and metadata.

# Fields
- `status::SimulationStatus`: Status of the simulation
- `version::String`: Qucs dataset version
- `independent_vars::Dict{String,DataVector}`: Independent variables (e.g., frequency, time)
- `dependent_vars::Dict{String,DataVector}`: Dependent variables (e.g., voltages, currents)
- `errors::Vector{String}`: Error messages
- `warnings::Vector{String}`: Warning messages
- `raw_output::String`: Raw simulator output
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
