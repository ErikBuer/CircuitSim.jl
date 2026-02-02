abstract type AbstractQucsSimulationResult <: AbstractSimulationResult end

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
    DCResult

DC operating point results.

# Fields

- `voltages::Dict{String,Float64}`: Node voltages (node_name => voltage)
- `currents::Dict{String,Float64}`: Branch currents (component_name => current)
"""
struct DCResult <: AbstractQucsSimulationResult
    voltages::Dict{String,Float64}
    currents::Dict{String,Float64}
end

"""
    ACResult

AC analysis results (frequency sweep).

# Fields

- `frequencies_Hz::Vector{Float64}`: Frequency points
- `voltages::Dict{String,Vector{ComplexF64}}`: Node voltages vs frequency
- `currents::Dict{String,Vector{ComplexF64}}`: Branch currents vs frequency
"""
struct ACResult <: AbstractQucsSimulationResult
    frequencies_Hz::Vector{Float64}
    voltages::Dict{String,Vector{ComplexF64}}
    currents::Dict{String,Vector{ComplexF64}}
end

"""
    TransientResult

Transient analysis results (time domain).

# Fields

- `time_s::Vector{Float64}`: Time points
- `voltages::Dict{String,Vector{Float64}}`: Node voltages vs time
- `currents::Dict{String,Vector{Float64}}`: Branch currents vs time
"""
struct TransientResult <: AbstractQucsSimulationResult
    time_s::Vector{Float64}
    voltages::Dict{String,Vector{Float64}}
    currents::Dict{String,Vector{Float64}}
end

"""
    SParameterResult

S-parameter analysis results.

# Fields

- `frequencies_Hz::Vector{Float64}`: Frequency points
- `num_ports::Int`: Number of ports
- `s_matrix::Dict{Tuple{Int,Int},Vector{ComplexF64}}`: S[i,j] vs frequency
- `z0_Ohm::Float64`: Reference impedance
- `F::Union{Nothing,Vector{Float64}}`: Noise figure (linear, not dB) vs frequency (if noise analysis enabled)
- `Fmin::Union{Nothing,Vector{Float64}}`: Minimum noise figure (linear) vs frequency (if noise analysis enabled)
- `Sopt::Union{Nothing,Vector{ComplexF64}}`: Optimal source reflection coefficient vs frequency (if noise analysis enabled)
- `Rn_Ohm::Union{Nothing,Vector{Float64}}`: Equivalent noise resistance in Ohms vs frequency (if noise analysis enabled)
"""
struct SParameterResult <: AbstractQucsSimulationResult
    frequencies_Hz::Vector{Float64}
    num_ports::Int
    s_matrix::Dict{Tuple{Int,Int},Vector{ComplexF64}}
    z0_Ohm::Float64
    F::Union{Nothing,Vector{Float64}}
    Fmin::Union{Nothing,Vector{Float64}}
    Sopt::Union{Nothing,Vector{ComplexF64}}
    Rn_Ohm::Union{Nothing,Vector{Float64}}
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

# Typed Result Extraction

Use `extract_dc_result()`, `extract_ac_result()`, `extract_transient_result()`, 
or `extract_sparameter_result()` to get typed data structures.
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

# Analysis-specific convenience methods for common access patterns

"""
    get_frequency(dataset::QucsDataset) -> Vector{Float64}

Get the frequency vector for S-parameter, AC, or other frequency-domain analyses.
Looks for 'frequency', 'acfrequency', or 'hbfrequency' (for HB analysis, returns unique frequencies).

# Returns

- Vector of frequency values in Hz

# Throws

- ErrorException if no frequency vector found
"""
function get_frequency(dataset::QucsDataset)::Vector{Float64}
    # S-parameter and other frequency sweeps
    if haskey(dataset.independent_vars, "frequency")
        return real.(dataset.independent_vars["frequency"].values)
    end
    # AC analysis
    if haskey(dataset.independent_vars, "acfrequency")
        return real.(dataset.independent_vars["acfrequency"].values)
    end
    # Harmonic balance (returns the harmonic frequency vector)
    if haskey(dataset.independent_vars, "hbfrequency")
        return real.(dataset.independent_vars["hbfrequency"].values)
    end

    error("No frequency vector found in dataset. Available independent variables: $(collect(keys(dataset.independent_vars)))")
end

"""
    get_time(dataset::QucsDataset) -> Vector{Float64}

