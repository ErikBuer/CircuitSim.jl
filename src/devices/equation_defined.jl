mutable struct EquationDefinedDevice <: AbstractEquationDefinedDevice
    name::String
    nodes::Vector{Int}
    num_branches::Int

    I_equations::Dict{Int,String}
    Q_equations::Dict{Int,String}

    function EquationDefinedDevice(name::String, num_branches::Int;
        I_equations::Dict{Int,String}=Dict{Int,String}(),
        Q_equations::Dict{Int,String}=Dict{Int,String}())

        if num_branches < 1 || num_branches > 20
            error("EquationDefinedDevice num_branches must be between 1 and 20, got: $num_branches")
        end

        if !haskey(I_equations, 1)
            error("EquationDefinedDevice must have at least I1 equation defined")
        end

        if !haskey(Q_equations, 1)
            error("EquationDefinedDevice must have at least Q1 equation defined")
        end

        nodes = zeros(Int, 2 * num_branches)

        new(name, nodes, num_branches, I_equations, Q_equations)
    end
end

const EDD = EquationDefinedDevice

function get_nodes(edd::EquationDefinedDevice)
    return edd.nodes
end

function connect!(edd::EquationDefinedDevice, nodes::Int...)
    if length(nodes) != 2 * edd.num_branches
        error("EquationDefinedDevice with $(edd.num_branches) branches requires $(2 * edd.num_branches) nodes, got $(length(nodes))")
    end
    edd.nodes = collect(nodes)
end

function to_qucs_netlist(edd::EquationDefinedDevice)::String
    props = String[]

    for i in 1:edd.num_branches
        if haskey(edd.I_equations, i)
            push!(props, "I$i=\"$(edd.I_equations[i])\"")
        else
            push!(props, "I$i=\"0\"")
        end

        if haskey(edd.Q_equations, i)
            push!(props, "Q$i=\"$(edd.Q_equations[i])\"")
        else
            push!(props, "Q$i=\"0\"")
        end
    end

    nodes_str = join(edd.nodes, " ")
    props_str = join(props, " ")

    return "EDD:$(edd.name) $nodes_str $props_str"
end
