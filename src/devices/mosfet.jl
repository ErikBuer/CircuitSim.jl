mutable struct MOSFET <: AbstractMOSFET
    name::String
    gate::Int
    drain::Int
    source::Int
    bulk::Int

    # Required properties
    Is::Real      # Bulk junction saturation current
    N::Real       # Emission coefficient
    Vt0::Real     # Zero-bias threshold voltage
    Lambda::Real  # Channel length modulation
    Kp::Real      # Transconductance parameter
    Gamma::Real   # Bulk threshold parameter
    Phi::Real     # Surface potential

    # Optional properties
    Theta::Real   # Mobility degradation
    Ld::Real      # Lateral diffusion
    W::Real       # Width
    L::Real       # Length
    Rd::Real      # Drain resistance
    Rs::Real      # Source resistance
    Rg::Real      # Gate resistance
    Rb::Real      # Bulk resistance
    Cbd::Real     # Bulk-drain capacitance
    Cbs::Real     # Bulk-source capacitance
    Cgb::Real     # Gate-bulk capacitance
    Cgd::Real     # Gate-drain capacitance
    Cgs::Real     # Gate-source capacitance
    Pb::Real      # Bulk junction potential
    Mj::Real      # Bulk grading coefficient
    Fc::Real      # Forward bias capacitance coefficient
    Isr::Real     # Recombination saturation current
    Js::Real      # Bulk junction saturation current density
    Ad::Real      # Drain area
    As::Real      # Source area
    Pd::Real      # Drain perimeter
    Ps::Real      # Source perimeter
    Temp::Real    # Simulation temperature
    Tnom::Real    # Nominal temperature
    Type::String  # "nfet" or "pfet"

    function MOSFET(name::String;
        Is::Real=1e-14,
        N::Real=1,
        Vt0::Real=0,
        Lambda::Real=0,
        Kp::Real=2e-5,
        Gamma::Real=0,
        Phi::Real=0.6,
        Theta::Real=0,
        Ld::Real=0,
        W::Real=1e-6,
        L::Real=1e-6,
        Rd::Real=0,
        Rs::Real=0,
        Rg::Real=0,
        Rb::Real=0,
        Cbd::Real=0,
        Cbs::Real=0,
        Cgb::Real=0,
        Cgd::Real=0,
        Cgs::Real=0,
        Pb::Real=0.8,
        Mj::Real=0.5,
        Fc::Real=0.5,
        Isr::Real=0,
        Js::Real=0,
        Ad::Real=0,
        As::Real=0,
        Pd::Real=0,
        Ps::Real=0,
        Temp::Real=26.85,
        Tnom::Real=26.85,
        Type::String="nfet")
        Type in ["nfet", "pfet"] || throw(ArgumentError("Type must be 'nfet' or 'pfet'"))
        new(name, 0, 0, 0, 0, Is, N, Vt0, Lambda, Kp, Gamma, Phi,
            Theta, Ld, W, L, Rd, Rs, Rg, Rb, Cbd, Cbs, Cgb, Cgd, Cgs,
            Pb, Mj, Fc, Isr, Js, Ad, As, Pd, Ps, Temp, Tnom, Type)
    end
end

get_nodes(m::MOSFET) = [m.gate, m.drain, m.source, m.bulk]
node_count(::Type{MOSFET}) = 4
get_name(m::MOSFET) = m.name

function connect!(m::MOSFET, gate::Int, drain::Int, source::Int, bulk::Int)
    m.gate = gate
    m.drain = drain
    m.source = source
    m.bulk = bulk
    return m
end

function to_qucs_netlist(m::MOSFET)::String
    parts = ["MOSFET:$(m.name)"]

    # Nodes (gate, drain, source, bulk)
    push!(parts, qucs_node(m.gate))
    push!(parts, qucs_node(m.drain))
    push!(parts, qucs_node(m.source))
    push!(parts, qucs_node(m.bulk))

    # Type
    push!(parts, "Type=\"$(m.Type)\"")

    # Required properties
    push!(parts, "Is=\"$(format_value(m.Is))\"")
    push!(parts, "N=\"$(m.N)\"")
    push!(parts, "Vt0=\"$(m.Vt0)\"")
    push!(parts, "Lambda=\"$(m.Lambda)\"")
    push!(parts, "Kp=\"$(format_value(m.Kp))\"")
    push!(parts, "Gamma=\"$(m.Gamma)\"")
    push!(parts, "Phi=\"$(m.Phi)\"")

    # Geometry (always include for MOSFET)
    push!(parts, "W=\"$(format_value(m.W))\"")
    push!(parts, "L=\"$(format_value(m.L))\"")

    # Optional properties
    m.Theta != 0 && push!(parts, "Theta=\"$(m.Theta)\"")
    m.Ld != 0 && push!(parts, "Ld=\"$(format_value(m.Ld))\"")
    m.Rd != 0 && push!(parts, "Rd=\"$(format_value(m.Rd))\"")
    m.Rs != 0 && push!(parts, "Rs=\"$(format_value(m.Rs))\"")
    m.Rg != 0 && push!(parts, "Rg=\"$(format_value(m.Rg))\"")
    m.Rb != 0 && push!(parts, "Rb=\"$(format_value(m.Rb))\"")
    m.Cbd != 0 && push!(parts, "Cbd=\"$(format_value(m.Cbd))\"")
    m.Cbs != 0 && push!(parts, "Cbs=\"$(format_value(m.Cbs))\"")
    m.Cgb != 0 && push!(parts, "Cgb=\"$(format_value(m.Cgb))\"")
    m.Cgd != 0 && push!(parts, "Cgd=\"$(format_value(m.Cgd))\"")
    m.Cgs != 0 && push!(parts, "Cgs=\"$(format_value(m.Cgs))\"")
    m.Pb != 0.8 && push!(parts, "Pb=\"$(m.Pb)\"")
    m.Mj != 0.5 && push!(parts, "Mj=\"$(m.Mj)\"")
    m.Fc != 0.5 && push!(parts, "Fc=\"$(m.Fc)\"")
    m.Isr != 0 && push!(parts, "Isr=\"$(format_value(m.Isr))\"")
    m.Js != 0 && push!(parts, "Js=\"$(format_value(m.Js))\"")
    m.Ad != 0 && push!(parts, "Ad=\"$(format_value(m.Ad))\"")
    m.As != 0 && push!(parts, "As=\"$(format_value(m.As))\"")
    m.Pd != 0 && push!(parts, "Pd=\"$(format_value(m.Pd))\"")
    m.Ps != 0 && push!(parts, "Ps=\"$(format_value(m.Ps))\"")
    m.Temp != 26.85 && push!(parts, "Temp=\"$(m.Temp)\"")
    m.Tnom != 26.85 && push!(parts, "Tnom=\"$(m.Tnom)\"")

    return join(parts, " ")
end
