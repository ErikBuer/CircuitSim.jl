mutable struct JFET <: AbstractJFET
    name::String

    gate::Int
    drain::Int
    source::Int

    # Required properties
    Is::Real      # Gate junction saturation current
    N::Real       # Emission coefficient
    Vt0::Real     # Threshold voltage
    Lambda::Real  # Channel length modulation
    Beta::Real    # Transconductance parameter
    M::Real       # Grading coefficient
    Pb::Real      # Gate junction potential
    Fc::Real      # Forward bias junction capacitance coefficient
    Cgs::Real     # Zero-bias G-S junction capacitance
    Cgd::Real     # Zero-bias G-D junction capacitance

    # Optional properties
    Rd::Real      # Drain resistance
    Rs::Real      # Source resistance
    Isr::Real     # Recombination saturation current
    Nr::Real      # Recombination emission coefficient
    Kf::Real      # Flicker noise coefficient
    Af::Real      # Flicker noise exponent
    Ffe::Real     # Flicker noise frequency exponent
    Temp::Real    # Simulation temperature
    Type::String  # "nfet" or "pfet"
    Xti::Real     # Saturation current temperature exponent
    Vt0tc::Real   # Vt0 temperature coefficient
    Betatce::Real # Beta exponential temperature coefficient
    Tnom::Real    # Nominal temperature
    Area::Real    # Area scaling factor

    function JFET(name::String;
        Is::Real=1e-14,
        N::Real=1,
        Vt0::Real=-2,
        Lambda::Real=0,
        Beta::Real=1e-4,
        M::Real=0.5,
        Pb::Real=1.0,
        Fc::Real=0.5,
        Cgs::Real=0,
        Cgd::Real=0,
        Rd::Real=0,
        Rs::Real=0,
        Isr::Real=0,
        Nr::Real=2,
        Kf::Real=0,
        Af::Real=1,
        Ffe::Real=1,
        Temp::Real=26.85,
        Type::String="nfet",
        Xti::Real=3,
        Vt0tc::Real=0,
        Betatce::Real=0,
        Tnom::Real=26.85,
        Area::Real=1
    )
        Type in ["nfet", "pfet"] || throw(ArgumentError("Type must be 'nfet' or 'pfet'"))
        new(name, 0, 0, 0, Is, N, Vt0, Lambda, Beta, M, Pb, Fc, Cgs, Cgd,
            Rd, Rs, Isr, Nr, Kf, Af, Ffe, Temp, Type, Xti, Vt0tc, Betatce, Tnom, Area)
    end
end

get_nodes(j::JFET) = [j.gate, j.drain, j.source]
node_count(::Type{JFET}) = 3
get_name(j::JFET) = j.name

function connect!(j::JFET, gate::Int, drain::Int, source::Int)
    j.gate = gate
    j.drain = drain
    j.source = source
    return j
end

function to_qucs_netlist(j::JFET)::String
    parts = ["JFET:$(j.name)"]

    # Nodes (gate, drain, source)
    push!(parts, qucs_node(j.gate))
    push!(parts, qucs_node(j.drain))
    push!(parts, qucs_node(j.source))

    # Type
    push!(parts, "Type=\"$(j.Type)\"")

    # Required properties
    push!(parts, "Is=\"$(format_value(j.Is))\"")
    push!(parts, "N=\"$(j.N)\"")
    push!(parts, "Vt0=\"$(j.Vt0)\"")
    push!(parts, "Lambda=\"$(j.Lambda)\"")
    push!(parts, "Beta=\"$(format_value(j.Beta))\"")
    push!(parts, "M=\"$(j.M)\"")
    push!(parts, "Pb=\"$(j.Pb)\"")
    push!(parts, "Fc=\"$(j.Fc)\"")
    push!(parts, "Cgs=\"$(format_value(j.Cgs))\"")
    push!(parts, "Cgd=\"$(format_value(j.Cgd))\"")

    # Optional properties
    j.Rd != 0 && push!(parts, "Rd=\"$(format_value(j.Rd))\"")
    j.Rs != 0 && push!(parts, "Rs=\"$(format_value(j.Rs))\"")
    j.Isr != 0 && push!(parts, "Isr=\"$(format_value(j.Isr))\"")
    j.Nr != 2 && push!(parts, "Nr=\"$(j.Nr)\"")
    j.Kf != 0 && push!(parts, "Kf=\"$(format_value(j.Kf))\"")
    j.Af != 1 && push!(parts, "Af=\"$(j.Af)\"")
    j.Ffe != 1 && push!(parts, "Ffe=\"$(j.Ffe)\"")
    j.Temp != 26.85 && push!(parts, "Temp=\"$(j.Temp)\"")
    j.Xti != 3 && push!(parts, "Xti=\"$(j.Xti)\"")
    j.Vt0tc != 0 && push!(parts, "Vt0tc=\"$(j.Vt0tc)\"")
    j.Betatce != 0 && push!(parts, "Betatce=\"$(j.Betatce)\"")
    j.Tnom != 26.85 && push!(parts, "Tnom=\"$(j.Tnom)\"")
    j.Area != 1 && push!(parts, "Area=\"$(j.Area)\"")

    return join(parts, " ")
end