Get the time vector for transient analyses.

# Returns

- Vector of time values in seconds

# Throws

- ErrorException if no time vector found
"""
function get_time(dataset::QucsDataset)::Vector{Float64}
    if haskey(dataset.independent_vars, "time")
        return real.(dataset.independent_vars["time"].values)
    end

    error("No time vector found in dataset. Available independent variables: $(collect(keys(dataset.independent_vars)))")
end

"""
    get_sparameter(dataset::QucsDataset, i::Int, j::Int) -> Vector{ComplexF64}

Get S-parameter S[i,j] from dataset.

# Arguments

- `dataset::QucsDataset`: The simulation results
- `i::Int`: Output port number (1-indexed)
- `j::Int`: Input port number (1-indexed)

# Returns

- Vector of complex S-parameter values

# Example

```julia
s21 = get_sparameter(result, 2, 1)  # Forward transmission
s11 = get_sparameter(result, 1, 1)  # Input reflection
```
"""
function get_sparameter(dataset::QucsDataset, i::Int, j::Int)::Vector{ComplexF64}
    name = "S[$i,$j]"
    if haskey(dataset.dependent_vars, name)
        return dataset.dependent_vars[name].values
    end

    # If S-parameter not found, return vector of zeros with same length as frequency vector
    # This handles cases where ports are not connected (S-parameter would be zero anyway)
    try
        freq_length = length(get_frequency(dataset))
        return zeros(ComplexF64, freq_length)
    catch
        # If we can't determine frequency length, return empty vector
        @warn "S-parameter '$name' not found and cannot determine frequency vector length."
        return ComplexF64[]
    end
end

"""
    get_node_voltage(dataset::QucsDataset, node_name::String) -> Vector{ComplexF64}

Get voltage at a named node.

# Arguments

- `dataset::QucsDataset`: The simulation results  
- `node_name::String`: Node name (e.g., "net1", "vout")

# Returns

- Vector of complex voltage values

# Example

```julia
v_out = get_node_voltage(result, "net5")
```
"""
function get_node_voltage(dataset::QucsDataset, node_name::String)::Vector{ComplexF64}
    # Try both with and without .V suffix
    names_to_try = [node_name, "$(node_name).V", "v.$(node_name)"]

    for name in names_to_try
        if haskey(dataset.dependent_vars, name)
            return dataset.dependent_vars[name].values
        end
    end

    error("Node voltage '$node_name' not found in dataset. Available voltage vectors: $(filter(n -> contains(n, ".V") || startswith(n, "v."), collect(keys(dataset.dependent_vars))))")
end

"""
    get_s_matrix_size(dataset::QucsDataset) -> Int

Determine the size of the S-parameter matrix (number of ports).

# Returns

- Number of ports in the S-parameter matrix

# Example

```julia
n_ports = get_s_matrix_size(result)  # Returns 2 for a 2-port network
```
"""
function get_s_matrix_size(dataset::QucsDataset)::Int
    max_port = 0
    for name in keys(dataset.dependent_vars)
        m = match(r"S\[(\d+),(\d+)\]", name)
        if m !== nothing
            i = parse(Int, m.captures[1])
            j = parse(Int, m.captures[2])
            max_port = max(max_port, i, j)
        end
    end

    if max_port == 0
        error("No S-parameters found in dataset")
    end


    return max_port
end

# Typed Result Extraction

"""
    extract_dc_result(dataset::QucsDataset) -> DCResult

Extract DC operating point results from dataset.

# Returns

- `DCResult` with voltages and currents dictionaries

# Example

