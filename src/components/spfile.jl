"""
    SPfile <: AbstractSParameterFile

S-parameter file (Touchstone format) component.

Loads S-parameters from a Touchstone file and uses them as a 
black-box frequency-domain model. The number of ports is automatically 
detected from the file extension.

# Port Structure

For an N-port S-parameter file, the component has N+1 nodes:
- `n1`, `n2`, ..., `nN`: Port terminal nodes
- `ref`: Ground reference node (always the last node)

# Fields

- `name::String`: Component identifier
- `nodes::Vector{Int}`: Port terminal nodes (N+1 total: N ports + ground)
- `file::String`: Path to Touchstone file
- `num_ports::Int`: Number of ports
- `data_format::String`: Data format ("rectangular" or "polar")
- `interpolator::String`: Interpolation method ("linear" or "cubic")
- `temp::Real`: Temperature in Kelvin (default 293.15K = 20°C)
- `during_dc::String`: DC behavior ("open", "short", or "unspecified")

# Example

```julia
# Load a 1-port S-parameter file (antenna)
antenna = SPfile("ANT1", "antenna.s1p")
@connect circ source.nplus antenna.n1
@connect circ antenna.ref ground

# Load a 2-port S-parameter file (amplifier)
amp = SPfile("AMP1", "amplifier.s2p")
@connect circ input.nplus amp.n1
@connect circ output.nplus amp.n2
@connect circ amp.ref ground

# Manually specify port count if filename doesn't follow .sNp convention
custom = SPfile("DEV", "data.txt", num_ports=3)

# Custom options
filter_sp = SPfile("FILT1", "filter.s2p", 
    data_format="polar",
    interpolator="cubic",
    temp=298.15)
```

# Notes

- File path can be absolute or relative to netlist location
- Supports Touchstone v1.0, v1.1, v2.0 formats
- Number of ports detected from .sNp filename (e.g., .s1p = 1-port, .s2p = 2-port)
- Can be overridden with `num_ports` parameter
- Always connect the `ref` node to circuit ground
"""
mutable struct SPfile <: AbstractSParameterFile
    name::String

    nodes::Vector{Int}

    file::String
    num_ports::Int
    data_format::String
    interpolator::String
    temp::Real
    during_dc::String

    function SPfile(name::AbstractString;
        file::AbstractString,
        num_ports::Union{Int,Nothing}=nothing,
        data_format::String="rectangular",
        interpolator::String="linear",
        temp::Real=293.15,
        during_dc::String="open"
    )

        data_format in ["rectangular", "polar"] || throw(ArgumentError("data_format must be 'rectangular' or 'polar'"))
        interpolator in ["linear", "cubic"] || throw(ArgumentError("interpolator must be 'linear' or 'cubic'"))
        during_dc in ["open", "short", "unspecified"] || throw(ArgumentError("during_dc must be 'open', 'short', or 'unspecified'"))

        # Detect number of ports from file extension or use provided value
        detected_ports = if num_ports !== nothing
            num_ports
        else
            detect_touchstone_ports(file)
        end

        # Initialize nodes array with zeros (will be assigned by @connect)
        # SPfile needs N+1 nodes: N port nodes + 1 ground reference node
        nodes = zeros(Int, detected_ports + 1)

        new(String(name), nodes, file, detected_ports, data_format, interpolator, temp, during_dc)
    end
end

# TODO dont limit to 4 ports - make dynamic
function Base.setproperty!(spf::SPfile, sym::Symbol, val)
    if sym === :n1 && Base.getfield(spf, :num_ports) >= 1
        Base.getfield(spf, :nodes)[1] = val
    elseif sym === :n2 && Base.getfield(spf, :num_ports) >= 2
        Base.getfield(spf, :nodes)[2] = val
    elseif sym === :n3 && Base.getfield(spf, :num_ports) >= 3
        Base.getfield(spf, :nodes)[3] = val
    elseif sym === :n4 && Base.getfield(spf, :num_ports) >= 4
        Base.getfield(spf, :nodes)[4] = val
    elseif sym === :ref
        # Ground reference is always the last node (N+1)
        Base.getfield(spf, :nodes)[end] = val
    else
        Base.setfield!(spf, sym, val)
    end
