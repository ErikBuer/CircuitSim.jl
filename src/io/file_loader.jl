"""
File loader module for qucsator file-based sources (Vfile/Ifile).

Supports:
- CSV format (two columns: time, value)
- Qucs Dataset format (native qucsator format)

Based on qucsator_rf requirements:
- Exactly 1 independent variable (time)
- Exactly 1 dependent variable (samples)
"""

struct FileData{T<:Number}
    times::Vector{Float64}
    samples::Vector{T}
    time_name::String
    var_name::String
    format::Symbol

    function FileData(times::Vector{Float64}, samples::Vector{T},
        time_name::String="time", var_name::String="data",
        format::Symbol=:unknown) where T<:Number
        @assert length(times) == length(samples) "times and samples must have same length"
        @assert length(times) >= 2 "must have at least 2 data points"
        @assert issorted(times) "times must be monotonically increasing"
        new{T}(times, samples, time_name, var_name, format)
    end
end

"""
    load_file_data(filepath::String; format::Symbol=:auto) -> FileData

Load time-series data from CSV or Qucs Dataset file.

# Arguments

- `filepath`: Path to data file
- `format`: Format hint (:auto, :csv, :qucs_dataset)

# Returns

- `FileData` struct with times, samples, and metadata

# Supported Formats

## CSV Format

Two columns: time, value (comma or semicolon separated)
Optional header row with column names

Example:
```
time,voltage
0.0,0.0
1e-9,1.0
2e-9,0.5
```

## Qucs Dataset Format

Native qucsator format with indep/dep blocks

Example:
```
<Qucs Dataset 1.0.0>
<indep time 4>
  0.0
  1e-9
  2e-9
  3e-9
</indep>
<dep V1 4>
  0.0
  1.0
  0.5
  0.0
</dep>
```
"""
function load_file_data(filepath::String; format::Symbol=:auto)::FileData
    @assert isfile(filepath) "File not found: $filepath"

    if format == :auto
        format = detect_format(filepath)
    end

    if format == :csv
        return load_csv(filepath)
    elseif format == :qucs_dataset
        return load_qucs_dataset(filepath)
    else
        error("Unsupported format: $format. Use :csv or :qucs_dataset")
    end
end

"""
    detect_format(filepath::String) -> Symbol

Detect file format by examining file content.
"""
function detect_format(filepath::String)::Symbol
    first_line = readline(filepath)

    if startswith(first_line, "<Qucs Dataset")
        return :qucs_dataset
    elseif occursin(r"[,;]", first_line) || occursin(r"^\s*[+-]?[\d.eE+-]+", first_line)
        return :csv
    else
        error("Unable to detect format for file: $filepath")
    end
end

"""
    load_csv(filepath::String) -> FileData

Load CSV file with two columns: time, value.
First row may be header with column names.
"""
function load_csv(filepath::String)::FileData
    lines = readlines(filepath)
    @assert length(lines) >= 2 "CSV file must have at least 2 data rows"

    first_line = strip(lines[1])
    delim = occursin(',', first_line) ? ',' : ';'

    has_header = !occursin(r"^[+-]?[\d.eE+-]", first_line)

    if has_header
        header_parts = split(first_line, delim)
        time_name = strip(String(header_parts[1]))
        var_name = length(header_parts) >= 2 ? strip(String(header_parts[2])) : "data"
        data_start = 2
    else
        time_name = "time"
        var_name = "data"
        data_start = 1
    end

    times = Float64[]
    samples = Float64[]

    for i in data_start:length(lines)
        line = strip(lines[i])
        isempty(line) && continue

        parts = split(line, delim)
        @assert length(parts) >= 2 "CSV row must have exactly 2 columns, got $(length(parts)) in line $i: $line"

        push!(times, parse(Float64, strip(parts[1])))
        push!(samples, parse(Float64, strip(parts[2])))
    end

    @assert length(times) >= 2 "CSV file must contain at least 2 data points"

    return FileData(times, samples, time_name, var_name, :csv)
end

"""
    load_qucs_dataset(filepath::String) -> FileData

Load Qucs Dataset format file.

Format:
```
<Qucs Dataset VERSION>
<indep TIME_NAME N>
  time1
  time2
  ...
</indep>
<dep VAR_NAME N>
  value1
  value2
  ...
</dep>
```
"""
function load_qucs_dataset(filepath::String)::FileData
    content = read(filepath, String)
    lines = split(content, '\n')

    version_match = match(r"<Qucs Dataset\s+([\d.]+)>", lines[1])
    @assert version_match !== nothing "Invalid Qucs Dataset header"

    times = Float64[]
    samples = Float64[]
    time_name = "time"
    var_name = "data"

    i = 2
    while i <= length(lines)
        line = strip(lines[i])

        if startswith(line, "<indep")
            m = match(r"<indep\s+(\w+)\s+(\d+)>", line)
            @assert m !== nothing "Invalid indep block header: $line"
            time_name = m.captures[1]
            n_points = parse(Int, m.captures[2])

            i += 1
            while i <= length(lines)
                line = strip(lines[i])
                if startswith(line, "</indep>")
                    break
                end
                if !isempty(line)
                    push!(times, parse(Float64, line))
                end
                i += 1
            end

        elseif startswith(line, "<dep")
            m = match(r"<dep\s+(\S+)\s+(\d+)>", line)
            @assert m !== nothing "Invalid dep block header: $line"
            var_name = m.captures[1]
            n_points = parse(Int, m.captures[2])

            i += 1
            while i <= length(lines)
                line = strip(lines[i])
                if startswith(line, "</dep>")
                    break
                end
                if !isempty(line)
                    push!(samples, parse(Float64, line))
                end
                i += 1
            end
        end

        i += 1
    end

    @assert length(times) >= 2 "Qucs Dataset must contain at least 2 time points"
    @assert length(samples) >= 2 "Qucs Dataset must contain at least 2 sample points"
    @assert length(times) == length(samples) "Qucs Dataset: indep and dep must have same length (got $(length(times)) and $(length(samples)))"

    return FileData(times, samples, time_name, var_name, :qucs_dataset)
end

"""
    write_csv(filepath::String, times::AbstractVector, samples::AbstractVector; 
              time_name="time", var_name="data")

Write data to CSV format file (two columns with header).
"""
function write_csv(filepath::String, times::AbstractVector, samples::AbstractVector;
    time_name::String="time", var_name::String="data")
    open(filepath, "w") do io
        println(io, "$time_name,$var_name")
        for (t, s) in zip(times, samples)
            println(io, "$t,$s")
        end
    end
end

"""
    write_qucs_dataset(filepath::String, times::AbstractVector, samples::AbstractVector;
                       time_name="time", var_name="data")

Write data to Qucs Dataset format file.
"""
function write_qucs_dataset(filepath::String, times::AbstractVector, samples::AbstractVector;
    time_name::String="time", var_name::String="data")
    N = length(times)
    @assert N == length(samples) "times and samples must have same length"

    open(filepath, "w") do io
        println(io, "<Qucs Dataset 1.0.0>")
        println(io, "<indep $time_name $N>")
        for t in times
            println(io, "  $t")
        end
        println(io, "</indep>")
        println(io, "<dep $var_name $N>")
        for s in samples
            println(io, "  $s")
        end
        println(io, "</dep>")
    end
end