```julia
dc_data = extract_dc_result(dataset)
v_out = dc_data.voltages["_net1"]
i_supply = dc_data.currents["V1"]
```
"""
function extract_dc_result(dataset::QucsDataset)::DCResult
    voltages = Dict{String,Float64}()
    currents = Dict{String,Float64}()

    # DC analysis outputs voltages and currents as independent variables
    # Extract all node voltages (format: "_netN.V" or "nodename.V")
    for (name, vec) in dataset.independent_vars
        if endswith(name, ".V")
            node_name = replace(name, ".V" => "")
            voltages[node_name] = real(vec.values[1])
        elseif endswith(name, ".I")
            comp_name = replace(name, ".I" => "")
            currents[comp_name] = real(vec.values[1])
        end
    end

    # Also check dependent_vars in case of different qucsator versions
    for (name, vec) in dataset.dependent_vars
        if endswith(name, ".V")
            node_name = replace(name, ".V" => "")
            voltages[node_name] = real(vec.values[1])
        elseif endswith(name, ".I")
            comp_name = replace(name, ".I" => "")
            currents[comp_name] = real(vec.values[1])
        end
    end

    return DCResult(voltages, currents)
end

"""
    extract_ac_result(dataset::QucsDataset) -> ACResult

Extract AC analysis results from dataset.

# Returns

- `ACResult` with frequency sweep data

# Example

```julia
ac_data = extract_ac_result(dataset)
freqs = ac_data.frequencies_Hz
v_out = ac_data.voltages["_net1"]  # ComplexF64 vector vs frequency
```
"""
function extract_ac_result(dataset::QucsDataset)::ACResult
    frequencies_Hz = get_frequency(dataset)
    voltages = Dict{String,Vector{ComplexF64}}()
    currents = Dict{String,Vector{ComplexF64}}()

    # Extract all node voltages and branch currents
    # Note: qucsator outputs lowercase .v and .i for AC analysis
    for (name, vec) in dataset.dependent_vars
        if endswith(name, ".V") || endswith(name, ".v")
            node_name = replace(replace(name, ".V" => ""), ".v" => "")
            voltages[node_name] = vec.values
        elseif endswith(name, ".I") || endswith(name, ".i")
            comp_name = replace(replace(name, ".I" => ""), ".i" => "")
            currents[comp_name] = vec.values
        end
    end

    return ACResult(frequencies_Hz, voltages, currents)
end

"""
    extract_transient_result(dataset::QucsDataset) -> TransientResult

Extract transient analysis results from dataset.

# Returns

- `TransientResult` with time domain data

# Example

```julia
tran_data = extract_transient_result(dataset)
times = tran_data.time_s
v_out = tran_data.voltages["_net1"]  # Float64 vector vs time
```
"""
function extract_transient_result(dataset::QucsDataset)::TransientResult
    time_s = get_time(dataset)
    voltages = Dict{String,Vector{Float64}}()
    currents = Dict{String,Vector{Float64}}()

    # Extract all node voltages and branch currents (real values for transient)
    # Note: Transient analysis uses .Vt (voltage-time) and .It (current-time) suffixes
    for (name, vec) in dataset.dependent_vars
        if endswith(name, ".Vt")
            node_name = replace(name, ".Vt" => "")
            voltages[node_name] = real.(vec.values)
        elseif endswith(name, ".It")
            comp_name = replace(name, ".It" => "")
            currents[comp_name] = real.(vec.values)
        end
    end

    return TransientResult(time_s, voltages, currents)
end

"""
    extract_sparameter_result(dataset::QucsDataset; z0::Real=50.0) -> SParameterResult

Extract S-parameter analysis results from dataset.

# Arguments

- `dataset::QucsDataset`: Parsed simulation output
- `z0::Real=50.0`: Reference impedance in Ohms

# Returns

- `SParameterResult` with S-parameter matrix data and noise parameters (if noise analysis was enabled)

# Example

