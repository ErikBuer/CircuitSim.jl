"""
    MicrostripTee <: AbstractMicrostripTee

A microstrip T-junction (3-port, MTEE).

# Fields

- `name::String`: Component identifier
- `n1::Int`: Port 1 node
- `n2::Int`: Port 2 node
- `n3::Int`: Port 3 node
- `w1::Float64`: Width at port 1 in meters (default: 1e-3, must be > 0)
- `w2::Float64`: Width at port 2 in meters (default: 1e-3, must be > 0)
- `w3::Float64`: Width at port 3 in meters (default: 2e-3, must be > 0)
- `substrate::String`: Substrate reference name (default: "Subst1")
- `disp_model::String`: Dispersion model (default: "Kirschning")
- `model::String`: Quasi-static model (default: "Hammerstad")
- `temp::Float64`: Temperature in °C (default: 26.85)

# Pins

- `:n1`: Port 1
- `:n2`: Port 2
- `:n3`: Port 3

# Example

```jldoctest
julia> tee = MicrostripTee("MTEE1")
MicrostripTee("MTEE1", 0, 0, 0, 0.001, 0.001, 0.002, "Subst1", "Kirschning", "Hammerstad", 26.85)
```
"""
mutable struct MicrostripTee <: AbstractMicrostripTee
    name::String

    n1::Int
    n2::Int
    n3::Int

    w1::Float64
    w2::Float64
    w3::Float64
    substrate::String
    disp_model::String
    model::String
    temp::Float64

    function MicrostripTee(name::AbstractString;
        w1::Real=1e-3,
        w2::Real=1e-3,
        w3::Real=2e-3,
        substrate::String="Subst1",
        disp_model::String="Kirschning",
        model::String="Hammerstad",
        temp::Real=26.85
    )
        w1 > 0 || error("w1 must be > 0 (got $w1)")
        w2 > 0 || error("w2 must be > 0 (got $w2)")
        w3 > 0 || error("w3 must be > 0 (got $w3)")
        temp >= -273.15 || error("temp must be >= -273.15 (got $temp)")

        model in ["Hammerstad", "Schneider", "Wheeler"] ||
            error("model must be one of: Hammerstad, Schneider, Wheeler")
        disp_model in ["Kirschning", "Hammerstad", "Getsinger", "Schneider", "Pramanick", "Yamashita", "Kobayashi"] ||
            error("disp_model must be one of: Kirschning, Hammerstad, Getsinger, Schneider, Pramanick, Yamashita, Kobayashi")

        new(String(name), 0, 0, 0,
            Float64(w1), Float64(w2), Float64(w3),
            substrate, disp_model, model, Float64(temp))
    end
end

function to_qucs_netlist(comp::MicrostripTee)::String
    parts = ["MTEE:$(comp.name)"]
    push!(parts, qucs_node(comp.n1))
    push!(parts, qucs_node(comp.n2))
    push!(parts, qucs_node(comp.n3))
    push!(parts, "W1=\"$(comp.w1)\"")
    push!(parts, "W2=\"$(comp.w2)\"")
    push!(parts, "W3=\"$(comp.w3)\"")
    push!(parts, "Subst=\"$(comp.substrate)\"")
    push!(parts, "MSDispModel=\"$(comp.disp_model)\"")
    push!(parts, "MSModel=\"$(comp.model)\"")
    push!(parts, "Temp=\"$(comp.temp)\"")
    return join(parts, " ")
end

function _get_node_number(comp::MicrostripTee, pin::Symbol)
    if pin == :n1
        return comp.n1
    elseif pin == :n2
        return comp.n2
    elseif pin == :n3
        return comp.n3
    else
        error("Invalid pin $pin for MicrostripTee. Use :n1, :n2 or :n3")
    end
end

function _set_node_number!(comp::MicrostripTee, pin::Symbol, node::Int)
    if pin == :n1
        comp.n1 = node
    elseif pin == :n2
        comp.n2 = node
    elseif pin == :n3
        comp.n3 = node
    else
        error("Invalid pin $pin for MicrostripTee. Use :n1, :n2 or :n3")
    end
end

function get_pins(::MicrostripTee)
    return [:n1, :n2, :n3]
end