end

"""
    prepare_external_files!(comp::SPfile, netlist_dir::String)

Copy S-parameter file to the netlist directory.
Called by the backend before running qucsator.
"""
function prepare_external_files!(spf::SPfile, netlist_dir::String)
    src_file = abspath(spf.file)
    dest_file = joinpath(netlist_dir, "$(spf.name).s$(spf.num_ports)p")
    cp(src_file, dest_file, force=true)
    return nothing
end

function to_qucs_netlist(spf::SPfile)::String
    # Build node list: N port nodes followed by ground reference node
    parts = ["SPfile:$(spf.name)"]

    # Add all N+1 nodes (N ports + 1 ground reference)
    for i in 1:length(spf.nodes)
        push!(parts, qucs_node(spf.nodes[i]))
    end

    # Use component name for the file reference - backend creates symlink with this name
    # This avoids issues with absolute paths and spaces that qucsator cannot handle
    push!(parts, "File=\"$(spf.name).s$(spf.num_ports)p\"")
    push!(parts, "Data=\"$(spf.data_format)\"")
    push!(parts, "Interpolator=\"$(spf.interpolator)\"")
    push!(parts, "duringDC=\"$(spf.during_dc)\"")
    return join(parts, " ")
end

function to_spice_netlist(spf::SPfile)::String
    "* S-parameter file $(spf.name) from $(spf.file)"
end

# TODO dont limit to 4 ports - make dynamic
function _get_node_number(spf::SPfile, pin::Symbol)::Int
    if pin === :n1 && spf.num_ports >= 1
        return spf.nodes[1]
    elseif pin === :n2 && spf.num_ports >= 2
        return spf.nodes[2]
    elseif pin === :n3 && spf.num_ports >= 3
        return spf.nodes[3]
    elseif pin === :n4 && spf.num_ports >= 4
        return spf.nodes[4]
    elseif pin === :ref
        return spf.nodes[end]
    else
        error("Invalid pin $pin for SPfile $(spf.name). Valid pins: n1" *
              (spf.num_ports >= 2 ? ", n2" : "") *
              (spf.num_ports >= 3 ? ", n3" : "") *
              (spf.num_ports >= 4 ? ", n4" : "") *
              ", ref")
    end
end


function num_pins(spf::SPfile)
    # SPfile has N+1 pins: N port pins + 1 ground reference
    return spf.num_ports + 1
end

# Register SPfile pins in union-find
function _register_pins_in_uf!(uf::UnionFind, comp::SPfile)
    for i in 1:comp.num_ports
        p = Pin(comp, Symbol("n$i"))
        uf_find(uf, pinid(p))
    end
    p = Pin(comp, :ref)
    uf_find(uf, pinid(p))
end

# Collect roots from SPfile pins
function _collect_roots!(rootset::Dict{UInt64,Int}, uf::UnionFind, comp::SPfile)
    for i in 1:comp.num_ports
        root = uf_find(uf, pinid(Pin(comp, Symbol("n$i"))))
        rootset[root] = 1
    end
    root = uf_find(uf, pinid(Pin(comp, :ref)))
    rootset[root] = 1
end

# Write back node numbers to SPfile
function _write_node_numbers!(comp::SPfile, uf::UnionFind, node_map::Dict{UInt64,Int})
    for i in 1:comp.num_ports
        root = uf_find(uf, pinid(Pin(comp, Symbol("n$i"))))
        node = get(node_map, root, 0)
        setproperty!(comp, Symbol("n$i"), node)
    end
    root = uf_find(uf, pinid(Pin(comp, :ref)))
    node = get(node_map, root, 0)
    setproperty!(comp, :ref, node)
end

