mutable struct Triac <: AbstractTriac
    name::String

    t1::Int  # Terminal 1
    gate::Int
    t2::Int  # Terminal 2

    # Required properties
    Vbo::Real   # Breakover voltage

    # Optional properties
    Cj0::Real   # Zero-bias junction capacitance
    Is::Real    # Saturation current
    N::Real     # Emission coefficient
    Ri::Real    # Intrinsic resistance
    Rg::Real    # Gate resistance
    Temp::Real  # Simulation temperature

    function Triac(name::String;
        Vbo::Real=30,
        Cj0::Real=10e-12,
        Is::Real=1e-10,
        N::Real=2,
        Ri::Real=10,
        Rg::Real=5,
        Temp::Real=26.85
    )
        new(name, 0, 0, 0, Vbo, Cj0, Is, N, Ri, Rg, Temp)
    end
end

get_nodes(t::Triac) = [t.t1, t.gate, t.t2]
node_count(::Type{Triac}) = 3
get_name(t::Triac) = t.name

function connect!(t::Triac, t1::Int, gate::Int, t2::Int)
    t.t1 = t1
    t.gate = gate
    t.t2 = t2
    return t
end

function to_qucs_netlist(t::Triac)::String
    parts = ["Triac:$(t.name)"]

    # Nodes (T1, gate, T2)
    push!(parts, qucs_node(t.t1))
    push!(parts, qucs_node(t.gate))
    push!(parts, qucs_node(t.t2))

    # Required properties
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