```julia
sp_data = extract_sparameter_result(dataset)
freqs = sp_data.frequencies_Hz
s21 = sp_data.s_matrix[(2,1)]  # Forward transmission vs frequency

# Noise parameters (if available)
if !isnothing(sp_data.F)
    nf_db = 10 * log10.(sp_data.F)  # Convert to dB
    fmin_db = 10 * log10.(sp_data.Fmin)  # Minimum NF in dB
    gamma_opt = sp_data.Sopt  # Optimal source reflection coefficient
    rn = sp_data.Rn_Ohm  # Equivalent noise resistance
end
```
"""
function extract_sparameter_result(dataset::QucsDataset; z0::Real=50.0)::SParameterResult
    frequencies_Hz = get_frequency(dataset)
    num_ports = get_s_matrix_size(dataset)
    s_matrix = Dict{Tuple{Int,Int},Vector{ComplexF64}}()

    # Extract all S-parameters
    for i in 1:num_ports
        for j in 1:num_ports
            s_matrix[(i, j)] = get_sparameter(dataset, i, j)
        end
    end

    # Extract noise parameters if present
    # Noise parameters are computed by qucsator when Noise="yes" in S-parameter analysis
    # F: Noise figure (linear)
    # Fmin: Minimum noise figure (linear)
    # Sopt: Optimal source reflection coefficient for minimum noise
    # Rn: Equivalent noise resistance (Ohms)
    F = haskey(dataset.dependent_vars, "F") ? real.(dataset.dependent_vars["F"].values) : nothing
    Fmin = haskey(dataset.dependent_vars, "Fmin") ? real.(dataset.dependent_vars["Fmin"].values) : nothing
    Sopt = haskey(dataset.dependent_vars, "Sopt") ? dataset.dependent_vars["Sopt"].values : nothing
    Rn_Ohm = haskey(dataset.dependent_vars, "Rn") ? real.(dataset.dependent_vars["Rn"].values) : nothing

    return SParameterResult(frequencies_Hz, num_ports, s_matrix, Float64(z0), F, Fmin, Sopt, Rn_Ohm)
end

"""
    MultiAnalysisResult

Results from multiple analyses run simultaneously.

Contains the raw QucsDataset plus typed results for each analysis type found.

# Fields

- `dataset::QucsDataset`: Raw parsed dataset with all vectors
- `dc::Union{Nothing,DCResult}`: DC analysis results (if DC analysis was run)
- `ac::Union{Nothing,ACResult}`: AC analysis results (if AC analysis was run)
- `transient::Union{Nothing,TransientResult}`: Transient analysis results (if transient analysis was run)
- `sparameter::Union{Nothing,SParameterResult}`: S-parameter results (if S-parameter analysis was run)

# Example

```julia
# Run DC + S-parameter analysis together
results = simulate_qucsator(circ, [DCAnalysis(), SParameterAnalysis(1e9, 10e9, 101)])

# Access DC results
if !isnothing(results.dc)
    v_node = results.dc.voltages["_net1"]
end

# Access S-parameter results
if !isnothing(results.sparameter)
    s21 = results.sparameter.s_matrix[(2,1)]
end
```
"""
struct MultiAnalysisResult <: AbstractQucsSimulationResult
    dataset::QucsDataset
    dc::Union{Nothing,DCResult}
    ac::Union{Nothing,ACResult}
    transient::Union{Nothing,TransientResult}
    sparameter::Union{Nothing,SParameterResult}
end

"""
    MultiAnalysisResult(dataset::QucsDataset, analyses::Vector{<:AbstractAnalysis})

Create a MultiAnalysisResult by extracting typed results for each analysis type.

# Arguments

- `dataset::QucsDataset`: Parsed simulation output
- `analyses::Vector{<:AbstractAnalysis}`: List of analyses that were run

# Returns

- `MultiAnalysisResult` with typed results for each analysis found
"""
function MultiAnalysisResult(dataset::QucsDataset, analyses::Vector{<:AbstractAnalysis})
    # Extract results based on analysis types present
    dc = nothing
    ac = nothing
    transient = nothing
    sparameter = nothing

    for analysis in analyses
        try
            if analysis isa DCAnalysis && isnothing(dc)
                dc = extract_dc_result(dataset)
            elseif analysis isa ACAnalysis && isnothing(ac)
                ac = extract_ac_result(dataset)
            elseif analysis isa TransientAnalysis && isnothing(transient)
                transient = extract_transient_result(dataset)
            elseif analysis isa SParameterAnalysis && isnothing(sparameter)
                sparameter = extract_sparameter_result(dataset, z0=analysis.z0)
            end
        catch e
            # If extraction fails for this analysis, leave it as nothing
            @warn "Failed to extract results for $(typeof(analysis)): $e"
        end
    end

    return MultiAnalysisResult(dataset, dc, ac, transient, sparameter) #TODO finish implementation
end


