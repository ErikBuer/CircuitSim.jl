mutable struct DIAC <: AbstractDiode
    name::String

    cathode::Int  # Also labeled as A2 in some references
    anode::Int    # Also labeled as A1 in some references

    # Required properties
    Ibo::Real   # Breakover current
    Vbo::Real   # Breakover voltage

    # Optional properties
    Cj0::Real   # Zero-bias junction capacitance
    Is::Real    # Saturation current
    N::Real     # Emission coefficient
    Ri::Real    # Intrinsic resistance
    Temp::Real  # Simulation temperature

    function DIAC(name::String;
        Ibo::Real=50e-6,
        Vbo::Real=30,
        Cj0::Real=10e-12,
        Is::Real=1e-10,
        N::Real=2,
        Ri::Real=10,
        Temp::Real=26.85
    )
        new(name, 0, 0, Ibo, Vbo, Cj0, Is, N, Ri, Temp)
    end
end

function to_qucs_netlist(d::DIAC)::String
    parts = ["Diac:$(d.name)"]

    # Nodes (cathode/A2 first, then anode/A1)
    push!(parts, qucs_node(d.cathode))
    push!(parts, qucs_node(d.anode))

    # Required properties
    push!(parts, "Ibo=\"$(format_value(d.Ibo))\"")
    push!(parts, "Vbo=\"$(d.Vbo)\"")

    # Optional properties
    d.Cj0 != 10e-12 && push!(parts, "Cj0=\"$(format_value(d.Cj0))\"")
    d.Is != 1e-10 && push!(parts, "Is=\"$(format_value(d.Is))\"")
    d.N != 2 && push!(parts, "N=\"$(d.N)\"")
    d.Ri != 10 && push!(parts, "Ri=\"$(d.Ri)\"")
    d.Temp != 26.85 && push!(parts, "Temp=\"$(d.Temp)\"")

    return join(parts, " ")
end
