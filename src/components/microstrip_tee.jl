"""
    MicrostripTee <: AbstractMicrostripTee

A microstrip T-junction (3-port).

# Fields

- `name::String`: Component identifier
- `n1::Int`: Node 1 (main line input)
- `n2::Int`: Node 2 (main line output)
- `n3::Int`: Node 3 (branch)
- `substrate::Substrate`: Substrate definition reference
- `w1::Real`: Main line width (m)
- `w2::Real`: Branch width (m)

# Example

```julia
sub = Substrate("FR4", er=4.5, h=1.6e-3)
tee = MicrostripTee("MTEE1", sub, w1=3.0e-3, w2=1.5e-3)
```

# Qucs Format

`MTEE:Name Node1 Node2 Node3 Subst="SubstName" W1="width1" W2="width2" W3="width3"`
"""
mutable struct MicrostripTee <: AbstractMicrostripTee
    name::String

    n1::Int
    n2::Int
    n3::Int

    substrate::Substrate
    w1::Real        # Port 1 width (m)
    w2::Real        # Port 2 width (m)
    w3::Real        # Port 3 (branch) width (m)

    function MicrostripTee(name::AbstractString;
        substrate::Substrate,
        w1::Real=1e-3,
        w2::Real=1e-3,
        w3::Real=1e-3
    )
        w1 > 0 || throw(ArgumentError("Width 1 must be positive"))
        w2 > 0 || throw(ArgumentError("Width 2 must be positive"))
        w3 > 0 || throw(ArgumentError("Width 3 must be positive"))
        new(String(name), 0, 0, 0, substrate, w1, w2, w3)
    end
end

function to_qucs_netlist(mt::MicrostripTee)::String
    parts = ["MTEE:$(mt.name)"]
    push!(parts, qucs_node(mt.n1))
    push!(parts, qucs_node(mt.n2))
    push!(parts, qucs_node(mt.n3))
    push!(parts, "Subst=\"$(mt.substrate.name)\"")
    push!(parts, "W1=\"$(format_value(mt.w1))\"")
    push!(parts, "W2=\"$(format_value(mt.w2))\"")
    push!(parts, "W3=\"$(format_value(mt.w3))\"")
    push!(parts, "MSModel=\"Hammerstad\"")
    push!(parts, "MSDispModel=\"Kirschning\"")
    return join(parts, " ")
end

function to_spice_netlist(mt::MicrostripTee)::String
    "* Microstrip tee $(mt.name) nodes $(mt.n1)-$(mt.n2)-$(mt.n3), W1=$(mt.w1)m, W2=$(mt.w2)m, W3=$(mt.w3)m"
end

function _get_node_number(mt::MicrostripTee, terminal::Int)::Int
    terminal == 1 && return mt.n1
    terminal == 2 && return mt.n2
    terminal == 3 && return mt.n3
    throw(ArgumentError("MicrostripTee has 3 terminals (1, 2, 3), got $terminal"))
end
