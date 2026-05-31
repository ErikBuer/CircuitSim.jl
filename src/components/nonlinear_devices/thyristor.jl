mutable struct Thyristor <: AbstractThyristor
    name::String

    anode::Int
    gate::Int
    cathode::Int

    # Required properties
    Igt::Real   # Gate trigger current
    Vbo::Real   # Breakover voltage

    # Optional properties
    Cj0::Real   # Zero-bias junction capacitance
    Is::Real    # Saturation current
    N::Real     # Emission coefficient
    Ri::Real    # Intrinsic resistance
    Rg::Real    # Gate resistance
    Temp::Real  # Simulation temperature

    function Thyristor(name::String;
        Igt::Real=50e-6,
        Vbo::Real=30,
        Cj0::Real=10e-12,
        Is::Real=1e-10,
        N::Real=2,
        Ri::Real=10,
        Rg::Real=5,
        Temp::Real=26.85
    )
        new(name, 0, 0, 0, Igt, Vbo, Cj0, Is, N, Ri, Rg, Temp)
    end
end

const SCR = Thyristor

get_nodes(t::Thyristor) = [t.anode, t.gate, t.cathode]
node_count(::Type{Thyristor}) = 3
get_name(t::Thyristor) = t.name

function connect!(t::Thyristor, anode::Int, gate::Int, cathode::Int)
    t.anode = anode
    t.gate = gate
    t.cathode = cathode
    return t
end

function to_qucs_netlist(t::Thyristor)::String
    parts = ["SCR:$(t.name)"]

    # Nodes (anode, gate, cathode)
    push!(parts, qucs_node(t.anode))
    push!(parts, qucs_node(t.gate))
    push!(parts, qucs_node(t.cathode))

    # Required properties
    push!(parts, "Igt=\"$(format_value(t.Igt))\"")
    push!(parts, "Vbo=\"$(t.Vbo)\"")

    # Optional properties
    t.Cj0 != 10e-12 && push!(parts, "Cj0=\"$(format_value(t.Cj0))\"")
    t.Is != 1e-10 && push!(parts, "Is=\"$(format_value(t.Is))\"")
    t.N != 2 && push!(parts, "N=\"$(t.N)\"")
    t.Ri != 10 && push!(parts, "Ri=\"$(t.Ri)\"")
    t.Rg != 5 && push!(parts, "Rg=\"$(t.Rg)\"")
    t.Temp != 26.85 && push!(parts, "Temp=\"$(t.Temp)\"")

    return join(parts, " ")
end
