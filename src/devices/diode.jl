mutable struct Diode <: AbstractDiode
    name::String
    cathode::Int  # Negative terminal, connects to lower potential
    anode::Int    # Positive terminal, connects to higher potential

    # Required properties
    Is::Real    # Saturation current
    N::Real     # Emission coefficient
    M::Real     # Grading coefficient
    Cj0::Real   # Zero-bias junction capacitance
    Vj::Real    # Junction potential

    # Optional properties with defaults
    Rs::Real    # Series resistance
    Isr::Real   # Recombination saturation current
    Nr::Real    # Recombination emission coefficient
    Bv::Real    # Breakdown voltage
    Ibv::Real   # Breakdown current
    Ikf::Real   # High-injection knee current
    Tt::Real    # Transit time
    Fc::Real    # Forward bias depletion capacitance coefficient
    Cp::Real    # Parallel capacitance
    Kf::Real    # Flicker noise coefficient
    Af::Real    # Flicker noise exponent
    Ffe::Real   # Flicker noise frequency exponent
    Temp::Real  # Simulation temperature
    Xti::Real   # Saturation current temperature exponent
    Eg::Real    # Energy gap
    Tbv::Real   # Breakdown voltage temperature coefficient
    Trs::Real   # Series resistance temperature coefficient
    Ttt1::Real  # Transit time temperature coefficient (linear)
    Ttt2::Real  # Transit time temperature coefficient (quadratic)
    Tm1::Real   # Grading coefficient temperature coefficient (linear)
    Tm2::Real   # Grading coefficient temperature coefficient (quadratic)
    Tnom::Real  # Nominal temperature
    Area::Real  # Area scaling factor

    function Diode(name::String;
        Is::Real=1e-15,
        N::Real=1,
        M::Real=0.5,
        Cj0::Real=10e-15,
        Vj::Real=0.7,
        Rs::Real=0,
        Isr::Real=0,
        Nr::Real=2,
        Bv::Real=0,
        Ibv::Real=1e-3,
        Ikf::Real=0,
        Tt::Real=0,
        Fc::Real=0.5,
        Cp::Real=0,
        Kf::Real=0,
        Af::Real=1,
        Ffe::Real=1,
        Temp::Real=26.85,
        Xti::Real=3,
        Eg::Real=1.11,  # EgSi
        Tbv::Real=0,
        Trs::Real=0,
        Ttt1::Real=0,
        Ttt2::Real=0,
        Tm1::Real=0,
        Tm2::Real=0,
        Tnom::Real=26.85,
        Area::Real=1)
        new(name, 0, 0, Is, N, M, Cj0, Vj, Rs, Isr, Nr, Bv, Ibv, Ikf, Tt, Fc, Cp,
            Kf, Af, Ffe, Temp, Xti, Eg, Tbv, Trs, Ttt1, Ttt2, Tm1, Tm2, Tnom, Area)
    end
end

const D = Diode

get_nodes(d::AbstractDiode) = [d.cathode, d.anode]
node_count(::Type{<:AbstractDiode}) = 2
get_name(d::AbstractDiode) = d.name

function connect!(d::AbstractDiode, cathode::Int, anode::Int)
    d.cathode = cathode
    d.anode = anode
    return d
end

function to_qucs_netlist(d::Diode)::String
    parts = ["Diode:$(d.name)"]

    # Nodes (cathode first, then anode)
    push!(parts, qucs_node(d.cathode))
    push!(parts, qucs_node(d.anode))

    # Required properties
    push!(parts, "Is=\"$(format_value(d.Is))\"")
    push!(parts, "N=\"$(d.N)\"")
    push!(parts, "M=\"$(d.M)\"")
    push!(parts, "Cj0=\"$(format_value(d.Cj0))\"")
    push!(parts, "Vj=\"$(d.Vj)\"")

    # Optional properties (include only if non-default)
    d.Rs != 0 && push!(parts, "Rs=\"$(format_value(d.Rs))\"")
    d.Isr != 0 && push!(parts, "Isr=\"$(format_value(d.Isr))\"")
    d.Nr != 2 && push!(parts, "Nr=\"$(d.Nr)\"")
    d.Bv != 0 && push!(parts, "Bv=\"$(d.Bv)\"")
    d.Ibv != 1e-3 && push!(parts, "Ibv=\"$(format_value(d.Ibv))\"")
    d.Ikf != 0 && push!(parts, "Ikf=\"$(format_value(d.Ikf))\"")
    d.Tt != 0 && push!(parts, "Tt=\"$(format_value(d.Tt))\"")
    d.Fc != 0.5 && push!(parts, "Fc=\"$(d.Fc)\"")
    d.Cp != 0 && push!(parts, "Cp=\"$(format_value(d.Cp))\"")
    d.Kf != 0 && push!(parts, "Kf=\"$(format_value(d.Kf))\"")
    d.Af != 1 && push!(parts, "Af=\"$(d.Af)\"")
    d.Ffe != 1 && push!(parts, "Ffe=\"$(d.Ffe)\"")
    d.Temp != 26.85 && push!(parts, "Temp=\"$(d.Temp)\"")
    d.Xti != 3 && push!(parts, "Xti=\"$(d.Xti)\"")
    d.Eg != 1.11 && push!(parts, "Eg=\"$(d.Eg)\"")
    d.Tbv != 0 && push!(parts, "Tbv=\"$(d.Tbv)\"")
    d.Trs != 0 && push!(parts, "Trs=\"$(d.Trs)\"")
    d.Ttt1 != 0 && push!(parts, "Ttt1=\"$(d.Ttt1)\"")
    d.Ttt2 != 0 && push!(parts, "Ttt2=\"$(d.Ttt2)\"")
    d.Tm1 != 0 && push!(parts, "Tm1=\"$(d.Tm1)\"")
    d.Tm2 != 0 && push!(parts, "Tm2=\"$(d.Tm2)\"")
    d.Tnom != 26.85 && push!(parts, "Tnom=\"$(d.Tnom)\"")
    d.Area != 1 && push!(parts, "Area=\"$(d.Area)\"")

    return join(parts, " ")
end
